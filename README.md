# WireSpot

WireSpot is a Flutter Android application for managing MikroTik RouterOS hotspot operations securely through WireGuard VPN.

This codebase is original work. It does not copy Mikhmon, WireNex, or proprietary application code. Router communication is implemented through public RouterOS API behavior and original app code.

## Version

- Current app version: `0.1.6+7`
- Release notes: [CHANGELOG.md](CHANGELOG.md)
- License: [WireSpot Proprietary License](LICENSE)
- Security policy: [SECURITY.md](SECURITY.md)
- Contributing guide: [CONTRIBUTING.md](CONTRIBUTING.md)
- Code of conduct: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)

## Branding

- Product: WireSpot
- Company: Vexel Innovations
- Email: Vexelvision@gmail.com
- Phone: +234(0)7038953065
- Website: https://vexel-innovations.vercel.app/
- Logo asset: assets/images/vexel_logo.png

## Documentation

- User manual: [docs/user-manual.md](docs/user-manual.md)
- Technical diagnostics: [docs/technical-diagnostics.md](docs/technical-diagnostics.md)

## Build

Successful debug APK command:

```powershell
cd "C:\Users\HP\Documents\Codex\2026-07-10\you-are-an-expert-flutter-android"
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build apk --debug --target-platform android-arm64
```

Debug APK path:

```text
build\app\outputs\flutter-apk\app-debug.apk
```

## Step 1 Scope

- Flutter project scaffold
- Material 3 app shell
- Riverpod bootstrap
- GoRouter configuration
- Dependency injection entrypoint
- Splash screen
- Login page
- Dashboard skeleton
- Clean Architecture folder structure
- Android host project files

## Step 2 Scope

- Drift database schema
- Secure credential storage boundaries
- Repository contracts
- Local repository implementations
- Dependency injection for persistence services

## Step 3 Scope

- Original RouterOS API socket client
- RouterOS sentence length encoding and decoding
- Modern and legacy RouterOS login flows
- Command execution, read responses, and listen streams
- Trap, fatal, timeout, SSL, and connection error handling
- VPN-required guard before RouterOS communication
- Router identity, resource, and interface snapshot service

## Step 4 Scope

- WireGuard config parser with QR-text import support
- VPN service abstraction and platform implementation
- Android MethodChannel and EventChannel bridge
- Official WireGuard Android tunnel dependency and `GoBackend` VPN service registration
- Tunnel status, statistics, logs, connect, disconnect, and import calls
- Secure storage for WireGuard configs
- Auto-reconnect coordinator

## Step 5 Scope

- Router list screen
- Add and edit router form
- Router repository providers
- Secure credential handoff from UI to storage boundary
- Delete router flow
- Test connection action through VPN-aware RouterOS service
- Dashboard navigation to router management

## Step 6 Scope

- Vexel Innovations branding constants
- Dashboard data provider
- Router snapshot display
- Router health panel
- Interface status panel
- Dashboard support/contact panel
- Utility formatting tests

## Step 7 Scope

- Hotspot users, profiles, active sessions, cookies, IP bindings, and queues domain entities
- RouterOS hotspot command service
- Create, update, delete, reset counters, disconnect, and remove command mappings
- Hotspot feature Riverpod providers
- Input validation for hotspot users, profiles, and IP bindings
- Hotspot entity and input mapping tests

## Step 8 Scope

- Hotspot management screen
- Router selector for hotspot operations
- Users, profiles, sessions, cookies, IP bindings, and queues tabs
- Create hotspot user workflow
- Create hotspot profile workflow
- Disconnect active session workflow
- Delete user, profile, cookie, and IP binding actions
- Dashboard navigation to hotspot management

## Step 9 Scope

- Voucher plan presets
- Random username and password generation
- Batch voucher generation service
- Secure voucher password storage through the voucher repository
- QR login payload service
- Vexel-branded receipt template foundation
- Voucher generation and history screen
- Dashboard navigation to voucher management

## Step 10 Scope

- Optional RouterOS hotspot user provisioning during voucher generation
- RouterOS profile selection field for generated vouchers
- Share receipt platform channel foundation
- Bluetooth printer service abstraction
- Android Bluetooth printer discovery and ESC/POS RFCOMM/SPP printing
- Vexel-branded ESC/POS text formatter foundation
- Voucher print/share actions

## Step 11 Scope

- Daily, weekly, and monthly report date ranges
- Revenue summary service
- Report export model and CSV/PDF-text export foundation
- Reports screen with router and period filters
- Revenue and transaction summary cards
- Sales list
- Export preview actions for PDF and Excel
- Dashboard navigation to reports

## Step 12 Scope

- Settings screen
- Theme, language, notification, and business-name settings model
- Printer settings UI
- Default printer handling
- Backup JSON payload foundation
- Backup preview UI
- Restore placeholder
- Dashboard navigation to settings

## Step 13 Scope

- Local PIN setup and login flow
- Salted SHA-256 PIN hashing
- Session token storage
- Biometric authentication boundary
- GoRouter authentication guard
- Sign-out control in Settings
- PIN hash tests

## Step 14 Scope

- Flutter SDK extraction and local verification
- Dependency resolution
- Drift code generation
- Analyzer cleanup
- Test cleanup
- Android SDK configuration
- AndroidX/Gradle/AGP/Kotlin build configuration updates
- Successful Android debug APK build for `android-arm64`

## Next Step

Step 15 continues production hardening with official WireGuard Android backend wiring, Bluetooth printer discovery/connection, and updated diagnostics. Next work should focus on real-device tunnel validation, polished export file generation, QR bitmap printing, and deeper RouterOS integration tests.
