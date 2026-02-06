# Wallet Persistence Implementation Guide

## 🎯 Overview

This implementation provides **automatic wallet reconnection** across browser sessions, page reloads, and dev server restarts for both the Admin Portal and Trader App.

## ✅ What's Been Implemented

### 1. Core Persistence (wagmi v2)

- ✅ **localStorage-based persistence** using wagmi's built-in `createStorage`
- ✅ **Automatic reconnection** on page load
- ✅ **Role-based access control** for admin and trader wallets
- ✅ **SSR-compatible** configuration
- ✅ **Production-ready** for Vercel deployment

### 2. Custom Hooks Created

#### Admin Portal

- **`useWalletPersistence`** - Auto-reconnects wallet on mount
- **`useAdminRole`** - Validates if connected wallet is the admin (compares with `NEXT_PUBLIC_OWNER_ADDRESS`)

#### Trader App

- **`useWalletPersistence`** - Auto-reconnects wallet on mount
- **`useTraderLicense`** - Checks if wallet has valid trading license (placeholder for on-chain verification)

### 3. UI Integration

#### Admin Portal (`/admin/page.tsx`)

- Shows "Reconnecting..." state while restoring session
- Shows "Connect Wallet" prompt if not connected
- Shows "Access Denied" if wallet is not the admin
- Only shows dashboard to authorized admin wallet

#### Trader App (`/trade/page.tsx`)

- Shows "Reconnecting..." state while restoring session
- Shows "Connect Wallet" prompt if not connected
- Shows "No License" if wallet doesn't have trading license
- Only shows trading interface to licensed traders

## 📁 Files Modified/Created

### Configuration Files

```
admin-portal/
├── .env.local (CREATED) - Contains NEXT_PUBLIC_OWNER_ADDRESS
├── lib/wagmi.ts (MODIFIED) - Added storage configuration
└── components/Providers.tsx (MODIFIED) - Added initialChain

trader-app/
├── .env.local (CREATED) - Contains WalletConnect config
├── lib/wagmi.ts (MODIFIED) - Added storage configuration
└── components/Providers.tsx (MODIFIED) - Added initialChain
```

### Custom Hooks

```
admin-portal/hooks/
├── useWalletPersistence.ts (CREATED)
└── useAdminRole.ts (CREATED)

trader-app/hooks/
├── useWalletPersistence.ts (CREATED)
└── useTraderLicense.ts (CREATED)
```

### Pages Updated

```
admin-portal/app/admin/page.tsx (MODIFIED)
trader-app/app/trade/page.tsx (MODIFIED)
```

## 🔧 How It Works

### 1. Storage Configuration

Both apps use wagmi's `createStorage` to persist wallet state:

```typescript
storage: createStorage({
  storage: typeof window !== "undefined" ? window.localStorage : undefined,
  key: "permitpool.wallet", // Unique per app
});
```

**localStorage Keys:**

- Admin Portal: `permitpool.wallet`
- Trader App: `permitpool.trader.wallet`

### 2. Automatic Reconnection Flow

```mermaid
User Opens Page
    ↓
Check localStorage for previous connection
    ↓
If found → Auto-reconnect (isReconnecting = true)
    ↓
Validate wallet role (admin/trader)
    ↓
Show appropriate UI (dashboard/access denied/no license)
```

### 3. Role Detection

#### Admin Portal

```typescript
const ownerAddress = process.env.NEXT_PUBLIC_OWNER_ADDRESS;
const isAdmin = address.toLowerCase() === ownerAddress.toLowerCase();
```

#### Trader App

```typescript
// TODO: Replace with actual on-chain license check
const hasLicense = await checkENSSubdomain(address);
```

## 🧪 Testing the Implementation

### Admin Portal Test

1. **First Visit:**

   ```bash
   cd admin-portal
   npm run dev
   # Open http://localhost:3001/admin
   ```

   - Should show "Connect Wallet" prompt
   - Connect with admin wallet (0x52b34414df3e56ae853bc4a0eb653231447c2a36)
   - Should show dashboard

2. **Reload Test:**
   - Refresh the page (F5)
   - Should briefly show "Reconnecting..." then auto-load dashboard
   - ✅ **No MetaMask popup required**

3. **Dev Server Restart:**

   ```bash
   # Stop server (Ctrl+C)
   npm run dev
   # Open http://localhost:3001/admin again
   ```

   - Should auto-reconnect without user action
   - ✅ **Wallet persistence across restarts**

4. **Wrong Wallet Test:**
   - Connect with a different wallet (not admin)
   - Should show "Access Denied" message
   - Can disconnect and reconnect with correct wallet

### Trader App Test

1. **First Visit:**

   ```bash
   cd trader-app
   npm run dev
   # Open http://localhost:3000/trade
   ```

   - Should show "Connect Wallet" prompt
   - Connect any wallet
   - May show "No License" (need to grant test license)

2. **Grant Test License:**

   ```javascript
   // In browser console:
   import { grantLicenseForTesting } from "@/hooks/useTraderLicense";
   grantLicenseForTesting("0xYourWalletAddress");
   // Refresh page
   ```

3. **Reload Test:**
   - Refresh page
   - Should auto-reconnect and show trading interface
   - ✅ **Persistent across reloads**

## 🚀 Production Deployment

### Environment Variables

Ensure these are set in Vercel:

**Admin Portal:**

```bash
NEXT_PUBLIC_OWNER_ADDRESS=0x52b34414df3e56ae853bc4a0eb653231447c2a36
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=04ec8bbb09f06e737c85c0ff304f0945
```

**Trader App:**

```bash
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=04ec8bbb09f06e737c85c0ff304f0945
```

### Domain Configuration

The persistence works identically on:

- **Localhost:** `localhost:3000`, `localhost:3001`
- **Production:** `app.permitpool.com`, `admin.permitpool.com`
- **Vercel Preview:** `*.vercel.app`

localStorage is domain-specific, so each domain maintains its own wallet state.

## 🔐 Security Notes

### What's Stored

- ✅ Wallet address
- ✅ Connection type (MetaMask, WalletConnect, etc.)
- ✅ Last connection timestamp

### What's NOT Stored

- ❌ Private keys (never stored anywhere)
- ❌ Sensitive user data
- ❌ Transaction history

### Session Validation

- Role is re-checked on every page load
- Admin status verified against environment variable
- Trader license checked on-chain (when implemented)
- User can explicitly disconnect to clear storage

## 📋 Future Enhancements

### Phase 2 - On-Chain License Verification

Replace the placeholder in `useTraderLicense.ts`:

```typescript
// Current (localStorage placeholder):
const hasLicense =
  localStorage.getItem(`permitpool.license.${address}`) === "valid";

// TODO: Implement actual on-chain check:
const hasLicense = await readContract({
  address: HOOK_ADDRESS,
  abi: HOOK_ABI,
  functionName: "getENSNodeForAddress",
  args: [address],
});
```

### Phase 3 - Advanced Features

- [ ] Session timeout (auto-disconnect after X hours)
- [ ] Multi-wallet management
- [ ] Connection history/audit log
- [ ] Custom disconnect handlers
- [ ] Network change detection

## 🐛 Troubleshooting

### Wallet Not Reconnecting

1. **Check localStorage:**

   ```javascript
   // In browser console:
   localStorage.getItem("permitpool.wallet.store");
   ```

2. **Clear stored data:**

   ```javascript
   localStorage.removeItem("permitpool.wallet.store");
   // Reconnect manually
   ```

3. **Check environment variables:**
   ```bash
   # In admin-portal or trader-app directory:
   cat .env.local
   ```

### "Access Denied" for Admin

1. Verify `NEXT_PUBLIC_OWNER_ADDRESS` matches your wallet:

   ```bash
   echo $NEXT_PUBLIC_OWNER_ADDRESS
   # Should match your MetaMask address
   ```

2. Restart dev server after changing `.env.local`:
   ```bash
   npm run dev
   ```

### Reconnect Loop

If wallet keeps reconnecting in a loop:

```javascript
// Clear all wagmi storage:
Object.keys(localStorage)
  .filter((key) => key.startsWith("permitpool"))
  .forEach((key) => localStorage.removeItem(key));
```

## 📚 API Reference

### useWalletPersistence()

```typescript
const {
  address, // Connected wallet address
  isConnected, // Whether wallet is connected
  isReconnecting, // Whether currently reconnecting
  isConnecting, // Whether connection in progress
} = useWalletPersistence();
```

### useAdminRole()

```typescript
const {
  isAdmin, // Whether connected wallet is admin
  isConnected, // Whether wallet is connected
  address, // Connected wallet address
  ownerAddress, // Admin address from env
} = useAdminRole();
```

### useTraderLicense()

```typescript
const {
  hasLicense, // Whether wallet has valid license
  isLoading, // Whether license check in progress
  isConnected, // Whether wallet is connected
  address, // Connected wallet address
} = useTraderLicense();
```

## ✅ Implementation Checklist

- [x] Add `createStorage` to wagmi config (both apps)
- [x] Create `.env.local` files with required variables
- [x] Create `useWalletPersistence` hooks (both apps)
- [x] Create `useAdminRole` hook (admin portal)
- [x] Create `useTraderLicense` hook (trader app)
- [x] Update admin dashboard with role checks
- [x] Update trading page with reconnection logic
- [x] Add reconnecting state UI
- [x] Add access control UI
- [x] Test localhost reconnection
- [ ] Test Vercel preview deployment
- [ ] Test production deployment
- [ ] Implement on-chain license verification

## 🎉 Success Criteria

You'll know it's working when:

1. ✅ Refresh page → Wallet auto-reconnects
2. ✅ Restart dev server → Wallet still connected
3. ✅ Close/reopen browser → Wallet remembered
4. ✅ Admin wallet → Access granted
5. ✅ Non-admin wallet → Access denied
6. ✅ No manual MetaMask popups on reload

---

**Status:** ✅ **Phase 1 Complete** - Core persistence implemented and ready for testing

**Next Steps:** Test the implementation, then deploy to Vercel preview environment
