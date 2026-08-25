# 🏗️ Architecture Overview

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter (Dart) |
| **Design System** | Material 3 |
| **State Management** | Riverpod |
| **Routing** | GoRouter |
| **Database** | Drift (SQLite) |
| **Secure Storage** | Flutter Secure Storage |
| **Native Integration** | Android Platform Channels |
| **VPN Backend** | Official WireGuard Android Tunnel Library (`com.wireguard.android:tunnel`) |
| **Bluetooth** | Android Bluetooth SPP (RFCOMM) via Platform Channel |

---

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── app.dart                   # Root MaterialApp with theme, routing, locale
├── core/                      # Core infrastructure (55 files)
│   ├── api/                   # RouterOS API client (socket protocol)
│   ├── database/              # Drift database, tables, DAOs, migrations
│   ├── routing/               # GoRouter configuration
│   ├── theme/                 # Material 3 theme setup
│   └── ...
├── features/                  # Feature modules (93 files)
│   ├── authentication/        # PIN login, biometric
│   ├── dashboard/             # Router health, metrics, navigation
│   ├── hotspot/               # Users, profiles, sessions, setup assistant
│   ├── routers/               # Router CRUD, fleet, brands, groups
│   ├── voucher/               # Generation, encoding, QR, receipts
│   ├── vpn/                   # WireGuard tunnel management
│   ├── reports/               # Revenue tracking, export
│   ├── settings/              # App configuration
│   ├── scheduler/             # Automated task execution
│   ├── permissions/           # Android permission readiness
│   ├── splash/                # App splash screen
│   └── users/                 # User management
├── models/                    # Shared domain models
├── services/                  # Cross-feature services
├── shared/                    # Shared utilities (6 files)
└── widgets/                   # Reusable UI components
```

---

## Key Architectural Patterns

### Feature Module Pattern

Each feature in `lib/features/` is self-contained with:
- **Screens** — UI pages
- **Widgets** — Feature-specific components
- **Providers** — Riverpod state management
- **Services** — Business logic
- **Models** — Feature-specific data models

### Repository Pattern

Data access follows the repository pattern:
- Repositories abstract database and API operations
- Features depend on repository interfaces, not database details
- Drift DAOs handle raw SQLite queries

### RouterOS API Client

The RouterOS API client is **implemented from scratch** — not a third-party package:
- Socket-level protocol implementation
- Command execution, login, read/write operations
- Listen support for real-time data
- Timeout and error handling
- SSL-ready connection paths

### Multi-Brand Connector Architecture

Router records store vendor and capability metadata:

| Vendor | Status |
|--------|--------|
| `mikrotik` | ✅ Full live connector (RouterOS API) |
| `ruijie` | ⚡ Cloud connection test only |
| `openWrt` | 📋 Planned connector |
| `tpLinkOmada` | 📋 Planned connector |
| `ubiquitiUniFi` | 📋 Planned connector |
| `generic` | 📋 Planned connector |

### Platform Channels

Android-native features are bridged through Flutter platform channels:

| Channel | Purpose |
|---------|---------|
| **WireGuard** | VPN connect, disconnect, status, logs, statistics |
| **Bluetooth** | Paired printer listing, ESC/POS receipt printing |
| **Play Store** | Subscription management (planned) |

---

## Database

- **Engine:** Drift (SQLite)
- **Schema migrations:** Committed generated Drift files
- **Sensitive data:** Router credentials and voucher passwords stored through secure storage boundaries
- **Code generation:** Run `dart run build_runner build` after schema changes

---

## Build System

- AndroidX enabled
- Gradle wrapper `8.14.3`
- Android Gradle Plugin `8.11.1`
- Kotlin plugin `2.2.20`
- Extended Gradle HTTP timeouts for dependency downloads
