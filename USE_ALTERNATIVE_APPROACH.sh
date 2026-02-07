#!/bin/bash
source .env

echo "=========================================="
echo "   ALTERNATIVE: Use setSubnodeRecord()"
echo "   (Bypasses PARENT_CANNOT_CONTROL)"
echo "=========================================="
echo ""

# ENS has setSubnodeRecord() on the Registry (not NameWrapper)
# This might work if the Registry owner is still our address

REGISTRY="0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"
PARENT_NODE="0xc169c678e259ddaa848f328d412546f7148c1b92d04e0e09690e7fa63a9fb051"

echo "Checking Registry owner of parent..."
REGISTRY_OWNER=$(cast call "$REGISTRY" "owner(bytes32)" "$PARENT_NODE" --rpc-url sepolia)
echo "Registry owner: $REGISTRY_OWNER"

NAME_WRAPPER="0x0635513f179D50A207757E05759CbD106d7dFcE8"
echo "NameWrapper address: $NAME_WRAPPER"

NORMALIZED_WRAPPER=$(echo "$NAME_WRAPPER" | tr '[:upper:]' '[:lower:]')
REGISTRY_OWNER_NORM=$(echo "$REGISTRY_OWNER" | grep -oE '0x[a-f0-9]{40}' | tr '[:upper:]' '[:lower:]')

echo ""
if [[ "$REGISTRY_OWNER_NORM" == "$NORMALIZED_WRAPPER" ]]; then
    echo "❌ Registry owner is NameWrapper - can't bypass fuse restrictions"
    echo ""
    echo "The parent is fully wrapped, so we MUST either:"
    echo "  A) Unwrap it successfully (hasn't worked so far)"
    echo "  B) Use a different parent domain"
    echo "  C) Transfer ownership to LicenseManager contract"
    echo ""
    echo "RECOMMENDED: Use a fresh parent domain"
    echo "Run: ./QUICKEST_SOLUTION.sh"
else
    echo "✅ Registry owner is different - might be able to bypass!"
    echo "This is unusual but let's try..."
    # This would be rare for a wrapped name
fi

echo ""
echo "=========================================="
