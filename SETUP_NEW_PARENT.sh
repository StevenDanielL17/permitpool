#!/bin/bash
set -e

# Setup New Parent Domain for License System
# Run this after registering a new .eth domain on Sepolia

echo "=========================================="
echo "  NEW PARENT DOMAIN SETUP"
echo "=========================================="
echo ""

# Load environment
source .env

# Get new domain name from user
read -p "Enter your NEW registered domain name (without .eth): " DOMAIN_NAME
echo ""

echo "📝 Configuration:"
echo "   Domain: ${DOMAIN_NAME}.eth"
echo "   Owner: $OWNER_ADDRESS"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# Step 1: Compute parent node
echo ""
echo "======================================"
echo "Step 1: Computing Parent Node"
echo "======================================"

ETH_NODE=$(cast keccak "eth")
LABEL_HASH=$(cast keccak "$DOMAIN_NAME")

# Compute namehash manually (namehash = keccak256(parent_hash + label_hash))
PARENT_NODE=$(cast keccak "$(printf '%s%s' "$ETH_NODE" "$LABEL_HASH" | sed 's/0x//g')")

echo "✅ Parent Node: $PARENT_NODE"

# Step 2: Wrap domain
echo ""
echo "======================================"
echo "Step 2: Wrapping Domain"
echo "======================================"
echo "This wraps ${DOMAIN_NAME}.eth with fuse value 1 (CANNOT_UNWRAP only)"
echo "This allows you to create subdomains while protecting the parent"
echo ""

cast send 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
  "wrapETH2LD(string,address,uint16,address)" \
  "$DOMAIN_NAME" \
  "$OWNER_ADDRESS" \
  1 \
  "$OWNER_ADDRESS" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY

echo "✅ Domain wrapped successfully"

# Step 3: Verify fuses
echo ""
echo "======================================"
echo "Step 3: Verifying Fuses"
echo "======================================"

FUSES=$(cast call 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
  "getFuses(bytes32)" \
  "$PARENT_NODE" \
  --rpc-url $SEPOLIA_RPC_URL)

echo "Current fuses: $FUSES"

# Step 4: Update .env file
echo ""
echo "======================================"
echo "Step 4: Updating Environment"
echo "======================================"

# Backup current .env
cp .env .env.backup.$(date +%s)

# Update values
sed -i "s|PARENT_NODE=.*|PARENT_NODE=$PARENT_NODE|" .env
sed -i "s|PARENT_NAME=.*|PARENT_NAME=${DOMAIN_NAME}.eth|" .env

echo "✅ Updated .env with new parent domain"
echo ""
echo "Old values backed up to .env.backup.*"

# Step 5: Redeploy contracts
echo ""
echo "======================================"
echo "Step 5: Deploying Contracts"
echo "======================================"
echo "Deploying with new parent domain..."
echo ""

forge script script/Deploy.s.sol:DeployScript \
  --rpc-url sepolia \
  --broadcast \
  --legacy

# Extract deployment addresses
echo ""
echo "📋 Extracting deployment addresses..."

BROADCAST_DIR="broadcast/Deploy.s.sol/11155111"
LATEST_RUN=$(ls -t "$BROADCAST_DIR"/run-*.json | head -1)

if [ ! -f "$LATEST_RUN" ]; then
    echo "❌ Could not find deployment output"
    exit 1
fi

# Parse addresses from broadcast file
LICENSE_MANAGER=$(jq -r '.transactions[] | select(.contractName == "LicenseManager") | .contractAddress' "$LATEST_RUN" | head -1)
HOOK=$(jq -r '.transactions[] | select(.contractName == "PermitPoolHook") | .contractAddress' "$LATEST_RUN" | head -1)

if [ -z "$LICENSE_MANAGER" ] || [ "$LICENSE_MANAGER" == "null" ]; then
    echo "❌ Failed to extract LicenseManager address"
    exit 1
fi

# Update .env with new addresses
sed -i "s|LICENSE_MANAGER=.*|LICENSE_MANAGER=$LICENSE_MANAGER|" .env
sed -i "s|HOOK_ADDRESS=.*|HOOK_ADDRESS=$HOOK|" .env

echo "✅ Contracts deployed:"
echo "   LicenseManager: $LICENSE_MANAGER"
echo "   Hook: $HOOK"

# Step 6: Approve LicenseManager
echo ""
echo "======================================"
echo "Step 6: Approving LicenseManager"
echo "======================================"

cast send 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
  "setApprovalForAll(address,bool)" \
  "$LICENSE_MANAGER" \
  true \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY

echo "✅ LicenseManager approved for subdomain creation"

# Step 7: Test license issuance
echo ""
echo "======================================"
echo "Step 7: Testing License Issuance"
echo "======================================"

TEST_SUBDOMAIN="test-$(date +%s)"
TEST_ADDR="0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb0"

echo "Issuing test license: ${TEST_SUBDOMAIN}.${DOMAIN_NAME}.eth"

cast send "$LICENSE_MANAGER" \
  "issueLicense(address,string,string)" \
  "$TEST_ADDR" \
  "$TEST_SUBDOMAIN" \
  "arc:test:verification" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY

echo "✅ Test license issued successfully!"

# Verify subdomain
echo ""
echo "Verifying subdomain creation..."

TEST_LABEL_HASH=$(cast keccak "$TEST_SUBDOMAIN")
TEST_NODE=$(cast keccak "$(printf '%s%s' "$PARENT_NODE" "$TEST_LABEL_HASH" | sed 's/0x//g')")

OWNER=$(cast call 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e \
  "owner(bytes32)" \
  "$TEST_NODE" \
  --rpc-url $SEPOLIA_RPC_URL)

if [ "$OWNER" == "$TEST_ADDR" ]; then
    echo "✅ Subdomain owner verified: $OWNER"
else
    echo "⚠️  Subdomain owner: $OWNER (expected: $TEST_ADDR)"
fi

# Complete
echo ""
echo "=========================================="
echo "  ✅ SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "📋 Summary:"
echo "   Domain: ${DOMAIN_NAME}.eth"
echo "   Parent Node: $PARENT_NODE"
echo "   LicenseManager: $LICENSE_MANAGER"
echo "   Hook: $HOOK"
echo "   Test License: ${TEST_SUBDOMAIN}.${DOMAIN_NAME}.eth"
echo ""
echo "🎯 Next Steps:"
echo "   1. Run ./PHASE_8_MULTI_LICENSE.sh to issue multiple licenses"
echo "   2. Run ./PHASE_7_TEST_HOOK.sh to test hook integration"
echo "   3. Run ./TEST_COMPLETE_FLOW.sh for E2E testing"
echo "   4. Update frontend apps with new addresses"
echo ""
echo "📁 Configuration saved in .env"
echo "📁 Backup saved in .env.backup.*"
echo ""
