# WireSpot Cloud Web Dashboard (`web_app/`)

The **WireSpot Cloud Web Dashboard** provides a feature-complete web management interface for WireSpot hotspot operators, technicians, and ISP administrators. It runs directly in any modern browser without external framework dependencies.

---

## 🚀 Key Features & Capabilities

- **Account Sync & Mobile Pairing**:
  - Signup creates a workspace Organization ID and access code, then opens Cloud Sync setup so the same values can be entered in the mobile app.
  - The API Base URL is operator-supplied (your deployed WireSpot backend); credentials can be copied directly from the Cloud Sync panel.
  - Keep accounts, active hotspot profiles, router credentials, and voucher configurations in sync.

- **4-Step Guided Auto-Configuration Wizard**:
  - Interactive onboarding wizard tailored for non-technical users:
    1. **Business Profile**: Operator co-branding setup.
    2. **Router Setup**: RouterOS host IP, credentials, API port configuration.
    3. **Hotspot Presets**: Selectable business templates (Quick Voucher, Small Business, Hotel Guest, RADIUS).
    4. **Ticket Customizer**: POS voucher thermal ticket layout selection & live preview.

- **Subscriptions & Tier Billing**:
  - Active subscription status tracking (**Free**, **Pro**, **Enterprise**).
  - Feature entitlements table & renewal flow.
  - PDF Invoice generator for billing records.

- **Advanced Hotspot User Management**:
  - Full CRUD operations for Hotspot users, profiles, and active sessions.
  - One-click counter reset tools (bytes/time limits).
  - Search, filter, and batch export user lists to CSV/JSON.

- **Interactive RouterOS CLI**:
  - Remote RouterOS command terminal with interactive execution and history log.

- **Thermal POS Ticket Customizer**:
  - Live preview editor for 58 mm, 80 mm, and QR-compact receipt layouts.
  - Custom logo upload, header/footer text, and price formatting.

- **Analytics & Export Engine**:
  - Sales charts, revenue breakdown, and voucher detail with date-range filters.
  - Live CSV export (opens in Excel), JSON workspace backup, and branded browser
    print-to-PDF reports. Reports use the selected WireSpot currency (NGN,
    KES, GHS, or USD) and never fabricate records when the workspace is empty.

---

## 🛠️ Architecture & Tech Stack

- **Structure**: Vanilla HTML5, CSS3, JavaScript (ES6 Modules).
- **Design**: Premium Glassmorphic Dark UI theme.
- **State Management**: Reactive event-driven state model (`app.js`).
- **Storage**: LocalStorage fallback with REST/Cloud API sync synchronization.

---

## 🖥️ Local Execution

Launch the web app locally using Python's built-in HTTP server:

```bash
cd web_app
python -m http.server 8080
```

Open `http://localhost:8080` in your browser.

---

## 📦 Deployment Options

Because `web_app` consists of static assets (`index.html`, `styles.css`, `app.js`), it can be hosted on any static hosting platform:

- **Vercel**: `vercel deploy web_app`
- **Netlify**: `netlify deploy --dir=web_app`
- **GitHub Pages**: Deploy contents of `web_app/` to `gh-pages` branch.
- **Nginx / Apache / Caddy**: Copy contents of `web_app/` to standard webroot directory (e.g. `/var/www/html`).
