#!/bin/bash
source .env

echo "=== CLEARING STUCK TRANSACTION BY SENDING SELF 0 ETH ===" 
echo "This will use the same nonce but with minimal gas/data to clear the stuck tx"
echo ""

# Send 0 ETH to self with high gas to clear the stuck nonce
cast send $OWNER_ADDRESS \
  --value 0 \
  --rpc-url sepolia \
  --private-key $OWNER_PRIVATE_KEY \
  --gas-price 100000000000 \
  --gas-limit 21000

echo ""
echo "Nonce should now be cleared. Waiting 10 seconds..."
sleep 10

echo ""
echo "=== NOW ISSUING LICENSE WITH NORMAL GAS ===" 
LICENSE_MANAGER="${LICENSE_MANAGER:-0x4923Dca912171FD754c33e3Eab9fAB859259A02D}"

cast send "$LICENSE_MANAGER" \
  "issueLicense(address,string,string)" \
  0x1234567890123456789012345678901234567890 \
  "employee006" \
  "did:arc:credential-v6" \
  --rpc-url sepolia \
  --private-key $OWNER_PRIVATE_KEY \
  --gas-limit 500000

echo ""
echo "=== Verifying Result ==="
SUBNODE=$(cast keccak $(cast concat-hex 0xc169c678e259ddaa848f328d412546f7148c1b92d04e0e09690e7fa63a9fb051 $(cast keccak "employee006")))
echo "Subdomain node: $SUBNODE"

echo "Owner of employee006.myhedgefund-v2.eth:"
cast call 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
  "ownerOf(uint256)(address)" \
  $SUBNODE \
  --rpc-url sepolia
