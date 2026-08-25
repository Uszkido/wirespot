# 🔧 Troubleshooting

## Router Connection Issues

| Symptom | Diagnosis |
|---------|-----------|
| **Cannot connect** | Confirm phone network/VPN route, host/IP, and port |
| **Login fails** | Wrong RouterOS username/password or disabled API service |
| **SSL connection fails** | API-SSL not configured correctly on RouterOS |
| **Dashboard metrics blank** | No router configured, VPN disconnected, or RouterOS command rejected |
| **Voucher provisioning fails** | Profile doesn't exist or RouterOS user lacks write permission |

### RouterOS API Verification

Check that the API service is enabled:

```routeros
/ip service print where name~"api"
```

Enable plain API if needed:

```routeros
/ip service enable api
```

Check hotspot users and sessions:

```routeros
/ip hotspot user print
/ip hotspot active print
/ip hotspot user profile print
```

---

## VPN Issues

| Symptom | Diagnosis |
|---------|-----------|
| **VPN won't connect** | Re-import config and check syntax |
| **Permission not appearing** | Settings → Permission readiness → Request VPN consent |
| **Tunnel times out** | Verify router WireGuard peer config and allowed IPs |
| **Router unreachable over VPN** | Check VPN address matches the router record host |

### Verify RouterOS WireGuard Peer

```routeros
/interface wireguard peers print detail
```

Confirm the Android peer has an allowed IP and shows a recent handshake.

---

## Printer Issues

| Symptom | Diagnosis |
|---------|-----------|
| **Printer not listed** | Pair in Android Bluetooth settings first |
| **Print fails** | Confirm printer is powered on, not connected to another app |
| **Garbled output** | Try switching 58mm ↔ 80mm |
| **No permission** | Approve Bluetooth permission, then retry |

---

## Build Issues

### Gradle Hangs

If Gradle hangs downloading artifacts:

1. Build with single target: `flutter build apk --debug --target-platform android-arm64`
2. If processes are stuck: Close Android Studio → Task Manager → End stale `java.exe`, `dart.exe`, or Gradle processes → Retry.

### Environment Variables

If Android tooling is not detected, set in PowerShell:

```powershell
$env:ANDROID_HOME = "C:\Users\<USER>\AppData\Local\Android\Sdk"
$env:ANDROID_SDK_ROOT = "C:\Users\<USER>\AppData\Local\Android\Sdk"
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
```

### Drift Code Generation

After database schema changes:

```powershell
dart run build_runner build
```

---

## License Issues

| Symptom | Diagnosis |
|---------|-----------|
| **License remains in trial** | Generate key with the exact Device License ID shown on the phone |
| **Key rejected** | Paste without extra spaces |
| **Still shows trial** | Tap **Apply license** after pasting |

---

## Language Issues

If language does not change:
- Restart the screen or app after changing language.
- Confirm translated labels are available for that page.

---

## Database Notes

- Local persistence uses **Drift/SQLite**
- Sensitive values are stored through secure storage boundaries
- Generated Drift files are committed for immediate builds
- Regenerate after schema changes

---

## Security Checklist

- ✅ Never commit real router credentials
- ✅ Do not expose RouterOS API ports publicly
- ✅ Use WireGuard for management access
- ✅ Use dedicated RouterOS credentials with limited permissions
- ✅ Rotate passwords if a device is lost
- ✅ Keep release signing keys outside the repository
