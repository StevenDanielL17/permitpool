#!/bin/bash

# ==========================================
# CHECK AND SET REVERSE ENS RESOLUTION
# ==========================================
# This script checks if reverse resolution is set up
# and helps you set it if needed

source .env

DEXTER_ADDRESS="0xDexter7cB14025b6f67B1e4347cDCc1c494c5cD65"
LICENSE_NAME="dexter"

echo "🔍 CHECKING REVERSE ENS RESOLUTION"
echo "===================================="
echo ""

# Check reverse resolution
echo "📋 Checking if $DEXTER_ADDRESS resolves to an ENS name..."

cast call 0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb \
  "node(address)(bytes32)" \
  "$DEXTER_ADDRESS" \
  --rpc-url "$SEPOLIA_RPC_URL"

REVERSE_NODE=$(cast call 0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb \
  "node(address)(bytes32)" \
  "$DEXTER_ADDRESS" \
  --rpc-url "$SEPOLIA_RPC_URL")

echo "Reverse node: $REVERSE_NODE"
echo ""

# Check what the reverse node resolves to
echo "🔄 Checking what the reverse node resolves to..."

RESOLVED_NAME=$(cast call 0x8FADE66B79cC9f707aB26799354482EB93a5B7dD \
  "name(bytes32)(string)" \
  "$REVERSE_NODE" \
  --rpc-url "$SEPOLIA_RPC_URL")

echo "Resolved name: $RESOLVED_NAME"
echo ""

if [ "$RESOLVED_NAME" == "" ] || [ "$RESOLVED_NAME" == "0x" ]; then
  echo "❌ NO REVERSE RESOLUTION SET!"
  echo ""
  echo "This is why the Trader App can't detect the license."
  echo "The app does: wallet address → ENS lookup → check if *.hedgefund-v3.eth"
  echo ""
  echo "🔧 TO FIX THIS:"
  echo ""
  echo "The wallet owner ($DEXTER_ADDRESS) needs to:"
  echo "1. Go to app.ens.domains"
  echo "2. Connect their wallet"
  echo "3. Click 'My Account' → 'Primary ENS Name'"
  echo "4. Select '$LICENSE_NAME.hedgefund-v3.eth'"
  echo "5. Confirm the transaction"
  echo ""
  echo "OR run this cast command from the Dexter wallet:"
  echo ""
  echo "cast send 0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb \\"
  echo "  'setName(string)' \\"
  echo "  '$LICENSE_NAME.hedgefund-v3.eth' \\"
  echo "  --rpc-url \$SEPOLIA_RPC_URL \\"
  echo "  --private-key <DEXTER_PRIVATE_KEY>"
  echo ""
else
  echo "✅ REVERSE RESOLUTION IS SET!"
  echo "Address resolves to: $RESOLVED_NAME"
  
  if [[ "$RESOLVED_NAME" == *"hedgefund-v3.eth"* ]]; then
    echo "✅ License should be detected by the Trader App!"
  else
    echo "⚠️  But it's not a hedgefund-v3.eth subdomain"
  fi
fi

echo ""
echo "===================================="
echo "DONE"
