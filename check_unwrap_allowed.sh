#!/bin/bash
source .env

# Check if name can be unwrapped
echo "Checking if myhedgefund-v2.eth can be unwrapped..."
echo ""

PARENT_NODE="0xc169c678e259ddaa848f328d412546f7148c1b92d04e0e09690e7fa63a9fb051"
NAME_WRAPPER="0x0635513f179D50A207757E05759CbD106d7dFcE8"

# Get fuses
DATA=$(cast call "$NAME_WRAPPER" "getData(uint256)(address,uint32,uint64)" "$PARENT_NODE" --rpc-url sepolia)
echo "Data: $DATA"

# Try calling unwrapETH2LD as static call to see if it would revert
echo ""
echo "Testing unwrapETH2LD staticcall..."
cast call "$NAME_WRAPPER" \
  "unwrapETH2LD(bytes32,address,address)" \
  "0x6d0c659cd3d7088f887af2ce83ca5b4ce7f08c11f0aa72a5bcda7ba4cb8adb19" \
  "$OWNER_ADDRESS" \
  "$OWNER_ADDRESS" \
  --rpc-url sepolia \
  --from $OWNER_ADDRESS
  
echo ""
echo "Exit code: $?"
