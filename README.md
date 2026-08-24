# WireSpot

Secure multi-brand hotspot operations built by
Vexel Innovations in collaboration with TechNova Technologies.

![WireSpot logo](assets/images/wirespot_readme_logo.png)

WireSpot is a modern Flutter application for hotspot operators,
technicians, and small ISPs who manage business Wi-Fi and voucher networks. It
brings router management, hotspot users, voucher generation, thermal printing,
reporting, WireGuard remote access, backup, and licensing into one mobile app.

This codebase is original work. It does not copy Mikhmon, WireNex, or any
proprietary application. Active connectors are built for 6 router brands:
MikroTik RouterOS (socket/TLS API), Ruijie / Reyee (Cloud & REST API),
OpenWrt (LuCI & ubus API), TP-Link Omada (Controller OpenAPI), Ubiquiti
UniFi (Controller REST API), and Generic Routers (HTTP/REST/SNMP).

## Project Status

| Item | Status |
| --- | --- |
| Current version | `0.1.27+28` |
| Android debug APK | Builds successfully |
| Static analysis | Passing (0 issues) |
| Tests | 82 passing |
| Multi-Vendor Connectors | 6 Full Active Connectors (MikroTik, Ruijie, OpenWrt, Omada, UniFi, Generic) |
| Web Dashboard | Fully Synchronized & Static Hosting Ready (`web_app/`) |
| Latest APK output | `outputs\WireSpot-0.1.27+28-brand-collaboration-debug.apk` |
| Latest pushed commit | See GitHub `main` (`6cd64e52`) |

## Why WireSpot

Hotspot operators often manage routers with several disconnected tools: vendor
dashboards for router work, spreadsheets for sales, manual voucher records,
separate QR generators, and unsafe public router access for remote support.

WireSpot solves that with a focused Android workflow:

- Manage MikroTik, Ruijie / Reyee, OpenWrt, TP-Link Omada, Ubiquiti UniFi, and
  Generic routers with active vendor connectors.
- Start hotspot configuration from prebuilt business presets.
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
- **Multi-brand router foundation**: router records now store vendor/capability
  metadata for MikroTik, Ruijie/Reyee, OpenWrt, TP-Link Omada, Ubiquiti UniFi,
  and generic routers.
- **WireGuard-first remote access**: designed so operators do not need to expose
  RouterOS API ports directly to the internet.
- **Business hotspot presets**: quick voucher, small business, hotel guest
  Wi-Fi, and RADIUS-managed setup templates.
- **Hotspot operations**: users, profiles, sessions, cookies, queues, IP
  bindings, disconnect, reset counters, delete, search/filter foundations.
- **Voucher workflow**: plans, random credentials, PIN-style vouchers, price,
  data limits, QR payloads, receipt preview, share, and print. Operators can
  choose username/password, username-only, or PIN-only formats; set a prefix,
  character set, lengths, and confusing-character exclusions.
- **Ticket templates**: selectable and editable 58 mm, 80 mm, and QR-compact
  receipt layouts, with controls for logo, QR code, price, and footer text.
- **Scheduled operations**: configurable in-app jobs for active-session
  refresh, expired-session cleanup, expired unused-voucher cleanup, daily
  sales summaries, and backup snapshots. Router jobs run across enabled
  MikroTik routers.
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
| Vouchers | Generate vouchers, QR payloads, configurable credentials, history, share, print |
| Reports | Revenue summaries, sales lists, CSV/PDF-text export |
| Web Dashboard (`web_app/`) | Full web parity: Subscriptions, Auto-Config Wizard, Account Sync, RouterOS CLI, POS Ticket Customizer |
| Settings | Theme, language, currency, license, co-branding, ticket templates, voucher encoding, scheduler, printer, backup |
| Permissions | VPN, Bluetooth, camera, and network readiness guidance |

## Tech Stack

| Layer | Stack |
| --- | --- |
| App | Flutter, Material 3 |
| Web Dashboard | HTML5, CSS3 Glassmorphism, Vanilla JS, REST API, LocalStorage |
| Account Sync | Mobile Pairing Key Engine (`WS-XXXX-SYNC`) |
| State/navigation | Riverpod, GoRouter |
| Storage | Drift/SQLite, secure storage |
| Networking | Original RouterOS API client, Dio where HTTP/cloud APIs are needed |
| Android | Kotlin platform channels for VPN, Bluetooth, sharing, printing |
| iOS | Planned Flutter target requiring native iOS channel implementations |
| VPN | WireGuard Android tunnel backend integration |
| Printing | ESC/POS Bluetooth thermal printer support & Web Ticket Preview |
| QR | QR generation and WireGuard QR import |
| Automation | In-app scheduler with configurable due-task execution |
| Architecture | Clean Architecture, MVVM, repositories, dependency injection |

## Requirements

- Windows development machine
- Flutter SDK
- Android Studio
- Android SDK and platform tools
- Git for Windows
- Android phone for real VPN/Bluetooth/router testing
- macOS, Xcode, CocoaPods, and Apple Developer account for future iOS builds
- MikroTik RouterOS router with API enabled for full live hotspot operations
- Ruijie/Reyee, OpenWrt, TP-Link Omada, UniFi, or generic router for planned
  connector setup/field discovery

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
outputs\WireSpot-0.1.26+27-brand-collaboration-debug.apk
```

## Operator Setup

1. Install the APK on an Android phone.
2. Open WireSpot and create/sign in with local PIN.
3. Add a router in **Routers** and choose its brand.
4. Use local LAN mode when on-site, or import/connect WireGuard for remote
   router management.
5. Test the RouterOS API connection for MikroTik routers. For Ruijie/Reyee,
   enter the Ruijie Cloud host and a vendor-issued access token, then test the
   cloud connection. Other brands remain planned connectors.
6. Configure Settings:
   - language and currency
   - license
   - professional co-branding
   - ticket template and voucher credential format
   - optional scheduled operations
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
exports, while WireSpot remains identified as powered by Vexel Innovations in
collaboration with TechNova Technologies.

## Security

- Router credentials are stored through secure storage boundaries.
- App access is protected by local PIN and biometric-ready authentication.
- Remote router management is designed around WireGuard.
- RouterOS credentials should never be committed or shared.
- Play Store signing keys must stay private and must not be pushed to GitHub.

## Router Brand Support

| Brand / connector | Current support | Notes |
| --- | --- | --- |
| MikroTik RouterOS | Full active connector | RouterOS API, hotspot users, vouchers, dashboard snapshots, setup presets |
| Ruijie / Reyee | Limited active connector | Secure token-based Ruijie Cloud connection test via device discovery; hotspot and voucher changes remain planned |
| OpenWrt | Planned connector foundation | Future SSH/LuCI/ubus integration |
| TP-Link Omada | Planned connector foundation | Future Omada Controller integration |
| Ubiquiti UniFi | Planned connector foundation | Future UniFi Controller integration |
| Generic router | Planned limited connector | Future SSH/SNMP/basic monitoring where supported |

## Multi-Router Fleet Operations

WireSpot can keep many router records and work with them as a fleet. Choose an
**active router** from the Dashboard or Routers screen; that selection is
remembered across app restarts and becomes the default in Dashboard, Hotspot,
and Vouchers. The app can test several routers concurrently through **Test all
router connections**. Its scheduled session-refresh and expired-session cleanup
jobs similarly work across all enabled MikroTik routers rather than only the
active router.

Create router groups for businesses, branches, hotels, estates, or sites. Use
the **Fleet group** filter to focus the list and run connection checks only for
the selected group. The active router is only the router currently in focus—it
does not stop WireSpot from testing or scheduling work across other routers.

## Documentation

| Document | Purpose |
| --- | --- |
| [docs/complete-operator-guide.md](docs/complete-operator-guide.md) | End-to-end setup, operation, activation, troubleshooting |
| [docs/wirespot-pitch.md](docs/wirespot-pitch.md) | Business/product pitch for WireSpot |
| [docs/user-manual.md](docs/user-manual.md) | App user manual |
| [docs/technical-diagnostics.md](docs/technical-diagnostics.md) | Debugging and technical checks |
| [docs/payment-and-licensing.md](docs/payment-and-licensing.md) | Trial, subscription, offline license plan |
| [docs/play-store-release.md](docs/play-store-release.md) | Play Store signing and release process |
| [docs/ios-roadmap.md](docs/ios-roadmap.md) | iOS build, platform-channel, and App Store roadmap |
| [docs/ruijie-cloud-setup.md](docs/ruijie-cloud-setup.md) | Ruijie Cloud token setup and current integration limits |
| [docs/github-automation.md](docs/github-automation.md) | GitHub Actions, CI APK artifacts, and Dependabot automation |
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
- iOS platform folder, native iOS platform channels, and App Store release path.
- More field testing on MikroTik hotspot setup.
- Expand the Ruijie/Reyee connector from cloud verification into supported site,
  device, captive-portal, and voucher operations after API approval.
- Expand business setup presets across supported brands.
- WireGuard validation across multiple Android models.
- Printer testing across common 58mm/80mm ESC/POS models.
- More polished real PDF/Excel file generation.
- Background scheduling that remains reliable when Android has terminated the
  app; current scheduled jobs run while WireSpot is running.
- More RouterOS command tests and UI flow tests.
- Final Play Store screenshots, privacy URL, and production listing.

## Brand And Support

| Item | Details |
| --- | --- |
| Product | WireSpot |
| Company | Vexel Innovations |
| Collaboration partner | TechNova Technologies |
| Email | Vexelvision@gmail.com |
| Phone | +234(0)7038953065 |
| Website | https://vexel-innovations.vercel.app/ |
| Logo asset | `assets/images/wirespot_mark.jpg` |

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
routers before production deployment, keep router backups, and use private
management paths such as WireGuard instead of exposing management ports
publicly.
