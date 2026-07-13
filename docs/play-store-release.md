# WireSpot Play Store Release Guide

## Current Release Target

- Package name: `com.wirespot.app`
- Current version: see `VERSION`
- Release artifact: Android App Bundle (`.aab`)

## 1. Create Upload Keystore

Run this locally and keep the passwords private:

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

Copy `android/key.properties.template` to `android/key.properties` and fill in the passwords.

## 2. Build Release AAB

```powershell
cd "C:\Users\HP\Documents\Codex\2026-07-10\you-are-an-expert-flutter-android"

C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check clean
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check pub get
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check analyze
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check test
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build appbundle --release
```

Output:

```text
build\app\outputs\bundle\release\app-release.aab
```

## 3. Play Console Checklist

- App name: WireSpot
- Developer/company: Vexel Innovations
- Support email: Vexelvision@gmail.com
- Support phone: +234(0)7038953065
- Website: https://vexel-innovations.vercel.app/
- Privacy policy: publish `docs/privacy-policy.md` content on a public URL.
- App category: Tools or Business
- Content rating: complete Play Console questionnaire truthfully.
- Data Safety: declare local storage, camera for QR scanning, Bluetooth for printers, network access for router communication, and VPN functionality.
- Screenshots: dashboard, router setup, hotspot users, voucher generation, WireGuard, reports, settings.
- Testing track: start with Internal testing before Production.

## 4. Manual Release Validation

- Install release build on a real Android phone.
- Add a MikroTik router over local LAN.
- Test WireGuard permission and tunnel connection.
- Confirm RouterOS status loads.
- Confirm hotspot active users load.
- Generate a voucher.
- Print and share a voucher receipt.
- Export and share a report.
- Confirm license/trial screen behavior.

## 5. Important Notes

- Never commit `android/key.properties`.
- Never commit `android/app/upload-keystore.jks`.
- Keep Play App Signing enabled in Play Console.
- Production licensing should use Play Billing or server validation before public paid release.
