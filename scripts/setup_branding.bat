@echo off
REM Complete branding setup script - generates both icons and splash screen

echo ========================================
echo Complete App Branding Setup
echo ========================================
echo.
echo This script will:
echo 1. Generate app launcher icons
echo 2. Generate splash screen
echo 3. Clean and rebuild
echo.

REM Check if all required files exist
set MISSING_FILES=0

if not exist "assets\icon\app_icon.png" (
    echo ERROR: assets\icon\app_icon.png not found!
    set MISSING_FILES=1
)

if not exist "assets\icon\app_icon_foreground.png" (
    echo WARNING: assets\icon\app_icon_foreground.png not found!
    echo Android adaptive icons will use the main icon.
)

if not exist "assets\splash\splash_logo.png" (
    echo ERROR: assets\splash\splash_logo.png not found!
    set MISSING_FILES=1
)

if %MISSING_FILES%==1 (
    echo.
    echo Please add the required logo files before running this script.
    echo See LOGO_PLACEHOLDER.md files in assets/icon and assets/splash directories.
    echo.
    pause
    exit /b 1
)

echo All required files found!
echo.

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

echo Step 3: Generating splash screen...
call flutter pub run flutter_native_splash:create
if errorlevel 1 (
    echo ERROR: Splash screen generation failed
    pause
    exit /b 1
)
echo.

echo Step 4: Cleaning build...
call flutter clean
if errorlevel 1 (
    echo ERROR: flutter clean failed
    pause
    exit /b 1
)
echo.

echo Step 5: Getting dependencies...
call flutter pub get
if errorlevel 1 (
    echo ERROR: flutter pub get failed
    pause
    exit /b 1
)
echo.

echo ========================================
echo SUCCESS: Branding setup complete!
echo ========================================
echo.
echo Generated:
echo - App launcher icons (Android and iOS)
echo - Splash screens (Android and iOS)
echo.
echo Your app is now ready to build with the new branding!
echo.
echo To run the app:
echo   flutter run
echo.
echo To build release:
echo   flutter build apk --release
echo   flutter build ios --release
echo.
pause
