# WireSpot Workstation Transfer Guide

This guide explains how to move WireSpot development to another Windows PC
without losing the project, build setup, or Play Store release identity.

## What Must Be Preserved

The GitHub repository preserves the source code, documentation, tests, and
project history.

The Play Store upload keystore is different. Once created, it must be backed up
privately and must not be committed to GitHub.

Critical private files:

```text
android/app/upload-keystore.jks
android/key.properties
```

## New PC Requirements

Install:

- Git for Windows
- Flutter SDK
- Android Studio
- Android SDK Platform Tools
- Android SDK Build Tools
- Android SDK Command-line Tools
- Java bundled with Android Studio

Verify:

```powershell
git --version
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat doctor
```

If your Flutter SDK is installed somewhere else, replace the path in the
commands.

## Clone WireSpot

```powershell
git clone https://github.com/Uszkido/wirespot.git
cd wirespot
```

Check status:

```powershell
& "C:\Program Files\Git\cmd\git.exe" status
```

## Restore Dependencies

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check pub get
```

## Validate The Project

```powershell
C:\tmp\wirespot_flutter\flutter\bin\dart.bat format lib test tools
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check analyze
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check test
```

## Build Debug APK

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build apk --debug --target-platform android-arm64
```

Output:

```text
build\app\outputs\flutter-apk\app-debug.apk
```

## Restore Play Store Signing Files

Only after the upload keystore exists, copy the private files into the same
paths:

```text
android/app/upload-keystore.jks
android/key.properties
```

Then build release AAB:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build appbundle --release
```

## Files That Must Stay Private

Never push:

- `android/key.properties`
- `android/app/upload-keystore.jks`
- production API keys
- production billing secrets
- server license signing keys
- real router credentials
- customer private data

## Recommended Backup Locations

Use at least two:

- encrypted cloud drive
- external USB drive
- password manager secure file storage
- offline archive drive

## Handover Checklist

Before switching PC:

- push latest code to GitHub
- confirm working tree is clean
- back up upload keystore if it exists
- back up private passwords
- copy any test APKs or release artifacts you still need
- document Flutter and Android SDK paths

After switching PC:

- clone repository
- run `pub get`
- run analyze and tests
- build debug APK
- install APK on phone
- test router connection
- test WireGuard and printer flows
