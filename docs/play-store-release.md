# WireSpot Play Store Release Guide

This guide describes the release path for publishing WireSpot to Google Play.
It covers signing, release builds, Play Console setup, billing readiness, and
manual validation.

## Release Target

| Item | Value |
| --- | --- |
| App name | WireSpot |
| Android package | `com.wirespot.app` |
| Company | Vexel Innovations |
| Collaboration partner | TechNova Technologies |
| Release artifact | Android App Bundle (`.aab`) |
| Current version | See `VERSION` |
| Support email | Vexelvision@gmail.com |
| Website | https://vexel-innovations.vercel.app/ |

## Release Readiness Summary

Prepared in the repository:

- release signing configuration path
- `android/key.properties.template`
- ProGuard rules file
- privacy policy draft
- payment and licensing strategy
- Play Store release checklist

Required before production:

- create upload keystore
- keep keystore backed up securely
- configure `android/key.properties`
- build release AAB
- create Play Console listing
- configure subscriptions/products
- run internal testing
- validate WireGuard, RouterOS, printing, reports, and licensing on real phones

## 1. Create Upload Keystore

Run locally from the project root:

```powershell
cd "C:\Users\HP\Documents\Codex\2026-07-10\you-are-an-expert-flutter-android"

keytool -genkeypair `
  -v `
  -keystore android\app\upload-keystore.jks `
  -storetype JKS `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias wirespot
```

Back up the generated keystore immediately.

Never commit:

```text
android/app/upload-keystore.jks
android/key.properties
```

## 2. Configure Signing Properties

Copy:

```text
android/key.properties.template
```

to:

```text
android/key.properties
```

Fill in:

```properties
storePassword=...
keyPassword=...
keyAlias=wirespot
storeFile=app/upload-keystore.jks
```

Keep the passwords private.

## 3. Pre-release Checks

Run:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check clean
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check pub get
C:\tmp\wirespot_flutter\flutter\bin\dart.bat format lib test tools
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check analyze
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check test
```

The release should not proceed unless analysis and tests pass.

## 4. Build Release AAB

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build appbundle --release
```

Output:

```text
build\app\outputs\bundle\release\app-release.aab
```

## 5. Play Console Listing

Recommended listing values:

| Field | Value |
| --- | --- |
| App name | WireSpot |
| Developer | Vexel Innovations |
| Category | Tools or Business |
| Support email | Vexelvision@gmail.com |
| Support phone | +234(0)7038953065 |
| Website | https://vexel-innovations.vercel.app/ |
| Privacy policy | Public URL based on `docs/privacy-policy.md` |

## 6. Data Safety Notes

Declare truthfully in Play Console:

- local app settings and router records
- camera access for WireGuard QR scanning
- Bluetooth access for thermal printers
- network access for RouterOS communication
- VPN functionality for private router access
- generated/exported reports and voucher receipts
- future billing or license validation network calls

## 7. Screenshot Plan

Capture real screenshots for:

- dashboard
- router add/test connection
- WireGuard tunnel screen
- hotspot users/sessions
- voucher generation
- co-branded voucher receipt
- reports
- settings/license/co-branding
- permission readiness

Use realistic demo data and avoid exposing real router credentials.

## 8. Billing Setup

Create subscription products from:

- `wirespot_small_monthly`
- `wirespot_pro_monthly`
- `wirespot_pro_yearly`

For direct/offline installs, use:

- `wirespot_lifetime_device`

Production billing should validate purchase tokens through a backend before
granting long-term entitlement.

## 9. Internal Testing Checklist

Before production rollout:

- install from Play internal testing
- complete first launch and PIN setup
- add local MikroTik router
- test RouterOS API connection
- import and connect WireGuard tunnel
- load dashboard health data
- load hotspot users and active sessions
- generate voucher
- print/share voucher receipt
- export/share report
- test backup and restore
- test trial/license screens
- verify app survives restart
- verify no sensitive test data appears in screenshots

## 10. Release Safety

- Keep Play App Signing enabled.
- Back up the upload keystore in at least two secure places.
- Never commit signing files.
- Tag each production release in Git.
- Keep changelog updated.
- Test on more than one Android device before public rollout.
