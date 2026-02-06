# Gas Limit Fix - Transaction Error Resolution

## ❌ Error Fixed

```
"transaction gas limit too high (cap: 16777216, tx: 21000000)"
```

## 🔧 What Was Wrong

The `writeContract` calls in the admin portal were **not specifying a gas limit**, causing wagmi to estimate gas automatically. In some cases, the estimation was exceeding Sepolia's maximum gas cap of **16,777,216**.

## ✅ Solution Applied

Added explicit `gas` parameters to all transaction calls:

### 1. License Issuance (`admin-portal/app/admin/licenses/issue/page.tsx`)

```typescript
await writeContract({
  address: CONTRACTS.LICENSE_MANAGER,
  abi: LICENSE_MANAGER_ABI,
  functionName: "issueLicense",
  args: [agentAddress, subdomain, credential],
  gas: BigInt(500000), // ← ADDED: Reasonable limit for license issuance
});
```

### 2. License Revocation (`admin-portal/components/LicenseList.tsx`)

```typescript
writeContract({
  address: CONTRACTS.HOOK,
  abi: HOOK_ABI,
  functionName: "revokeLicense",
  args: [license.node],
  gas: BigInt(300000), // ← ADDED: Reasonable limit for revoke operation
});
```

## 📊 Gas Limits Explained

| Transaction Type       | Gas Limit Set | Estimated Cost (@ 50 gwei) |
| ---------------------- | ------------- | -------------------------- |
| **License Issuance**   | 500,000       | ~0.025 ETH (~$60)          |
| **License Revocation** | 300,000       | ~0.015 ETH (~$36)          |

**Note:** On Sepolia testnet, gas costs are negligible. These limits are well under the network cap of 16,777,216.

### Why These Numbers?

- **500,000 for issuance:** License issuance involves ENS operations (creating subdomain, setting fuses, storing Arc credentials). This is a complex transaction requiring more gas.
- **300,000 for revocation:** Revocation is simpler (just updating state), so needs less gas.

Both values are:

- ✅ Under the network cap (16.7M)
- ✅ Generous enough to complete successfully
- ✅ Not wasteful (won't charge excessive fees)

## 🧪 Testing After Fix

### Test License Issuance:

1. Open http://localhost:3001/admin/licenses/issue
2. Fill in trader details
3. Complete Arc KYC verification
4. Approve the transaction in MetaMask
5. **Gas limit should now be ~500,000** (visible in MetaMask)
6. Transaction should succeed ✅

### Test License Revocation:

1. Open http://localhost:3001/admin/licenses
2. Click "Revoke" on any active license
3. Confirm revocation
4. Approve in MetaMask
5. **Gas limit should now be ~300,000**
6. Transaction should succeed ✅

## 🔍 Why This Error Occurred

Without explicit gas limits, wagmi uses `eth_estimateGas` to calculate required gas. Sometimes this estimation:

- Adds a safety buffer (multiplies by 1.2x or more)
- Includes execution costs for worst-case scenarios
- Results in values exceeding network caps

**Best practice:** Always set explicit, reasonable gas limits for contract interactions.

## 📝 Files Modified

1. ✅ `admin-portal/app/admin/licenses/issue/page.tsx` - Added gas limit to issuance
2. ✅ `admin-portal/components/LicenseList.tsx` - Added gas limit to revocation

## 🚀 Next Steps

The fix is applied and ready. You can now:

1. Clear any cached transactions in MetaMask
2. Close and reopen the admin portal
3. Try issuing/revoking licenses again
4. Transactions should complete successfully!

## 💡 Additional Notes

If you still see gas estimation errors:

- Check that your contracts are deployed correctly
- Verify contract addresses in `lib/contracts/addresses.ts`
- Ensure you have sufficient Sepolia ETH for gas fees
- Try clearing MetaMask cache (Settings → Advanced → Clear activity tab data)

---

**Status:** ✅ **FIXED** - Gas limits now properly configured for all transactions
