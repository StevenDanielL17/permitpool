#!/bin/bash
set -e

source .env

echo "================================================"
echo "  TESTING LICENSE ISSUANCE"
echo "================================================"

TEST_ADDRESS="0x1111111111111111111111111111111111111111"
TEST_SUBDOMAIN="trader001"
TEST_ARC_DID="did:arc:test-$(date +%s)"

echo ""
echo "Test Parameters:"
echo "  Licensee: $TEST_ADDRESS"
echo "  Subdomain: $TEST_SUBDOMAIN"
echo "  Arc DID: $TEST_ARC_DID"
echo "  Parent: $PARENT_NODE"
echo ""

echo "Issuing license..."
cast send $LICENSE_MANAGER \
  "issueLicense(address,string,string)" \
  $TEST_ADDRESS \
  $TEST_SUBDOMAIN \
  $TEST_ARC_DID \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY \
  --legacy \
  --gas-limit 1000000

echo ""
echo "✅ License issued! Waiting for confirmation..."
sleep 10

echo ""
echo "Verifying license..."
HAS_LICENSE=$(cast call $LICENSE_MANAGER \
  "hasValidLicense(address)(bool)" \
  $TEST_ADDRESS \
  --rpc-url $SEPOLIA_RPC_URL)

if [ "$HAS_LICENSE" = "true" ]; then
    echo "🎉 SUCCESS! License validated."
    echo ""
    echo "License details:"
    cast call $LICENSE_MANAGER \
      "getLicense(address)" \
      $TEST_ADDRESS \
      --rpc-url $SEPOLIA_RPC_URL
else
    echo "❌ License validation failed."
    exit 1
fi
