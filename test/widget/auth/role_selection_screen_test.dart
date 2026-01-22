import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taxi_dispatch_app/presentation/screens/auth/role_selection_screen.dart';

void main() {
  group('RoleSelectionScreen Widget Tests', () {
    testWidgets('renders role selection options', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RoleSelectionScreen(),
          ),
        ),
      );

      // Verify title
      expect(find.text('Choose Your Role'), findsOneWidget);

      // Verify role options
      expect(find.text('Driver'), findsOneWidget);
      expect(find.text('Company'), findsOneWidget);
    });

    testWidgets('driver card is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RoleSelectionScreen(),
          ),
        ),
      );

      // Find and tap driver card
      final driverCard = find.text('Driver');
      expect(driverCard, findsOneWidget);
      
      // Verify card is interactive
      await tester.tap(driverCard);
      await tester.pumpAndSettle();
    });

    testWidgets('company card is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RoleSelectionScreen(),
          ),
        ),
      );

      // Find and tap company card
      final companyCard = find.text('Company');
      expect(companyCard, findsOneWidget);
      
      // Verify card is interactive
      await tester.tap(companyCard);
      await tester.pumpAndSettle();
    });
  });
}
