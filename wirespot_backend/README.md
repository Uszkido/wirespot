# WireSpot 100% Free Cloud Backend (`wirespot_backend/`)

This directory contains the lightweight **Dart Frog API Server** for WireSpot.
It provides the mobile/web API contract and an organization-scoped JSON file
store. The store survives process restarts when its path is on persistent disk.
Firestore is still recommended before multi-instance hosting.

---

## 🚀 100% Free Deployment (No Credit Card Needed)

### 1. Database Setup: Firebase Firestore (Free Spark Plan)
1. Go to [console.firebase.google.com](https://console.firebase.google.com/) and click **Add Project**.
2. Name your project `wirespot-cloud`.
3. In the left navigation bar, go to **Build > Firestore Database** and click **Create Database**.
4. Choose **Start in Test Mode** (or production rules).
5. Done! You now have 1 GB of free storage and 50,000 free reads per day without entering any credit card.

---

### 2. Git-based hosting deployment: Render

The repository includes a root-level [`render.yaml`](../render.yaml) Blueprint.
It keeps deployment configuration in Git and builds the existing Docker image
from `wirespot_backend/`.

1. Create a free account at [render.com](https://render.com/) and connect GitHub.
2. Choose **New > Blueprint**, select `Uszkido/wirespot`, and choose the `main`
   branch.
3. Render detects `render.yaml`. Review the `wirespot-api` service and click
   **Apply**.
4. Wait for the first build, then copy the generated HTTPS URL, for example
   `https://wirespot-api.onrender.com`.
5. Set that URL as the API Base URL in the WireSpot web or mobile setup screen.

The service is configured with `/health` for health checks and CORS for both
Firebase hosting sites. Render's free web services sleep after inactivity, so
the first request after idle may take longer. The free tier is suitable for
testing and small pilots, not guaranteed production availability.

For another Git provider, use the same Docker settings: root directory
`wirespot_backend`, Dockerfile `Dockerfile`, context `.`, and port `8080`.

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

Set `WIRESPOT_STORE_PATH` to a persistent disk path (for example
`/var/data/wirespot/store.json` on Render) to retain data across restarts.
Without a persistent volume, the service remains functional but its local
snapshot can be lost during redeployments.

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
