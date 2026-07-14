# WireSpot Complete Operator Guide

This guide explains WireSpot from setup to daily operation, activation,
testing, backup, and Play Store preparation.

## 1. What WireSpot Is

WireSpot is an Android app for managing MikroTik RouterOS hotspot operations.
It supports router management, local LAN access, WireGuard remote access,
hotspot users, profiles, sessions, voucher generation, QR codes, ticket
printing, reporting, scheduler settings, backup, app security, and licensing.

## 2. Main Features

- App login with local PIN and biometric-ready flow.
- Secure router credential storage.
- Multiple MikroTik router records.
- Local LAN mode and WireGuard-required mode.
- Router connection testing.
- Dashboard with online users, sales, CPU, memory, health, and interfaces.
- Hotspot users, profiles, active sessions, queues, cookies, and IP bindings.
- Hotspot setup assistant with review before applying changes.
- Single and batch voucher generation.
- Username/password, username-only, and PIN-style voucher modes.
- Voucher QR payload generation.
- Bluetooth thermal printer support for 58mm and 80mm receipts.
- Ticket template settings.
- Sales and revenue reporting.
- CSV and PDF-text report export.
- Scheduler settings and in-app execution.
- Settings for language, currency, notifications, backup, printer, VPN, and
  license.
- Professional co-branding settings for operator business details.
- 7-day trial and device-bound local license support.

## 3. Recommended Router Security

For remote routers, do not expose RouterOS API ports directly to the internet.
Use WireGuard.

Recommended approach:

1. Configure WireGuard on the MikroTik router.
2. Import the WireGuard client config into WireSpot.
3. Mark the router in WireSpot as requiring WireGuard.
4. Connect the VPN before testing RouterOS API access.

For on-site/local routers, use local LAN mode and connect directly to the
router IP from the same network.

## 4. Installing the APK

Build or copy the latest debug APK:

```text
outputs\WireSpot-0.1.23+24-cobranding-docs-debug.apk
```

Transfer it to the phone and install it. Android may ask you to allow installs
from the source app.

## 5. First Launch

1. Open WireSpot.
2. Create or enter your local PIN.
3. Use the dashboard to add a router.
4. Go to Settings to review language, currency, license, VPN, and printer
   settings.

## 6. Adding a Router

Use the Routers screen:

1. Tap add router.
2. Enter router name, host/IP, port, username, and password.
3. Choose whether the router requires WireGuard.
4. Save.
5. Tap test connection.

RouterOS API access must be enabled on the MikroTik router. The default API
port is usually `8728`; API-SSL is usually `8729` when configured.

## 7. Local LAN Mode

Use local LAN mode when the phone is connected to the same network as the
MikroTik router.

Example:

```text
Router IP: 192.168.88.1
API port: 8728
Require WireGuard: Off
```

## 8. WireGuard Remote Mode

Use WireGuard remote mode when managing a router away from the site.

Steps:

1. Open Settings.
2. Open WireGuard VPN.
3. Import a WireGuard config or scan a QR config.
4. Request Android VPN permission if prompted.
5. Tap Connect.
6. Return to Routers and test connection.

If Android VPN permission does not appear, open Settings > Permission
readiness and request VPN consent from there.

## 9. Hotspot Management

The Hotspot screen is for daily customer/user operations:

- View hotspot users.
- Create new users.
- Edit user profile/time/data fields.
- Disconnect active sessions.
- Reset counters.
- Delete users.
- Manage profiles.
- Review sessions, cookies, IP bindings, and queues.

## 10. Hotspot Setup

The hotspot setup assistant helps prepare common MikroTik hotspot components.
Review the generated plan before applying changes. Field testing on real
routers is still recommended before using it on a production site.

## 11. Voucher Generation

Vouchers support:

- Single generation.
- Batch generation.
- Random usernames.
- Random passwords.
- Username-only or PIN-style users.
- Profile selection.
- Price in the selected currency.
- Time quantity.
- Prefix settings.
- QR code payload.
- Receipt preview, share, and print output.

## 12. Voucher Encoding

Settings > Voucher encoding controls:

- Username + password.
- Username only.
- Username as PIN.
- Numeric, alphabetic, or alphanumeric codes.
- Username/password length ranges.
- Prefix.
- Avoid confusing characters.

## 13. Printing

WireSpot supports Bluetooth thermal printer setup:

1. Pair the printer in Android Bluetooth settings.
2. Open WireSpot Settings.
3. Add printer.
4. Load paired printers.
5. Select the printer.
6. Choose 58mm or 80mm.
7. Save.

Printer output depends on printer ESC/POS compatibility. Real printer testing
is still required for each printer model.

## 14. Reports

Reports support:

- Daily, weekly, and monthly ranges.
- Revenue summary.
- Sales history.
- CSV export.
- PDF-text export.
- Android share sheet support.

## 15. Settings

Settings includes:

- Brand and Vexel Innovations support contact.
- Security/sign out.
- Permission readiness.
- WireGuard VPN.
- Premium license.
- Theme.
- Language: English, French, Hausa labels.
- Default currency.
- Notifications.
- Professional co-branding.
- Voucher encoding.
- Ticket templates.
- Scheduler.
- Printers.
- Backup preview and JSON restore.

## 16. Trial and License Activation

WireSpot includes a 7-day full-access trial.

After trial expiry, a license is required.

To activate with a local device license:

1. Open Settings.
2. Copy the Device License ID.
3. Generate a license key with:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\dart.bat run tools/license_generator.dart DEVICE_ID
```

4. Enter the generated key in Settings.
5. Tap Apply license.

Each generated license key is for one device/account device ID.

## 17. Professional Co-branding

Professional users can configure operator branding in Settings:

- Business name.
- Business email.
- Business phone.
- Business website.

Current behavior:

- Voucher receipts show the operator business details.
- Reports show the operator identity.
- WireSpot remains identified as powered by Vexel Innovations.

This keeps the app suitable for technicians, resellers, hotels, estates, and
ISPs who want customer-facing materials to carry their own business identity.

## 18. Backup and Restore

Backup preview creates a JSON-style snapshot of settings and printer profiles.
Restore accepts that JSON and writes supported settings and printer profiles
back into the local database.

## 19. Building the App

From the project root:

```powershell
cd "C:\Users\HP\Documents\Codex\2026-07-10\you-are-an-expert-flutter-android"
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check pub get
C:\tmp\wirespot_flutter\flutter\bin\dart.bat format lib test
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check analyze
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check test
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build apk --debug --target-platform android-arm64
```

Debug APK output:

```text
build\app\outputs\flutter-apk\app-debug.apk
```

## 20. Play Store Release Path

Before Play Store release:

1. Create upload keystore.
2. Configure `android/key.properties`.
3. Build release AAB.
4. Create Google Play Console app.
5. Upload AAB to internal testing.
6. Add privacy policy URL.
7. Add screenshots, description, category, and support contact.
8. Add Play Billing subscription products.
9. Test purchase and restore flows.
10. Promote from internal testing after validation.

See:

- `docs/play-store-release.md`
- `docs/payment-and-licensing.md`
- `docs/privacy-policy.md`

## 21. Moving to Another PC

See:

```text
docs/workstation-transfer.md
```

The most important thing is to keep the Play Store upload keystore backed up
once it is created.

## 22. Troubleshooting

Router cannot connect:

- Confirm phone network/VPN route.
- Confirm RouterOS API service is enabled.
- Confirm host/IP and port.
- Confirm username/password.
- Confirm WireGuard is connected for remote routers.

VPN cannot connect:

- Re-import config.
- Request Android VPN permission.
- Check phone VPN settings.
- Confirm RouterOS WireGuard peer and allowed IPs.

Printer cannot print:

- Pair printer in Android first.
- Load paired printers in WireSpot.
- Confirm printer supports ESC/POS over Bluetooth SPP.
- Try both 58mm and 80mm settings.

License does not activate:

- Copy the exact Device License ID from Settings.
- Generate a new license with that ID.
- Paste the generated key without extra spaces.
- Tap Apply license.

## 23. Current Production Readiness

WireSpot is suitable for continued field testing with real MikroTik routers.
The core Android app, RouterOS integration, dashboard metrics, hotspot
workflows, voucher generation, licensing foundation, co-branding, printing
path, reports, and debug APK build are working.

Production release readiness still requires release signing, Google Play
Billing validation, Play Store internal testing, broader Android device
coverage, and printer model validation.
