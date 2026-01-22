# Vezunchik Taxi Dispatch App

A professional taxi dispatch application built with Flutter for managing ride requests between companies and drivers.

## Features

### For Companies
- 🚗 Request rides with real-time driver tracking
- 📍 Branch management for multiple pickup locations
- 📊 Analytics dashboard with ride statistics
- 💳 Integrated payment system
- 💬 Real-time chat with drivers
- ⭐ Rating system for drivers
- 📜 Ride history and transaction tracking

### For Drivers
- 🔔 Instant ride request notifications
- 📱 Accept/decline ride requests
- 🗺️ Real-time navigation and tracking
- 💰 Earnings tracking and analytics
- 💬 Chat with companies
- ⭐ Rating system
- 📊 Performance metrics

### Technical Features
- 🔐 Secure authentication with Firebase
- 🗺️ OpenStreetMap integration
- 📲 Push notifications via FCM
- 💾 Cloud Firestore database
- 🎨 Modern Material Design UI
- 🌍 Full Russian localization
- 📱 Optimized for production

## Requirements

- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Firebase account
- Google Maps API key (optional)

## Installation

1. Clone the repository
2. Run `flutter pub get`
3. Configure Firebase (see FIREBASE_SETUP.md)
4. Run `flutter run`

## Build for Production

```bash
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## Configuration

### Firebase
- Configure `google-services.json` for Android
- Configure `GoogleService-Info.plist` for iOS
- Set up Firestore security rules
- Enable Firebase Authentication
- Enable Cloud Messaging

### Environment
- Set up environment variables for API keys
- Configure Stripe for payments (optional)

## Architecture

The app follows Clean Architecture principles:

```
lib/
├── core/           # Core utilities, theme, constants
├── data/           # Data sources, repositories, models
├── domain/         # Entities, repositories interfaces
└── presentation/   # UI, widgets, screens, providers
```

## State Management

- Riverpod for state management
- Provider pattern for dependency injection
- Stream providers for real-time data

## Testing

Run tests with:
```bash
flutter test
```

## License

Proprietary - All rights reserved

## Support

For support, contact: support@vezunchik.uz

## Version

1.0.0 - Production Release
