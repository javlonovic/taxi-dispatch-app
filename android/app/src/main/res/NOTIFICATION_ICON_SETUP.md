# Notification Icon Setup

## Overview

This document explains how notification icons are configured for the Taxi Dispatch app.

## Current Configuration

### Android

The app uses the launcher icon for notifications, configured in `AndroidManifest.xml`:

```xml
<!-- Firebase Cloud Messaging notification icon -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@mipmap/ic_launcher" />

<!-- Notification icon color -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_color"
    android:resource="@color/notification_color" />
```

### Notification Color

The notification icon color is defined in `values/colors.xml`:
- Default: `#FFA000` (Amber/Orange - traditional taxi color)
- This color is applied to the notification icon in the status bar
- Adjust this to match your brand color

## Custom Notification Icon (Optional)

If you want to use a different icon for notifications instead of the launcher icon:

### 1. Create Notification Icon

Create a simple, monochrome icon (white on transparent background):
- Size: 24x24 dp
- Format: PNG
- Style: Simple silhouette (no gradients or colors)
- Background: Transparent

### 2. Generate Icon Sizes

Create the following sizes:
- `drawable-mdpi/ic_notification.png` (24x24 px)
- `drawable-hdpi/ic_notification.png` (36x36 px)
- `drawable-xhdpi/ic_notification.png` (48x48 px)
- `drawable-xxhdpi/ic_notification.png` (72x72 px)
- `drawable-xxxhdpi/ic_notification.png` (96x96 px)

### 3. Update AndroidManifest.xml

Change the notification icon resource:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/ic_notification" />
```

## iOS

iOS automatically uses the app icon for notifications. No additional configuration needed.

## Testing Notifications

To test notification icons:

1. Send a test notification from Firebase Console
2. Check the notification in the status bar (Android)
3. Check the notification in the notification center
4. Verify the icon color matches your brand

## Design Guidelines

### Android Notification Icons

- Use simple, recognizable shapes
- Avoid fine details
- Use solid white color on transparent background
- Keep design centered with padding
- Test at small sizes (24x24 dp)

### Recommended Icons for Taxi App

- Taxi/car silhouette
- Location pin
- Steering wheel
- Simple geometric shape representing movement

## Current Status

✅ Configured to use launcher icon
✅ Notification color set to amber/orange (#FFA000)
⚠️ Custom notification icon not created (using launcher icon)

## Next Steps

1. Design custom notification icon (optional)
2. Generate all required sizes
3. Update AndroidManifest.xml reference
4. Test on various Android versions
5. Adjust notification color if needed
