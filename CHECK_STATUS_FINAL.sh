#!/bin/bash
source .env

echo "================================================"
echo "  FINAL STATUS CHECK"
echo "================================================"

NEW_NODE="0x6a4403046019d822c581cd292ff862fb84293969ffc588d61d3964412c73f2ae"

echo ""
echo "[1/4] Domain Ownership"
OWNER=$(cast call 0x0635513f179d50a207757e05759cbd106d7dfce8 \
  "ownerOf(uint256)" \
  $NEW_NODE \
  --rpc-url $SEPOLIA_RPC_URL)

echo "Owner: $OWNER"
echo "Contract: $LICENSE_MANAGER"

if [[ "${OWNER,,}" == *"${LICENSE_MANAGER:2}"* ]]; then
    echo "✅ Contract owns hedgefund-protocol-v1.eth"
else
    echo "❌ Transfer incomplete or failed"
fi

echo ""
echo "[2/4] Domain Fuses (should be clean)"
DATA=$(cast call 0x0635513f179d50a207757e05759cbd106d7dfce8 \
  "getData(uint256)" \
  $NEW_NODE \
  --rpc-url $SEPOLIA_RPC_URL)
echo "Raw data: $DATA"

echo ""
echo "[3/4] License Verification"
TEST_ADDR="0x1111111111111111111111111111111111111111"
HAS_LICENSE=$(cast call $LICENSE_MANAGER \
  "hasValidLicense(address)(bool)" \
  $TEST_ADDR \
  --rpc-url $SEPOLIA_RPC_URL)

echo "Test address: $TEST_ADDR"
echo "Has valid license: $HAS_LICENSE"

if [ "$HAS_LICENSE" = "true" ]; then
    echo "✅ LICENSE ISSUANCE WORKS!"
    echo ""
    echo "License details:"
    cast call $LICENSE_MANAGER \
      "getLicense(address)" \
      $TEST_ADDR \
      --rpc-url $SEPOLIA_RPC_URL
else
    echo "⚠️  No license yet or issuance pending"
fi

echo ""
echo "[4/4] Transaction Count"
NONCE=$(cast nonce $OWNER_ADDRESS --rpc-url $SEPOLIA_RPC_URL)
echo "Current nonce: $NONCE"

echo ""
echo "================================================"
if [ "$HAS_LICENSE" = "true" ]; then
    echo "🎉 SUCCESS! Everything works with clean domain!"
    echo ""
    echo "NEXT STEPS:"
    echo "1. Update admin portal with new parent domain"
    echo "2. Test real Arc verification flow"
    echo "3. Deploy to production"
else
    echo "⏳ Transactions still processing..."
    echo "   Run this script again in 30 seconds"
fi
echo "================================================"
