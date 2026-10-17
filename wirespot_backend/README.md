# WireSpot 100% Free Cloud Backend (`wirespot_backend/`)

This directory contains the lightweight **Dart Frog API Server** for WireSpot.
It provides the mobile/web API contract and a process-local store suitable for
local and single-instance testing. Firestore persistence is required before
production or multi-instance hosting.

---

## 🚀 100% Free Deployment (No Credit Card Needed)

### 1. Database Setup: Firebase Firestore (Free Spark Plan)
1. Go to [console.firebase.google.com](https://console.firebase.google.com/) and click **Add Project**.
2. Name your project `wirespot-cloud`.
3. In the left navigation bar, go to **Build > Firestore Database** and click **Create Database**.
4. Choose **Start in Test Mode** (or production rules).
5. Done! You now have 1 GB of free storage and 50,000 free reads per day without entering any credit card.

---

### 2. Free Hosting Deployment: Koyeb (0 Card Required)
1. Create a free account on [koyeb.com](https://www.koyeb.com/) using your GitHub account (No credit card asked).
2. Click **Create App** > Select **GitHub**.
3. Select this repository and set the root directory to `wirespot_backend`.
4. Koyeb automatically detects `wirespot_backend/Dockerfile`, builds the lightweight Dart container (< 50MB RAM footprint), and issues a free SSL HTTPS domain:
   - Example API URL: `https://wirespot-cloud-xxx.koyeb.app`

---

## 🌐 Provided Cloud Endpoints

- `GET /health`: Health probe check returning database & backend status.
- `POST /api/v1/auth/pair`: Validate mobile-web device pairing keys (`WS-XXXX-SYNC`).
- `POST /api/v1/auth/login` and `/api/v1/auth/register`: Create a development session.
- `POST /api/v1/auth/recover`: Start account recovery (requires a hosted identity provider for delivery in production).
- `GET /api/v1/sync/vouchers` & `POST /api/v1/sync/vouchers`: Sync generated voucher batches across devices.
- `GET /api/v1/routers`: Sync router fleet inventory (MikroTik, Ruijie, OpenWrt, Omada, UniFi, Generic).
- `GET /api/v1/commands/pending`: Return organization-scoped pending cloud commands.
- `POST /api/v1/commands/pending`: Queue a `remote_reboot` or `router_command`
  for an online mobile agent; the agent executes it and acknowledges the result.
- `POST /api/v1/commands/<id>/ack`: Record command completion or failure.
- `POST /api/v1/telemetry`: Accept telemetry frames.
- `POST /api/v1/backup/upload` & `GET /api/v1/backup/latest`: Upload and retrieve the latest backup.
- `GET /api/v1/license/entitlement`: Read the organization's verified entitlement.
- `POST /api/v1/license/entitlement`: Issue an entitlement only when the
  server-only `WIRESPOT_ENTITLEMENT_ADMIN_TOKEN` is configured.

All `/api/v1` data endpoints require `Authorization: Bearer ws_...`. Health
and authentication endpoints are public. Development login/register tokens are
intentionally not production credentials. For a production deployment, set
`WIRESPOT_ENV=production` and configure
`WIRESPOT_OPERATOR_TOKENS` as comma-separated `token|organizationId|role`
entries. In production, organization and role claims come only from the
server-side token allow-list; client-provided role/organization headers are
ignored. Replace this allow-list with a hosted identity provider before
multi-tenant public launch.

---

## 🛠️ Local Testing

Run locally on port 8080:

```bash
cd wirespot_backend
dart pub get
dart pub global activate dart_frog_cli
dart_frog dev
```

Test health check:
```bash
curl http://localhost:8080/health
```
