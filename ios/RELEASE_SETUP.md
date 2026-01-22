# iOS Release Setup Guide

This guide explains how to configure your iOS app for release builds and App Store distribution.

## Prerequisites

- macOS with Xcode installed
- Apple Developer Account ($99/year)
- Access to App Store Connect

## Step 1: Configure Xcode Project

1. Open the iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Select the **Runner** project in the navigator

3. Select the **Runner** target

4. Go to **Signing & Capabilities** tab

### Development Signing:
- **Automatically manage signing**: Checked
- **Team**: Select your Apple Developer team
- **Bundle Identifier**: `com.taxidispatch.taxi-dispatch-app`

### Release Signing:
- For App Store distribution, you'll need:
  - Distribution Certificate
  - App Store Provisioning Profile

## Step 2: Configure Build Settings

### General Tab:
- **Display Name**: Taxi Dispatch
- **Bundle Identifier**: `com.taxidispatch.taxi-dispatch-app`
- **Version**: 1.0.0 (matches pubspec.yaml)
- **Build**: 1 (matches pubspec.yaml)

### Deployment Info:
- **Deployment Target**: iOS 12.0 or higher
- **Devices**: iPhone (or Universal for iPad support)
- **Supported Orientations**: 
  - Portrait
  - Landscape Left
  - Landscape Right

### Capabilities:
Ensure these capabilities are enabled:
- ✅ Background Modes
  - Location updates
  - Background fetch
  - Remote notifications
- ✅ Push Notifications
- ✅ Associated Domains (for deep linking)
- ✅ Maps

## Step 3: Configure Info.plist

The Info.plist should already contain required permissions. Verify these keys exist:

```xml
<!-- Location Permissions -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to show nearby drivers and track rides.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to your location in the background to update your position during rides.</string>

<!-- Camera Permission (for profile photos) -->
<key>NSCameraUsageDescription</key>
<string>This app needs access to your camera to take profile and license photos.</string>

<!-- Photo Library Permission -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to select profile and license photos.</string>
```

## Step 4: Configure App Icons

1. Prepare your app icon (1024x1024 px PNG)
2. Place in `assets/icon/app_icon.png`
3. Run icon generator:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

Or manually:
1. Open `ios/Runner/Assets.xcassets/AppIcon.appiconset`
2. Drag and drop icon images for each size
3. Xcode will validate the icons

## Step 5: Configure Splash Screen

1. Prepare your splash logo (1024x1024 px PNG)
2. Place in `assets/splash/splash_logo.png`
3. Run splash generator:
   ```bash
   flutter pub get
   flutter pub run flutter_native_splash:create
   ```

## Step 6: Build for Release

### Build IPA for Testing:
```bash
flutter build ios --release
```

### Build for App Store:
```bash
flutter build ipa --release
```

Output: `build/ios/ipa/taxi_dispatch_app.ipa`

### Archive in Xcode:
1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select **Any iOS Device** as the build target
3. Go to **Product > Archive**
4. Once complete, the Organizer window opens
5. Select your archive and click **Distribute App**

## Step 7: App Store Connect Setup

### Create App Record:
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** > **+** > **New App**
3. Fill in app information:
   - **Platform**: iOS
   - **Name**: Taxi Dispatch
   - **Primary Language**: English
   - **Bundle ID**: Select your bundle ID
   - **SKU**: Unique identifier (e.g., `taxi-dispatch-001`)

### App Information:
- **Category**: Navigation or Business
- **Content Rights**: Own or have rights to use
- **Age Rating**: Complete questionnaire

### Pricing and Availability:
- Set price tier (or free)
- Select countries/regions
- Set availability date

### App Privacy:
- Complete privacy questionnaire
- Add privacy policy URL
- Describe data collection practices

## Step 8: Prepare App Store Listing

### Required Assets:

1. **App Screenshots** (required for each device size):
   - iPhone 6.7" (1290 x 2796 px) - iPhone 14 Pro Max
   - iPhone 6.5" (1242 x 2688 px) - iPhone 11 Pro Max
   - iPhone 5.5" (1242 x 2208 px) - iPhone 8 Plus
   - iPad Pro 12.9" (2048 x 2732 px)

2. **App Preview Videos** (optional):
   - 15-30 seconds
   - Same sizes as screenshots

3. **App Icon** (1024x1024 px):
   - No transparency
   - No rounded corners (Apple adds them)

### App Description:
```
Taxi Dispatch connects professional taxi drivers with companies needing reliable transportation services. 

Features:
• Real-time ride requests and matching
• Live GPS tracking
• In-app communication
• Secure payments
• Driver ratings and reviews
• Ride history and receipts

For Drivers:
• Manage your availability
• Accept ride requests
• Navigate to pickup locations
• Track your earnings

For Companies:
• Request rides instantly
• View available drivers nearby
• Track rides in real-time
• Manage payment methods
```

### Keywords:
```
taxi, dispatch, ride, driver, transportation, gps, tracking, fleet
```

### Support URL:
- Create a support website or page
- Include contact information

### Marketing URL (optional):
- Your app's marketing website

## Step 9: Submit for Review

1. Upload your build via Xcode or Transporter app
2. Wait for build to process (10-30 minutes)
3. Select the build in App Store Connect
4. Fill in **What's New in This Version**
5. Complete all required fields
6. Click **Submit for Review**

### Review Notes:
Provide test credentials if needed:
```
Driver Account:
Email: driver.test@example.com
Password: TestDriver123!

Company Account:
Email: company.test@example.com
Password: TestCompany123!
```

## Step 10: TestFlight (Optional)

Before submitting to App Store, test with TestFlight:

1. Upload build to App Store Connect
2. Go to **TestFlight** tab
3. Add internal testers (up to 100)
4. Add external testers (requires beta review)
5. Distribute build to testers

## Troubleshooting

### Build Errors:

**"No signing certificate found"**
- Go to Xcode > Preferences > Accounts
- Select your team and click **Manage Certificates**
- Create a new certificate if needed

**"Provisioning profile doesn't match"**
- Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
- Clean build folder in Xcode: Product > Clean Build Folder
- Try automatic signing first

**"Missing required icon"**
- Ensure all icon sizes are provided
- Use flutter_launcher_icons to generate all sizes

### App Store Rejection:

**Common reasons:**
- Missing privacy policy
- Incomplete app description
- Crashes or bugs
- Missing required permissions explanations
- Violates App Store guidelines

**How to respond:**
- Read rejection reason carefully
- Fix the issues
- Respond in Resolution Center
- Submit new build if needed

## Build Optimization

### Reduce App Size:
1. Enable bitcode (if supported by all dependencies)
2. Use app thinning (automatic in App Store)
3. Remove unused assets
4. Optimize images

### Performance:
1. Test on real devices
2. Profile with Instruments
3. Optimize heavy operations
4. Use lazy loading

## Continuous Deployment

For automated builds, consider:
- **Fastlane**: Automate screenshots, builds, and uploads
- **Codemagic**: CI/CD for Flutter apps
- **GitHub Actions**: Custom CI/CD workflows

See the CI/CD setup guide for more details.

## Additional Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
