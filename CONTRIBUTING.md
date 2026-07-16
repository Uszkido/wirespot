# Contributing To WireSpot

Thank you for helping improve WireSpot. This repository is the working source
for a Vexel Innovations Android application for MikroTik RouterOS hotspot
operations, voucher sales, WireGuard remote access, reports, printing, and
operator licensing.

## Ground Rules

- Do not copy source code, UI, assets, templates, or private behavior from
  Mikhmon, WireNex, or any proprietary application.
- Do not commit real RouterOS credentials, WireGuard private keys, customer
  data, sales exports, Android keystores, billing secrets, or production
  license-signing secrets.
- Keep changes aligned with the current architecture: Flutter, Material 3,
  Riverpod, GoRouter, Drift/SQLite, repository pattern, and Android platform
  channels where native behavior is required.
- Keep pull requests focused. Separate unrelated UI, networking, database, and
  documentation changes.
- Document user-facing changes in `README.md`, `CHANGELOG.md`, or `docs/`
  when needed.

## Development Setup

Project root:

```powershell
C:\Users\HP\Documents\Codex\2026-07-10\you-are-an-expert-flutter-android
```

Local Flutter SDK:

```powershell
C:\tmp\wirespot_flutter\flutter
```

Install packages:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check pub get
```

Run analysis:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check analyze
```

Run tests:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check test
```

Build a debug APK:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build apk --debug --target-platform android-arm64
```

Generate Drift code after database schema changes:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\cache\dart-sdk\bin\dart.exe run build_runner build
```

## Branch And Commit Style

Use clear branch names:

- `feature/routeros-hotspot-profile-limits`
- `fix/wireguard-permission-resume`
- `docs/play-store-release-guide`
- `chore/android-release-signing`

Use direct commit messages:

- `Add co-branded receipt logo path`
- `Fix dashboard support layout`
- `Document local license generation`

## Pull Request Checklist

Before review:

- `flutter analyze` passes.
- Relevant tests pass.
- Android APK builds when Android, platform-channel, or dependency behavior
  changes.
- RouterOS command changes include tests or documented manual validation.
- Database schema changes include generated Drift updates.
- Security-sensitive behavior is documented.
- No secrets, generated local caches, APKs, AABs, or signing files are staged.

## Testing Expectations

Match testing depth to risk:

- Domain logic: unit tests.
- Repository/database changes: repository or migration tests.
- RouterOS command generation: command/attribute tests.
- UI layout and navigation: widget tests where practical.
- Android platform channels: method-channel tests plus real-device testing.
- WireGuard, Bluetooth, and RouterOS integration: real-device/manual validation
  notes in the pull request.

## Security And Privacy

Never put secrets in GitHub issues, pull requests, screenshots, logs, or sample
configs. Replace sensitive values with placeholders such as:

```text
ROUTER_HOST
ROUTER_USERNAME
WIREGUARD_PRIVATE_KEY_REMOVED
CUSTOMER_PHONE_REMOVED
```

Report vulnerabilities privately using [SECURITY.md](SECURITY.md).

## License

WireSpot is proprietary Vexel Innovations software. Contributions are accepted
only for the WireSpot project and may be used, modified, shipped, documented,
licensed, or commercialized by Vexel Innovations as part of WireSpot.
