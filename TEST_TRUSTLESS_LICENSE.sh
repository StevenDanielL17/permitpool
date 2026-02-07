#!/bin/bash
# Test trustless license creation with the fixed LicenseManager

set -e
cd /home/stevendaniell/BackUp/Dan/dansprojects/Eth-Online
source .env

LICENSE_MANAGER="0xe8faf26e16068d2c6d77834b4441805c521a91b6"
TEST_LICENSEE="0x1234567890123456789012345678901234567890"
SUBDOMAIN="verified123"

echo "=========================================="
echo "  TESTING TRUSTLESS LICENSE CREATION"
echo "=========================================="
echo ""
echo "LicenseManager: $LICENSE_MANAGER"
echo "Test Licensee: $TEST_LICENSEE"
echo "Subdomain: $SUBDOMAIN.myhedgefund.eth"
echo ""

echo "Step 1: Verify contract has correct fuses in bytecode..."
echo "---"
if cast code $LICENSE_MANAGER --rpc-url $SEPOLIA_RPC_URL | grep -q "62010011"; then
    echo "✅ Bytecode contains 0x10011 (PARENT_CANNOT_CONTROL | CANNOT_UNWRAP | CANNOT_TRANSFER)"
else
    echo "❌ ERROR: Bytecode does NOT contain 0x10011!"
    exit 1
fi
echo ""

echo "Step 2: Check NameWrapper approval..."
echo "---"
APPROVED=$(cast call 0x0635513f179D50A207757E05759CbD106d7dFcE8 "isApprovedForAll(address,address)(bool)" $OWNER_ADDRESS $LICENSE_MANAGER --rpc-url $SEPOLIA_RPC_URL)
if [ "$APPROVED" = "true" ]; then
    echo "✅ LicenseManager is approved"
else
    echo "❌ ERROR: LicenseManager NOT approved!"
    exit 1
fi
echo ""

echo "Step 3: Check admin authorization..."
echo "---"
CONTRACT_ADMIN=$(cast call $LICENSE_MANAGER "admin()" --rpc-url $SEPOLIA_RPC_URL | cast parse-bytes32-address)
echo "Contract Admin: $CONTRACT_ADMIN"
echo "Owner Address: $OWNER_ADDRESS"
if [ "$(echo $CONTRACT_ADMIN | tr '[:upper:]' '[:lower:]')" = "$(echo $OWNER_ADDRESS | tr '[:upper:]' '[:lower:]')" ]; then
    echo "✅ Admin matches owner"
else
    echo "❌ ERROR: Admin mismatch!"
    exit 1
fi
echo ""

echo "Step 4: Issue trustless license..."
echo "---"
echo "Executing: issueLicense($TEST_LICENSEE, \"$SUBDOMAIN\", \"did:arc:final-test\")"
echo ""

cast send $LICENSE_MANAGER \
    "issueLicense(address,string,string)" \
    $TEST_LICENSEE \
    $SUBDOMAIN \
    "did:arc:final-test" \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $OWNER_PRIVATE_KEY \
    --legacy \
    --gas-limit 800000

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Transaction sent successfully!"
    echo ""
    echo "Step 5: Waiting 30 seconds for confirmation..."
    sleep 30
    
    echo ""
    echo "Step 6: Verifying subdomain creation..."
    echo "---"
    SUBDOMAIN_NODE=$(cast namehash ${SUBDOMAIN}.myhedgefund.eth)
    echo "Subdomain node: $SUBDOMAIN_NODE"
    echo ""
    
    cast call 0x0635513f179D50A207757E05759CbD106d7dFcE8 \
        "getData(uint256)(address,uint32,uint64)" \
        $SUBDOMAIN_NODE \
        --rpc-url $SEPOLIA_RPC_URL
    
    echo ""
    echo "✅ TEST COMPLETE!"
    echo ""
    echo "Expected fuses: 65553 (0x10011)"
    echo "  - PARENT_CANNOT_CONTROL: 65536 (0x10000)"
    echo "  - CANNOT_TRANSFER: 16 (0x10)"
    echo "  - CANNOT_UNWRAP: 1 (0x1)"
else
    echo ""
    echo "❌ Transaction FAILED!"
    exit 1
fi
