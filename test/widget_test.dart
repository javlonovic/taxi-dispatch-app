import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taxi_dispatch_app/presentation/screens/auth/login_screen.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build the login screen with ProviderScope
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const LoginScreen(),
        ),
      ),
    );

    // Verify that the login screen renders successfully
    expect(find.text('Taxi Dispatch'), findsOneWidget);
    expect(find.text('Login to your account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
    expect(find.text('Login'), findsOneWidget);
    expect(find.text("Don't have an account? "), findsOneWidget);
  });
}
