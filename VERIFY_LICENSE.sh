#!/bin/bash
source .env

echo "======================================"
echo "   LICENSE VERIFICATION SCRIPT"
echo "======================================"
echo ""

SUBDOMAIN="employee004"
LICENSEE="0x1234567890123456789012345678901234567890"

# Compute subnode
echo "Computing subnode for $SUBDOMAIN.myhedgefund-v2.eth..."
LABEL_HASH=$(cast keccak "$SUBDOMAIN")
SUBNODE=$(cast keccak $(cast concat-hex 0xc169c678e259ddaa848f328d412546f7148c1b92d04e0e09690e7fa63a9fb051 $LABEL_HASH))
echo "Subnode: $SUBNODE"
echo ""

echo "======================================"
echo "1. ENS NameWrapper Verification"
echo "======================================"
echo "Checking owner of $SUBDOMAIN.myhedgefund-v2.eth..."
OWNER=$(cast call 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
  "ownerOf(uint256)(address)" \
  $SUBNODE \
  --rpc-url sepolia)
echo "Owner: $OWNER"

if [ "$OWNER" = "0x0000000000000000000000000000000000000000" ]; then
    echo "❌ FAIL: Subdomain does not exist"
else
    echo "✅ PASS: Subdomain exists"
    if [ "${OWNER,,}" = "${LICENSEE,,}" ]; then
        echo "✅ PASS: Owned by correct licensee"
    else
        echo "⚠️  WARNING: Owned by $OWNER instead of $LICENSEE"
    fi
fi
echo ""

echo "======================================"
echo "2. LicenseManager Contract Verification"
echo "======================================"
echo "Checking license mapping in LicenseManager..."
LICENSE_NODE=$(cast call $LICENSE_MANAGER \
  "addressToLicense(address)(bytes32)" \
  $LICENSEE \
  --rpc-url sepolia)
echo "License node for $LICENSEE: $LICENSE_NODE"

if [ "$LICENSE_NODE" = "0x0000000000000000000000000000000000000000000000000000000000000000" ]; then
    echo "❌ FAIL: No license registered in contract"
else
    echo "✅ PASS: License registered in contract"
    if [ "${LICENSE_NODE,,}" = "${SUBNODE,,}" ]; then
        echo "✅ PASS: License node matches subdomain"
    else
        echo "⚠️  WARNING: License node mismatch"
    fi
fi
echo ""

echo "======================================"
echo "3. License Validation Check"
echo "======================================"
echo "Checking hasValidLicense() for $LICENSEE..."
HAS_LICENSE=$(cast call $LICENSE_MANAGER \
  "hasValidLicense(address)(bool)" \
  $LICENSEE \
  --rpc-url sepolia)
echo "hasValidLicense: $HAS_LICENSE"

if [ "$HAS_LICENSE" = "true" ]; then
    echo "✅ PASS: License is valid"
else
    echo "❌ FAIL: License not valid"
fi
echo ""

echo "======================================"
echo "4. PermitPoolHook Registration Check"
echo "======================================"
echo "Checking if license is registered with PermitPoolHook..."
HOOK_LICENSE=$(cast call $HOOK_ADDRESS \
  "userLicenseNode(address)(bytes32)" \
  $LICENSEE \
  --rpc-url sepolia 2>/dev/null || echo "0x0000000000000000000000000000000000000000000000000000000000000000")
echo "Hook license node: $HOOK_LICENSE"

if [ "$HOOK_LICENSE" = "0x0000000000000000000000000000000000000000000000000000000000000000" ]; then
    echo "⚠️  Not registered with hook yet (requires registerLicense call)"
else
    echo "✅ Hook registration exists"
fi
echo ""

echo "======================================"
echo "   VERIFICATION SUMMARY"
echo "======================================"
echo ""
echo "Subdomain: $SUBDOMAIN.myhedgefund-v2.eth"
echo "Subnode: $SUBNODE"
echo "Licensee: $LICENSEE"
echo "Owner: $OWNER"
echo "License valid: $HAS_LICENSE"
echo ""

if [ "$HAS_LICENSE" = "true" ] && [ "$OWNER" != "0x0000000000000000000000000000000000000000" ]; then
    echo "🎉 SUCCESS: License is fully operational!"
else
    echo "⚠️  License verification incomplete or failed"
fi
