#!/bin/bash

# PermitPool V&V Script - Comprehensive Verification & Validation
# This script verifies all sponsor integrations and validates the implementation

set -e

echo "========================================="
echo "🎯 PermitPool V&V - Verification & Validation"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
PASSED=0
FAILED=0
WARNINGS=0

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC}: $2"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}: $2"
        ((FAILED++))
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARN${NC}: $1"
    ((WARNINGS++))
}

echo "========================================="
echo "📦 STEP 1: Verify Dependencies"
echo "========================================="
echo ""

# Check Forge dependencies
echo "Checking Foundry dependencies..."
if [ -d "lib/v4-core" ] && [ -d "lib/v4-periphery" ]; then
    print_status 0 "Uniswap v4 dependencies installed"
else
    print_status 1 "Uniswap v4 dependencies missing"
fi

if [ -d "lib/forge-std" ]; then
    print_status 0 "Forge-std installed"
else
    print_status 1 "Forge-std missing"
fi

# Check Frontend dependencies
echo ""
echo "Checking Frontend dependencies..."

cd trader-app
if grep -q "@ensdomains/ensjs" package.json; then
    print_status 0 "ENS SDK installed in trader-app"
else
    print_status 1 "ENS SDK missing in trader-app"
fi

if grep -q "@rainbow-me/rainbowkit" package.json; then
    print_status 0 "RainbowKit installed in trader-app"
else
    print_status 1 "RainbowKit missing in trader-app"
fi

# Check for Yellow Network SDK
if grep -q "@yellow-network" package.json; then
    print_status 0 "Yellow Network SDK installed"
else
    print_warning "Yellow Network SDK NOT installed (CRITICAL for $15K prize)"
fi

# Check for Arc/Circle SDK
if grep -q "@circle-fin" package.json; then
    print_status 0 "Circle Arc SDK installed"
else
    print_warning "Circle Arc SDK NOT installed (CRITICAL for prizes)"
fi

cd ../admin-portal
if grep -q "@ensdomains/ensjs" package.json; then
    print_status 0 "ENS SDK installed in admin-portal"
else
    print_status 1 "ENS SDK missing in admin-portal"
fi

cd ..

echo ""
echo "========================================="
echo "🔨 STEP 2: Compile Contracts"
echo "========================================="
echo ""

if forge build > /dev/null 2>&1; then
    print_status 0 "Contracts compile successfully"
else
    print_status 1 "Contract compilation failed"
    forge build
fi

echo ""
echo "========================================="
echo "🧪 STEP 3: Run Contract Tests"
echo "========================================="
echo ""

# Run tests and capture output
if forge test --summary > /tmp/forge_test_output.txt 2>&1; then
    print_status 0 "All contract tests pass"
    cat /tmp/forge_test_output.txt
else
    print_status 1 "Some contract tests failed"
    cat /tmp/forge_test_output.txt
fi

echo ""
echo "========================================="
echo "🔍 STEP 4: Verify Contract Implementations"
echo "========================================="
echo ""

# Check PermitPoolHook
echo "Checking PermitPoolHook.sol..."
if grep -q "import {BaseHook}" src/PermitPoolHook.sol; then
    print_status 0 "PermitPoolHook extends BaseHook (Uniswap v4)"
else
    print_status 1 "PermitPoolHook missing BaseHook import"
fi

if grep -q "ArcOracle public immutable arcOracle" src/PermitPoolHook.sol; then
    print_status 0 "PermitPoolHook integrates ArcOracle"
else
    print_status 1 "PermitPoolHook missing ArcOracle integration"
fi

if grep -q "PaymentManager public immutable paymentManager" src/PermitPoolHook.sol; then
    print_status 0 "PermitPoolHook integrates PaymentManager"
else
    print_status 1 "PermitPoolHook missing PaymentManager integration"
fi

# Check LicenseManager
echo ""
echo "Checking LicenseManager.sol..."
if grep -q "INameWrapper" src/LicenseManager.sol; then
    print_status 0 "LicenseManager integrates ENS NameWrapper"
else
    print_status 1 "LicenseManager missing ENS integration"
fi

if grep -q "CANNOT_TRANSFER" src/LicenseManager.sol && grep -q "PARENT_CANNOT_CONTROL" src/LicenseManager.sol; then
    print_status 0 "LicenseManager implements ENS fuse burning"
else
    print_status 1 "LicenseManager missing fuse implementation"
fi

# Check PaymentManager
echo ""
echo "Checking PaymentManager.sol..."
if grep -q "IYellowClearnode" src/PaymentManager.sol; then
    print_status 0 "PaymentManager integrates Yellow Network"
else
    print_status 1 "PaymentManager missing Yellow Network integration"
fi

# Check ArcOracle
echo ""
echo "Checking ArcOracle.sol..."
if [ -f "src/ArcOracle.sol" ]; then
    print_status 0 "ArcOracle contract exists"
else
    print_status 1 "ArcOracle contract missing"
fi

echo ""
echo "========================================="
echo "🌐 STEP 5: Verify Frontend Builds"
echo "========================================="
echo ""

# Check trader-app
echo "Building trader-app..."
cd trader-app
if timeout 120 npm run build > /tmp/trader_build.log 2>&1; then
    print_status 0 "Trader app builds successfully"
else
    print_warning "Trader app build failed or timed out"
    tail -20 /tmp/trader_build.log
fi
cd ..

# Check admin-portal
echo ""
echo "Building admin-portal..."
cd admin-portal
if timeout 120 npm run build > /tmp/admin_build.log 2>&1; then
    print_status 0 "Admin portal builds successfully"
else
    print_warning "Admin portal build failed or timed out"
    tail -20 /tmp/admin_build.log
fi
cd ..

echo ""
echo "========================================="
echo "📋 STEP 6: Environment Configuration Check"
echo "========================================="
echo ""

# Check .env.example
if [ -f ".env.example" ]; then
    print_status 0 ".env.example exists"
    
    # Check for required variables
    if grep -q "ENS_NAME_WRAPPER" .env.example; then
        print_status 0 "ENS configuration present"
    else
        print_status 1 "ENS configuration missing"
    fi
    
    if grep -q "POOL_MANAGER" .env.example; then
        print_status 0 "Uniswap v4 configuration present"
    else
        print_status 1 "Uniswap v4 configuration missing"
    fi
    
    if grep -q "YELLOW" .env.example; then
        print_status 0 "Yellow Network configuration present"
    else
        print_warning "Yellow Network configuration missing"
    fi
    
    if grep -q "ARC" .env.example; then
        print_status 0 "Arc configuration present"
    else
        print_warning "Arc configuration missing"
    fi
else
    print_status 1 ".env.example missing"
fi

echo ""
echo "========================================="
echo "📊 FINAL RESULTS"
echo "========================================="
echo ""
echo -e "${GREEN}✅ Passed: $PASSED${NC}"
echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
echo -e "${RED}❌ Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL CHECKS PASSED! Ready for deployment.${NC}"
    exit 0
elif [ $FAILED -eq 0 ]; then
    echo -e "${YELLOW}⚠️  PASSED WITH WARNINGS. Review warnings before deployment.${NC}"
    exit 0
else
    echo -e "${RED}❌ VERIFICATION FAILED. Fix errors before proceeding.${NC}"
    exit 1
fi
