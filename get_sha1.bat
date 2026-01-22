@echo off
echo ========================================
echo Getting SHA-1 for Android Debug Keystore
echo ========================================
echo.
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android 2>nul | findstr "SHA1:"
echo.
echo ========================================
echo INSTRUCTIONS:
echo 1. Copy the SHA-1 value above
echo 2. Go to Firebase Console
echo 3. Project Settings ^> Your Android App
echo 4. Click "Add fingerprint"
echo 5. Paste the SHA-1
echo 6. Download new google-services.json
echo 7. Replace android/app/google-services.json
echo 8. Run: flutter clean
echo 9. Run: flutter run
echo ========================================
echo.
pause
