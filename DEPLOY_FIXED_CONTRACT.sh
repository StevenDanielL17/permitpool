#!/bin/bash
# Deploy the fixed LicenseManager contract

cd /home/stevendaniell/BackUp/Dan/dansprojects/Eth-Online

echo "=== Deploying Fixed Contracts ==="
echo "Date: $(date)"
echo ""

forge script script/Deploy.s.sol:DeployScript \
  --rpc-url sepolia \
  --broadcast \
  --legacy \
  -vvv

echo ""
echo "=== Deployment Complete ==="
echo "Check broadcast/Deploy.s.sol/11155111/run-latest.json for addresses"
