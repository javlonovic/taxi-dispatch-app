# Android Keystore Setup Guide

This guide explains how to create and configure a keystore for signing your Android release builds.

## Prerequisites

- Java Development Kit (JDK) installed
- Access to command line/terminal

## Step 1: Generate a Keystore

Run the following command in your terminal:

```bash
keytool -genkey -v -keystore ~/taxi-dispatch-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias taxi-dispatch
```

### Command Explanation:
- `-genkey`: Generates a new key pair
- `-v`: Verbose output
- `-keystore`: Path where the keystore will be saved
- `-keyalg RSA`: Algorithm to use (RSA)
- `-keysize 2048`: Key size in bits
- `-validity 10000`: Validity period in days (~27 years)
- `-alias`: Alias name for the key

### You will be prompted for:
1. **Keystore password**: Choose a strong password (remember this!)
2. **Key password**: Can be the same as keystore password
3. **Name and organizational details**: Fill in your information
   - First and last name
   - Organizational unit
   - Organization name
   - City/Locality
   - State/Province
   - Country code (2 letters)

## Step 2: Store the Keystore Securely

1. Move the keystore file to a secure location:
   ```bash
   # Example: Move to project's android directory (NOT recommended for production)
   mv ~/taxi-dispatch-release-key.jks ./android/
   ```

2. **IMPORTANT**: For production apps:
   - Store the keystore in a secure, backed-up location
   - NEVER commit the keystore to version control
   - Consider using a password manager for credentials
   - Keep multiple secure backups

## Step 3: Configure key.properties

1. Copy the example file:
   ```bash
   cp android/key.properties.example android/key.properties
   ```

2. Edit `android/key.properties` with your keystore details:
   ```properties
   RELEASE_STORE_FILE=../taxi-dispatch-release-key.jks
   RELEASE_STORE_PASSWORD=your_keystore_password
   RELEASE_KEY_ALIAS=taxi-dispatch
   RELEASE_KEY_PASSWORD=your_key_password
   ```

3. **IMPORTANT**: Add `key.properties` to `.gitignore`:
   ```bash
   echo "android/key.properties" >> .gitignore
   ```

## Step 4: Verify Configuration

1. Check that `android/app/build.gradle` loads the keystore properties
2. Verify the signing configuration is set up correctly
3. Test by building a release APK:
   ```bash
   flutter build apk --release
   ```

## Step 5: Build Release APK/Bundle

### Build APK (for direct distribution):
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (for Google Play Store):
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## Troubleshooting

### Error: "Keystore file not found"
- Check the path in `key.properties`
- Ensure the path is relative to the `android` directory
- Use `../` to go up one directory level

### Error: "Incorrect keystore password"
- Verify the password in `key.properties`
- Ensure there are no extra spaces or quotes

### Error: "Key alias not found"
- Check the alias name matches what you used when creating the keystore
- List aliases in keystore: `keytool -list -v -keystore path/to/keystore.jks`

## Security Best Practices

1. **Never commit sensitive files**:
   - `key.properties`
   - `*.jks` (keystore files)
   - Passwords or credentials

2. **Backup your keystore**:
   - Store in multiple secure locations
   - Use encrypted cloud storage
   - Keep offline backups

3. **Protect your passwords**:
   - Use a password manager
   - Don't share passwords via email or chat
   - Use different passwords for different environments

4. **For CI/CD**:
   - Use environment variables or secrets management
   - Encrypt keystore files in repository
   - Use secure credential storage (GitHub Secrets, etc.)

## Lost Keystore?

If you lose your keystore:
- **Google Play Store**: You cannot update your app! You'll need to publish as a new app
- **Direct distribution**: You can create a new keystore, but users will see it as a different app

**This is why backups are critical!**

## Additional Resources

- [Android App Signing Documentation](https://developer.android.com/studio/publish/app-signing)
- [Flutter Deployment Documentation](https://docs.flutter.dev/deployment/android)
- [Google Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756)
