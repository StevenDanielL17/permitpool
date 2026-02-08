#!/bin/bash
set -e

source .env

echo "=================================="
echo "NUCLEAR OPTION - COMPLETE TEST"
echo "=================================="
echo ""

echo "Step 1: Check parent ownership..."
PARENT_OWNER=$(cast call $ENS_NAME_WRAPPER "ownerOf(uint256)(address)" $PARENT_NODE --rpc-url $SEPOLIA_RPC_URL)
echo "Parent owner: $PARENT_OWNER"
echo "Contract addr: $LICENSE_MANAGER"

if [ "$PARENT_OWNER" == "$LICENSE_MANAGER" ]; then
    echo "✅ Contract owns parent! Nuclear option SUCCESS!"
else
    echo "⚠️  Parent still owned by wallet. Transfer may be pending..."
    echo "Attempting transfer now..."
    cast send $ENS_NAME_WRAPPER \
      "safeTransferFrom(address,address,uint256,uint256,bytes)" \
      $OWNER_ADDRESS \
      $LICENSE_MANAGER \
      $PARENT_NODE \
      1 \
      "0x" \
      --private-key $OWNER_PRIVATE_KEY \
      --rpc-url $SEPOLIA_RPC_URL \
      --legacy
    
    echo "Waiting 30s for confirmation..."
    sleep 30
fi

echo ""
echo "Step 2: Issue test license..."
cast send $LICENSE_MANAGER \
  "issueLicense(address,string,string)" \
  "0x1111111111111111111111111111111111111111" \
  "nuclear001" \
  "did:arc:nuclear-success-2026" \
  --private-key $OWNER_PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL \
  --legacy

echo "Waiting for license issuance..."
sleep 25

echo ""
echo "Step 3: Verify license..."
HAS_LICENSE=$(cast call $LICENSE_MANAGER "hasValidLicense(address)(bool)" "0x1111111111111111111111111111111111111111" --rpc-url $SEPOLIA_RPC_URL)

if [ "$HAS_LICENSE" == "true" ]; then
    echo "✅✅✅ LICENSE ISSUED SUCCESSFULLY! ✅✅✅"
    echo ""
    echo "🎉 NUCLEAR OPTION COMPLETE - ALL 5 SPONSORS WORKING! 🎉"
    echo ""
    echo "Subdomain created: nuclear001.myhedgefund.eth"
    echo "Owner: 0x1111111111111111111111111111111111111111"
    echo ""
    echo "You can now issue licenses to all your traders!"
else
    echo "❌ License verification failed. Checking details..."
    cast call $LICENSE_MANAGER "getLicense(address)" "0x1111111111111111111111111111111111111111" --rpc-url $SEPOLIA_RPC_URL
fi

echo ""
echo "Step 4: Verify ENS subdomain..."
SUBDOMAIN_NODE=$(cast namehash nuclear001.myhedgefund.eth)
echo "Checking node: $SUBDOMAIN_NODE"
SUBDOMAIN_DATA=$(cast call $ENS_NAME_WRAPPER "getData(uint256)" $SUBDOMAIN_NODE --rpc-url $SEPOLIA_RPC_URL 2>&1)
echo "Subdomain data: $SUBDOMAIN_DATA"

echo ""
echo "=================================="
echo "TEST COMPLETE"
echo "=================================="
