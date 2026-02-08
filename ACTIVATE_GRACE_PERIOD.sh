#!/bin/bash

# Register existing licenses with 30-day grace period
# This fixes the "Payment Overdue" issue for new/existing users

set -e

echo "🔄 Registering existing licenses with grace period..."
echo ""

# Build contracts first
echo "📦 Building contracts..."
forge build

echo ""
echo "📝 Deploying grace period for existing licenses..."
forge script script/RegisterExistingLicenses.s.sol:RegisterExistingLicensesScript \
    --rpc-url $RPC_URL \
    --broadcast \
    --slow \
    -vvv

echo ""
echo "✅ Done! All licenses now have 30-day grace period"
echo "🎉 No more \"Payment Overdue\" for new users!"
