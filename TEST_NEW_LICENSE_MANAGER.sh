#!/bin/bash
# Complete test of the new LicenseManager deployment

set -e
cd /home/stevendaniell/BackUp/Dan/dansprojects/Eth-Online
source .env

NEW_LICENSE_MANAGER="0xe8faf26e16068d2c6d77834b4441805c521a91b6"
PARENT_NODE=$(cast namehash myhedgefund.eth)

echo "========================================"
echo "  TESTING NEW LICENSE MANAGER"
echo "========================================"
echo ""
echo "LicenseManager: $NEW_LICENSE_MANAGER"
echo "Parent: myhedgefund.eth"
echo "Parent Node: $PARENT_NODE"
echo ""

echo "Step 1: Check parent domain state..."
echo "---"
DATA=$(cast call 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
  "getData(uint256)(address,uint32,uint64)" \
  $PARENT_NODE \
  --rpc-url $SEPOLIA_RPC_URL)

echo "$DATA" | head -1 | awk '{print "Owner: " $0}'
FUSES=$(echo "$DATA" | sed -n '2p')
echo "Fuses: $FUSES"
EXPIRY=$(echo "$DATA" | sed -n '3p')
echo "Expiry: $EXPIRY"

# Check if CANNOT_UNWRAP is set
if [ "$FUSES" == "196609" ] || [ "$FUSES" == "196609 [1.966e5]" ]; then
  echo "✅ Parent is LOCKED (CANNOT_UNWRAP is set)"
else
  echo "⚠️  Parent fuses: $FUSES"
  echo "   Attempting to lock parent..."
  cast send $NEW_LICENSE_MANAGER \
    "ensureParentLocked()" \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $OWNER_PRIVATE_KEY \
    --legacy
  echo "   Waiting 15s for confirmation..."
  sleep 15
fi

echo ""
echo "Step 2: Issue test license..."
echo "---"
TEST_NAME="frank$(date +%s | tail -c 4)"
echo "Creating: $TEST_NAME.myhedgefund.eth"

cast send $NEW_LICENSE_MANAGER \
  "issueLicense(address,string,string)" \
  "0x1234567890123456789012345678901234567890" \
  "$TEST_NAME" \
  "did:arc:test-$TEST_NAME" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY \
  --legacy

echo ""
echo "Step 3: Waiting for confirmation..."
sleep 20

echo ""
echo "Step 4: Verifying subdomain was created..."
echo "---"
TEST_NODE=$(cast namehash "$TEST_NAME.myhedgefund.eth")
echo "Subdomain node: $TEST_NODE"

SUBDATA=$(cast call 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
  "getData(uint256)(address,uint32,uint64)" \
  $TEST_NODE \
  --rpc-url $SEPOLIA_RPC_URL)

OWNER=$(echo "$SUBDATA" | head -1)
SUB_FUSES=$(echo "$SUBDATA" | sed -n '2p')
SUB_EXPIRY=$(echo "$SUBDATA" | sed -n '3p')

if [ "$OWNER" == "0x0000000000000000000000000000000000000000" ]; then
  echo "❌ FAILED: Subdomain was not created"
  exit 1
else
  echo "✅ SUCCESS!"
  echo "   Owner: $OWNER"
  echo "   Fuses: $SUB_FUSES"
  echo "   Expiry: $SUB_EXPIRY"
  echo ""
  echo "🎉 $TEST_NAME.myhedgefund.eth created successfully!"
fi

echo ""
echo "========================================"
echo "  DEPLOYMENT SUMMARY"
echo "========================================"
echo ""
echo "✅ New LicenseManager: $NEW_LICENSE_MANAGER"
echo "✅ Parent Domain: myhedgefund.eth (LOCKED)"
echo "✅ Test License: $TEST_NAME.myhedgefund.eth"
echo ""
echo "Update your frontend .env.local:"
echo "NEXT_PUBLIC_LICENSE_MANAGER_ADDRESS=$NEW_LICENSE_MANAGER"
echo ""
echo "Then restart: npm run dev:admin"
echo "========================================"
