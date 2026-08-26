# WireSpot 100% Free Cloud Backend (`wirespot_backend/`)

This directory contains the production **Dart Frog API Server** for WireSpot, pre-configured for **Firebase Firestore** and **Koyeb Container Hosting** (100% Free, **0 Credit Card Required**).

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
- `GET /api/v1/sync/vouchers` & `POST /api/v1/sync/vouchers`: Sync generated voucher batches across devices.
- `GET /api/v1/routers`: Sync router fleet inventory (MikroTik, Ruijie, OpenWrt, Omada, UniFi, Generic).

---

## 🛠️ Local Testing

Run locally on port 8080:

```bash
cd wirespot_backend
dart pub get
dart bin/server.dart
```

Test health check:
```bash
curl http://localhost:8080/health
```
