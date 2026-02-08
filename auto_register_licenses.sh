#!/bin/bash
# AUTO-REGISTER ALL ISSUED LICENSES WITH HOOK CONTRACT
# This finds all LicenseIssued events and registers them with the HOOK

set -e

source .env

echo "🔍 Scanning for issued licenses..."
echo ""

# Get the deployment block (reduce scan range)
CURRENT_BLOCK=$(cast block-number --rpc-url $SEPOLIA_RPC_URL)
FROM_BLOCK=$((CURRENT_BLOCK - 10000))  # Last 10k blocks (~1-2 days)

echo "Scanning blocks $FROM_BLOCK to $CURRENT_BLOCK..."
echo ""

# Query LicenseIssued events
# Event signature: LicenseIssued(address indexed licensee, bytes32 indexed subnode, string subdomain)
cast logs \
  --address $LICENSE_MANAGER \
  --from-block $FROM_BLOCK \
  "LicenseIssued(address indexed, bytes32 indexed, string)" \
  --rpc-url $SEPOLIA_RPC_URL \
  --json > /tmp/licenses.json

# Parse and register each license
LICENSE_COUNT=$(jq length /tmp/licenses.json)

if [ "$LICENSE_COUNT" -eq 0 ]; then
  echo "❌ No licenses found in the last 10,000 blocks."
  echo "The license might be older. Please run './register_license.sh' manually."
  exit 0
fi

echo "✅ Found $LICENSE_COUNT license(s)!"
echo ""

for i in $(seq 0 $((LICENSE_COUNT - 1))); do
  # Extract data from event
  LICENSEE_RAW=$(jq -r ".[$i].topics[1]" /tmp/licenses.json)
  # Remove 0x prefix and pad, then add 0x and take last 40 chars as address
  LICENSEE="0x$(echo $LICENSEE_RAW | sed 's/0x//g' | tail -c 41)"
  
  NODE=$(jq -r ".[$i].topics[2]" /tmp/licenses.json)
  
  # Decode the subdomain from data field
  DATA_RAW=$(jq -r ".[$i].data" /tmp/licenses.json)
  SUBDOMAIN=$(cast --abi-decode "x(string)" "$DATA_RAW" | tr -d '"')
  
  echo "📝 Registering License #$((i + 1)):"
  echo "   Trader: $LICENSEE"
  echo "   Subdomain: $SUBDOMAIN.hedgefund-v3.eth"
  echo "   Node: $NODE"
  echo ""
  
  # Register with HOOK
  cast send $PERMIT_POOL_HOOK \
    "registerLicenseNode(address,bytes32)" \
    "$LICENSEE" \
    "$NODE" \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $OWNER_PRIVATE_KEY \
    --confirmations 1
  
  echo "✅ License #$((i + 1)) registered!"
  echo ""
done

echo "🎉 ALL LICENSES REGISTERED!"
echo "Traders can now access http://localhost:3001"

rm /tmp/licenses.json
