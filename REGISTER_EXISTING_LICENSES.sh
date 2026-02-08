#!/bin/bash
# Register Existing Licenses with HOOK Contract

# Example: Replace these with your actual values
TRADER_ADDRESS="YOUR_TRADER_WALLET_ADDRESS"
SUBDOMAIN="dexter"  # Just the subdomain, not the full name

# Calculate the node hash using cast
FULL_DOMAIN="${SUBDOMAIN}.hedgefund-v3.eth"
NODE_HASH=$(cast namehash "$FULL_DOMAIN")

echo "🔍 Registration Details:"
echo "  Trader: $TRADER_ADDRESS"
echo "  Domain: $FULL_DOMAIN"
echo "  Node Hash: $NODE_HASH"
echo ""

# Register with HOOK contract
echo "📝 Registering license with HOOK contract..."
cast send $PERMIT_POOL_HOOK \
  "registerLicenseNode(address,bytes32)" \
  "$TRADER_ADDRESS" \
  "$NODE_HASH" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY

echo "✅ License registered! Trader can now use the platform."
