# WireSpot Technical Diagnostics

This guide helps diagnose Flutter, Android, RouterOS API, WireGuard, database,
Bluetooth printer, licensing, and release-build issues for WireSpot.

## 1. Project Paths

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

## 2. Verified Build Command

The successful debug APK build used a single target platform to reduce Gradle download load:

```powershell
cd "C:\Users\HP\Documents\Codex\2026-07-10\you-are-an-expert-flutter-android"
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build apk --debug --target-platform android-arm64
```

## 3. Environment Variables

If Android tooling is not detected, set these in the active PowerShell:

```powershell
$env:ANDROID_HOME = "C:\Users\HP\AppData\Local\Android\Sdk"
$env:ANDROID_SDK_ROOT = "C:\Users\HP\AppData\Local\Android\Sdk"
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
```

## 4. Dependency And Code Generation

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

## 5. Known Build Notes

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

## 6. GitHub Workflow

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

## 7. RouterOS API Diagnostics

Check RouterOS API service:

```routeros
/ip service print where name~"api"
```

Enable plain API if needed:

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

## 8. Local LAN Versus WireGuard Mode

Each router has a `requireVpn` flag:

- `true`: WireSpot checks that WireGuard/VPN status is connected before RouterOS API commands.
- `false`: WireSpot skips the VPN guard and connects directly to the router host/port.

## 9. WireGuard Android Backend

WireSpot uses the official WireGuard Android tunnel library through `com.wireguard.android:tunnel` and registers the WireGuard `GoBackend` VPN service in the Android manifest.

If VPN connect does not work:

1. Confirm Gradle downloaded `com.wireguard.android:tunnel`.
2. Confirm Android VPN permission was approved.
3. Import a valid WireGuard config with `[Interface]` and `[Peer]`.
4. Keep the tunnel name within WireGuard's Android name rules.
5. Check WireSpot VPN logs from the app diagnostics screen.

Default is `true` for safety. Existing routers are migrated to `true`.

Use local mode only when the Android device is on the same trusted LAN as the MikroTik. Do not expose RouterOS API ports to the public internet.

## 10. Bluetooth Printer Diagnostics

WireSpot can list paired Bluetooth printers and print ESC/POS text receipts over RFCOMM/SPP.

Checklist:

1. Pair the thermal printer in Android Bluetooth settings first.
2. Open WireSpot Settings.
3. Tap Add printer.
4. Tap Load paired printers.
5. Approve Bluetooth permission if Android asks.
6. Select the printer and save.

If printing fails:

- Confirm the printer is powered on.
- Confirm it is paired in Android settings.
- Confirm no other app is currently connected to the printer.
- Try turning Bluetooth off and on.
- Retry the print action after permission approval.

Supported production path:

- Paired Bluetooth thermal printers.
- ESC/POS text receipts.
- Standard serial profile UUID `00001101-0000-1000-8000-00805F9B34FB`.

Model-dependent validation:

- Vendor-specific printer SDKs.
- Bitmap QR/image printing.

## 11. Network Diagnostics

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

## 12. App Diagnostics

Common symptoms:

- Router test fails immediately: VPN disconnected or bad host/port.
- Login fails: wrong RouterOS username/password or disabled API service.
- SSL connection fails: API SSL not configured correctly on RouterOS.
- Dashboard metrics are blank: no router configured, VPN disconnected, or RouterOS command rejected.
- Voucher provisioning fails: selected profile does not exist or RouterOS user lacks write permission.
- License remains in trial: generate the key with the exact Device License ID
  shown on the phone and paste it without extra spaces.
- Language does not change: restart the screen or app after changing language,
  then confirm translated labels are available for that page.

## 13. Database Notes

Local persistence uses Drift/SQLite. Sensitive values such as router credentials and voucher passwords are stored through secure storage boundaries instead of plain text tables.

Generated Drift files are committed so the project can build immediately, but regenerate them after schema changes.

## 14. Security Checklist

- Never commit real router credentials.
- Do not expose RouterOS API ports publicly.
- Use WireGuard for management access.
- Use dedicated RouterOS credentials with limited permissions.
- Rotate passwords if an operator device is lost.
- Keep release signing keys outside the repository.
