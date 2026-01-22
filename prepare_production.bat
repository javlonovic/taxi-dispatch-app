@echo off
echo ========================================
echo   Vezunchik Production Preparation
echo ========================================
echo.

echo [1/6] Cleaning build artifacts...
call flutter clean
if %errorlevel% neq 0 goto :error

echo.
echo [2/6] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 goto :error

echo.
echo [3/6] Generating localization files...
call flutter gen-l10n
if %errorlevel% neq 0 goto :error

echo.
echo [4/6] Analyzing production code (lib folder only)...
call flutter analyze lib
if %errorlevel% neq 0 (
    echo WARNING: Some analysis issues found, but continuing...
)

echo.
echo [5/6] Building release bundle...
call flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
if %errorlevel% neq 0 goto :error

echo.
echo [6/6] Building release APK...
call flutter build apk --release --obfuscate --split-debug-info=build/symbols
if %errorlevel% neq 0 goto :error

echo.
echo ========================================
echo   SUCCESS! Production build ready
echo ========================================
echo.
echo Release outputs:
echo - App Bundle: build\app\outputs\bundle\release\app-release.aab
echo - APK: build\app\outputs\flutter-apk\app-release.apk
echo - Debug symbols: build\symbols
echo.
echo Next steps:
echo 1. Test the release APK on real devices
echo 2. Deploy Firebase functions: firebase deploy
echo 3. Upload App Bundle to Google Play Console
echo 4. Monitor Firebase Crashlytics for issues
echo.
echo Note: Tests were skipped for production build.
echo Run 'flutter test' separately to verify test suite.
echo.
goto :end

:error
echo.
echo ========================================
echo   ERROR! Build failed
echo ========================================
echo.
echo Please fix the errors and try again.
echo.
exit /b 1

:end
pause
