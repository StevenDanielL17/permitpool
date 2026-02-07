#!/bin/bash

# STOP ALL NODE PROCESSES
echo "🛑 Killing all node processes (admin/trader servers)..."
pkill -f "next" || true
pkill -f "node" || true
echo "✅ Ports 3000 and 3001 clear."

# SET ENV VARS
export LICENSE_MANAGER_ADDRESS=0x3620fc1df2b72a4d35c058175e5c3621caf8bb18
echo "📍 LicenseManager Address: $LICENSE_MANAGER_ADDRESS"

# CHECK ENV FILE
if [ ! -f .env ]; then
    echo "❌ .env file not found! Please create it with OWNER_PRIVATE_KEY."
    exit 1
fi

source .env

# RUN ENS APPROVAL
echo "🚀 Approving LicenseManager on ENS NameWrapper..."
forge script script/ApproveENS.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast

if [ $? -eq 0 ]; then
    echo "✅ ENS APPROVAL SUCCESSFUL!"
    echo "---------------------------------------------------"
    echo "🎉 FIX COMPLETE. NOW RUN THESE COMMANDS IN TWO TERMINALS:"
    echo "   1. npm run dev:admin   (Runs on http://localhost:3000)"
    echo "   2. npm run dev:trader  (Runs on http://localhost:3001)"
    echo "---------------------------------------------------"
    echo "⚠️  IMPORTANT: Disconnect your wallet from localhost and reconnect!"
else
    echo "❌ ENS Approval Failed. Check your RPC URL or Private Key."
fi
