# Contributing To WireSpot

Thank you for helping improve WireSpot. This project is a Vexel Innovations
product for MikroTik RouterOS hotspot operations over secure or local network
connections.

## Ground Rules

- Do not copy Mikhmon, WireNex, or any proprietary application code.
- Do not commit real router credentials, WireGuard private keys, customer data,
  sales data, or printer pairing secrets.
- Keep changes aligned with the existing Clean Architecture, Riverpod, GoRouter,
  Drift, and platform-channel structure.
- Prefer small, focused commits.
- Run analysis and tests before opening a pull request.

## Development Setup

Project root:

```powershell
C:\Users\HP\Documents\Codex\2026-07-10\you-are-an-expert-flutter-android
```

Local Flutter SDK:

```powershell
C:\tmp\wirespot_flutter\flutter
```

Install dependencies:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check pub get
```

Generate Drift code after database schema changes:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\cache\dart-sdk\bin\dart.exe run build_runner build
```

Analyze:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check analyze
```

Test:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check test
```

Build debug APK:

```powershell
C:\tmp\wirespot_flutter\flutter\bin\flutter.bat --no-version-check build apk --debug --target-platform android-arm64
```

## Branch And Commit Style

Use descriptive branch names:

- `feature/local-lan-router-mode`
- `fix/routeros-login-timeout`
- `docs/operator-manual`
- `chore/android-build-config`

Use clear commit messages:

- `Add local LAN router mode`
- `Fix dashboard back navigation`
- `Document RouterOS API diagnostics`

## Pull Request Checklist

Before requesting review:

- Analysis passes.
- Relevant tests pass.
- APK builds if Android behavior changed.
- New database fields include migrations.
- New user-facing behavior is documented.
- No secrets or generated local caches are committed.

