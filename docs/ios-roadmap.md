# WireSpot iOS Roadmap

WireSpot is built with Flutter, so the app can target iOS when the project adds
the iOS platform folder and implements iOS equivalents for the current Android
platform channels.

## Current State

The repository currently contains an Android platform implementation only. The
shared Dart/Flutter layers already help us prepare for iOS:

- app UI and navigation
- router and voucher domain models
- RouterOS protocol code
- reports and receipt formatting
- local settings/repository patterns
- multi-brand router foundation
- hotspot setup presets

The missing part is native iOS platform work.

## iOS Work Required

| Area | Current Android path | iOS work needed |
| --- | --- | --- |
| Project platform | `android/` exists | Add `ios/` Flutter platform folder on macOS |
| Build tooling | Android Studio, Gradle | macOS, Xcode, CocoaPods, Apple Developer account |
| VPN | Android WireGuard tunnel backend | iOS Network Extension or supported WireGuard app handoff |
| Bluetooth printing | Android Bluetooth SPP channel | iOS-compatible printer path, usually BLE, AirPrint, or vendor SDK |
| Sharing | Android share intent channel | iOS share sheet channel or Flutter plugin |
| External actions | Android intents | iOS URL launcher equivalents |
| Billing | Google Play Billing planned | App Store in-app purchase/subscription path |
| Permissions | Android manifest/runtime permissions | iOS `Info.plist` usage descriptions and permission flow |
| CI/release | GitHub Android APK/AAB build | macOS runner for iOS archive/test builds |

## Practical Release Strategy

1. Finish the Android operator workflow and router connector architecture.
2. Add the iOS Flutter platform folder on a Mac.
3. Keep shared Dart features platform-neutral wherever possible.
4. Replace Android-only channel implementations with platform-specific
   Android/iOS implementations behind the same Dart interfaces.
5. Start iOS with core features: login, router records, reports, vouchers,
   sharing, and non-VPN local/cloud router access.
6. Add iOS VPN and printer support after validating the App Store-safe native
   approach.
7. Add App Store subscription/license support after Play Billing/server
   validation is settled.

## Feature Expectations

The final iOS app can support the same product goal as Android, but not every
native feature will be implemented the same way:

- RouterOS and cloud/controller APIs can work on iOS because they are network
  protocols.
- Voucher generation, reports, QR, co-branding, and setup presets should port
  cleanly.
- WireGuard control on iOS needs a dedicated iOS strategy because VPN APIs are
  stricter.
- Bluetooth thermal printing needs printer-model testing because many cheap
  ESC/POS printers expose Android-friendly SPP but not iOS-friendly BLE or
  AirPrint.

## Definition Of Done For iOS

- iOS project builds on macOS with Xcode.
- Core UI runs on iPhone and iPad layouts.
- Secure storage works for router credentials and voucher secrets.
- Router records, multi-brand selection, and setup presets work.
- MikroTik RouterOS network operations pass on a reachable test router.
- Sharing/export works through the iOS share sheet.
- Printer and VPN behavior has a documented supported path.
- App Store privacy, permissions, signing, and billing requirements are
  documented and tested.
