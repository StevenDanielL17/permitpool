#!/bin/bash
# REGISTER EXISTING LICENSE WITH HOOK CONTRACT
# This script registers a license that was already issued but not registered with the HOOK

set -e

source .env

# Input: You need to provide these
read -p "Enter the trader's wallet address (who received the license): " TRADER_ADDRESS
read -p "Enter the subdomain (e.g., 'dexter'): " SUBDOMAIN

# Calculate the node hash
FULL_DOMAIN="${SUBDOMAIN}.hedgefund-v3.eth"
NODE_HASH=$(cast namehash "$FULL_DOMAIN")

echo ""
echo "🔍 Registration Details:"
echo "  Trader Address: $TRADER_ADDRESS"
echo "  Full Domain: $FULL_DOMAIN"
echo "  Node Hash: $NODE_HASH"
echo "  HOOK Contract: $PERMIT_POOL_HOOK"
echo ""
echo "📝 Registering license with HOOK contract..."
echo ""

# Register with HOOK contract
cast send $PERMIT_POOL_HOOK \
  "registerLicenseNode(address,bytes32)" \
  "$TRADER_ADDRESS" \
  "$NODE_HASH" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY

echo ""
echo "✅ LICENSE REGISTERED WITH HOOK!"
echo "The trader can now use the platform at http://localhost:3001"
echo ""
echo "🔄 Refresh the trader app to see the license verified."
