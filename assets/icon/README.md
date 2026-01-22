# App Icon Assets

## Required Files

Place your app icon files in this directory:

1. **app_icon.png** - Main app icon (1024x1024 px)
   - This will be used for both iOS and Android
   - Should be a square PNG with transparent background if needed
   - Recommended: 1024x1024 pixels

2. **app_icon_foreground.png** - Android adaptive icon foreground (1024x1024 px)
   - Used for Android 8.0+ adaptive icons
   - Should contain only the foreground elements
   - Background will be white (#FFFFFF)

## Design Guidelines

### iOS
- Use a simple, recognizable design
- Avoid text in the icon
- Use the full square canvas
- iOS will automatically apply rounded corners

### Android
- Adaptive icons consist of foreground and background layers
- Foreground should be centered and not extend to edges
- Safe zone: Keep important elements within the center 66% of the canvas
- System will apply various shapes (circle, square, rounded square)

## Generating Icons

After placing your icon files here, run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will generate all required icon sizes for both platforms.

## Icon Specifications

### iOS Icon Sizes
- 20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 1024x1024

### Android Icon Sizes
- mdpi: 48x48
- hdpi: 72x72
- xhdpi: 96x96
- xxhdpi: 144x144
- xxxhdpi: 192x192

All sizes are generated automatically from your 1024x1024 source image.
