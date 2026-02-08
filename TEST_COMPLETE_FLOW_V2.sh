#!/bin/bash

# Complete Flow Test for License Issuance - Factory Pattern
source .env

echo "================================================"
echo "  TESTING COMPLETE LICENSE ISSUANCE FLOW"
echo "================================================"
echo ""

# Use existing deployed contract for now
DEPLOYED_CONTRACT="0x8a7B23126dD019ab706c3532cD54c90e4Fd861D3"
TEST_USER="0x3333333333333333333333333333333333333333"
TEST_SUBDOMAIN="quicktest$(date +%s | tail -c 4)"
TEST_CREDENTIAL="did:arc:test-$(date +%s)"

echo "Configuration:"
echo "  Contract: $DEPLOYED_CONTRACT"
echo "  User: $TEST_USER"
echo "  Subdomain: $TEST_SUBDOMAIN"
echo ""

# STEP 1: Verify contract exists
echo "Step 1: Checking contract..."
CODE=$(cast code $DEPLOYED_CONTRACT --rpc-url $SEPOLIA_RPC_URL)
if [ "$CODE" == "0x" ]; then
  echo "❌ ERROR: No bytecode at $DEPLOYED_CONTRACT"
  exit 1
fi
echo "✅ Contract deployed"

# STEP 2: Check parent locked
echo ""
echo "Step 2: Checking parent domain..."
PARENT_DATA=$(cast call 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
  "getData(uint256)(address,uint32,uint64)" \
  $PARENT_NODE \
  --rpc-url $SEPOLIA_RPC_URL)
echo "Parent data: $PARENT_DATA"
PARENT_FUSES=$(echo $PARENT_DATA | awk '{print $2}')
if [ $(($PARENT_FUSES & 1)) -eq 0 ]; then
  echo "❌ ERROR: Parent not locked"
  exit 1
fi
echo "✅ Parent locked"

# STEP 3: Issue license
echo ""
echo "Step 3: Issuing license..."
echo "Creating: $TEST_SUBDOMAIN.myhedgefund.eth"

cast send $DEPLOYED_CONTRACT \
  "issueLicense(address,string,string)" \
  $TEST_USER \
  "$TEST_SUBDOMAIN" \
  "$TEST_CREDENTIAL" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY \
  --legacy 2>&1 | tee /tmp/issue_result.txt

if [ ${PIPESTATUS[0]} -ne 0 ]; then
  echo ""
  echo "❌ ERROR: License issuance failed"
  echo "Error details above ^"
  exit 1
fi

echo "✅ Transaction submitted"

# STEP 4: Wait and verify
echo ""
echo "Step 4: Waiting for confirmation..."
sleep 20

SUBDOMAIN_NODE=$(cast namehash "$TEST_SUBDOMAIN.myhedgefund.eth")
echo "Checking node: $SUBDOMAIN_NODE"

SUBDOMAIN_DATA=$(cast call 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
  "getData(uint256)(address,uint32,uint64)" \
  $SUBDOMAIN_NODE \
  --rpc-url $SEPOLIA_RPC_URL)

echo "Subdomain data: $SUBDOMAIN_DATA"

OWNER=$(echo $SUBDOMAIN_DATA | awk '{print $1}')
if [ "$OWNER" == "0x0000000000000000000000000000000000000000" ]; then
  echo "❌ ERROR: Subdomain not created"
  exit 1
fi

echo "✅ Subdomain created!"
echo "Owner: $OWNER"
echo "Fuses: $(echo $SUBDOMAIN_DATA | awk '{print $2}')"
echo ""
echo "================================================"
echo "  FLOW TEST COMPLETE"
echo "================================================"
