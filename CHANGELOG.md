# Changelog

All notable WireSpot changes should be documented here.

The format follows practical release notes for operators and maintainers.

## 0.1.22+23 - 2026-07-13

Settings, language, currency, and support polish build.

### Added

- Root app wiring for saved theme and language preferences.
- Hausa language option beside English and French for WireSpot-controlled labels.
- Default currency setting with NGN and common African/global currencies.
- More organized Vexel Innovations support card with copyable contact rows.
- Workstation transfer guide for moving the project to another PC.

### Changed

- License card now makes active licensed access clear even during the trial period.
- Applying a license now shows an immediate refresh confirmation.

## 0.1.21+22 - 2026-07-13

Payment and licensing foundation build.

### Added

- Subscription plan catalog for trial, monthly, yearly, and lifetime device plans.
- Entitlement source tracking for trial, device license, Google Play, server license, and development access.
- Expiring billing entitlement support for future Play Billing and server validation.
- License settings UI with active plan/source details and subscription plan list.
- Payment and licensing strategy documentation with Play Console product IDs.
- Unit coverage for active and expired billing entitlements.

## 0.1.20+21 - 2026-07-13

Play Store release preparation build.

### Added

- Release signing configuration using local `android/key.properties`.
- Safe signing properties template and ProGuard rules placeholder.
- Privacy policy draft for Play Store publication.
- Play Store release guide with AAB build and listing checklist.

## 0.1.19+20 - 2026-07-13

Reports export polish build.

### Changed

- Improved report PDF text layout with branded summary and detailed sales sections.
- Expanded CSV export columns with minor-unit and major-unit amounts.
- Added report sharing through the Android share sheet.
- Expanded report export tests.

## 0.1.18+19 - 2026-07-13

Scheduler execution engine build.

### Added

- In-app scheduler execution service that starts at app boot.
- Due-task interval checks and last-run status recording.
- Daily sales summary and database backup scheduler execution actions.
- Scheduler last-run status display in Settings.
- Scheduler execution service tests.

## 0.1.17+18 - 2026-07-13

Thermal logo raster build.

### Added

- Android ESC/POS raster logo printing from the Vexel logo asset.
- Paper-width-aware logo scaling before voucher receipt text.
- Best-effort logo printing fallback so receipts still print if raster output fails.
- Platform printer test coverage for logo asset handoff.

## 0.1.16+17 - 2026-07-13

Native thermal QR build.

### Added

- ESC/POS native QR commands for voucher receipt printing.
- Paper-width-aware QR sizing for 58mm and 80mm printers.
- Text fallback payload below the native QR block.

## 0.1.15+16 - 2026-07-13

Thermal receipt layout build.

### Changed

- Improved 58mm and 80mm thermal receipt text layout.
- Added ESC/POS text alignment, bold, and header sizing commands.
- Wrapped QR payloads and long contact lines for narrow receipt printers.
- Expanded receipt formatter test coverage.

## 0.1.14+15 - 2026-07-13

Ticket template editor build.

### Added

- Editable ticket template layout controls in Settings.
- Saved custom ticket template fields for paper width, logo marker, QR, price, and footer.
- Ticket template serialization coverage.

## 0.1.13+14 - 2026-07-13

WireGuard permission hotfix build.

### Fixed

- Android VPN permission approval now returns to WireSpot and resumes the pending tunnel connection.
- WireGuard auto-reconnect settings are hydrated after the Flutter frame instead of during build.
- WireGuard VPN service now has an explicit label for Android VPN settings.

## 0.1.12+13 - 2026-07-12

WireGuard QR import build.

### Added

- Camera permission declaration for WireGuard QR imports.
- WireGuard QR scanner page backed by `mobile_scanner`.
- Scan QR action on the WireGuard tunnel card.
- Camera readiness guidance on the Permissions screen.

## 0.1.11+12 - 2026-07-12

Android permission readiness build.

### Added

- Permission Readiness screen for VPN consent, Bluetooth printer access, and network permission guidance.
- Direct Android WireGuard VPN permission request method through the platform channel.
- Settings shortcut for permission readiness checks.
- WireGuard page action for granting Android VPN access before connecting.

## 0.1.10+11 - 2026-07-12

Trial licensing and operator access build.

### Added

- 7-day app trial with full-app license gate after expiry.
- Device-bound license ID and license status in Settings.
- Local license generator script and license-generation documentation.
- Dashboard online-users metric now opens Hotspot sessions directly.
- WireGuard page now explains Android VPN consent requirements.
- WireGuard selected-tunnel and auto-reconnect settings foundation.

### Changed

- Dashboard app bar branding is more restrained and professional.

## 0.1.9+10 - 2026-07-12

WireGuard management screen build.

### Added

- WireGuard page for tunnel import, connect, disconnect, status, statistics, and logs.
- WireGuard route linked from Settings.
- Router action shortcut for routers that require WireGuard.

## 0.1.8+9 - 2026-07-12

Hotspot setup analyzer cleanup build.

### Fixed

- Added a mounted guard before opening the hotspot setup review dialog after an async gap.

## 0.1.7+8 - 2026-07-12

Hotspot setup review build.

### Added

- Review step before applying hotspot setup changes.
- Hotspot setup plan model that lists planned RouterOS command groups and attributes.
- Unit coverage for setup plan ordering.

## 0.1.6+7 - 2026-07-12

Advanced hotspot network provisioning build.

### Added

- Optional LAN provisioning controls in the hotspot setup assistant.
- RouterOS IP address, pool, DHCP network, DHCP server, and NAT masquerade command generation.
- Idempotent RouterOS checks before adding network provisioning records.
- Unit coverage for advanced hotspot provisioning attributes.

## 0.1.5+6 - 2026-07-12

Hotspot setup assistant build.

### Added

- Hotspot setup assistant entry point on the Hotspot screen.
- RouterOS hotspot setup input model for server name, interface, server profile, DNS name, hotspot address, pool, login modes, and RADIUS.
- RouterOS hotspot setup service flow that creates/reuses the hotspot server profile and adds or updates the hotspot server.
- Unit coverage for hotspot setup RouterOS attribute mapping.

## 0.1.4+5 - 2026-07-12

Ticket template selection build.

### Added

- Premium-gated ticket template selector in Settings.
- Settings-backed selected receipt template for voucher preview, sharing, and printing.
- Receipt output now includes the selected template name and template footer.

### Fixed

- QR preview visibility now follows the selected template instead of requiring a voucher password.

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
