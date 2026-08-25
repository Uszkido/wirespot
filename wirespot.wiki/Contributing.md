# 🤝 Contributing

Thank you for helping improve WireSpot! This repository is the working source for a Vexel Innovations Android application for MikroTik RouterOS hotspot operations, voucher sales, WireGuard remote access, reports, printing, and operator licensing.

---

## Ground Rules

- ❌ Do **not** copy source code, UI, assets, or behavior from Mikhmon, WireNex, or any proprietary application.
- ❌ Do **not** commit real RouterOS credentials, WireGuard private keys, customer data, sales exports, Android keystores, or production secrets.
- ✅ Keep changes aligned with the architecture: **Flutter, Material 3, Riverpod, GoRouter, Drift/SQLite, repository pattern, and Android platform channels**.
- ✅ Keep pull requests focused — separate unrelated UI, networking, database, and documentation changes.
- ✅ Document user-facing changes in `README.md`, `CHANGELOG.md`, or `docs/`.

---

## Development Setup

### Install Dependencies

```powershell
flutter pub get
```

### Analyze

```powershell
flutter analyze
```

### Run Tests

```powershell
flutter test
```

### Build Debug APK

```powershell
flutter build apk --debug --target-platform android-arm64
```

### Generate Drift Code (after schema changes)

```powershell
dart run build_runner build
```

---

## Branch and Commit Style

### Branch Names

```
feature/routeros-hotspot-profile-limits
fix/wireguard-permission-resume
docs/play-store-release-guide
chore/android-release-signing
```

### Commit Messages

```
Add co-branded receipt logo path
Fix dashboard support layout
Document local license generation
```

---

## Pull Request Checklist

Before submitting for review:

- [ ] `flutter analyze` passes
- [ ] Relevant tests pass
- [ ] Android APK builds (when platform/dependency changes are involved)
- [ ] RouterOS command changes include tests or documented manual validation
- [ ] Database schema changes include generated Drift updates
- [ ] Security-sensitive behavior is documented
- [ ] No secrets, local caches, APKs, AABs, or signing files are staged

---

## Testing Expectations

Match testing depth to risk:

| Area | Testing Approach |
|------|-----------------|
| Domain logic | Unit tests |
| Repository/database | Repository or migration tests |
| RouterOS commands | Command/attribute tests |
| UI layout/navigation | Widget tests where practical |
| Platform channels | Method-channel tests + real-device testing |
| WireGuard, Bluetooth, RouterOS | Real-device validation notes in PR |

---

## Security and Privacy

Never put secrets in GitHub issues, PRs, screenshots, logs, or sample configs. Replace sensitive values with placeholders:

```
ROUTER_HOST
ROUTER_USERNAME
WIREGUARD_PRIVATE_KEY_REMOVED
CUSTOMER_PHONE_REMOVED
```

Report vulnerabilities privately using [SECURITY.md](https://github.com/Uszkido/wirespot/blob/main/SECURITY.md).

---

## License

WireSpot is proprietary Vexel Innovations software. Contributions are accepted only for the WireSpot project and may be used, modified, shipped, documented, licensed, or commercialized by Vexel Innovations as part of WireSpot.
