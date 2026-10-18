OpenWrt (LuCI & ubus API), TP-Link Omada (Controller OpenAPI), Ubiquiti
UniFi (Controller REST API), and Generic Routers (HTTP/REST/SNMP).

## Project Status

| Item | Status |
| --- | --- |
| Current version | `0.1.27+31` |
| Android debug APK | Builds successfully |
| Windows desktop | Windows runner added; CI produces a portable `windows-x64` artifact |
| Linux desktop | Linux runner added; CI produces a portable `linux-x64` bundle |
| iOS | iOS target added; CI produces an unsigned release app (Apple signing required for devices/TestFlight) |
| Static analysis | Passing (0 issues) |
| Tests | 82 passing |
| Multi-Vendor Connectors | MikroTik hotspot/voucher connector plus authenticated connection/discovery foundations for Ruijie, OpenWrt, Omada, UniFi, and Generic |
| Web Dashboard | Fully Synchronized & Static Hosting Ready (`web_app/`) |
| Latest APK output | `outputs\WireSpot-0.1.27+31-brand-collaboration-debug.apk` |
| Latest pushed commit | See GitHub `main` |

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
- **PPPoE subscriber access**: configure RouterOS PPPoE server profiles with
  FreeRADIUS authentication and accounting, alongside an optional PPPoE ISP
  client for WAN uplink. PPPoE/RADIUS authenticates subscribers; the cloud
  agent remains the secure remote-management path.
- **FreeRADIUS deployment bundle**: `radius/` contains a Docker Compose service,
  RouterOS client configuration, starter subscriber policy, and production
  hardening guidance for PPPoE authentication/accounting.
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
| Web Dashboard (`web_app/`) | Responsive static dashboard with signup/login, router fleet, vouchers, cloud sync, reports, and setup wizard |
| Settings | Theme, language, currency, license, co-branding, ticket templates, voucher encoding, scheduler, printer, backup |
| Permissions | VPN, Bluetooth, camera, and network readiness guidance |

## Tech Stack

| Layer | Stack |
| --- | --- |
| App | Flutter, Material 3 |
| Web Dashboard | HTML5, CSS3, Vanilla JS, REST API, LocalStorage |
| Account Sync | Mobile Pairing Key Engine (`WS-XXXX-SYNC`) |
| State/navigation | Riverpod, GoRouter |
| Storage | Drift/SQLite, secure storage |
| Networking | Original RouterOS API client, Dio where HTTP/cloud APIs are needed |
| Android | Kotlin platform channels for VPN, Bluetooth, sharing, printing |
| Windows | Flutter Windows desktop runner; router, reports, local storage, and cloud workflows |
| iOS | Flutter target with unsigned CI builds; Apple signing and iOS-specific native integrations are required for store/device distribution |
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
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build windows --release
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build linux --release
```

Debug APK:

```text
build\app\outputs\flutter-apk\app-debug.apk
```

Current packaged debug APK:

```text
outputs\WireSpot-0.1.27+31-brand-collaboration-debug.apk
```

Windows release output:

```text
build\windows\x64\runner\Release\wirespot.exe
```

Linux release output:

```text
build/linux/x64/release/bundle/wirespot
```

The Windows build is distributed as the complete `Release` folder, not only
the executable, because Flutter bundles its DLLs and data files beside it.
On a local Windows workstation, enable **Developer Mode** before building so
Flutter can create plugin symlinks. GitHub Actions builds and uploads the same
folder as the `WireSpot-windows-x64` artifact.

Windows integrations include WireGuard tunnel-service control through the
official WireGuard CLI, Windows printer queues (including paired Bluetooth
printers exposed as Windows printers), and Windows Hello through Flutter's
`local_auth` plugin. Install WireGuard for Windows and pair the printer in
Windows before using those features.

Linux and iOS targets share the Flutter application and cloud workflows. Linux
is packaged as a portable desktop bundle by CI. The iOS CI artifact is
intentionally unsigned: installing on an iPhone, TestFlight distribution, and
App Store release require an Apple Developer team, certificates, and a macOS
signing workflow. Native iOS implementations for platform-specific features
such as WireGuard, Bluetooth printing, and biometrics should be validated on a
real iPhone before release.

## Operator Setup

1. Install the APK on an Android phone.
2. Open WireSpot and create/sign in with local PIN.
3. On first launch, follow the four-page onboarding guide. Use **Next** to
   continue, or **Skip** to go directly to the dashboard.
4. Add a router in **Routers** and choose its brand.
5. Use local LAN mode when on-site, or import/connect WireGuard for remote
   router management.
6. Test the RouterOS API connection for MikroTik routers. For Ruijie/Reyee,
   enter the Ruijie Cloud host and a vendor-issued access token, then test the
   cloud connection. Other brands remain planned connectors.
7. Configure Settings:
   - language and currency
   - license
   - professional co-branding
   - ticket template and voucher credential format
   - optional scheduled operations
   - Bluetooth printer
   - WireGuard and permission readiness
8. Generate vouchers, print tickets, manage users, and review reports.

### First-time VPN setup

For a remote router, open **WireGuard** during onboarding or from the VPN
screen. Import the `.conf` file supplied by the VPN administrator or scan its
QR code, grant Android VPN permission, and connect the tunnel. Add the router
using its private VPN address, then run the connection test.

### Web Dashboard cloud connection

Open **Cloud Sync → Cloud Settings**, enter the deployed API base URL, save it,
test `/health`, and use **Sync Now**. Voucher uploads and router refreshes
require a valid bearer token from signup/login or mobile pairing.

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

For a direct/offline time-limited activation, include a plan and UTC expiry:

```powershell
dart run tools/license_generator.dart DEVICE_ID --plan monthly --expires 2026-11-14
dart run tools/license_generator.dart DEVICE_ID --plan yearly --expires 2027-10-15
```

Local timed keys rely on the device clock and cannot be remotely revoked;
server-verified entitlements remain the safer choice for paid subscriptions.

Repository operators can generate the same mobile activation from GitHub:
open **Actions → Generate mobile device activation → Run workflow**, enter the
device ID shown in WireSpot Settings, and download the short-lived activation
artifact. The workflow's lifetime option produces the offline device-bound key;
monthly and yearly plans must be issued by the authenticated cloud billing
service so they can expire and be revoked safely.

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
| Ruijie / Reyee | Connection and discovery foundation | Secure token-based Ruijie Cloud connection test and device discovery; hotspot and voucher mutations are rejected until vendor API mapping is implemented |
| OpenWrt | Connection and dashboard foundation | LuCI/ubus connection path; hotspot and voucher mutations require authenticated package-specific mapping |
| TP-Link Omada | Controller connection foundation | Controller health path; site/portal/voucher mutations require controller-version mapping |
| Ubiquiti UniFi | Controller connection foundation | Controller health path; site/guest/voucher mutations require controller-version mapping |
| Generic router | Connection foundation | No universal mutation API exists; configure a vendor-specific adapter before enabling mutations |

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
