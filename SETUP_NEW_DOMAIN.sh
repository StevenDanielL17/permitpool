#!/bin/bash
set -e

source .env

NEW_DOMAIN="hedgefund-protocol-v1.eth"
NEW_NODE="0x6a4403046019d822c581cd292ff862fb84293969ffc588d61d3964412c73f2ae"

echo "================================================"
echo "  NEW DOMAIN SETUP: $NEW_DOMAIN"
echo "================================================"

echo ""
echo "[1/5] Checking current ownership..."
OWNER=$(cast call 0x0635513f179d50a207757e05759cbd106d7dfce8 \
  "ownerOf(uint256)(address)" \
  $NEW_NODE \
  --rpc-url $SEPOLIA_RPC_URL 2>/dev/null || echo "0x0000000000000000000000000000000000000000")

if [ "$OWNER" = "0x0000000000000000000000000000000000000000" ]; then
    echo "⚠️  Domain not wrapped yet. Wrapping now..."
    
    echo ""
    echo "[2/5] Approving NameWrapper..."
    cast send 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e \
      "setApprovalForAll(address,bool)" \
      0x0635513f179d50a207757e05759cbd106d7dfce8 \
      true \
      --rpc-url $SEPOLIA_RPC_URL \
      --private-key $OWNER_PRIVATE_KEY \
      --legacy \
      --gas-limit 100000
    
    echo "✅ Approval sent. Waiting for confirmation..."
    sleep 15
    
    echo ""
    echo "[3/5] Wrapping domain..."
    cast send 0x0635513f179d50a207757e05759cbd106d7dfce8 \
      "wrapETH2LD(string,address,uint16,address)" \
      "hedgefund-protocol-v1" \
      $OWNER_ADDRESS \
      0 \
      $OWNER_ADDRESS \
      --rpc-url $SEPOLIA_RPC_URL \
      --private-key $OWNER_PRIVATE_KEY \
      --legacy \
      --gas-limit 500000
    
    echo "✅ Wrap sent. Waiting for confirmation..."
    sleep 15
else
    echo "✅ Domain already wrapped. Owner: $OWNER"
fi

echo ""
echo "[4/5] Transferring to LicenseManager..."
cast send 0x0635513f179d50a207757e05759cbd106d7dfce8 \
  "safeTransferFrom(address,address,uint256,uint256,bytes)" \
  $OWNER_ADDRESS \
  $LICENSE_MANAGER \
  $NEW_NODE \
  1 \
  0x \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY \
  --legacy \
  --gas-limit 300000

echo "✅ Transfer sent. Waiting for confirmation..."
sleep 15

echo ""
echo "[5/5] Verifying final ownership..."
FINAL_OWNER=$(cast call 0x0635513f179d50a207757e05759cbd106d7dfce8 \
  "ownerOf(uint256)(address)" \
  $NEW_NODE \
  --rpc-url $SEPOLIA_RPC_URL)

echo "Final owner: $FINAL_OWNER"
echo "Contract:    $LICENSE_MANAGER"

if [ "$FINAL_OWNER" = "$LICENSE_MANAGER" ]; then
    echo ""
    echo "🎉 SUCCESS! Contract now owns $NEW_DOMAIN"
    echo ""
    echo "================================================"
    echo "  NEXT STEPS:"
    echo "================================================"
    echo "1. Update your .env file:"
    echo "   PARENT_NODE=$NEW_NODE"
    echo ""
    echo "2. Test license issuance:"
    echo "   ./TEST_NEW_LICENSE.sh"
else
    echo ""
    echo "❌ Transfer failed. Owner doesn't match contract."
    exit 1
fi
