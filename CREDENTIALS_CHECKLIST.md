# 📋 PERMITPOOL - CREDENTIALS & CONFIGURATION CHECKLIST

**Status Date:** February 6, 2026

---

## 🔐 CIRCLE / ARC KYC SETUP

### Required for: UNIT 2 (Arc KYC Integration)

- [ ] **Circle Developer Account Created**
  - URL: https://console.circle.com
  - Status: Created / Not started
  - Account Email: _________________

- [ ] **Circle API Key Generated**
  - Key: `20578535483303b3a5a6918cbc743174:2f15d4e4c7b669d78846d01c0bea2886`
  - Scope: Developer-Controlled Wallets
  - Status: ✅ Already in .env.example

- [ ] **Circle Entity Secret Generated**
  - Command: `npm run setup:circle-secret`
  - Secret: ________________________
  - Recovery File Location: ________________________
  - Status: Not started / In progress / Done

- [ ] **Update .env with Circle credentials**
  ```env
  CIRCLE_API_KEY=...
  CIRCLE_ENTITY_SECRET=...
  CIRCLE_RECOVERY_FILE=...
  ```
  - Status: Not started / Done

---

## 🟨 YELLOW NETWORK SETUP

### Required for: UNIT 1 (Yellow Network Auth & Payment)

- [ ] **Get Yellow Node URL**
  - Sandboxnet: `https://clearnet-sandbox.yellow.com`
  - Testnet: `https://testnet.yellow.org`
  - Production: `https://clearnet.yellow.com`
  - Choice: _________________
  - Status: Not started / Confirmed

- [ ] **USDC Contract Address (Sepolia)**
  - Already checked: `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238` ✅
  - Status: Confirmed

- [ ] **Monthly License Fee Amount**
  - USDC per month: _______ (e.g., 50, 100)
  - Status: Not started / Decided

- [ ] **Update .env with Yellow config**
  ```env
  YELLOW_NODE_URL=https://clearnet-sandbox.yellow.com
  YELLOW_CLEARNODE=0x...
  MONTHLY_FEE_USDC=50
  ```
  - Status: Not started / Done

---

## 🟢 ENS LICENSE SETUP

### Required for: UNIT 3 (ENS License Deployment)

- [ ] **Choose Parent ENS Domain**
  - Domain name: _________________________ (e.g., hedgefund.eth, permitpool.eth)
  - You must own this domain!
  - Status: Not owned / Owned / Need to register

- [ ] **ENS Domain Owner Wallet Address**
  - Owner: 0x________________________
  - Status: Not started / Identified

- [ ] **ENS NameWrapper Address (Sepolia)**
  - Already checked: `0x0635513f179D50A207757E05759CbD106d7dFcE8` ✅
  - Status: Confirmed

- [ ] **ENS Public Resolver Address (Sepolia)**
  - Already checked: `0x8FADE66B79cC9f707aB26799354482EB93a5B7dD` ✅
  - Status: Confirmed

- [ ] **Parent Node Namehash (Sepolia)**
  - Command: `namehash('your-domain.eth')`
  - Already available: `0x5c7ff35237c2a59c3cfa914cbc481abf5b6e11a7fae301b8290d0a0deed3deb9` (for fund.eth)
  - Your domain hash: 0x_________________________
  - Status: Not started / Calculated

- [ ] **Update .env with ENS config**
  ```env
  PARENT_DOMAIN_NAME=hedgefund.eth
  PARENT_NODE=0x...
  ENS_NAME_WRAPPER=0x0635513f179D50A207757E05759CbD106d7dFcE8
  ENS_RESOLVER=0x8FADE66B79cC9f707aB26799354482EB93a5B7dD
  ```
  - Status: Not started / Done

---

## 🟣 UNISWAP V4 SETUP

### Required for: UNIT 4 (Uniswap v4 Hook Deployment)

- [ ] **Uniswap v4 PoolManager Address (Sepolia)**
  - Already available: `0xE03A1074c86CFeDd5C142C4F04F1a1536e203543` ✅
  - Status: Confirmed

- [ ] **WETH Address (Sepolia)**
  - Already confirmed: `0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14` ✅
  - Status: Confirmed

- [ ] **USDC Address (Sepolia)**
  - Already confirmed: `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238` ✅
  - Status: Confirmed

- [ ] **Fee Tier for Pool**
  - Options: 3000 (0.3%), 10000 (1%)
  - Choice: _______ (recommend 10000 for institutional)
  - Status: Not decided / Decided

- [ ] **Update .env with Uniswap config**
  ```env
  POOL_MANAGER=0xE03A1074c86CFeDd5C142C4F04F1a1536e203543
  WETH_ADDRESS=0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14
  USDC_ADDRESS=0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
  POOL_FEE_TIER=10000
  ```
  - Status: Not started / Done

---

## 🎨 FRONTEND SETUP

### Required for: UNIT 5 (Frontend Integration)

- [ ] **Sepolia RPC URL**
  - Current: `https://eth-sepolia.g.alchemy.com/v2/pwne_tuyO5AK0JMS4_bvO` ✅
  - Status: Confirmed

- [ ] **Wallet Connect Project ID**
  - Current: `04ec8bbb09f06e737c85c0ff304f0945` ✅
  - Status: Confirmed

- [ ] **All Contract Addresses from Units 1-4**
  - From Unit 1 (Yellow): ❓ YELLOW_CLEARNODE
  - From Unit 2 (Arc): ❓ ARC_VERIFIER
  - From Unit 3 (ENS): ✅ Will deploy LicenseManager
  - From Unit 4 (Uniswap): ✅ PermitPoolHook + Pool addresses
  - Status: Waiting for deployments

- [ ] **Update .env with Frontend config**
  ```env
  NEXT_PUBLIC_SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/...
  NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=04ec8bbb09f06e737c85c0ff304f0945
  NEXT_PUBLIC_LICENSE_MANAGER=0x...
  NEXT_PUBLIC_PERMIT_POOL_HOOK=0x...
  NEXT_PUBLIC_ARC_VERIFIER=0x...
  NEXT_PUBLIC_YELLOW_CLEARNODE=0x...
  ```
  - Status: Not started / Waiting for deployments

---

## 🎯 EXECUTION ORDER

```
┌─ PHASE 1: Information Gathering ─┐
│ Gather all credentials above       │
│ Fill in this checklist             │
└──────────────────────────────────┘
         ↓
┌─ PHASE 2: Setup (Prerequisites) ─┐
│ □ Circle Entity Secret setup       │
│ □ Confirm ENS domain ownership     │
│ □ Verify Uniswap v4 availability   │
└──────────────────────────────────┘
         ↓
┌─ PHASE 3: Deployment ─────────────┐
│ UNIT 3 → ENS License               │
│ UNIT 4 → Uniswap v4 Hook           │
│ UNIT 1 → Yellow Network            │
│ UNIT 2 → Arc KYC                   │
│ UNIT 5 → Frontend                  │
└──────────────────────────────────┘
```

---

## 📊 PROGRESS TRACKING

### Credentials Status
| Item | Status | Verified |
|------|--------|----------|
| Circle API Key | ✅ Present | Yes |
| Circle Entity Secret | ⏳ Pending | No |
| Yellow Node URL | ⏳ Pending | No |
| ENS Parent Domain | ⏳ Pending | No |
| Uniswap PoolManager | ✅ Present | Yes |
| RPC URL | ✅ Present | Yes |
| WalletConnect ID | ✅ Present | Yes |

### Deployment Status
| Unit | Status | Completed |
|------|--------|-----------|
| UNIT 1 - Yellow | ⏳ Pending | 0% |
| UNIT 2 - Arc | ⏳ Pending | 0% |
| UNIT 3 - ENS | ⏳ Pending | 0% |
| UNIT 4 - Uniswap | ⏳ Pending | 0% |
| UNIT 5 - Frontend | ⏳ Pending | 0% |

---

## 🚀 Next Steps

1. **Print this checklist**
2. **Fill in the blanks** with your values
3. **Get missing credentials:**
   - Circle Entity Secret → Run `npm run setup:circle-secret`
   - ENS Domain → Register on ens.domains
   - Yellow credentials → Get from Yellow Network console
4. **Update .env** with all values
5. **Run Unit 3** → ENS deployment
6. **Continue sequentially** through Units 4, 1, 2, 5

---

## 💾 Files to Update

After gathering credentials, update:

```
.env ← Add all credentials here
.env.example ← Template (already updated)
```

**Never commit .env to git!** ✅ Already in .gitignore

---

## ✨ STATUS

- [ ] Checklist complete
- [ ] All credentials gathered
- [ ] .env file updated
- [ ] Ready to start Unit 3 (ENS)

**Current Status:** ⏳ Waiting for your input

