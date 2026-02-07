#!/bin/bash
source .env

echo "=========================================="
echo "   PHASE 8: Issue Multiple Licenses"
echo "=========================================="
echo ""

LICENSE_MANAGER="0x4923Dca912171FD754c33e3Eab9fAB859259A02D"

# Define employees to license
declare -a EMPLOYEES=(
    "employee001:0x1111111111111111111111111111111111111111:did:arc:emp001"
    "employee002:0x2222222222222222222222222222222222222222:did:arc:emp002"
    "employee003:0x3333333333333333333333333333333333333333:did:arc:emp003"
    "trader001:0x1234567890123456789012345678901234567890:did:arc:trader001"
    "trader002:0x4444444444444444444444444444444444444444:did:arc:trader002"
)

echo "Will issue ${#EMPLOYEES[@]} licenses:"
echo ""
for emp in "${EMPLOYEES[@]}"; do
    IFS=':' read -r subdomain address credential <<< "$emp"
    echo "  - $subdomain.myhedgefund-v2.eth → $address"
done

echo ""
read -p "Continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 0
fi

echo ""
echo "Issuing licenses..."
echo "=========================================="

SUCCESS_COUNT=0
FAILED_COUNT=0

for emp in "${EMPLOYEES[@]}"; do
    IFS=':' read -r subdomain address credential <<< "$emp"
    
    echo ""
    echo "[$((SUCCESS_COUNT + FAILED_COUNT + 1))/${#EMPLOYEES[@]}] Issuing: $subdomain"
    echo "  Address: $address"
    echo "  Credential: $credential"
    
    # Issue license
    TX_OUTPUT=$(cast send "$LICENSE_MANAGER" \
        "issueLicense(address,string,string)" \
        "$address" \
        "$subdomain" \
        "$credential" \
        --rpc-url sepolia \
        --private-key $OWNER_PRIVATE_KEY \
        --gas-limit 500000 \
        --json 2>&1)
    
    if [[ $? -eq 0 ]] && [[ "$TX_OUTPUT" == *"transactionHash"* ]]; then
        TX_HASH=$(echo "$TX_OUTPUT" | jq -r '.transactionHash' 2>/dev/null)
        echo "  ✅ Success! TX: $TX_HASH"
        ((SUCCESS_COUNT++))
        
        # Wait for confirmation
        sleep 3
        
        # Verify
        HAS_LICENSE=$(cast call "$LICENSE_MANAGER" "hasValidLicense(address)(bool)" "$address" --rpc-url sepolia 2>&1)
        if [[ "$HAS_LICENSE" == "true" ]]; then
            echo "  ✅ Verified: License active"
        else
            echo "  ⚠️  Warning: License not detected (may need more time)"
        fi
    else
        echo "  ❌ Failed: $TX_OUTPUT"
        ((FAILED_COUNT++))
    fi
    
    # Rate limiting
    sleep 2
done

echo ""
echo "=========================================="
echo "Issuance Complete"
echo "=========================================="
echo ""
echo "Results:"
echo "  ✅ Successful: $SUCCESS_COUNT"
echo "  ❌ Failed: $FAILED_COUNT"
echo "  📊 Total: ${#EMPLOYEES[@]}"
echo ""

if [[ $SUCCESS_COUNT -gt 0 ]]; then
    echo "Checking all licenses..."
    echo ""
    for emp in "${EMPLOYEES[@]}"; do
        IFS=':' read -r subdomain address credential <<< "$emp"
        HAS_LICENSE=$(cast call "$LICENSE_MANAGER" "hasValidLicense(address)(bool)" "$address" --rpc-url sepolia 2>&1)
        if [[ "$HAS_LICENSE" == "true" ]]; then
            echo "  ✅ $subdomain.myhedgefund-v2.eth"
        else
            echo "  ❌ $subdomain (not found)"
        fi
    done
fi

echo ""
echo "Next steps:"
echo "1. Ask employees to set ENS reverse records"
echo "2. Test frontend with MetaMask"
echo "3. Run ./VERIFY_LICENSE.sh for each license"
echo ""
