# SpendTrack — Personal Expense Tracker

iOS 17+ expense tracker with Plaid bank integration. Tracks spending across all connected US accounts with category breakdowns, monthly budgets, and Face ID protection.

---

## Quick Start

### Step 1 — Install Xcode
Download **Xcode** (free) from the Mac App Store. Requires macOS 14+.

### Step 2 — Get Plaid API Keys (free)
1. Go to [dashboard.plaid.com](https://dashboard.plaid.com) and create an account
2. Navigate to **Team → Keys**
3. Copy your **Client ID** and **Sandbox Secret**

### Step 3 — Start the Backend Server
```bash
cd ~/Documents/SpendTrack/Server
cp .env.example .env
# Edit .env and paste your Plaid credentials
./start-server.sh
```

Verify it's running: open http://localhost:3000/health in your browser.

### Step 4 — Open the iOS App in Xcode
```bash
open ~/Documents/SpendTrack/SpendTrack.xcodeproj
```

Xcode will automatically download the Plaid LinkKit SDK via Swift Package Manager (takes ~1 min on first open).

### Step 5 — Build & Run
- Select the **iPhone Simulator** or your **iPhone** as the target device
- Press **⌘R** to build and run
- In the app, go to **Accounts → + → Connect Account**

---

## Testing with Plaid Sandbox

In Sandbox mode, no real bank credentials are used. Use these test credentials in the Plaid Link flow:

| Field | Value |
|-------|-------|
| Username | `user_good` |
| Password | `pass_good` |
| MFA code | `1234` |

---

## Project Structure

```
SpendTrack/
├── SpendTrack.xcodeproj      ← Open this in Xcode
├── SpendTrack/               ← iOS app source (Swift)
│   ├── Models/               ← SwiftData models
│   ├── Views/                ← SwiftUI screens
│   ├── ViewModels/           ← Business logic
│   ├── Services/             ← Plaid, Auth, Notifications
│   └── Utilities/            ← Extensions, helpers
└── Server/                   ← Node.js backend
    ├── server.js
    ├── routes/plaid.js       ← All Plaid API calls
    ├── data/items.json       ← Auto-created, stores access tokens locally
    └── .env                  ← Your Plaid credentials (never commit this)
```

---

## App Features

| Feature | Details |
|---------|---------|
| **Plaid Integration** | Connect credit cards, debit accounts — US only |
| **Dashboard** | Monthly spend, income, category bar chart |
| **Transactions** | Search, filter, swipe to categorize |
| **Custom Tags** | Tag any transaction with a custom label |
| **Budgets** | Per-category monthly limits with progress |
| **Notifications** | Alerts at 80% and 100% of each budget |
| **Face ID** | App locks on background, unlocks with biometrics |
| **Dark Mode** | Full system dark/light mode support |

---

## Publishing to the App Store

### Prerequisites
1. **Apple Developer Program** — $99/year at [developer.apple.com](https://developer.apple.com)
2. **Plaid Production Access** — Apply at [dashboard.plaid.com](https://dashboard.plaid.com) (free for personal use)
3. **Backend hosting** — Deploy the Node.js server (Railway, Render, or Fly.io all have free tiers)

### Steps
1. Update `ServerBaseURL` in `Info.plist` to your production server URL
2. Change `PlaidEnvironment` in `Info.plist` from `sandbox` to `production`
3. In Xcode: **Product → Archive** → **Distribute App → App Store Connect**
4. Submit for App Store review

### Backend Deployment (Railway — easiest)
```bash
# Install Railway CLI
brew install railway

# From the Server directory
cd ~/Documents/SpendTrack/Server
railway login
railway init
railway up

# Set env vars in Railway dashboard:
# PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV=production
```

---

## Architecture Notes

- **SwiftData** stores all local data (transactions, budgets, accounts). Survives app restarts.
- **Plaid access tokens** never touch the iOS app — they're stored server-side in `data/items.json`.
- **Incremental sync** uses Plaid's `/transactions/sync` cursor API, so only new/changed transactions are fetched each time.
- **Budget notifications** are local `UNUserNotificationCenter` notifications — no push server needed.

---

## Regenerating the Xcode Project

If you add new Swift files outside Xcode, regenerate the project:
```bash
cd ~/Documents/SpendTrack
xcodegen generate
```
