# Changelog

All notable WireSpot changes should be documented here.

The format follows practical release notes for operators and maintainers.

## 0.1.3+4 - 2026-07-12

Premium and advanced hotspot foundation build.

### Added

- Local premium entitlement service and dev license keys for Play Store billing preparation.
- Premium gate foundation for batch vouchers and advanced voucher generation.
- Voucher encoding settings for username/password mode, PIN-only mode, numeric/alphanumeric generation, prefix, and length ranges.
- Advanced voucher generation controls for NGN price, data limit, profile, quantity, prefix, username length, and password length.
- Ticket template domain model for 58mm, 80mm, and QR compact ticket layouts.
- Scheduler settings foundation for active-session refresh, expired-user cleanup, voucher cleanup, daily sales summary, and database backup.
- Advanced hotspot profile inputs for upload/download speed, shared users, session timeout, idle timeout, keepalive timeout, price, and data limit metadata.
- Advanced hotspot user inputs for username/password, username-only, PIN-only, NGN price notes, time limit, profile, and data limit.

## 0.1.2+3 - 2026-07-11

Phone-tested navigation and layout fix build.

### Fixed

- Dashboard section buttons now push pages so Android back/swipe returns to the dashboard instead of exiting the app.
- Dashboard active-user count now reads hotspot active sessions and falls back to authorized hotspot hosts.
- Dashboard app bar uses a compact section menu to avoid right-side overflow on narrow phones.
- Report summary cards and settings printer dialog controls now have safer constraints for phone screens and larger text.
- Router add/edit save and cancel return to the previous page when possible.

## 0.1.1+2 - 2026-07-11

Step 15 hardening build.

### Added

- Real Android Bluetooth paired-printer listing through the printer platform channel.
- ESC/POS text receipt printing over Bluetooth RFCOMM/SPP for paired thermal printers.
- Android Bluetooth runtime permission handling.
- Settings dialog support for loading and selecting paired Bluetooth printers.
- Android VPN permission launch when WireGuard connect is requested.
- Official WireGuard Android tunnel dependency wiring through `com.wireguard.android:tunnel`.
- Android WireGuard `GoBackend` connect, disconnect, status, log, and statistics integration.

### Changed

- Printer platform errors now return operator-readable messages to Flutter.
- WireGuard Android layer now reports permission needs more clearly before backend connection.

### Still In Progress

- Official WireGuard tunnel backend is wired in. Final validation requires a real Android device, a valid WireGuard config, and first-time Gradle dependency resolution.

## 0.1.0+1 - 2026-07-11

Initial active development build.

### Added

- Flutter Android project scaffold.
- Vexel Innovations branding and logo.
- Local PIN setup and login flow.
- Dashboard shell with router health panels.
- Router management with secure credential storage.
- RouterOS API client implemented from scratch.
- WireGuard service abstraction and Android platform-channel foundation.
- Local LAN router mode with per-router `Require WireGuard VPN` toggle.
- Hotspot users, profiles, sessions, cookies, IP bindings, and queues management foundation.
- Voucher generation, QR payload, receipt template, history, print/share foundations.
- Reports, revenue summaries, export foundations, settings, backup preview.
- Android debug APK build flow.
- User manual and technical diagnostics documentation.

### Verified

- `flutter analyze` passes.
- Android debug APK builds with:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build apk --debug --target-platform android-arm64
```

### Known Limitations

- Real-device WireGuard tunnel validation and reconnect hardening are still production-hardening tasks.
- Vendor-specific ESC/POS handling needs completion for printers that do not support standard SPP text mode.
- Export actions are foundations and need polished file output flows.
- Full RouterOS hotspot server setup wizard is planned for a later step.
