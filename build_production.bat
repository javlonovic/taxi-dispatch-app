@echo off
echo ========================================
echo Building Production APK (No Tests)
echo ========================================

echo.
echo [1/3] Cleaning previous builds...
call flutter clean
if %ERRORLEVEL% NEQ 0 (
    echo ERROR! Clean failed
    exit /b 1
)

echo.
echo [2/3] Getting dependencies...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo ERROR! Dependency fetch failed
    exit /b 1
)

echo.
echo [3/3] Building release APK...
call flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
if %ERRORLEVEL% NEQ 0 (
    echo ERROR! Build failed
    exit /b 1
)

echo.
echo ========================================
echo SUCCESS! Production APK built
echo ========================================
echo.
echo APK location: build\app\outputs\flutter-apk\app-release.apk
echo.
echo Next steps:
echo 1. Test the APK on a physical device
echo 2. Upload to Google Play Console
echo 3. Monitor Firebase Crashlytics for any issues
echo.
