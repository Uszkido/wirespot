# WireSpot License Generation Guide

This guide explains how to generate and apply local device-bound WireSpot
licenses for direct APK installs, field testing, early customers, and offline
operators.

## Overview

WireSpot includes:

- 7-day full-access trial.
- Device license ID shown inside Settings.
- Device-bound license generator.
- Local license activation inside the app.

Each generated license is tied to one WireSpot device ID. A key generated for
one phone should not activate another phone.

## When To Use Local Licenses

Use local licenses for:

- direct APK installs outside Play Store
- early field testing
- enterprise/offline customers
- customers who cannot use Google Play Billing
- support demos and controlled pilots

For public Play Store release, use Play Billing or server-side validation as
the production licensing path.

## Operator Activation Flow

1. Open WireSpot.
2. Go to **Settings**.
3. Find **Premium license**.
4. Copy the **Device license ID**.
5. Send the device ID to the license issuer.
6. Enter the returned license key in WireSpot.
7. Tap **Apply license**.
8. Confirm the license status changes to active.

## Generate A License

From the project root:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\dart.bat run tools\license_generator.dart DEVICE_ID
```

Example:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\dart.bat run tools\license_generator.dart 1234567890ABCDEF
```

Example output:

```text
1234567890ABCDEF => WS-12345678-XXXXXXXXXXXXXXXX
```

Use the generated `WS-...` value as the license key in WireSpot Settings.

## Batch Generation

You can pass multiple device IDs:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\dart.bat run tools\license_generator.dart DEVICE_ID_1 DEVICE_ID_2 DEVICE_ID_3
```

The tool prints one license per device ID.

## Rules

- Device IDs must be at least 8 characters.
- Copy the device ID exactly from WireSpot.
- Remove accidental spaces before generating.
- Do not reuse one device license for multiple operators.
- Store issued license records securely.

## Recommended License Record

Keep a private record like this:

```text
Customer:
Business:
Phone:
Email:
Device ID:
License key:
Plan:
Issued date:
Expiry or lifetime:
Notes:
```

## Security Notes

Local licenses are useful for offline/direct distribution, but they are not a
replacement for production billing security. For public paid release, validate
entitlements with Google Play Billing or a Vexel license server.

Never publish private signing keys, billing secrets, or server license signing
secrets in the GitHub repository.
