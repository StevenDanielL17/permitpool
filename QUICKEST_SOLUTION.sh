#!/bin/bash
source .env

echo "=========================================="
echo "   QUICKEST SOLUTION"
echo "   Transfer Parent to LicenseManager"
echo "=========================================="
echo ""

LICENSE_MANAGER="0x4923Dca912171FD754c33e3Eab9fAB859259A02D"
NAME_WRAPPER="0x0635513f179D50A207757E05759CbD106d7dFcE8"
PARENT_NODE="0xc169c678e259ddaa848f328d412546f7148c1b92d04e0e09690e7fa63a9fb051"

echo "Strategy: Transfer myhedgefund-v2.eth ownership to LicenseManager"
echo "This gives the contract direct control to create subdomains"
echo ""

echo "Step 1: Verify current owner..."
CURRENT_OWNER=$(cast call "$NAME_WRAPPER" "ownerOf(uint256)" "$PARENT_NODE" --rpc-url sepolia)
echo "Current owner (raw): $CURRENT_OWNER"
# Extract address from padded hex (last 40 chars)
CURRENT_OWNER_ADDR="0x${CURRENT_OWNER: -40}"
echo "Current owner: $CURRENT_OWNER_ADDR"
echo "Your address: $OWNER_ADDRESS"

if [[ "$(echo $CURRENT_OWNER_ADDR | tr '[:upper:]' '[:lower:]')" != "$(echo $OWNER_ADDRESS | tr '[:upper:]' '[:lower:]')" ]]; then
    echo "❌ You don't own the parent - cannot transfer"
    echo "Owner: $(echo $CURRENT_OWNER_ADDR | tr '[:upper:]' '[:lower:]')"
    echo "You: $(echo $OWNER_ADDRESS | tr '[:upper:]' '[:lower:]')"
    exit 1
fi

echo ""
echo "Step 2: Transfer to LicenseManager..."
echo "safeTransferFrom($OWNER_ADDRESS, $LICENSE_MANAGER, $PARENT_NODE)"

TX_HASH=$(cast send "$NAME_WRAPPER" \
  "safeTransferFrom(address,address,uint256)" \
  "$OWNER_ADDRESS" \
  "$LICENSE_MANAGER" \
  "$PARENT_NODE" \
  --rpc-url sepolia \
  --private-key $OWNER_PRIVATE_KEY \
  --gas-limit 200000 \
  --json | jq -r '.transactionHash')

echo "Transfer TX: $TX_HASH"
echo "Waiting for confirmation..."
cast receipt "$TX_HASH" --rpc-url sepolia --confirmations 2 > /dev/null || {
    echo "❌ Transaction failed!"
    cast receipt "$TX_HASH" --rpc-url sepolia
    exit 1
}

echo "✅ Transfer confirmed!"
echo ""

echo "Step 3: Verify new owner..."
NEW_OWNER_RAW=$(cast call "$NAME_WRAPPER" "ownerOf(uint256)" "$PARENT_NODE" --rpc-url sepolia)
NEW_OWNER="0x${NEW_OWNER_RAW: -40}"
echo "New owner: $NEW_OWNER"
echo "Expected (LicenseManager): $LICENSE_MANAGER"

if [[ "$(echo $NEW_OWNER | tr '[:upper:]' '[:lower:]')" == "$(echo $LICENSE_MANAGER | tr '[:upper:]' '[:lower:]')" ]]; then
    echo "✅ SUCCESS! LicenseManager now owns the parent"
    echo ""
    echo "⚠️  IMPORTANT: LicenseManager must now call setSubnodeOwner as the owner"
    echo "The fuse restrictions still apply, but now the contract can check:"
    echo "  if (msg.sender == ownerOf(PARENT_NODE))"
    echo ""
    echo "Step 4: Testing license issuance..."
    echo ""
    
    # Try to issue a license now
    echo "Attempting to issue trader001 license..."
    ./FINAL_ISSUE_LICENSE.sh
    
else
    echo "❌ Transfer didn't work as expected"
    echo "Actual owner: $NEW_OWNER"
fi

echo ""
echo "=========================================="
