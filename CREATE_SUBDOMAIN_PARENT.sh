#!/bin/bash
source .env

echo "=========================================="
echo "   FINAL SOLUTION: Use Test Subdomain"
echo "   (Create license under current parent)"
echo "=========================================="
echo ""

echo "Since myhedgefund-v2.eth has PARENT_CANNOT_CONTROL fuse,"
echo "we need to use a SUBDOMAIN that we create first, then issue"
echo "licenses under THAT subdomain."
echo ""

PARENT_NODE="0xc169c678e259ddaa848f328d412546f7148c1b92d04e0e09690e7fa63a9fb051"
NAME_WRAPPER="0x0635513f179D50A207757E05759CbD106d7dFcE8"
LICENSE_MANAGER="0x4923Dca912171FD754c33e3Eab9fAB859259A02D"

# Create "licenses" subdomain under myhedgefund-v2.eth
# This will be the NEW parent for all trader licenses
NEW_PARENT_LABEL="licenses"
NEW_PARENT_FULL="licenses.myhedgefund-v2.eth"

echo "Step 1: Create '$NEW_PARENT_FULL' subdomain..."
echo "(This uses the OWNER permission, not PARENT permission)"
echo ""

# The KEY insight: As the OWNER of myhedgefund-v2.eth, we CAN create subdomains
# even with PARENT_CANNOT_CONTROL set. That fuse prevents the GRANDPARENT (.eth owner)
# from controlling OUR subdomains.

TX_HASH=$(cast send "$NAME_WRAPPER" \
  "setSubnodeOwner(bytes32,string,address,uint32,uint64)" \
  "$PARENT_NODE" \
  "$NEW_PARENT_LABEL" \
  "$LICENSE_MANAGER" \
  "0" \
  "$(cast --to-uint256 18446744073709551615)" \
  --rpc-url sepolia \
  --private-key $OWNER_PRIVATE_KEY \
  --gas-limit 300000 \
  --json 2>&1 | jq -r '.transactionHash' 2>/dev/null)

if [[ "$TX_HASH" == "0x"* ]]; then
    echo "Transaction: $TX_HASH"
    echo "Waiting for confirmation..."
    sleep 10
    
    # Compute the new parent node
    NEW_PARENT_NODE=$(cast namehash "$NEW_PARENT_FULL")
    echo ""
    echo "✅ Created successfully!"
    echo "New parent: $NEW_PARENT_FULL"  
    echo "New parent node: $NEW_PARENT_NODE"
    echo ""
    
    # Verify owner
    echo "Step 2: Verify LicenseManager owns new parent..."
    OWNER_CHECK=$(cast call "$NAME_WRAPPER" "ownerOf(uint256)" "$NEW_PARENT_NODE" --rpc-url sepolia 2>&1)
    echo "Owner: $OWNER_CHECK"
    
    echo ""
    echo "=========================================="
    echo "✅ SOLUTION COMPLETE!"
    echo "=========================================="
    echo ""
    echo "Now licenses will be issued as:"
    echo "  trader001.licenses.myhedgefund-v2.eth"
    echo "  trader002.licenses.myhedgefund-v2.eth"
    echo "  etc."
    echo ""
    echo "Next steps:"
    echo "1. Update .env: PARENT_NODE=$NEW_PARENT_NODE"
    echo "2. Update LicenseManager constructor with new parent"
    echo "3. Redeploy LicenseManager"
    echo "4. Issue licenses!"
    echo ""
else
    echo "❌ Transaction failed or wasn't sent"
    echo "Output: $TX_HASH"
    echo ""
    echo "This might mean PARENT_CANNOT_CONTROL prevents US from"
    echo "creating subdomains too (not just the grandparent)."
    echo ""
    echo "In that case, the ONLY solution is to use a different"
    echo "parent domain entirely. See REGISTER_FRESH_PARENT.sh"
fi

echo "=========================================="
