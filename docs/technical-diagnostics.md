# WireSpot Technical Diagnostics

This guide helps diagnose Flutter, Android, RouterOS API, WireGuard, database, and build issues for WireSpot.

## Project Paths

Project root:

```powershell
C:\Users\HP\Documents\Codex\2026-07-10\you-are-an-expert-flutter-android
```

Local Flutter SDK:

```powershell
C:\tmp\wirespot_flutter\flutter
```

Android SDK:

```powershell
C:\Users\HP\AppData\Local\Android\Sdk
```

Debug APK output:

```powershell
build\app\outputs\flutter-apk\app-debug.apk
outputs\WireSpot-debug.apk
```

## Verified Build Command

The successful debug APK build used a single target platform to reduce Gradle download load:

```powershell
cd "C:\Users\HP\Documents\Codex\2026-07-10\you-are-an-expert-flutter-android"
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build apk --debug --target-platform android-arm64
```

## Environment Variables

If Android tooling is not detected, set these in the active PowerShell:

```powershell
$env:ANDROID_HOME = "C:\Users\HP\AppData\Local\Android\Sdk"
$env:ANDROID_SDK_ROOT = "C:\Users\HP\AppData\Local\Android\Sdk"
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
```

## Dependency And Code Generation

Resolve Flutter packages:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check pub get
```

Generate Drift database code:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\cache\dart-sdk\bin\dart.exe run build_runner build
```

Analyze:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check analyze
```

Run tests:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check test
```

## Known Build Notes

The project is configured with:

- AndroidX enabled
- Gradle wrapper `8.14.3`
- Android Gradle Plugin `8.11.1`
- Kotlin plugin `2.2.20`
- Extended Gradle HTTP timeouts

If Gradle hangs while downloading artifacts, build with:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build apk --debug --target-platform android-arm64
```

If a Java or Gradle process remains stuck:

1. Close Android Studio.
2. Open Task Manager.
3. End stale `java.exe`, `OpenJDK Platform binary`, `dart.exe`, or Gradle processes.
4. Re-run the single-target build command.

## GitHub Workflow

Remote:

```text
https://github.com/Uszkido/wirespot.git
```

Status:

```powershell
& "C:\Program Files\Git\cmd\git.exe" status
```

Commit:

```powershell
& "C:\Program Files\Git\cmd\git.exe" add .
& "C:\Program Files\Git\cmd\git.exe" commit -m "Describe change"
```

Push:

```powershell
& "C:\Program Files\Git\cmd\git.exe" push
```

Use normal Git, not Flutter's bundled mini-git, for GitHub pushes.

## RouterOS API Diagnostics

Check RouterOS API service:

```routeros
/ip service print where name~"api"
```

Enable API if needed:

```routeros
/ip service enable api
```

Enable SSL API only if certificates are configured:

```routeros
/ip service enable api-ssl
```

Check hotspot users:

```routeros
/ip hotspot user print
```

Check active hotspot sessions:

```routeros
/ip hotspot active print
```

Check hotspot profiles:

```routeros
/ip hotspot user profile print
```

## Network Diagnostics

From Android, verify:

- WireGuard tunnel is connected.
- Router VPN address is reachable.
- RouterOS API port is open.
- Router credentials are correct.
- RouterOS user has hotspot permissions.

From RouterOS, confirm the Android peer has an allowed IP and latest handshake:

```routeros
/interface wireguard peers print detail
```

## App Diagnostics

Common symptoms:

- Router test fails immediately: VPN disconnected or bad host/port.
- Login fails: wrong RouterOS username/password or disabled API service.
- SSL connection fails: API SSL not configured correctly on RouterOS.
- Dashboard metrics are blank: no router configured, VPN disconnected, or RouterOS command rejected.
- Voucher provisioning fails: selected profile does not exist or RouterOS user lacks write permission.

## Database Notes

Local persistence uses Drift/SQLite. Sensitive values such as router credentials and voucher passwords are stored through secure storage boundaries instead of plain text tables.

Generated Drift files are committed so the project can build immediately, but regenerate them after schema changes.

## Security Checklist

- Never commit real router credentials.
- Do not expose RouterOS API ports publicly.
- Use WireGuard for management access.
- Use dedicated RouterOS credentials with limited permissions.
- Rotate passwords if an operator device is lost.
- Keep release signing keys outside the repository.

