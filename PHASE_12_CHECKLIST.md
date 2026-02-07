# Phase 12: Production Deployment Checklist

## ✅ Pre-Deployment Testing

### Smart Contract Testing
- [ ] All unit tests pass (`forge test`)
- [ ] Integration tests pass
- [ ] Gas optimization completed
- [ ] No critical compiler warnings
- [ ] Contract sizes under 24KB limit

### License System Testing  
- [ ] Can issue licenses successfully
- [ ] Can revoke licenses
- [ ] hasValidLicense() works correctly
- [ ] Hook correctly reads license status
- [ ] Unauthorized wallets are blocked

### ENS Integration Testing
- [ ] ENS names resolve correctly
- [ ] Reverse records work (address → name)
- [ ] Subdomain creation works
- [ ] NameWrapper permissions correct

### Frontend Testing
- [ ] MetaMask connection works
- [ ] ENS name detection works
- [ ] License status displays correctly
- [ ] Swap interface functional
- [ ] Admin functions work (if applicable)

---

## 🔒 Security Review

- [ ] **Run Slither static analysis**
  ```bash
  pip install slither-analyzer
  slither src/
  ```

- [ ] **Check for common vulnerabilities:**
  - [ ] Reentrancy guards in place
  - [ ] Access control on admin functions
  - [ ] No unchecked external calls
  - [ ] Integer overflow protection (Solidity 0.8+)
  - [ ] Front-running mitigation

- [ ] **Review critical functions:**
  - [ ] `issueLicense()` - only admin can call
  - [ ] `revokeLicense()` - only admin can call
  - [ ] `hasValidLicense()` - view function, no state changes
  - [ ] Hook's `beforeSwap()` - properly checks licenses

- [ ] **Optional: Professional audit**
  - Consider audit if handling significant value
  - Estimated cost: $5,000-$50,000
  - Platforms: OpenZeppelin, Consensys Diligence, Trail of Bits

---

## 💰 Cost Analysis

### Sepolia Testnet (Current)
- ENS domain registration: FREE (testnet)
- Contract deployment: ~0.05-0.1 test ETH
- License issuance: ~0.001-0.005 test ETH per license
- Swap gas: ~150,000-300,000 gas

### Mainnet Costs (Estimated)
- ENS domain registration: $5-50/year (e.g., "mycompany.eth")
- Contract deployment: $200-500 (varies with gas price)
- License issuance: $10-30 per license
- Swap gas: $5-15 per swap (at 50 gwei)

**Budget for 100 employees:**
- Initial: ~$3,000-5,000
- Annual: ~$1,000-3,000 (new licenses + operations)

---

## 🌐 Mainnet Deployment Steps

### 1. Prepare Mainnet ENS Domain
```bash
# Option A: Use existing domain you own
# Option B: Register new domain at app.ens.domains

# Ensure domain does NOT have PARENT_CANNOT_CONTROL fuse
# Check fuses before using
```

### 2. Update Configuration
```bash
# .env for mainnet
MAINNET_RPC_URL="https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY"
OWNER_PRIVATE_KEY="0x..." # Use hardware wallet in production!
PARENT_NODE="0x..." # Your mainnet ENS node
```

### 3. Deploy Contracts
```bash
# Deploy to mainnet
forge script script/Deploy.s.sol \
  --rpc-url mainnet \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY

# WAIT for Etherscan verification to complete
```

### 4. Verify Deployment
```bash
# Check all contract addresses
# Verify on Etherscan
# Test with small transactions first
```

### 5. Issue Test License
```bash
# Issue ONE license to your own wallet first
# Test complete flow
# Verify everything works before mass issuance
```

---

## 👥 Employee Onboarding Process

### For Each New Employee:

1. **Get their Ethereum address**
   - They install MetaMask
   - Share their address: `0x...`

2. **Issue license from admin wallet**
   ```bash
   cast send $LICENSE_MANAGER \
     "issueLicense(address,string,string)" \
     EMPLOYEE_ADDRESS \
     "firstname-lastname" \
     "did:arc:credential-hash" \
     --rpc-url mainnet \
     --private-key $ADMIN_KEY
   ```

3. **Employee sets reverse record**
   - Go to app.ens.domains
   - Connect wallet
   - Set primary name to `firstname-lastname.mycompany.eth`

4. **Verify access**
   - Employee connects to your frontend
   - Tests a small swap
   - Confirms everything works

---

## 🔧 Maintenance & Monitoring

### Regular Tasks
- [ ] Monitor contract balances
- [ ] Check for failed transactions
- [ ] Review license issuance logs
- [ ] Update employee list
- [ ] Renew ENS domain annually

### Emergency Procedures
- [ ] **License revocation process documented**
  ```bash
  cast send $LICENSE_MANAGER \
    "revokeLicense(address)" \
    EMPLOYEE_ADDRESS \
    --rpc-url mainnet \
    --private-key $ADMIN_KEY
  ```

- [ ] **Backup admin keys secured**
  - Store in hardware wallet
  - Use multi-sig for added security
  - Keep offline backup of recovery phrase

- [ ] **Incident response plan**
  - Who to contact if issues arise
  - How to pause trading if needed
  - Communication protocol

### Monitoring Setup
```javascript
// Example: Monitor license issuance events
const filter = licenseManager.filters.LicenseIssued();
licenseManager.on(filter, (licensee, subdomain, node, credential) => {
    console.log(`New license: ${subdomain} → ${licensee}`);
    // Send notification, update database, etc.
});
```

---

## 📊 Analytics & Reporting

### Key Metrics to Track
- [ ] Number of active licenses
- [ ] Number of swaps per day/week
- [ ] Gas costs per transaction
- [ ] Failed swap attempts (unauthorized)
- [ ] License revocations

### Dashboard Ideas
- Current licensed traders
- Swap volume by trader
- Gas costs over time
- Authorization failures (security monitoring)

---

## 🚀 Go-Live Checklist

**Final verification before production:**

- [ ] All tests passing on mainnet testnet (Sepolia)
- [ ] Security review completed
- [ ] Admin wallet secured (hardware wallet)
- [ ] Backup admin designated
- [ ] ENS domain registered and configured
- [ ] Contracts deployed to mainnet
- [ ] Contracts verified on Etherscan
- [ ] Frontend deployed and tested
- [ ] Employee onboarding process documented
- [ ] At least 2 test licenses issued and verified
- [ ] Emergency procedures documented
- [ ] Monitoring setup
- [ ] Team trained on system operation

---

## 📝 Documentation Requirements

### For Operations Team
- [ ] How to issue a license
- [ ] How to revoke a license
- [ ] How to check license status
- [ ] Emergency procedures
- [ ] Troubleshooting guide

### For Employees
- [ ] How to install MetaMask
- [ ] How to connect their wallet
- [ ] How to check their license
- [ ] How to execute swaps
- [ ] FAQ / Support contact

### For Developers
- [ ] Contract architecture diagram
- [ ] API documentation
- [ ] Deployment process
- [ ] Testing procedures
- [ ] Code repository access

---

## 🎯 Success Metrics

After 1 month in production:
- [ ] Zero security incidents
- [ ] <1% failed authorization attempts
- [ ] Average gas cost within budget
- [ ] All employees successfully onboarded
- [ ] <1 hour response time for issues
- [ ] Zero unplanned downtime

---

## Next Steps After Go-Live

1. **Gather feedback** from first users
2. **Monitor gas costs** and optimize if needed
3. **Add features** based on usage patterns:
   - License expiration dates
   - Tiered access levels
   - Analytics dashboard
   - Mobile app support
4. **Scale** to more employees
5. **Consider** additional DeFi integrations

---

## Emergency Contacts

- **Smart Contract Issues**: [Your dev team]
- **ENS Problems**: ENS Discord / Support
- **Alchemy RPC Issues**: support@alchemy.com
- **MetaMask Support**: support@metamask.io

---

**Remember:** Start small, test thoroughly, and scale gradually. DeFi is unforgiving of mistakes!
