# Logo Placeholder

## Required Logo Files

Please add the following logo files to this directory:

### 1. app_icon.png (1024x1024 px)
- Main app launcher icon
- Square format, 1024x1024 pixels
- PNG format with transparent background (if needed)
- This will be used to generate all iOS and Android icon sizes

### 2. app_icon_foreground.png (1024x1024 px)
- Android adaptive icon foreground layer
- Square format, 1024x1024 pixels
- PNG format with transparent background
- Keep important elements within center 66% (safe zone)
- Background will be white (#FFFFFF)

## Temporary Placeholder

Until actual logo files are provided, the app will use Flutter's default icons.

## How to Add Your Logo

1. Save your logo files as:
   - `assets/icon/app_icon.png`
   - `assets/icon/app_icon_foreground.png`

2. Run the icon generator:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

3. Run the splash screen generator:
   ```bash
   flutter pub run flutter_native_splash:create
   ```

4. Rebuild the app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Logo Design Guidelines

### For Taxi Dispatch App
- Use recognizable taxi/car imagery
- Keep design simple and clear
- Ensure good visibility at small sizes
- Use brand colors consistently
- Avoid fine details that won't scale well

### Color Recommendations
- Primary: Yellow/Orange (traditional taxi colors)
- Accent: Black or dark gray
- Background: White or transparent

### Icon Content Ideas
- Stylized taxi/car silhouette
- Location pin with car
- Steering wheel
- Road/route symbol
- Combination of above elements

## Current Status

⚠️ **PLACEHOLDER FILES NEEDED**

The following files are currently missing and need to be added:
- [ ] assets/icon/app_icon.png
- [ ] assets/icon/app_icon_foreground.png
- [ ] assets/splash/splash_logo.png

Once these files are added, run the generators to apply them to the app.
