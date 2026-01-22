@echo off
REM Script to generate splash screen for Android and iOS

echo ========================================
echo Generating Splash Screen
echo ========================================
echo.

REM Check if splash logo exists
if not exist "assets\splash\splash_logo.png" (
    echo ERROR: assets\splash\splash_logo.png not found!
    echo Please add your splash logo file before running this script.
    echo See assets\splash\LOGO_PLACEHOLDER.md for details.
    echo.
    pause
    exit /b 1
)

echo Step 1: Running flutter pub get...
call flutter pub get
if errorlevel 1 (
    echo ERROR: flutter pub get failed
    pause
    exit /b 1
)
echo.

echo Step 2: Generating splash screen...
call flutter pub run flutter_native_splash:create
if errorlevel 1 (
    echo ERROR: Splash screen generation failed
    pause
    exit /b 1
)
echo.

echo ========================================
echo SUCCESS: Splash screen generated!
echo ========================================
echo.
echo Generated splash screens for:
echo - Android (including Android 12+)
echo - iOS
echo.
echo Next steps:
echo 1. Run: flutter clean
echo 2. Run: flutter pub get
echo 3. Rebuild your app
echo.
pause
