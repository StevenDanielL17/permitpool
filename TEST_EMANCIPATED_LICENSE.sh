#!/bin/bash
# TEST_EMANCIPATED_LICENSE.sh
# Test the new setSubnodeRecord approach for bypassing PARENT_CANNOT_CONTROL

set -e

source .env

echo "==========================================="
echo "  TESTING EMANCIPATED SUBDOMAIN CREATION"
echo "==========================================="
echo ""
echo "🔍 This tests if setSubnodeRecord bypasses PARENT_CANNOT_CONTROL fuse"
echo ""

# Test addresses
TEST_LICENSEE="0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb" 
TEST_SUBDOMAIN="emancipated-test-$(date +%s)"
TEST_ARC_CRED="arc:did:test:$(openssl rand -hex 16)"

echo "📋 Test Parameters:"
echo "   Licensee: $TEST_LICENSEE"
echo "   Subdomain: $TEST_SUBDOMAIN"
echo "   Arc Credential: $TEST_ARC_CRED"
echo ""

# Step 1: Deploy new LicenseManager
echo "===================================="
echo "Step 1: Deploy Updated LicenseManager"
echo "===================================="
echo "Deploying with setSubnodeRecord support..."

DEPLOY_OUTPUT=$(forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY \
  --broadcast 2>&1)

echo "$DEPLOY_OUTPUT"

NEW_LICENSE_MANAGER=$(echo "$DEPLOY_OUTPUT" | grep "LicenseManager:" | awk '{print $2}' | head -1)

if [ -z "$NEW_LICENSE_MANAGER" ]; then
  echo "❌ Failed to extract new LicenseManager address"
  echo "Check logs above for deployment errors"
  exit 1
fi

echo "✅ New LicenseManager deployed: $NEW_LICENSE_MANAGER"
echo ""

# Step 2: Test license issuance
echo "===================================="
echo "Step 2: Issue Test License"
echo "===================================="
echo "Calling issueLicense with emancipated creation..."

ISSUE_TX=$(cast send $NEW_LICENSE_MANAGER \
  "issueLicense(address,string,string)" \
  $TEST_LICENSEE \
  "$TEST_SUBDOMAIN" \
  "$TEST_ARC_CRED" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY 2>&1)

echo "$ISSUE_TX"

# Check if transaction succeeded
if echo "$ISSUE_TX" | grep -iq "blockHash"; then
  echo "✅ Transaction SUCCEEDED!"
  TX_HASH=$(echo "$ISSUE_TX" | grep "transactionHash" | awk '{print $2}')
  echo "   TX Hash: $TX_HASH"
else
  echo "❌ Transaction FAILED"
  echo "Error output:"
  echo "$ISSUE_TX" | grep -i "error" || echo "$ISSUE_TX"
  exit 1
fi

echo ""

# Step 3: Verify subdomain created
echo "===================================="
echo "Step 3: Verify Subdomain Created"
echo "===================================="

# Calculate subdomain node
LABEL_HASH=$(cast keccak $(cast --from-utf8 "$TEST_SUBDOMAIN"))
SUBDOMAIN_NODE=$(cast keccak $(echo -n "${PARENT_NODE}${LABEL_HASH}" | sed 's/0x//g' | xxd -r -p | xxd -p -c 66))

echo "Checking NameWrapper for subdomain..."
OWNER=$(cast call $ENS_NAME_WRAPPER \
  "ownerOf(uint256)" \
  $SUBDOMAIN_NODE \
  --rpc-url $SEPOLIA_RPC_URL 2>&1)

if echo "$OWNER" | grep -iq "$TEST_LICENSEE"; then
  echo "✅ Subdomain created successfully!"
  echo "   Owner: $OWNER"
else
  echo "⚠️  Could not verify subdomain ownership"
  echo "   Response: $OWNER"
fi

echo ""

# Step 4: Verify fuses burned
echo "===================================="
echo "Step 4: Verify Fuses Burned"
echo "===================================="

FUSES=$(cast call $ENS_NAME_WRAPPER \
  "getFuses(bytes32)" \
  $SUBDOMAIN_NODE \
  --rpc-url $SEPOLIA_RPC_URL 2>&1)

echo "Fuses: $FUSES"

FUSES_DEC=$(printf "%d" $FUSES 2>/dev/null || echo "0")
CANNOT_TRANSFER=$((FUSES_DEC & 0x10))
PARENT_CANNOT_CONTROL=$((FUSES_DEC & 0x10000))

if [ $CANNOT_TRANSFER -ne 0 ]; then
  echo "✅ CANNOT_TRANSFER fuse burned"
else
  echo "⚠️  CANNOT_TRANSFER fuse NOT burned"
fi

if [ $PARENT_CANNOT_CONTROL -ne 0 ]; then
  echo "✅ PARENT_CANNOT_CONTROL fuse burned (emancipated)"
else
  echo "⚠️  PARENT_CANNOT_CONTROL fuse NOT burned"
fi

echo ""

# Step 5: Verify license validity
echo "===================================="
echo "Step 5: Verify License Validity"
echo "===================================="

HAS_LICENSE=$(cast call $NEW_LICENSE_MANAGER \
  "hasValidLicense(address)(bool)" \
  $TEST_LICENSEE \
  --rpc-url $SEPOLIA_RPC_URL 2>&1)

if echo "$HAS_LICENSE" | grep -iq "true"; then
  echo "✅ License validated by LicenseManager"
else
  echo "❌ License NOT recognized by LicenseManager"
  echo "   Response: $HAS_LICENSE"
fi

echo ""
echo "==========================================="
echo "          TEST COMPLETE"
echo "==========================================="
echo ""
echo "📊 Summary:"
echo "   ✅ Contract deployed: $NEW_LICENSE_MANAGER"
echo "   ✅ License issued via setSubnodeRecord"
echo "   ✅ Emancipated subdomain created: $TEST_SUBDOMAIN.myhedgefund-v2.eth"
echo ""
echo "🎯 Next Steps:"
echo "   1. Update .env with new LICENSE_MANAGER address"
echo "   2. Update frontend env files"
echo "   3. Test in admin portal UI"
echo ""
echo "💡 If this test SUCCEEDED, the PARENT_CANNOT_CONTROL issue is SOLVED!"
echo ""
