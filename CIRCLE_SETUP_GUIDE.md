# 🔐 Circle Entity Secret Setup Guide

## Overview

The **Entity Secret** is a cryptographic key that secures Circle's developer-controlled wallets. This guide walks through generating and registering it.

---

## 📋 Prerequisites

1. **Circle Developer Account** - Register at https://console.circle.com
2. **Circle API Key** - Generate in your developer console
3. **Node.js** - v16+ installed locally
4. **npm** - Package manager

---

## 🚀 Step 1: Get Your Circle API Key

### A. Create Developer Account

1. Go to https://console.circle.com
2. Click **Sign Up** and create account
3. Verify email
4. Complete onboarding (KYC if needed for production)

### B. Generate API Key

1. In Circle Console, go to **Developer** → **API Credentials**
2. Click **Create API Key**
3. Choose scope: **Developer-Controlled Wallets** (at minimum)
4. Copy the generated key (format: `xxxx_API_KEY:yy...zz`)
5. **Keep this safe** - you'll only see it once!

---

## 🔧 Step 2: Install Circle SDK

The setup script uses the Circle SDK. Install it in your project:

```bash
cd /home/stevendaniell/BackUp/Dan/dansprojects/Eth-Online
npm install @circle-fin/developer-controlled-wallets
```

---

## ⚙️ Step 3: Run the Setup Script

### A. Set Environment Variable

Before running the script, export your Circle API key:

```bash
export CIRCLE_API_KEY="your_api_key_here"
```

**Example:**
```bash
export CIRCLE_API_KEY="20578535483303b3a5a6918cbc743174:2f15d4e4c7b669d78846d01c0bea2886"
```

### B. Run the Setup Script

```bash
npm run setup:circle-secret
```

**What happens:**
1. ✅ Generates a random 32-byte Entity Secret
2. ✅ Registers it with Circle (auto-encrypted)
3. ✅ Saves recovery file to `.circle-recovery/`
4. ✅ Outputs environment variables

---

## 📝 Step 4: Add to .env

The script will output something like:

```bash
============= ADD TO .env ==============

# Circle Entity Secret
CIRCLE_ENTITY_SECRET="ecd4d5e33b8e...c546"
CIRCLE_RECOVERY_FILE=".circle-recovery/entity-secret-recovery-1707276800000.json"
```

### A. Create .env file

Copy from `.env.example`:
```bash
cp .env.example .env
```

### B. Update the fields:

Edit `.env` and add:

```bash
# Circle Entity Secret (from setup script)
CIRCLE_ENTITY_SECRET="ecd4d5e33b8e...c546"
CIRCLE_RECOVERY_FILE=".circle-recovery/entity-secret-recovery-1707276800000.json"
CIRCLE_API_KEY="your_api_key_here"
```

---

## 🔒 Step 5: Secure Your Files

**⚠️ CRITICAL - Do this immediately:**

### A. Store Entity Secret Safely

```bash
# Option 1: Password Manager (Recommended)
# - 1Password
# - LastPass
# - Bitwarden
# - Dashlane

# Option 2: Secure Storage
# - Encrypted external drive
# - Hardware wallet backup
# - Offline encrypted file
```

### B. Store Recovery File Safely

```bash
# Move recovery file to separate secure location
mkdir -p ~/Secure/circle-backups
mv .circle-recovery/entity-secret-recovery-*.json ~/Secure/circle-backups/

# Update .env to point to this location
CIRCLE_RECOVERY_FILE="~/Secure/circle-backups/entity-secret-recovery-1707276800000.json"
```

### C. Update .gitignore

Create or update `.gitignore`:

```bash
# Circle sensitive files
.env
.env.local
.env.*.local
.circle-recovery/
```

---

## ✅ Verification

Test that everything is working:

```bash
# Check that .env is loaded
cd /home/stevendaniell/BackUp/Dan/dansprojects/Eth-Online
node -e "require('dotenv').config(); console.log('✓ CIRCLE_ENTITY_SECRET:', process.env.CIRCLE_ENTITY_SECRET ? 'SET' : 'MISSING')"
```

**Expected output:**
```
✓ CIRCLE_ENTITY_SECRET: SET
```

---

## 🐛 Troubleshooting

### Error: "CIRCLE_API_KEY not found"

**Fix:**
```bash
export CIRCLE_API_KEY="your_key_here"
npm run setup:circle-secret
```

### Error: "Circle SDK not installed"

**Fix:**
```bash
npm install @circle-fin/developer-controlled-wallets
npm run setup:circle-secret
```

### Error: "API request failed"

**Possible causes:**
- API key is wrong → Regenerate in Circle Console
- API key has insufficient permissions → Update scope to "Developer-Controlled Wallets"
- Network issue → Check internet connection
- Rate limited → Wait a few minutes and try again

### Recovery File Missing

**If lost:**
1. You'll need to reset your Entity Secret using the recovery file
2. If recovery file is also lost, you must generate a new Entity Secret:
   ```bash
   npm run setup:circle-secret
   ```
3. **Note:** Old wallets will not be accessible with a new Entity Secret

---

## 🔄 Rotating Entity Secret (Optional)

If you need to rotate your Entity Secret (good practice every 90 days):

```bash
npm run setup:circle-secret
```

Then update `.env` with the new values. Old wallets remain accessible with the new secret.

---

## 📚 Next Steps

After setting up Entity Secret:

1. **Create Developer-Controlled Wallets** - See Circle docs
2. **Integrate with PermitPool** - Add wallet creation to admin portal
3. **Link to ENS Licenses** - Store wallet addresses in license records
4. **Test Transactions** - Execute swaps and transfers

---

## ⚠️ Important Notes

- **Circle cannot recover lost Entity Secrets** - You are solely responsible
- **Each API request needs a fresh ciphertext** - SDK handles this automatically
- **Do not reuse ciphertexts** - Creates security vulnerabilities
- **Test thoroughly on testnet** - Before using with real funds
- **Monitor for unusual activity** - Set up alerts in Circle Console

---

## 📞 Support

- **Circle Docs:** https://developers.circle.com
- **Circle Support:** support@circle.com
- **GitHub Issues:** Report setup issues in project repo

---

## Summary

| Step | Action | Result |
|------|--------|--------|
| 1 | Create Circle account | Developer console access |
| 2 | Generate API key | Can authenticate with Circle |
| 3 | Install SDK | Can run setup script |
| 4 | Run setup script | Entity Secret generated & registered |
| 5 | Add to .env | Environment configured |
| 6 | Secure files | Files stored safely |
| 7 | Verify setup | Ready to use |

**Status: Ready to create developer-controlled wallets!** 🎉

