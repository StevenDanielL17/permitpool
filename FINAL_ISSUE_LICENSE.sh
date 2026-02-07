#!/bin/bash
source .env

echo "======================================"
echo "   FINAL LICENSE ISSUANCE SCRIPT"
echo "   (Run after mempool clears)"
echo "======================================"
echo ""

LICENSE_MANAGER="${LICENSE_MANAGER:-0x4923Dca912171FD754c33e3Eab9fAB859259A02D}"
SUBDOMAIN="trader001"
LICENSEE="0x1234567890123456789012345678901234567890"

echo "Checking current nonce..."
CURRENT_NONCE=$(cast nonce $OWNER_ADDRESS --rpc-url sepolia)
echo "Current nonce: $CURRENT_NONCE"
echo ""

echo "======================================"
echo "Issuing License"
echo "======================================"
echo "LicenseManager: $LICENSE_MANAGER"
echo "Licensee: $LICENSEE"
echo "Subdomain: $SUBDOMAIN"
echo "Full ENS: $SUBDOMAIN.myhedgefund-v2.eth"
echo ""

# Issue license with normal gas (will use default gas price which is fine once mempool clears)
cast send "$LICENSE_MANAGER" \
  "issueLicense(address,string,string)" \
  "$LICENSEE" \
  "$SUBDOMAIN" \
  "did:arc:trader-license-001" \
  --rpc-url sepolia \
  --private-key $OWNER_PRIVATE_KEY \
  --gas-limit 500000 \
  --confirmations 2

EXIT_CODE=$?

echo ""
echo "======================================"
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Transaction submitted successfully!"
else
    echo "❌ Transaction failed with exit code: $EXIT_CODE"
    exit $EXIT_CODE
fi
echo "======================================"
echo ""

echo "Waiting 10 seconds for transaction to be mined..."
sleep 10

echo ""
echo "======================================"
echo "Verifying License"
echo "======================================"

# Compute subnode
LABEL_HASH=$(cast keccak "$SUBDOMAIN")
SUBNODE=$(cast keccak $(cast concat-hex 0xc169c678e259ddaa848f328d412546f7148c1b92d04e0e09690e7fa63a9fb051 $LABEL_HASH))
echo "Subnode: $SUBNODE"
echo ""

# Check ENS ownership
echo "1. Checking ENS NameWrapper ownership..."
OWNER=$(cast call 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
  "ownerOf(uint256)(address)" \
  $SUBNODE \
  --rpc-url sepolia)
echo "   Owner: $OWNER"

if [ "$OWNER" = "0x0000000000000000000000000000000000000000" ]; then
    echo "   ❌ FAIL: Subdomain does not exist"
    exit 1
elif [ "${OWNER,,}" = "${LICENSEE,,}" ]; then
    echo "   ✅ PASS: Owned by correct licensee"
else
    echo "   ⚠️  WARNING: Owned by different address"
fi
echo ""

# Check LicenseManager mapping
echo "2. Checking LicenseManager contract mapping..."
LICENSE_NODE=$(cast call "$LICENSE_MANAGER" \
  "addressToLicense(address)(bytes32)" \
  "$LICENSEE" \
  --rpc-url sepolia)
echo "   License node: $LICENSE_NODE"

if [ "$LICENSE_NODE" = "0x0000000000000000000000000000000000000000000000000000000000000000" ]; then
    echo "   ❌ FAIL: No license in contract"
    exit 1
else
    echo "   ✅ PASS: License registered"
fi
echo ""

# Check hasValidLicense
echo "3. Checking hasValidLicense()..."
HAS_LICENSE=$(cast call "$LICENSE_MANAGER" \
  "hasValidLicense(address)(bool)" \
  "$LICENSEE" \
  --rpc-url sepolia)
echo "   Result: $HAS_LICENSE"

if [ "$HAS_LICENSE" = "true" ]; then
    echo "   ✅ PASS: License is valid"
else
    echo "   ❌ FAIL: License not valid"
    exit 1
fi
echo ""

echo "======================================"
echo "🎉 SUCCESS! License fully operational!"
echo "======================================"
echo ""
echo "License Details:"
echo "  ENS Name: $SUBDOMAIN.myhedgefund-v2.eth"
echo "  Subnode: $SUBNODE"
echo "  Holder: $LICENSEE"
echo "  Status: Active ✓"
echo ""
echo "Next Steps:"
echo "  1. Run VERIFY_LICENSE.sh for detailed checks"
echo "  2. Test frontend with MetaMask"
echo "  3. Verify swap interface shows license badge"
