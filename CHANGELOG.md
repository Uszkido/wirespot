# Changelog

All notable WireSpot changes should be documented here.

The format follows practical release notes for operators and maintainers.

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

- Official WireGuard Android backend integration is still a production-hardening task.
- Bluetooth printer discovery and vendor-specific ESC/POS handling need completion.
- Export actions are foundations and need polished file output flows.
- Full RouterOS hotspot server setup wizard is planned for a later step.

