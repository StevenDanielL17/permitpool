#!/bin/bash
# SIMPLE: Register a single license manually
# Usage: ./register_one_license.sh <trader_address> <subdomain>

set -e

source .env

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <trader_address> <subdomain>"
    echo "Example: $0 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb 0 dexter"
    exit 1
fi

TRADER_ADDRESS=$1
SUBDOMAIN=$2

# Calculate the node hash
FULL_DOMAIN="${SUBDOMAIN}.hedgefund-v3.eth"
NODE_HASH=$(cast namehash "$FULL_DOMAIN")

echo ""
echo "🔍 Registration Details:"
echo "  Trader: $TRADER_ADDRESS"
echo "  Domain: $FULL_DOMAIN"
echo "  Node: $NODE_HASH"
echo ""

# Register with HOOK
echo "📝 Registering with HOOK contract..."
cast send $PERMIT_POOL_HOOK \
  "registerLicenseNode(address,bytes32)" \
  "$TRADER_ADDRESS" \
  "$NODE_HASH" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY

echo ""
echo "✅ LICENSE REGISTERED!"
echo "Trader can now access the platform."
