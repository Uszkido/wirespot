# 🚀 Getting Started

## Requirements

### Development Environment
- Windows development machine
- Flutter SDK
- Android Studio
- Android SDK and platform tools
- Git for Windows

### Testing
- Android phone for real VPN / Bluetooth / router testing
- MikroTik RouterOS router with API enabled for full live hotspot operations
- Ruijie/Reyee, OpenWrt, TP-Link Omada, UniFi, or generic router for planned connector discovery

### Future iOS
- macOS, Xcode, CocoaPods, and Apple Developer account (see [[FAQ]])

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Uszkido/wirespot.git
cd wirespot
```

### 2. Install Dependencies

```powershell
flutter pub get
```

### 3. Analyze the Code

```powershell
flutter analyze
```

### 4. Run Tests

```powershell
flutter test
```

### 5. Build Debug APK

```powershell
flutter build apk --debug --target-platform android-arm64
```

Debug APK output:

```
build\app\outputs\flutter-apk\app-debug.apk
```

Current packaged debug APK:

```
outputs\WireSpot-0.1.26+27-brand-collaboration-debug.apk
```

---

## Installing the APK

1. Transfer the debug APK to your Android phone.
2. Android may ask to allow installs from the source app — approve it.
3. Install and open WireSpot.

---

## First Launch

1. **Open WireSpot** on your Android device.
2. **Create a local PIN** — this is your app access code (stored as a salted hash).
3. **Enable biometric login** if your device supports it.
4. **Follow the onboarding guide**. Tap **Next** to move through router setup,
   WireGuard, and cloud backup guidance, or tap **Skip** to go straight to the
   dashboard. The guide appears automatically only for a new installation.
5. **Add a router** from the Dashboard → Routers.
6. **Review Settings** for language, currency, license, VPN, and printer.

### Cloud sync from the web dashboard

The web dashboard starts with signup/login. Open **Cloud Sync → Cloud Settings**,
enter the deployed WireSpot API base URL, save it, test `/health`, and select
**Sync Now**. Voucher uploads and router refreshes use the authenticated cloud
session; the dashboard does not ship with fake router records.

---

## What's Next?

- [[User Manual]] — Full end-to-end operator guide
- [[Router Setup and Fleet Management]] — Configure your first router
- [[Licensing]] — Activate your trial or license
- [[Architecture Overview]] — Understand the codebase
