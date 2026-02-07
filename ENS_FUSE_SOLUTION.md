# ENS Parent Fuse Issue - Solution Summary

## Problem
The parent domain `myhedgefund-v2.eth` has the `PARENT_CANNOT_CONTROL` fuse set (fuses = 0x30000).  
This fuse **permanently** prevents certain subdomain creation operations until the name expires or is completely unwrapped.

## What We've Tried
1. ✗ Direct license issuance → OperationProhibited error
2. ✗ Unwrapping with `unwrap()` → Fuses unchanged
3. ✗ Unwrapping with `unwrapETH2LD()` → Fuses unchanged  
4. ✗ Transferring ownership to LicenseManager → Transaction reverted
5. ✗ Using `setFuses()` to change fuses → Can only ADD fuses, not remove them
6. ✗ Creating intermediate subdomain → Pending/unclear if successful

## Root Cause
ENS NameWrapper fuses are **immutable** once set. The `PARENT_CANNOT_CONTROL` fuse:
- Prevents approved operators from creating subdomains
- May prevent even the owner from certain operations
- Cannot be removed except by:
  - Unwrapping the name (which is failing)
  - Waiting for expiry (2027+)

## RECOMMENDED SOLUTION

### Option A: Use a Fresh Parent Domain (FASTEST)
**This is the cleanest solution for production.**

1. Register a new .eth name without fuse restrictions:
   ```bash
   # Visit https://app.ens.domains/ on Sepolia testnet
   # Register something like: hedgefund-licenses.eth
   # OR use an existing domain you control
   ```

2. Wrap it with minimal fuses (CANNOT_UNWRAP only):
   ```bash
   cast send 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
     "wrapETH2LD(string,address,uint16,address)" \
     "hedgefund-licenses" \
     "$OWNER_ADDRESS" \
     "1" \
     "$OWNER_ADDRESS" \
     --rpc-url sepolia --private-key $OWNER_PRIVATE_KEY
   ```

3. Update `.env` with new parent node:
   ```bash
   NEW_PARENT_NODE=$(cast namehash "hedgefund-licenses.eth")
   echo "PARENT_NODE=$NEW_PARENT_NODE" >> .env
   ```

4. Update and redeploy LicenseManager:
   ```solidity
   // In src/LicenseManager.sol constructor
   PARENT_NODE = 0x... // new parent node
   ```

5. Redeploy:
   ```bash
   forge script script/Deploy.s.sol --rpc-url sepolia --broadcast
   ```

6. Issue licenses:
   ```bash
   ./FINAL_ISSUE_LICENSE.sh
   ```

   Licenses will be issued as:
   - `trader001.hedgefund-licenses.eth`
   - `trader002.hedgefund-licenses.eth`

### Option B: Use Intermediate Subdomain (WORKAROUND)
**Try this if you can't register a new domain.**

The idea: Since we own `myhedgefund-v2.eth`, we *might* be able to create a subdomain like `licenses.myhedgefund-v2.eth` and use THAT as the parent.

```bash
./CREATE_SUBDOMAIN_PARENT.sh
```

If successful, licenses become:
- `trader001.licenses.myhedgefund-v2.eth`

**Status**: Attempted but subdomain creation appears to have failed or is pending.

### Option C: Fork ENS Locally (DEVELOPMENT ONLY)
For local testing, deploy a fresh ENS system without fuse restrictions.

**Not recommended for Sepolia/production.**

## Current Status

- ✅ Phase 1-3: Contracts fixed and deployed
- ✅ Phase 5: Verification scripts created
- ✅ Phase 6: Frontend ENS integration complete
- ❌ Phase 4: License issuance **BLOCKED** by parent fuse issue

## Next Steps

**IMMEDIATE ACTION REQUIRED:**

Choose Option A or B above. **Option A is strongly recommended** for a production-ready solution.

Once resolved:
1. Issue first license (trader001)
2. Run `./VERIFY_LICENSE.sh`
3. Test frontend with MetaMask
4. Document success

## Technical Details

### Fuse Breakdown
```
0x30000 = 0b110000000000000000
- Bit 0 (CANNOT_UNWRAP): NOT set ← Should allow unwrap (but doesn't work)
- Bit 16 (PARENT_CANNOT_CONTROL): SET ← BLOCKS operations
- Bit 17 (CAN_EXTEND_EXPIRY): SET
```

### Failed Transaction Examples
- Nonce 182-190: Various unwrap/transfer attempts
- All reverted with "OperationProhibited" or "execution reverted"

### Contract Addresses
- LicenseManager: `0x4923Dca912171FD754c33e3Eab9fAB859259A02D`
- NameWrapper: `0x0635513f179D50A207757E05759CbD106d7dFcE8`
- Current Parent: `myhedgefund-v2.eth`  
  Node: `0xc169c678e259ddaa848f328d412546f7148c1b92d04e0e09690e7fa63a9fb051`

## Conclusion

The ENS fuse system is working as designed - fuses are permanent restrictions. **The only viable solution is to use a different parent domain** that doesn't have `PARENT_CANNOT_CONTROL` set.

Estimate: **30-60 minutes** to register new domain, redeploy, and complete Phase 4-6.
