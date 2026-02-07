#!/bin/bash
# Deploy the FIXED LicenseManager with correct expiry handling

set -e  # Exit on error

cd /home/stevendaniell/BackUp/Dan/dansprojects/Eth-Online
source .env

echo "============================================"
echo "   DEPLOYING FIXED LICENSE MANAGER"
echo "============================================"
echo ""
echo "Fix: Changed type(uint64).max to parentExpiry"
echo "     to comply with ENS NameWrapper rules"
echo ""

# Force rebuild
echo "Step 1: Recompiling contracts..."
forge clean
forge build --force

echo ""
echo "Step 2: Deploying new LicenseManager..."
forge script script/QuickDeployLicense.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --broadcast \
  --legacy

echo ""
echo "Step 3: Extracting new contract address..."
NEW_LICENSE_MANAGER=$(cat broadcast/QuickDeployLicense.s.sol/11155111/run-latest.json | grep -o '"contractAddress":"0x[^"]*"' | head -1 | cut -d'"' -f4)

echo "✅ New LicenseManager: $NEW_LICENSE_MANAGER"
echo ""

echo "Step 4: Testing license issuance..."
echo "Issuing license for: david.myhedgefund.eth"
cast send $NEW_LICENSE_MANAGER \
  "issueLicense(address,string,string)" \
  "0x1234567890123456789012345678901234567890" \
  "david" \
  "did:arc:test-david-$(date +%s)" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY \
  --legacy

echo ""
echo "Step 5: Verifying subdomain creation..."
DAVID_NODE=$(cast namehash david.myhedgefund.eth)
echo "david.myhedgefund.eth node: $DAVID_NODE"

sleep 5  # Wait for block confirmation

cast call 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
  "getData(uint256)(address,uint32,uint64)" \
  $DAVID_NODE \
  --rpc-url $SEPOLIA_RPC_URL

echo ""
echo "============================================"
echo "   UPDATE FRONTEND"
echo "============================================"
echo "Edit admin-portal/.env.local:"
echo "NEXT_PUBLIC_LICENSE_MANAGER_ADDRESS=$NEW_LICENSE_MANAGER"
echo ""
echo "Then restart: npm run dev:admin"
echo "============================================"
