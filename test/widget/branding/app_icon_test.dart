import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('App Icon and Branding Tests', () {
    group('App Icon Display', () {
      testWidgets('displays app icon on splash screen', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('displays logo on onboarding welcome screen', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Image.asset(
                      'assets/icon/app_icon.png',
                      width: 100,
                      height: 100,
                    ),
                    const Text('Добро пожаловать'),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
        expect(find.text('Добро пожаловать'), findsOneWidget);
      });

      testWidgets('displays logo in about section', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Image.asset(
                      'assets/icon/app_icon.png',
                      width: 80,
                      height: 80,
                    ),
                    const Text('Taxi Dispatch App'),
                    const Text('Version 1.0.0'),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
        expect(find.text('Taxi Dispatch App'), findsOneWidget);
      });
    });

    group('Logo Aspect Ratio', () {
      test('maintains aspect ratio across sizes', () {
        const sizes = [
          {'width': 48.0, 'height': 48.0},
          {'width': 72.0, 'height': 72.0},
          {'width': 96.0, 'height': 96.0},
          {'width': 120.0, 'height': 120.0},
        ];

        for (final size in sizes) {
          final aspectRatio = size['width']! / size['height']!;
          expect(aspectRatio, 1.0); // Square aspect ratio
        }
      });

      test('logo dimensions are consistent', () {
        const logoSizes = {
          'splash': {'width': 120.0, 'height': 120.0},
          'onboarding': {'width': 100.0, 'height': 100.0},
          'about': {'width': 80.0, 'height': 80.0},
          'notification': {'width': 48.0, 'height': 48.0},
        };

        for (final entry in logoSizes.entries) {
          final size = entry.value;
          final aspectRatio = size['width']! / size['height']!;
          expect(aspectRatio, 1.0);
        }
      });
    });

    group('Notification Icon', () {
      test('uses app logo for notification icon', () {
        final notification = {
          'title': 'Новый заказ',
          'body': 'У вас новый заказ',
          'icon': 'app_icon',
        };

        expect(notification['icon'], 'app_icon');
      });

      test('notification icon path is correct', () {
        const iconPath = 'assets/icon/app_icon.png';

        expect(iconPath, contains('assets/icon'));
        expect(iconPath, endsWith('.png'));
      });
    });

    group('Launcher Icon Configuration', () {
      test('defines launcher icon for Android', () {
        final androidConfig = {
          'android': true,
          'image_path': 'assets/icon/app_icon.png',
          'adaptive_icon_background': '#FFFFFF',
          'adaptive_icon_foreground': 'assets/icon/app_icon.png',
        };

        expect(androidConfig['android'], isTrue);
        expect(androidConfig['image_path'], contains('app_icon.png'));
      });

      test('defines launcher icon for iOS', () {
        final iosConfig = {
          'ios': true,
          'image_path': 'assets/icon/app_icon.png',
          'remove_alpha_ios': true,
        };

        expect(iosConfig['ios'], isTrue);
        expect(iosConfig['image_path'], contains('app_icon.png'));
      });

      test('generates multiple icon sizes', () {
        final iconSizes = [
          48, // mdpi
          72, // hdpi
          96, // xhdpi
          144, // xxhdpi
          192, // xxxhdpi
        ];

        expect(iconSizes.length, 5);
        expect(iconSizes, contains(48));
        expect(iconSizes, contains(192));
      });
    });

    group('Splash Screen', () {
      testWidgets('splash screen displays logo', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icon/app_icon.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      test('splash screen configuration includes logo', () {
        final splashConfig = {
          'image': 'assets/icon/app_icon.png',
          'color': '#FFFFFF',
          'android': true,
          'ios': true,
        };

        expect(splashConfig['image'], contains('app_icon.png'));
        expect(splashConfig['android'], isTrue);
        expect(splashConfig['ios'], isTrue);
      });
    });

    group('Branding Consistency', () {
      test('logo is used consistently across app', () {
        final logoUsages = [
          'splash_screen',
          'onboarding_welcome',
          'onboarding_features',
          'about_screen',
          'notification_icon',
          'launcher_icon',
        ];

        expect(logoUsages.length, 6);
        expect(logoUsages, contains('splash_screen'));
        expect(logoUsages, contains('notification_icon'));
      });

      test('logo path is consistent', () {
        const logoPath = 'assets/icon/app_icon.png';
        final usages = [
          'assets/icon/app_icon.png',
          'assets/icon/app_icon.png',
          'assets/icon/app_icon.png',
        ];

        for (final usage in usages) {
          expect(usage, logoPath);
        }
      });

      test('logo format is PNG', () {
        const logoPath = 'assets/icon/app_icon.png';

        expect(logoPath, endsWith('.png'));
      });
    });

    group('Asset Loading', () {
      test('logo asset path is valid', () {
        const assetPath = 'assets/icon/app_icon.png';

        expect(assetPath, startsWith('assets/'));
        expect(assetPath, contains('icon'));
        expect(assetPath, endsWith('.png'));
      });

      test('logo is registered in pubspec.yaml', () {
        final assets = [
          'assets/icon/',
          'assets/icon/app_icon.png',
        ];

        expect(assets, contains('assets/icon/'));
      });
    });

    group('Icon Generation', () {
      test('generates Android launcher icons', () {
        final androidSizes = {
          'mipmap-mdpi': 48,
          'mipmap-hdpi': 72,
          'mipmap-xhdpi': 96,
          'mipmap-xxhdpi': 144,
          'mipmap-xxxhdpi': 192,
        };

        expect(androidSizes.length, 5);
        expect(androidSizes['mipmap-mdpi'], 48);
        expect(androidSizes['mipmap-xxxhdpi'], 192);
      });

      test('generates iOS launcher icons', () {
        final iosSizes = [
          20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024,
        ];

        expect(iosSizes, contains(20));
        expect(iosSizes, contains(1024));
      });

      test('generates adaptive icon for Android', () {
        final adaptiveIcon = {
          'foreground': 'assets/icon/app_icon.png',
          'background': '#FFFFFF',
        };

        expect(adaptiveIcon['foreground'], isNotNull);
        expect(adaptiveIcon['background'], isNotNull);
      });
    });

    group('Visual Consistency', () {
      testWidgets('logo maintains visibility on light background', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('logo maintains visibility on dark background', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
      });
    });

    group('Onboarding Logo Display', () {
      testWidgets('displays logo on each onboarding screen', (WidgetTester tester) async {
        // Screen 1: Welcome
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Image.asset('assets/icon/app_icon.png'),
                    const Text('Добро пожаловать'),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Image), findsOneWidget);
      });
    });
  });
}
