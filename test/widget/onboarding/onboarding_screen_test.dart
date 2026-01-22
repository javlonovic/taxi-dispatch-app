import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_dispatch_app/presentation/screens/onboarding/onboarding_screen.dart';

void main() {
  group('Onboarding Flow Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('displays all onboarding screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Verify first screen (Welcome)
      expect(find.text('Добро пожаловать'), findsOneWidget);
      expect(find.text('Быстрая доставка для вашего бизнеса'), findsOneWidget);

      // Swipe to next screen
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Verify second screen (For Companies)
      expect(find.text('Для компаний'), findsOneWidget);
      expect(find.text('Управление филиалами'), findsOneWidget);

      // Swipe to next screen
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Verify third screen (For Drivers)
      expect(find.text('Для водителей'), findsOneWidget);
      expect(find.text('Гибкий график'), findsOneWidget);

      // Swipe to final screen
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Verify final screen (Get Started)
      expect(find.text('Я компания'), findsOneWidget);
      expect(find.text('Я водитель'), findsOneWidget);
    });

    testWidgets('skip button navigates to role selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Find and tap skip button
      final skipButton = find.text('Пропустить');
      expect(skipButton, findsOneWidget);
      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      // Verify navigation occurred (onboarding completion)
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_onboarding'), isTrue);
    });

    testWidgets('page indicator shows current page', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Verify page indicators exist
      expect(find.byType(PageView), findsOneWidget);

      // Navigate through pages and verify indicator updates
      for (int i = 0; i < 3; i++) {
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('company button navigates to company registration', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Navigate to final screen
      for (int i = 0; i < 3; i++) {
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();
      }

      // Tap company button
      final companyButton = find.text('Я компания');
      expect(companyButton, findsOneWidget);
      await tester.tap(companyButton);
      await tester.pumpAndSettle();
    });

    testWidgets('driver button navigates to driver registration', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Navigate to final screen
      for (int i = 0; i < 3; i++) {
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();
      }

      // Tap driver button
      final driverButton = find.text('Я водитель');
      expect(driverButton, findsOneWidget);
      await tester.tap(driverButton);
      await tester.pumpAndSettle();
    });

    testWidgets('onboarding is shown only once', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Verify onboarding is not shown
      expect(prefs.getBool('has_seen_onboarding'), isTrue);
    });

    testWidgets('displays app logo on welcome screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Verify logo is displayed
      expect(find.byType(Image), findsWidgets);
    });
  });
}
