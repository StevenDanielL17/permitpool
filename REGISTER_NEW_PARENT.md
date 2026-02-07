# Register New Parent Domain Solution

## Problem
Current parent `myhedgefund-v2.eth` has PARENT_CANNOT_CONTROL fuse (0x30000) permanently set, blocking ALL subdomain creation.

## Solution: Register New Domain

### Step 1: Register Domain on Sepolia
1. Visit [Sepolia ENS App](https://app.ens.domains)
2. Connect wallet (0x52b34414Df3e56ae853BC4A0EB653231447C2A36)
3. Register domain (suggestions):
   - `hedgefund2026.eth`
   - `myhf-licenses.eth`
   - `defi-trader-v3.eth`
4. Complete registration (usually ~5 minutes)

### Step 2: Wrap Domain with Correct Fuses
```bash
# After registration, wrap the domain with ONLY minimal fuses
DOMAIN_NAME="hedgefund2026"  # Change to your registered name

# Wrap with fuse value 1 (CANNOT_UNWRAP only - allows subdomain creation)
cast send 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
  "wrapETH2LD(string,address,uint16,address)" \
  "$DOMAIN_NAME" \
  "$OWNER_ADDRESS" \
  1 \
  "$OWNER_ADDRESS" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY
```

### Step 3: Update Configuration
```bash
# Compute new parent node
PARENT_NODE=$(cast call 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e \
  "namehash(bytes32,bytes32)" \
  $(cast keccak "eth") \
  $(cast keccak "$DOMAIN_NAME") \
  --rpc-url $SEPOLIA_RPC_URL)

echo "PARENT_NODE=$PARENT_NODE"

# Update .env file
sed -i "s/PARENT_NODE=.*/PARENT_NODE=$PARENT_NODE/" .env
sed -i "s/PARENT_NAME=.*/PARENT_NAME=${DOMAIN_NAME}.eth/" .env
```

### Step 4: Redeploy LicenseManager
```bash
# Deploy with new parent domain
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url sepolia \
  --broadcast

# Extract new address and update .env
# (Or manually update LICENSE_MANAGER variable)
```

### Step 5: Test License Issuance
```bash
# Source updated .env
source .env

# Issue test license
cast send $LICENSE_MANAGER \
  "issueLicense(address,string,string)" \
  "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0" \
  "test-license-001" \
  "arc:test:verification-credential" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY

# Verify subdomain created
cast call 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e \
  "owner(bytes32)" \
  $(cast keccak "$(cast keccak "${DOMAIN_NAME}")$(cast keccak "test-license-001")") \
  --rpc-url $SEPOLIA_RPC_URL
```

### Step 6: Run Full Test Suite
```bash
# Execute all phases
./PHASE_8_MULTI_LICENSE.sh    # Batch license issuance
./PHASE_7_TEST_HOOK.sh        # Hook integration tests
./TEST_COMPLETE_FLOW.sh       # E2E verification
```

## Why This Works
- Fresh domain has NO restrictive fuses
- Wrapping with value `1` (CANNOT_UNWRAP only) preserves parent control
- Parent can freely create subdomains for licenses
- All existing contracts and frontend code work unchanged

## Time Estimate
- Domain registration: 5-10 minutes
- Configuration update: 2 minutes
- Redeployment: 3 minutes
- Testing: 5 minutes
**Total: ~20-25 minutes**

## Alternative: Use Existing Domain Without Fuses
If you have another domain already registered on Sepolia without PARENT_CANNOT_CONTROL, you can skip Step 1 and start from Step 2.
