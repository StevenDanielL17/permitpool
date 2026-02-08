#!/bin/bash
source .env

echo "================================================"
echo "  COMPREHENSIVE STATUS REPORT"
echo "  New Domain: hedgefund-protocol-v1.eth"
echo "================================================"

NEW_NODE="0x6a4403046019d822c581cd292ff862fb84293969ffc588d61d3964412c73f2ae"

echo ""
echo "===== DOMAIN ANALYSIS ====="
echo ""

echo "[1] Ownership Status"
OWNER=$(cast call 0x0635513f179d50a207757e05759cbd106d7dfce8 \
  "ownerOf(uint256)" \
  $NEW_NODE \
  --rpc-url $SEPOLIA_RPC_URL)
echo "  Raw owner: $OWNER"
echo "  Contract:  $LICENSE_MANAGER"
if [[ "${OWNER,,}" == *"${LICENSE_MANAGER:2,,}"* ]]; then
    echo "  ✅ CONTRACT OWNS DOMAIN"
else
    echo "  ❌ Ownership mismatch"
fi

echo ""
echo "[2] Fuse Analysis"
DATA=$(cast call 0x0635513f179d50a207757e05759cbd106d7dfce8 \
  "getData(uint256)" \
  $NEW_NODE \
  --rpc-url $SEPOLIA_RPC_URL)

python3 << EOF
data = "$DATA"
fuses_hex = data[66:74]  # bytes 32-36 (uint32 fuses)
fuses = int(fuses_hex, 16) if fuses_hex else 0

print(f"  Fuses value: 0x{fuses:x} ({fuses})")
print(f"  CANNOT_UNWRAP: {bool(fuses & 0x1)}")
print(f"  CANNOT_BURN_FUSES: {bool(fuses & 0x2)}")
print(f"  CANNOT_TRANSFER: {bool(fuses & 0x4)}")
print()
if fuses == 0:
    print("  ✅ CLEAN DOMAIN - NO FUSES SET!")
elif fuses & 0x2:
    print("  ❌ CANNOT_BURN_FUSES blocks subdomain creation")
else:
    print("  ⚠️  Some fuses set but CANNOT_BURN_FUSES is clear")
EOF

echo ""
echo "===== LICENSE TESTING ====="
echo ""

TEST_ADDRESSES=("0x1111111111111111111111111111111111111111" "0x2222222222222222222222222222222222222222")
for ADDR in "${TEST_ADDRESSES[@]}"; do
    echo "Testing: $ADDR"
    HAS_LICENSE=$(cast call $LICENSE_MANAGER \
      "hasValidLicense(address)(bool)" \
      $ADDR \
      --rpc-url $SEPOLIA_RPC_URL 2>&1)
    
    if [ "$HAS_LICENSE" = "true" ]; then
        echo "  ✅ HAS VALID LICENSE!"
        # Get subdomain details
        SUBDOMAIN_NODE=$(cast call $LICENSE_MANAGER \
          "addressToLicense(address)(bytes32)" \
          $ADDR \
          --rpc-url $SEPOLIA_RPC_URL 2>&1)
        echo "  License node: $SUBDOMAIN_NODE"
        
        # Check subdomain ownership in NameWrapper
        SUBDOMAIN_OWNER=$(cast call 0x0635513f179d50a207757e05759cbd106d7dfce8 \
          "ownerOf(uint256)" \
          $SUBDOMAIN_NODE \
          --rpc-url $SEPOLIA_RPC_URL 2>&1)
        echo "  Subdomain owner: $SUBDOMAIN_OWNER"
    else
        echo "  ⏳ No license (error or pending: ${HAS_LICENSE:0:50})"
    fi
    echo ""
done

echo "===== TRANSACTION STATUS ====="
echo ""
NONCE=$(cast nonce $OWNER_ADDRESS --rpc-url $SEPOLIA_RPC_URL)
echo "  Current nonce: $NONCE"
echo "  (Started at ~258, now at $NONCE)"

echo ""
echo "================================================"
echo "  SUMMARY"
echo "================================================"

# Final determination
if [[ "${OWNER,,}" == *"${LICENSE_MANAGER:2,,}"* ]]; then
    echo "✅ Domain transfer: SUCCESS"
else
    echo "❌ Domain transfer: FAILED"
fi

python3 << EOF
data = "$DATA"
fuses_hex = data[66:74]
fuses = int(fuses_hex, 16) if fuses_hex else 0
if fuses == 0:
    print("✅ Domain fuses: CLEAN (0x0)")
elif fuses & 0x2:
    print("❌ Domain fuses: BLOCKED (CANNOT_BURN_FUSES)")
else:
    print("⚠️  Domain fuses: PARTIAL (0x%x)" % fuses)
EOF

# Check if any license succeeded
ANY_SUCCESS=false
for ADDR in "${TEST_ADDRESSES[@]}"; do
    HAS_LICENSE=$(cast call $LICENSE_MANAGER \
      "hasValidLicense(address)(bool)" \
      $ADDR \
      --rpc-url $SEPOLIA_RPC_URL 2>&1)
    if [ "$HAS_LICENSE" = "true" ]; then
        ANY_SUCCESS=true
        break
    fi
done

if [ "$ANY_SUCCESS" = true ]; then
    echo "✅ License issuance: WORKS!"
    echo ""
    echo "🎉🎉🎉 COMPLETE SUCCESS! 🎉🎉🎉"
    echo ""
    echo "Your license issuance system is FULLY OPERATIONAL!"
    echo "You can now:"
    echo "  1. Update the admin portal"
    echo "  2. Integrate with Arc verification"
    echo "  3. Deploy to production"
else
    echo "⏳ License issuance: PENDING (check again in 30s)"
    echo ""
    echo "Run this script again after transactions confirm."
fi

echo "================================================"
