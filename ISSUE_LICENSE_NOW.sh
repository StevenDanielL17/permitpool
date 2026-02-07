#!/bin/bash
# Issue a license using the currently deployed contract

cd /home/stevendaniell/BackUp/Dan/dansprojects/Eth-Online
source .env

# Latest deployment (with parent locked)
LICENSE_MANAGER="0x2C093Ff1e639aa9442E1CADc3638dd7063c96460"

echo "=== Issuing License ==="
echo "LicenseManager: $LICENSE_MANAGER"
echo "Licensee: $OWNER_ADDRESS"
echo "Subdomain: testuser456"
echo ""

cast send $LICENSE_MANAGER \
  "issueLicense(string,address,string)" \
  "testuser456" \
  "$OWNER_ADDRESS" \
  "test-jwt-credential" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --legacy \
  --gas-limit 400000

echo ""
echo "=== Checking Result ==="
# Verify the subdomain was created
SUBNODE=$(cast namehash employee002.myhedgefund-v2.eth)
echo "Subdomain node: $SUBNODE"

cast call 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
  "ownerOf(uint256)(address)" \
  $SUBNODE \
  --rpc-url $SEPOLIA_RPC_URL

echo ""
echo "If the owner is 0x1234567890123456789012345678901234567890, SUCCESS!"
