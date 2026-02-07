#!/bin/bash
source .env

echo "======================================"
echo "   FIX PARENT FUSES"
echo "======================================"
echo ""

PARENT_NODE="0xc169c678e259ddaa848f328d412546f7148c1b92d04e0e09690e7fa63a9fb051"
NAME_WRAPPER="0x0635513f179D50A207757E05759CbD106d7dFcE8"

echo "Problem: Parent has PARENT_CANNOT_CONTROL fuse set"
echo "This prevents creating subdomains via setSubnodeOwner()"
echo ""

echo "Step 1: Unwrap myhedgefund-v2.eth to reset fuses..."
cast send "$NAME_WRAPPER" \
  "unwrap(bytes32,bytes32,address)" \
  "0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae" \
  "0x6d0c659cd3d7088f887af2ce83ca5b4ce7f08c11f0aa72a5bcda7ba4cb8adb19" \
  "$OWNER_ADDRESS" \
  --rpc-url sepolia \
  --private-key $OWNER_PRIVATE_KEY \
  --gas-limit 200000

echo ""
echo "Step 2: Wrap again with CANNOT_UNWRAP only (allows subdomain creation)..."
cast send "$NAME_WRAPPER" \
  "wrapETH2LD(string,address,uint16,address)" \
  "myhedgefund-v2" \
  "$OWNER_ADDRESS" \
  "1" \
  "$OWNER_ADDRESS" \
  --rpc-url sepolia \
  --private-key $OWNER_PRIVATE_KEY \
  --gas-limit 300000

echo ""
echo "Step 3: Verify new fuses..."
cast call "$NAME_WRAPPER" "getData(uint256)" "$PARENT_NODE" --rpc-url sepolia

echo ""
echo "======================================"
echo "✅ Parent should now allow subdomain creation!"
echo "======================================"
