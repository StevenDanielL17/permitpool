#!/bin/bash
source .env

echo "=========================================="
echo "   REGISTER FRESH PARENT DOMAIN"
echo "   (With correct fuse configuration)"
echo "=========================================="
echo ""

# Check available names
NEW_PARENT_NAME="hedgefund-licenses"
echo "Checking if '$NEW_PARENT_NAME.eth' is available..."

REGISTRAR="0xFED6a969AaA60E4961FCD3EBF1A2e8913ac65B72"  # BaseRegistrar on Sepolia
NAME_WRAPPER="0x0635513f179D50A207757E05759CbD106d7dFcE8"

# Compute label hash for the new name
LABEL_HASH=$(cast keccak "$NEW_PARENT_NAME")
echo "Label hash: $LABEL_HASH"

# Check if available on registrar
OWNER=$(cast call "$REGISTRAR" "ownerOf(uint256)" "$LABEL_HASH" --rpc-url sepolia 2>&1)

if [[ "$OWNER" == *"ERC721: invalid token ID"* ]] || [[ "$OWNER" == *"0x0000000000000000000000000000000000000000"* ]]; then
    echo "✅ Name is available for registration!"
    echo ""
    echo "⚠️  NOTE: This requires registering a new .eth name on Sepolia"
    echo "⚠️  You'll need Sepolia ETH and may need to use the ENS app"
    echo ""
    echo "Alternative: Reuse an existing domain you control"
    echo ""
    echo "To register via ENS app:"
    echo "1. Visit https://app.ens.domains/ (switch to Sepolia)"
    echo "2. Search for '$NEW_PARENT_NAME.eth'"
    echo "3. Register it for minimum 1 year"
    echo "4. After registration, run WRAP_NEW_PARENT.sh"
    exit 0
else
    echo "Name is already registered or checking failed"
    echo "Owner result: $OWNER"
    echo ""
    echo "Checking if YOU own it..."
    NORMALIZED_OWNER=$(echo "$OWNER" | tr '[:upper:]' '[:lower:]' | grep -oE '0x[a-f0-9]{40}')
    NORMALIZED_MY_ADDR=$(echo "$OWNER_ADDRESS" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$NORMALIZED_OWNER" == "$NORMALIZED_MY_ADDR" ]]; then
        echo "✅ YOU own this name! Proceeding to wrap it..."
        
        # Wrap the name with CANNOT_UNWRAP only (fuse = 1)
        echo ""
        echo "Wrapping $NEW_PARENT_NAME.eth with correct fuses..."
        
        TX_HASH=$(cast send "$NAME_WRAPPER" \
          "wrapETH2LD(string,address,uint16,address)" \
          "$NEW_PARENT_NAME" \
          "$OWNER_ADDRESS" \
          "1" \
          "$OWNER_ADDRESS" \
          --rpc-url sepolia \
          --private-key $OWNER_PRIVATE_KEY \
          --gas-limit 300000 \
          --json | jq -r '.transactionHash')
        
        echo "Wrap TX: $TX_HASH"
        echo "Waiting for confirmation..."
        cast receipt "$TX_HASH" --rpc-url sepolia --confirmations 2 > /dev/null
        
        # Compute parent node
        PARENT_NODE=$(cast namehash "$NEW_PARENT_NAME.eth")
        echo ""
        echo "✅ Wrapped successfully!"
        echo "Parent node: $PARENT_NODE"
        
        # Verify fuses
        echo ""
        echo "Verifying fuses..."
        FUSES=$(cast call "$NAME_WRAPPER" "getData(uint256)(address,uint32,uint64)" "$PARENT_NODE" --rpc-url sepolia | head -2 | tail -1)
        echo "Fuses: $FUSES"
        
        python3 -c "
fuses = int('$FUSES', 10) if '$FUSES'.isdigit() else int('$FUSES', 16)
print(f'Fuses value: {hex(fuses)}')
print(f'CANNOT_UNWRAP: {bool(fuses & 0x1)}')
print(f'PARENT_CANNOT_CONTROL: {bool(fuses & 0x10000)}')
if not (fuses & 0x10000):
    print('✅ Perfect! Parent CAN create subdomains')
else:
    print('❌ ERROR: PARENT_CANNOT_CONTROL is still set')
"
        
        echo ""
        echo "=========================================="
        echo "Next steps:"
        echo "1. Update .env with: PARENT_NODE=$PARENT_NODE"
        echo "2. Run: ./DEPLOY_NEW_LICENSE_MANAGER.sh"
        echo "=========================================="
        
    else
        echo "❌ Name is owned by: $NORMALIZED_OWNER"
        echo "❌ Your address: $NORMALIZED_MY_ADDR"
        echo ""
        echo "Try a different name or register a new one"
    fi
fi
