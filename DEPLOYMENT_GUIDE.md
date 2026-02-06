# 🚀 Deployment Guide - Completing the Setup

The deployment script is currently running or ready to run. Once it completes, you will see a list of **Deployed Addresses** in the terminal output.

## 📝 Step 1: Capture Deployed Addresses

Look for output similar to this:

```text
== Logs ==
  MockYellowClearnode deployed at: 0x...
  MockArcVerifier deployed at: 0x...
  ArcOracle deployed at: 0x123...             <-- COPY THIS
  PaymentManager deployed at: 0x456...        <-- COPY THIS
  PermitPoolHook deployed at: 0x789...        <-- COPY THIS
  LicenseManager deployed at: 0xabc...        <-- COPY THIS
```

## ⚙️ Step 2: Update Environment Variables

You need to update **3 files** with these new addresses.

### 1. Root `.env`

```bash
HOOK_ADDRESS=0x789...
LICENSE_MANAGER_ADDRESS=0xabc...
ARC_ORACLE_ADDRESS=0x123...
PAYMENT_MANAGER_ADDRESS=0x456...
```

### 2. `admin-portal/.env.local`

```bash
NEXT_PUBLIC_HOOK_ADDRESS=0x789...
NEXT_PUBLIC_LICENSE_MANAGER_ADDRESS=0xabc...
NEXT_PUBLIC_ARC_ORACLE_ADDRESS=0x123...
NEXT_PUBLIC_PAYMENT_MANAGER_ADDRESS=0x456...
```

### 3. `trader-app/.env.local`

```bash
NEXT_PUBLIC_HOOK_ADDRESS=0x789...
NEXT_PUBLIC_LICENSE_MANAGER_ADDRESS=0xabc...
NEXT_PUBLIC_ARC_ORACLE_ADDRESS=0x123...
NEXT_PUBLIC_PAYMENT_MANAGER_ADDRESS=0x456...
```

## 🔄 Step 3: Restart Servers

After updating the files, restart your development servers to load the new config:

```bash
# In admin-portal terminal
Ctrl+C
npm run dev -- -p 3001

# In trader-app terminal
Ctrl+C
npm run dev -- -p 3000
```

## 🧪 Verification

1. Go to **Admin Portal** > **Issue License**.
2. Complete KYC (Arc Mock).
3. Approve transaction.
4. **Success!** The license is now created on-chain with strict Arc verification.

## ⚠️ Troubleshooting

- **Script hangs?** It might be mining the hook salt (can take 1-2 mins).
- **"Insufficient funds"?** You need Sepolia ETH. Get some from a faucet.
- **"Gas limit error"?** We fixed this! The new contracts use optimized gas settings.

### Manual Verification

Check your LicenseManager on Etherscan (Sepolia) to see the `issueLicense` transaction success.
