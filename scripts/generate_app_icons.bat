@echo off
REM Script to generate app launcher icons for Android and iOS

echo ========================================
echo Generating App Launcher Icons
echo ========================================
echo.

REM Check if logo files exist
if not exist "assets\icon\app_icon.png" (
    echo ERROR: assets\icon\app_icon.png not found!
    echo Please add your app icon file before running this script.
    echo See assets\icon\LOGO_PLACEHOLDER.md for details.
    echo.
    pause
    exit /b 1
)

if not exist "assets\icon\app_icon_foreground.png" (
    echo WARNING: assets\icon\app_icon_foreground.png not found!
    echo Android adaptive icons will use the main icon.
    echo.
)

echo Step 1: Running flutter pub get...
call flutter pub get
if errorlevel 1 (
    echo ERROR: flutter pub get failed
    pause
    exit /b 1
)
echo.

echo Step 2: Generating launcher icons...
call flutter pub run flutter_launcher_icons
if errorlevel 1 (
    echo ERROR: Icon generation failed
    pause
    exit /b 1
)
echo.

echo ========================================
echo SUCCESS: App icons generated!
echo ========================================
echo.
echo Generated icons for:
echo - Android (all densities)
echo - iOS (all sizes)
echo.
echo Next steps:
echo 1. Run: flutter clean
echo 2. Run: flutter pub get
echo 3. Rebuild your app
echo.
pause
