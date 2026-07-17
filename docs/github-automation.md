# GitHub Automation

WireSpot uses GitHub automation to keep the repository healthy and to make APK
testing easier after every push.

## Continuous Integration

Workflow: `.github/workflows/ci.yml`

Runs on:

- Every push to `main`
- Every pull request targeting `main`
- Manual runs from the GitHub Actions tab

Checks:

- Installs Flutter stable and Java 17
- Runs `flutter pub get`
- Checks Dart formatting for `lib` and `test`
- Runs `flutter analyze`
- Runs `flutter test`
- Builds an Android ARM64 debug APK
- Uploads the APK as a GitHub Actions artifact named `WireSpot-debug-apk`

The formatting step is advisory for now. It reports formatting problems but does
not block the whole workflow. Analyzer, tests, and APK build failures still fail
the workflow.

## Downloading CI APKs

1. Open the repository on GitHub.
2. Go to **Actions**.
3. Open the latest **WireSpot CI** run.
4. Scroll to **Artifacts**.
5. Download `WireSpot-debug-apk`.

This APK is for internal testing only. Play Store uploads should use signed
release builds or Android App Bundles.

## Dependency Automation

Workflow configuration: `.github/dependabot.yml`

Dependabot checks weekly for:

- GitHub Actions updates
- Dart and Flutter package updates from `pubspec.yaml`

Dependabot opens pull requests instead of pushing directly to `main`, so updates
can be reviewed and tested before merging.

## Reading Failed Checks

Open the failed run in the **Actions** tab and inspect the first failed step:

- `Install dependencies`: package resolution or Flutter SDK issue
- `Analyze project`: Dart analyzer error
- `Run tests`: failing unit/widget test
- `Build Android debug APK`: Android, Gradle, Kotlin, or plugin build issue

After fixing locally, commit and push again. GitHub will automatically rerun CI.
