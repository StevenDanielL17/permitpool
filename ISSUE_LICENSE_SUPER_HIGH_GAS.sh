#!/bin/bash
source .env

LICENSE_MANAGER="${LICENSE_MANAGER:-0x4923Dca912171FD754c33e3Eab9fAB859259A02D}"

echo "=== Issuing License with VERY HIGH GAS PRICE (20 gwei) ==="
echo "LicenseManager: $LICENSE_MANAGER"
echo "Licensee: 0x1234567890123456789012345678901234567890"
echo "Subdomain: employee004"
echo ""

# Use 20 gwei gas price to definitely replace stuck transaction
cast send "$LICENSE_MANAGER" \
  "issueLicense(address,string,string)" \
  0x1234567890123456789012345678901234567890 \
  "employee004" \
  "did:arc:credential-v4" \
  --rpc-url sepolia \
  --private-key $OWNER_PRIVATE_KEY \
  --gas-price 20000000000 \
  --gas-limit 500000

echo ""
echo "=== Verifying Result ==="
# Compute the subnode for employee004
SUBNODE=$(cast keccak $(cast concat-hex 0xc169c678e259ddaa848f328d412546f7148c1b92d04e0e09690e7fa63a9fb051 $(cast keccak "employee004")))
echo "Subdomain node: $SUBNODE"

echo "Owner of employee004.myhedgefund-v2.eth:"
cast call 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
  "ownerOf(uint256)(address)" \
  $SUBNODE \
  --rpc-url sepolia
