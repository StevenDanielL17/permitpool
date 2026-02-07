#!/bin/bash
source .env

echo "======================================"
echo "   FIX PARENT FUSES V2 (Corrected)"
echo "======================================"
echo ""

PARENT_NODE="0xc169c678e259ddaa848f328d412546f7148c1b92d04e0e09690e7fa63a9fb051"
NAME_WRAPPER="0x0635513f179D50A207757E05759CbD106d7dFcE8"
LABEL_HASH="0x6d0c659cd3d7088f887af2ce83ca5b4ce7f08c11f0aa72a5bcda7ba4cb8adb19"

echo "Problem: Parent has PARENT_CANNOT_CONTROL fuse (0x30000)"
echo "Current fuses prevent subdomain creation"
echo ""

echo "Step 1: Check current fuses..."
echo -n "Current: "
cast call "$NAME_WRAPPER" "getData(uint256)" "$PARENT_NODE" --rpc-url sepolia | awk '{print $2}'

echo ""
echo "Step 2: unwrapETH2LD() myhedgefund-v2.eth to reset fuses..."
echo "(Using correct function for .eth 2LD names)"

TX_HASH=$(cast send "$NAME_WRAPPER" \
  "unwrapETH2LD(bytes32,address,address)" \
  "$LABEL_HASH" \
  "$OWNER_ADDRESS" \
  "$OWNER_ADDRESS" \
  --rpc-url sepolia \
  --private-key $OWNER_PRIVATE_KEY \
  --gas-limit 200000 \
  --json | jq -r '.transactionHash')

echo "Unwrap TX: $TX_HASH"
echo "Waiting for confirmation..."
cast receipt "$TX_HASH" --rpc-url sepolia --confirmations 1 > /dev/null 2>&1
echo "✅ Unwrap confirmed"

echo ""
echo "Step 3: Wrap again with CANNOT_UNWRAP only (fuse=1)..."

TX_HASH2=$(cast send "$NAME_WRAPPER" \
  "wrapETH2LD(string,address,uint16,address)" \
  "myhedgefund-v2" \
  "$OWNER_ADDRESS" \
  "1" \
  "$OWNER_ADDRESS" \
  --rpc-url sepolia \
  --private-key $OWNER_PRIVATE_KEY \
  --gas-limit 300000 \
  --json | jq -r '.transactionHash')

echo "Wrap TX: $TX_HASH2"
echo "Waiting for confirmation..."
cast receipt "$TX_HASH2" --rpc-url sepolia --confirmations 1 > /dev/null 2>&1
echo "✅ Wrap confirmed"

echo ""
echo "Step 4: Verify new fuses..."
echo -n "New fuses: "
NEW_FUSES=$(cast call "$NAME_WRAPPER" "getData(uint256)" "$PARENT_NODE" --rpc-url sepolia | awk '{print $2}')
echo "$NEW_FUSES"

# Decode the fuses
python3 - <<EOF
fuses = int('$NEW_FUSES', 16)
print(f"\nDecoded fuses: {hex(fuses)}")
print(f"  CANNOT_UNWRAP: {bool(fuses & 0x1)}")
print(f"  PARENT_CANNOT_CONTROL: {bool(fuses & 0x10000)}")
print(f"  CAN_EXTEND_EXPIRY: {bool(fuses & 0x20000)}")

if not (fuses & 0x10000):
    print("\n✅ SUCCESS: PARENT_CANNOT_CONTROL cleared!")
    print("✅ Parent can now create subdomains")
else:
    print("\n❌ FAILED: PARENT_CANNOT_CONTROL still set")
EOF

echo ""
echo "======================================"
