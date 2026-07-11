# Changelog

All notable WireSpot changes should be documented here.

The format follows practical release notes for operators and maintainers.

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
