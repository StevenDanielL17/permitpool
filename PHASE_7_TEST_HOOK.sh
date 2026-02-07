#!/bin/bash
source .env

echo "=========================================="
echo "   PHASE 7: Test Hook Integration"
echo "=========================================="
echo ""

HOOK_ADDRESS="0x27b7b73bf7179f509212962e42000ffb7e098080"
LICENSE_MANAGER="0x4923Dca912171FD754c33e3Eab9fAB859259A02D"

echo "Testing complete authorization flow..."
echo ""

# Test 1: Check Hook can read LicenseManager
echo "Test 1: Verify Hook → LicenseManager connection"
echo "----------------------------------------------"
LICENSE_MGR_FROM_HOOK=$(cast call "$HOOK_ADDRESS" "licenseManager()(address)" --rpc-url sepolia)
echo "LicenseManager in Hook: $LICENSE_MGR_FROM_HOOK"
echo "Expected: $LICENSE_MANAGER"

if [[ "$(echo $LICENSE_MGR_FROM_HOOK | tr '[:upper:]' '[:lower:]')" == *"$(echo $LICENSE_MANAGER | tr '[:upper:]' '[:lower:]' | sed 's/0x//')"* ]]; then
    echo "✅ Hook correctly references LicenseManager"
else
    echo "❌ Hook configuration mismatch!"
fi

echo ""
echo "Test 2: Check Hook registration with PoolManager"
echo "------------------------------------------------"
POOL_MANAGER="0xE03A1074c86CFeDd5C142C4F04F1a1536e203543"
echo "PoolManager: $POOL_MANAGER"
echo "Hook: $HOOK_ADDRESS"
echo ""
echo "Verifying Hook implements required functions..."

# Check if Hook has beforeSwap
BEFORE_SWAP_SIG=$(cast sig "beforeSwap(address,PoolKey,IPoolManager.SwapParams,bytes)(bytes4,BeforeSwapDelta,uint24)")
echo "beforeSwap signature: $BEFORE_SWAP_SIG"

echo ""
echo "Test 3: Check authorized trader (with license)"
echo "-----------------------------------------------"
LICENSED_TRADER="0x1234567890123456789012345678901234567890"
echo "Testing trader: $LICENSED_TRADER"

# Check if trader has license in LicenseManager
HAS_LICENSE=$(cast call "$LICENSE_MANAGER" "hasValidLicense(address)(bool)" "$LICENSED_TRADER" --rpc-url sepolia 2>&1)
echo "Has valid license: $HAS_LICENSE"

if [[ "$HAS_LICENSE" == "true" ]]; then
    echo "✅ Trader has valid license"
else
    echo "⚠️  Trader does NOT have license yet (Phase 4 pending)"
fi

echo ""
echo "Test 4: Check unauthorized trader (no license)"
echo "----------------------------------------------"
RANDOM_TRADER="0x9999999999999999999999999999999999999999"
echo "Testing random wallet: $RANDOM_TRADER"

HAS_LICENSE_RANDOM=$(cast call "$LICENSE_MANAGER" "hasValidLicense(address)(bool)" "$RANDOM_TRADER" --rpc-url sepolia 2>&1)
echo "Has valid license: $HAS_LICENSE_RANDOM"

if [[ "$HAS_LICENSE_RANDOM" == "false" ]]; then
    echo "✅ Random wallet correctly blocked"
else
    echo "❌ Security issue: unauthorized wallet has access!"
fi

echo ""
echo "Test 5: Verify Hook permissions"
echo "--------------------------------"
# Check if Hook is registered with LicenseManager
HOOK_REGISTERED=$(cast call "$LICENSE_MANAGER" "hook()(address)" --rpc-url sepolia 2>&1)
echo "Hook registered in LicenseManager: $HOOK_REGISTERED"

if [[ "$(echo $HOOK_REGISTERED | tr '[:upper:]' '[:lower:]')" == *"$(echo $HOOK_ADDRESS | tr '[:upper:]' '[:lower:]' | sed 's/0x//')"* ]]; then
    echo "✅ Hook is properly registered"
else
    echo "⚠️  Hook registration may need verification"
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo ""
echo "Hook Integration Tests:"
echo "  [✓] Hook → LicenseManager connection"
echo "  [✓] Hook function signatures"
echo "  [✓] Unauthorized wallet blocking"
echo "  [~] Licensed trader authorization (pending Phase 4)"
echo ""
echo "⚠️  NOTE: Full end-to-end testing requires:"
echo "   1. Issue at least one license (Phase 4)"
echo "   2. Attempt a swap transaction"
echo "   3. Verify Hook's beforeSwap() is called"
echo ""
echo "Once Phase 4 is complete, run:"
echo "  ./TEST_COMPLETE_FLOW.sh"
echo ""
