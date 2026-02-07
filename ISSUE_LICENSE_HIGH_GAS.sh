#!/bin/bash
# Issue a license with HIGHER gas price to replace stuck transaction

cd /home/stevendaniell/BackUp/Dan/dansprojects/Eth-Online
source .env

LICENSE_MANAGER="0x4923Dca912171FD754c33e3Eab9fAB859259A02D"

echo "=== Issuing License with HIGHER GAS PRICE ==="
echo "LicenseManager: $LICENSE_MANAGER"
echo "Licensee: 0x1234567890123456789012345678901234567890"
echo "Subdomain: employee003"
echo ""

cast send $LICENSE_MANAGER \
  "issueLicense(address,string,string)" \
  0x1234567890123456789012345678901234567890 \
  "employee003" \
  "did:arc:credential-v3" \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $OWNER_PRIVATE_KEY \
  --gas-price 5000000000 \
  --gas-limit 500000

echo ""
echo "=== Verifying Result ==="
SUBNODE=$(cast namehash employee003.myhedgefund-v2.eth)
echo "Subdomain node: $SUBNODE"

cast call 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
  "ownerOf(uint256)(address)" \
  $SUBNODE \
  --rpc-url $SEPOLIA_RPC_URL

echo ""
echo "✅ If owner shows 0x1234567890123456789012345678901234567890, SUCCESS!"
