# Splash Screen Assets

## Required Files

Place your splash screen logo in this directory:

1. **splash_logo.png** - Splash screen logo (1024x1024 px or larger)
   - This will be centered on a white background
   - Should be a PNG with transparent background
   - Recommended size: 1024x1024 pixels or larger for best quality

## Design Guidelines

- Keep the logo simple and recognizable
- Use transparent background for the logo PNG
- The logo will be centered on a white background (#FFFFFF)
- Consider how it looks on both light and dark system themes
- Avoid very thin lines that might not render well at smaller sizes

## Background Color

The splash screen uses a white background (#FFFFFF). To change this:

1. Edit `pubspec.yaml`
2. Find the `flutter_native_splash` section
3. Change the `color` value to your desired hex color

## Generating Splash Screens

After placing your splash logo here, run:

```bash
flutter pub get
flutter pub run flutter_native_splash:create
```

This will generate all required splash screen assets for both platforms.

## Platform-Specific Notes

### Android
- Supports Android 12+ splash screen API
- Legacy splash screens for older Android versions
- Splash screen will show while app initializes

### iOS
- Uses LaunchScreen.storyboard
- Splash screen shows during app launch
- Automatically adapts to device size

## Testing

To test your splash screen:

1. Uninstall the app from your device/emulator
2. Rebuild and install: `flutter run`
3. The splash screen should appear briefly on app launch
