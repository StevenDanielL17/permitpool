#!/bin/bash
# Set Reverse ENS Resolution for License Owner

source .env

LICENSE_OWNER="0x8b57bebe75d5a5CDB1A4bB3Ec6E2d349489d6A72"
LICENSE_NAME="dexter.hedgefund-v3.eth"

echo "🔧 SETTING UP REVERSE ENS RESOLUTION"
echo "====================================="
echo ""
echo "License Owner: $LICENSE_OWNER"
echo "License Name: $LICENSE_NAME"
echo ""

# Option 1: If you have the private key for this wallet
read -p "Do you have the private key for $LICENSE_OWNER? (y/n): " HAS_KEY

if [ "$HAS_KEY" = "y" ] || [ "$HAS_KEY" = "Y" ]; then
  read -sp "Enter the private key: " PRIVATE_KEY
  echo ""
  echo ""
  echo "Setting reverse resolution..."
  
  cast send 0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb \
    'setName(string)' \
    "$LICENSE_NAME" \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key "$PRIVATE_KEY"
  
  if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! Reverse resolution set!"
    echo ""
    echo "Wait 30 seconds, then refresh the Trader App."
    echo "The license should now be detected!"
  else
    echo ""
    echo "❌ Transaction failed. Check the error above."
  fi
else
  echo ""
  echo "📱 MANUAL SETUP REQUIRED"
  echo ""
  echo "The wallet owner ($LICENSE_OWNER) needs to:"
  echo ""
  echo "1. Go to https://app.ens.domains"
  echo "2. Connect wallet: $LICENSE_OWNER"
  echo "3. Click 'My Account' → 'Primary ENS Name'"
  echo "4. Select '$LICENSE_NAME'"
  echo "5. Confirm the transaction"
  echo ""
  echo "After the transaction confirms, the Trader App will detect the license!"
fi

echo ""
echo "====================================="
