# WireSpot

Secure MikroTik RouterOS hotspot management for Android, built by
Vexel Innovations.

![WireSpot logo](assets/images/vexel_logo.png)

WireSpot is a modern Flutter Android application for hotspot operators,
technicians, and small ISPs who manage MikroTik RouterOS networks. It brings
router management, hotspot users, voucher generation, thermal printing,
reporting, WireGuard remote access, backup, and licensing into one mobile app.

This codebase is original work. It does not copy Mikhmon, WireNex, or any
proprietary application. Router communication is implemented from scratch using
public RouterOS API behavior and original WireSpot code.

## Project Status

| Item | Status |
| --- | --- |
| Current version | `0.1.24+25` |
| Android debug APK | Builds successfully |
| Static analysis | Passing |
| Tests | 47 passing |
| Latest APK output | `outputs\WireSpot-0.1.24+25-branding-license-polish-debug.apk` |
| Latest pushed commit | `10f6753` |

## Why WireSpot

Hotspot operators often manage MikroTik routers with several disconnected
tools: WinBox for router work, spreadsheets for sales, manual voucher records,
separate QR generators, and unsafe public router access for remote support.

WireSpot solves that with a focused Android workflow:

- Manage MikroTik routers locally or through WireGuard VPN.
- Create and control hotspot users, profiles, sessions, queues, cookies, and
  IP bindings.
- Generate single or batch vouchers with QR payloads.
- Print co-branded voucher receipts on Bluetooth ESC/POS thermal printers.
- Track sales and export reports.
- Protect app access with PIN, biometric-ready authentication, encrypted local
  storage, and device-bound licensing.

## Highlights

- **RouterOS API client from scratch**: socket protocol, command execution,
  login, read/write, listen support, timeout/error handling, SSL-ready paths.
- **WireGuard-first remote access**: designed so operators do not need to expose
  RouterOS API ports directly to the internet.
- **Hotspot operations**: users, profiles, sessions, cookies, queues, IP
  bindings, disconnect, reset counters, delete, search/filter foundations.
- **Voucher workflow**: plans, random credentials, PIN-style vouchers, price,
  data limits, QR payloads, receipt preview, share, and print.
- **Professional co-branding**: operators can set business name, email, phone,
  and website for customer-facing receipts and reports.
- **Reporting**: daily, weekly, monthly summaries with CSV and PDF-text export
  through the Android share sheet.
- **Backup and restore**: JSON backup preview and restore for supported
  settings and printer profiles.
- **Production direction**: Play Store release prep, privacy policy draft,
  payment/licensing plan, and workstation transfer guide are included.

## Screens and Modules

| Module | What it does |
| --- | --- |
| Dashboard | Router status, online users, sales, CPU, memory, health, interfaces |
| Routers | Add, edit, delete, group-ready records, test connection |
| WireGuard | Import/scan configs, connect/disconnect, status, logs, statistics |
| Hotspot | Manage users, profiles, sessions, queues, cookies, IP bindings |
| Vouchers | Generate vouchers, QR payloads, history, share, print |
| Reports | Revenue summaries, sales lists, CSV/PDF-text export |
| Settings | Theme, language, currency, license, co-branding, printer, backup |
| Permissions | VPN, Bluetooth, camera, and network readiness guidance |

## Tech Stack

| Layer | Stack |
| --- | --- |
| App | Flutter, Material 3 |
| State/navigation | Riverpod, GoRouter |
| Storage | Drift/SQLite, secure storage |
| Networking | Original RouterOS API client, Dio where HTTP is needed |
| Android | Kotlin platform channels for VPN, Bluetooth, sharing, printing |
| VPN | WireGuard Android tunnel backend integration |
| Printing | ESC/POS Bluetooth thermal printer support |
| QR | QR generation and WireGuard QR import |
| Architecture | Clean Architecture, MVVM, repositories, dependency injection |

## Requirements

- Windows development machine
- Flutter SDK
- Android Studio
- Android SDK and platform tools
- Git for Windows
- Android phone for real VPN/Bluetooth/router testing
- MikroTik RouterOS router with API enabled

The project currently uses this local Flutter path in the documented commands:

```text
C:\tmp\wirespot_flutter\flutter
```

Adjust commands if your Flutter SDK is somewhere else.

## Quick Start

```powershell
git clone https://github.com/Uszkido/wirespot.git
cd wirespot

C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check pub get
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check analyze
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check test
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build apk --debug --target-platform android-arm64
```

Debug APK:

```text
build\app\outputs\flutter-apk\app-debug.apk
```

Current packaged debug APK:

```text
outputs\WireSpot-0.1.24+25-branding-license-polish-debug.apk
```

## Operator Setup

1. Install the APK on an Android phone.
2. Open WireSpot and create/sign in with local PIN.
3. Add a MikroTik router in **Routers**.
4. Use local LAN mode when on-site, or import/connect WireGuard for remote
   router management.
5. Test RouterOS API connection.
6. Configure Settings:
   - language and currency
   - license
   - professional co-branding
   - Bluetooth printer
   - WireGuard and permission readiness
7. Generate vouchers, print tickets, manage users, and review reports.

## Licensing

WireSpot includes a 7-day full-access trial. After the trial expires, the app
requires a valid license.

Current active licensing support:

- 7-day trial
- device license ID
- local device-bound license key generation
- license status in Settings
- license request copy action

Generate a local device-bound license:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\dart.bat run tools/license_generator.dart DEVICE_ID
```

Play Billing/server validation is planned for production release and documented
in [docs/payment-and-licensing.md](docs/payment-and-licensing.md).

## Professional Co-branding

Professional users can configure:

- business name
- business email
- business phone
- business website

These values are used in voucher receipt preview/share/print output and report
exports, while WireSpot remains identified as powered by Vexel Innovations.

## Security

- Router credentials are stored through secure storage boundaries.
- App access is protected by local PIN and biometric-ready authentication.
- Remote router management is designed around WireGuard.
- RouterOS credentials should never be committed or shared.
- Play Store signing keys must stay private and must not be pushed to GitHub.

## Documentation

| Document | Purpose |
| --- | --- |
| [docs/complete-operator-guide.md](docs/complete-operator-guide.md) | End-to-end setup, operation, activation, troubleshooting |
| [docs/wirespot-pitch.md](docs/wirespot-pitch.md) | Business/product pitch for WireSpot |
| [docs/user-manual.md](docs/user-manual.md) | App user manual |
| [docs/technical-diagnostics.md](docs/technical-diagnostics.md) | Debugging and technical checks |
| [docs/payment-and-licensing.md](docs/payment-and-licensing.md) | Trial, subscription, offline license plan |
| [docs/play-store-release.md](docs/play-store-release.md) | Play Store signing and release process |
| [docs/privacy-policy.md](docs/privacy-policy.md) | Privacy policy draft |
| [docs/workstation-transfer.md](docs/workstation-transfer.md) | Moving the project to another PC |
| [docs/license-generation.md](docs/license-generation.md) | Local license generation |

## Play Store Readiness

Already prepared:

- Android release signing configuration path
- `android/key.properties.template`
- ProGuard rules file
- privacy policy draft
- Play Store release guide
- payment/licensing product plan

Still required before production upload:

- create and securely back up upload keystore
- configure `android/key.properties`
- build release AAB
- create Play Console app listing
- add screenshots and store descriptions
- configure Play Billing products
- run internal testing
- complete production license validation path

## Roadmap To 100%

- Real Play Billing or server-side license validation.
- Release signing and Play Store AAB.
- More field testing on MikroTik hotspot setup.
- WireGuard validation across multiple Android models.
- Printer testing across common 58mm/80mm ESC/POS models.
- More polished real PDF/Excel file generation.
- More RouterOS command tests and UI flow tests.
- Final Play Store screenshots, privacy URL, and production listing.

## Brand And Support

| Item | Details |
| --- | --- |
| Product | WireSpot |
| Company | Vexel Innovations |
| Email | Vexelvision@gmail.com |
| Phone | +234(0)7038953065 |
| Website | https://vexel-innovations.vercel.app/ |
| Logo asset | `assets/images/vexel_logo.png` |

## Governance

- [CHANGELOG.md](CHANGELOG.md)
- [LICENSE](LICENSE)
- [SECURITY.md](SECURITY.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- [SUPPORT.md](SUPPORT.md)

WireSpot is proprietary Vexel Innovations software. See [LICENSE](LICENSE) for
authorized use, contribution, redistribution, and warranty terms.

## Disclaimer

WireSpot is in active development and field testing. Test on non-critical
routers before production deployment, keep RouterOS backups, and use WireGuard
for remote access instead of exposing RouterOS management ports publicly.
