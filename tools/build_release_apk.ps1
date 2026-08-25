# WireSpot Release APK Build Automation Script
# Usage: .\tools\build_release_apk.ps1

Write-Host "================================================" -ForegroundColor Cyan
Write-Host " Starting WireSpot Production Build Pipeline" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# 1. Run Static Analyzer
Write-Host "`n[1/3] Running static code analysis (flutter analyze)..." -ForegroundColor Yellow
flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "Analysis failed. Please fix analyzer issues before building." -ForegroundColor Red
    exit 1
}
Write-Host "Static analysis passed with 0 issues!" -ForegroundColor Green

# 2. Run Test Suite
Write-Host "`n[2/3] Running unit test suite (flutter test)..." -ForegroundColor Yellow
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "Unit tests failed. Aborting build." -ForegroundColor Red
    exit 1
}
Write-Host "All unit tests passed successfully!" -ForegroundColor Green

# 3. Assemble Release APK
Write-Host "`n[3/3] Assembling Flutter release APK (flutter build apk --release)..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nRelease build completed successfully!" -ForegroundColor Green
    Write-Host "Output APK location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
} else {
    Write-Host "Release APK build failed." -ForegroundColor Red
    exit 1
}
