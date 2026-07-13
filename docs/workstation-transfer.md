# Moving WireSpot to Another PC

This guide explains how to continue WireSpot development on another Windows PC.

## 1. Install Required Tools

Install:

- Git for Windows
- Flutter SDK
- Android Studio
- Android SDK Platform Tools
- Android SDK Build Tools
- Android SDK Command-line Tools

Verify:

```powershell
git --version
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat doctor
```

## 2. Clone the Repository

```powershell
git clone https://github.com/Uszkido/wirespot.git
cd wirespot
```

## 3. Restore Flutter Packages

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check pub get
```

## 4. Build a Debug APK

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build apk --debug --target-platform android-arm64
```

Output:

```text
build\app\outputs\flutter-apk\app-debug.apk
```

## 5. Play Store Keystore Backup

When the upload keystore is created, back up these files securely:

```text
android/app/upload-keystore.jks
android/key.properties
```

Do not commit them to GitHub. Keep copies in at least two secure places, such
as an encrypted cloud drive and an external USB drive.

If the upload keystore is lost, publishing updates to the Play Store becomes
much harder and may require Google Play App Signing recovery.

## 6. Files That Should Stay Private

Never push these to GitHub:

- `android/key.properties`
- `android/app/upload-keystore.jks`
- production API keys
- production billing secrets
- server signing private keys

## 7. After Cloning on a New PC

Run:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check analyze
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check test
```

Then build and install the APK on a test phone before continuing development.
