# 🚀 PermitPool Quick Start Guide

## Running Both Applications

### **Option 1: Two Separate Terminals (Recommended)**

#### Terminal 1 - Trader App:

```bash
cd /home/stevendaniell/BackUp/Dan/dansprojects/Eth-Online/trader-app
npm run dev
```

**Access at:** http://localhost:3000

#### Terminal 2 - Admin Portal:

```bash
cd /home/stevendaniell/BackUp/Dan/dansprojects/Eth-Online/admin-portal
npm run dev -- -p 3001
```

**Access at:** http://localhost:3001

---

### **Option 2: Single Command (Using tmux or screen)**

```bash
# Start both in background
cd /home/stevendaniell/BackUp/Dan/dansprojects/Eth-Online

# Trader App
cd trader-app && npm run dev &

# Admin Portal
cd ../admin-portal && npm run dev -- -p 3001 &
```

---

## 📱 Application URLs

### **Trader App** (Port 3000)

- Homepage: http://localhost:3000
- Dashboard: http://localhost:3000/dashboard
- Portfolio: http://localhost:3000/portfolio
- Trade: http://localhost:3000/trade
- Transactions: http://localhost:3000/transactions

### **Admin Portal** (Port 3001)

- Landing: http://localhost:3001
- Dashboard: http://localhost:3001/admin
- Licenses: http://localhost:3001/admin/licenses
- Issue License: http://localhost:3001/admin/licenses/issue
- Payments: http://localhost:3001/admin/payments
- Analytics: http://localhost:3001/admin/analytics

---

## 🔧 Troubleshooting

### **Port Already in Use:**

```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Kill process on port 3001
lsof -ti:3001 | xargs kill -9
```

### **Dependencies Not Installed:**

```bash
# Trader App
cd trader-app
npm install

# Admin Portal
cd admin-portal
npm install
```

### **Clear Cache:**

```bash
# Trader App
cd trader-app
rm -rf .next
npm run dev

# Admin Portal
cd admin-portal
rm -rf .next
npm run dev -- -p 3001
```

---

## ✅ Verification Checklist

After starting both apps, verify:

### **Trader App:**

- [ ] Homepage loads with hero section
- [ ] Header shows: Dashboard, Portfolio, Trade, Transactions
- [ ] Dashboard shows metrics cards
- [ ] Portfolio shows chart and holdings
- [ ] Trade shows swap interface
- [ ] Transactions shows table with filters

### **Admin Portal:**

- [ ] Landing page loads
- [ ] Header shows: Dashboard, Licenses, Payments, Analytics
- [ ] Dashboard shows 5 metric cards + activity feed
- [ ] Licenses shows table with search
- [ ] Issue License shows form
- [ ] Payments shows payment records
- [ ] Analytics shows multiple charts

---

## 🎨 Design Features to Verify

- [ ] Black background with blue radial glow
- [ ] Glass morphism on cards
- [ ] Dashed borders on cards
- [ ] Smooth hover effects
- [ ] Gradient text on logos
- [ ] Electric blue accents
- [ ] Monospace numbers
- [ ] Status badges (green/red/yellow)

---

## 📊 Test Data Available

### **Trader App:**

- Portfolio Value: $125,430
- Holdings: USDC, WETH, USDT
- Recent Trades: 5 transactions
- License Status: Active (23 days remaining)

### **Admin Portal:**

- Total Licenses: 24
- Active Traders: 18
- Trading Volume: $1.24M
- Monthly Revenue: $900
- Payment Records: 5 traders
- Analytics: Multiple chart datasets

---

## 🔗 Quick Links

**Documentation:**

- [Implementation Summary](./IMPLEMENTATION_SUMMARY.md)
- [Website Structure](./WEBSITE_STRUCTURE_IMPLEMENTATION.md)
- [Performance Optimizations](./PERFORMANCE_OPTIMIZATIONS.md)

**Key Files:**

- Trader App Header: `trader-app/components/Header.tsx`
- Admin Portal Header: `admin-portal/components/Header.tsx`
- Global Styles: `*/app/globals.css`

---

## 💡 Tips

1. **Connect Wallet:** Click "Connect Wallet" to see full dashboard features
2. **Navigation:** Use header links to navigate between pages
3. **Filters:** Try search and filter features on Licenses/Transactions pages
4. **Charts:** Click time range buttons (7d/30d/90d) to see chart updates
5. **Hover Effects:** Hover over cards and buttons to see animations

---

**Built by Steve | © 2026 PermitPool**
