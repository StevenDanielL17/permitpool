#!/bin/bash
# Run this script manually to issue the license

cd /home/stevendaniell/BackUp/Dan/dansprojects/Eth-Online

echo "=== Issuing License ==="
echo "LicenseManager: 0x4923Dca912171FD754c33e3Eab9fAB859259A02D"
echo "Subdomain: employee001"
echo ""

# Method 1: Using forge script
forge script script/IssueLicense.s.sol --rpc-url sepolia --broadcast -vvv

# Method 2: Using cast (alternative)
# Uncomment the line below if forge script doesn't work
# cast send 0x4923Dca912171FD754c33e3Eab9fAB859259A02D \
#   "issueLicense(address,string,string)" \
#   0x1234567890123456789012345678901234567890 \
#   "employee001" \
#   "did:arc:test-credential-hash-123" \
#   --rpc-url sepolia \
#   --private-key $OWNER_PRIVATE_KEY \
#   --gas-limit 500000
