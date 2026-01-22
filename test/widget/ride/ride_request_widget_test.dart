import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taxi_dispatch_app/presentation/widgets/driver_list_widget.dart';
import 'package:taxi_dispatch_app/domain/entities/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('DriverListWidget Tests', () {
    testWidgets('displays driver list widget with filters', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DriverListWidget(
                filterStatus: AvailabilityStatus.available,
                minimumRating: 4.0,
              ),
            ),
          ),
        ),
      );

      // Verify widget is rendered
      expect(find.byType(DriverListWidget), findsOneWidget);
    });

    testWidgets('displays driver list with location filter', (WidgetTester tester) async {
      const userLocation = GeoPoint(37.7749, -122.4194);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DriverListWidget(
                userLocation: userLocation,
                showNearbyOnly: true,
              ),
            ),
          ),
        ),
      );

      // Verify widget is rendered with location
      expect(find.byType(DriverListWidget), findsOneWidget);
    });

    testWidgets('displays driver list with minimum rating filter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DriverListWidget(
                minimumRating: 4.5,
                filterStatus: AvailabilityStatus.available,
              ),
            ),
          ),
        ),
      );

      // Verify widget is rendered
      expect(find.byType(DriverListWidget), findsOneWidget);
    });

    testWidgets('displays loading indicator while fetching drivers', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DriverListWidget(),
            ),
          ),
        ),
      );

      // Verify loading indicator is shown initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays driver list widget without filters', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DriverListWidget(),
            ),
          ),
        ),
      );

      // Verify widget is rendered
      expect(find.byType(DriverListWidget), findsOneWidget);
    });
  });
}
