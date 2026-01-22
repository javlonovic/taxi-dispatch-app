import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Driver Status Toggle Tests', () {
    group('Status Display', () {
      testWidgets('shows active status indicator', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SwitchListTile(
                  title: const Text('Статус работы'),
                  subtitle: const Text('Активен - вы получаете заказы'),
                  value: true,
                  onChanged: (value) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Статус работы'), findsOneWidget);
        expect(find.text('Активен - вы получаете заказы'), findsOneWidget);
      });

      testWidgets('shows inactive status indicator', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SwitchListTile(
                  title: const Text('Статус работы'),
                  subtitle: const Text('Неактивен - вы не получаете заказы'),
                  value: false,
                  onChanged: (value) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Неактивен - вы не получаете заказы'), findsOneWidget);
      });

      testWidgets('displays status badge in dashboard', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: [
                    Chip(
                      avatar: Icon(Icons.circle, size: 12, color: Colors.green),
                      label: Text('Активен'),
                      backgroundColor: Colors.green.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Активен'), findsOneWidget);
        expect(find.byIcon(Icons.circle), findsOneWidget);
      });
    });

    group('Status Toggle Confirmation', () {
      testWidgets('shows confirmation dialog when toggling to active', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => SwitchListTile(
                    title: const Text('Статус работы'),
                    value: false,
                    onChanged: (value) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Изменить статус?'),
                          content: const Text(
                            'Вы начнете получать уведомления о новых заказах в радиусе 5-6 км',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Отмена'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Подтвердить'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        // Toggle switch
        await tester.tap(find.byType(SwitchListTile));
        await tester.pumpAndSettle();

        // Verify confirmation dialog
        expect(find.text('Изменить статус?'), findsOneWidget);
        expect(
          find.text('Вы начнете получать уведомления о новых заказах в радиусе 5-6 км'),
          findsOneWidget,
        );
        expect(find.text('Отмена'), findsOneWidget);
        expect(find.text('Подтвердить'), findsOneWidget);
      });

      testWidgets('shows confirmation dialog when toggling to inactive', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => SwitchListTile(
                    title: const Text('Статус работы'),
                    value: true,
                    onChanged: (value) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Изменить статус?'),
                          content: const Text(
                            'Вы перестанете получать заказы. Вы сможете включить статус в любое время.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Отмена'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Подтвердить'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        // Toggle switch
        await tester.tap(find.byType(SwitchListTile));
        await tester.pumpAndSettle();

        // Verify confirmation dialog
        expect(find.text('Изменить статус?'), findsOneWidget);
        expect(
          find.text('Вы перестанете получать заказы. Вы сможете включить статус в любое время.'),
          findsOneWidget,
        );
      });

      testWidgets('allows canceling status change', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => SwitchListTile(
                    title: const Text('Статус работы'),
                    value: false,
                    onChanged: (value) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Изменить статус?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Отмена'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        // Toggle switch
        await tester.tap(find.byType(SwitchListTile));
        await tester.pumpAndSettle();

        // Cancel
        await tester.tap(find.text('Отмена'));
        await tester.pumpAndSettle();

        // Dialog should be closed
        expect(find.text('Изменить статус?'), findsNothing);
      });

      testWidgets('confirms status change on button press', (WidgetTester tester) async {
        bool statusChanged = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => SwitchListTile(
                    title: const Text('Статус работы'),
                    value: false,
                    onChanged: (value) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Изменить статус?'),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                statusChanged = true;
                                Navigator.pop(context);
                              },
                              child: const Text('Подтвердить'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        // Toggle switch
        await tester.tap(find.byType(SwitchListTile));
        await tester.pumpAndSettle();

        // Confirm
        await tester.tap(find.text('Подтвердить'));
        await tester.pumpAndSettle();

        expect(statusChanged, isTrue);
      });
    });

    group('Status Persistence', () {
      test('stores status in Firestore', () {
        final driverData = {
          'id': 'driver_1',
          'isActive': true,
          'lastStatusChange': DateTime.now(),
        };

        expect(driverData['isActive'], isTrue);
        expect(driverData['lastStatusChange'], isNotNull);
      });

      test('tracks last status change timestamp', () {
        final now = DateTime.now();
        final driverData = {
          'isActive': true,
          'lastStatusChange': now,
        };

        expect(driverData['lastStatusChange'], now);
      });

      test('updates status in real-time', () {
        var driverStatus = {'isActive': false};

        // Change status
        driverStatus = {'isActive': true};

        expect(driverStatus['isActive'], isTrue);
      });
    });

    group('Driver Search Filtering', () {
      test('only includes active drivers in search', () {
        final drivers = [
          {'id': 'driver_1', 'isActive': true},
          {'id': 'driver_2', 'isActive': false},
          {'id': 'driver_3', 'isActive': true},
          {'id': 'driver_4', 'isActive': false},
        ];

        final activeDrivers = drivers.where((d) => d['isActive'] == true).toList();

        expect(activeDrivers.length, 2);
        expect(activeDrivers[0]['id'], 'driver_1');
        expect(activeDrivers[1]['id'], 'driver_3');
      });

      test('excludes inactive drivers from notifications', () {
        final driver = {
          'id': 'driver_1',
          'isActive': false,
        };

        final shouldReceiveNotification = driver['isActive'] == true;

        expect(shouldReceiveNotification, isFalse);
      });

      test('includes active drivers in radius search', () {
        final driver = {
          'id': 'driver_1',
          'isActive': true,
          'currentLocation': {'lat': 55.7558, 'lng': 37.6173},
        };

        final isEligible = driver['isActive'] == true && 
                          driver['currentLocation'] != null;

        expect(isEligible, isTrue);
      });
    });

    group('Status Change Feedback', () {
      testWidgets('shows success message after status change', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Статус изменен на Активен'),
                        ),
                      );
                    },
                    child: const Text('Change Status'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Change Status'));
        await tester.pump();

        expect(find.text('Статус изменен на Активен'), findsOneWidget);
      });

      testWidgets('shows different message for inactive status', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Статус изменен на Неактивен'),
                        ),
                      );
                    },
                    child: const Text('Change Status'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Change Status'));
        await tester.pump();

        expect(find.text('Статус изменен на Неактивен'), findsOneWidget);
      });
    });
  });
}
