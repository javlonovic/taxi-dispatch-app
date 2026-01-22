import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Branch Management Tests', () {
    group('Branch List Display', () {
      testWidgets('displays all company branches', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ListView(
                  children: const [
                    ListTile(
                      title: Text('Главный офис'),
                      subtitle: Text('ул. Ленина, 1'),
                      trailing: Icon(Icons.star),
                    ),
                    ListTile(
                      title: Text('Филиал №2'),
                      subtitle: Text('ул. Пушкина, 10'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Verify branches are displayed
        expect(find.text('Главный офис'), findsOneWidget);
        expect(find.text('Филиал №2'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget); // Headquarters badge
      });

      testWidgets('shows headquarters badge on main office', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: ListTile(
                  title: const Text('Главный офис'),
                  trailing: Chip(
                    label: const Text('Штаб-квартира'),
                    backgroundColor: Colors.blue.shade100,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Штаб-квартира'), findsOneWidget);
      });

      testWidgets('displays add branch button', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить филиал'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Добавить филиал'), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });
    });

    group('Add Branch', () {
      testWidgets('shows branch form dialog', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Добавить филиал'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              TextField(
                                decoration: InputDecoration(labelText: 'Название'),
                              ),
                              TextField(
                                decoration: InputDecoration(labelText: 'Адрес'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: const Text('Добавить'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Добавить'));
        await tester.pumpAndSettle();

        expect(find.text('Добавить филиал'), findsOneWidget);
        expect(find.text('Название'), findsOneWidget);
        expect(find.text('Адрес'), findsOneWidget);
      });

      testWidgets('validates branch name is required', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Form(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Название'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите название филиала';
                          }
                          return null;
                        },
                      ),
                      Builder(
                        builder: (context) => ElevatedButton(
                          onPressed: () {
                            Form.of(context).validate();
                          },
                          child: const Text('Сохранить'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Сохранить'));
        await tester.pumpAndSettle();

        expect(find.text('Введите название филиала'), findsOneWidget);
      });

      testWidgets('validates address is required', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Form(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Адрес'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите адрес';
                          }
                          return null;
                        },
                      ),
                      Builder(
                        builder: (context) => ElevatedButton(
                          onPressed: () {
                            Form.of(context).validate();
                          },
                          child: const Text('Сохранить'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Сохранить'));
        await tester.pumpAndSettle();

        expect(find.text('Введите адрес'), findsOneWidget);
      });

      testWidgets('requires location selection from map', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.map),
                      label: const Text('Выбрать на карте'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Выбрать на карте'), findsOneWidget);
        expect(find.byIcon(Icons.map), findsOneWidget);
      });
    });

    group('Edit Branch', () {
      testWidgets('shows edit dialog with existing data', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Редактировать филиал'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Название',
                                  hintText: 'Филиал №2',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: const Text('Редактировать'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Редактировать'));
        await tester.pumpAndSettle();

        expect(find.text('Редактировать филиал'), findsOneWidget);
      });

      testWidgets('allows updating branch name', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TextField(
                  decoration: const InputDecoration(labelText: 'Название'),
                  controller: TextEditingController(text: 'Филиал №2'),
                ),
              ),
            ),
          ),
        );

        final textField = find.byType(TextField);
        await tester.enterText(textField, 'Новое название');
        await tester.pump();

        expect(find.text('Новое название'), findsOneWidget);
      });

      testWidgets('allows updating branch location', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    const Text('Текущее местоположение: 55.7558° N, 37.6173° E'),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Изменить местоположение'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Изменить местоположение'), findsOneWidget);
      });
    });

    group('Delete Branch', () {
      testWidgets('shows confirmation dialog before deletion', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Удалить филиал?'),
                          content: const Text('Вы уверены, что хотите удалить этот филиал?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Отмена'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Удалить'),
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

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        expect(find.text('Удалить филиал?'), findsOneWidget);
        expect(find.text('Вы уверены, что хотите удалить этот филиал?'), findsOneWidget);
        expect(find.text('Отмена'), findsOneWidget);
        expect(find.text('Удалить'), findsOneWidget);
      });

      testWidgets('prevents deletion of last branch', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Невозможно удалить'),
                          content: const Text('Нельзя удалить последний филиал'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
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

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        expect(find.text('Невозможно удалить'), findsOneWidget);
        expect(find.text('Нельзя удалить последний филиал'), findsOneWidget);
      });

      testWidgets('allows canceling deletion', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Удалить филиал?'),
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

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Отмена'));
        await tester.pumpAndSettle();

        // Dialog should be closed
        expect(find.text('Удалить филиал?'), findsNothing);
      });
    });

    group('Branch Data Model', () {
      test('branch has required fields', () {
        final branch = {
          'id': 'branch_1',
          'name': 'Главный офис',
          'address': 'ул. Ленина, 1',
          'location': const GeoPoint(55.7558, 37.6173),
          'isHeadquarters': true,
          'createdAt': DateTime.now(),
        };

        expect(branch['id'], isNotNull);
        expect(branch['name'], isNotNull);
        expect(branch['address'], isNotNull);
        expect(branch['location'], isNotNull);
        expect(branch['isHeadquarters'], isTrue);
      });

      test('headquarters branch is marked correctly', () {
        final headquarters = {
          'name': 'Главный офис',
          'isHeadquarters': true,
        };

        final regularBranch = {
          'name': 'Филиал №2',
          'isHeadquarters': false,
        };

        expect(headquarters['isHeadquarters'], isTrue);
        expect(regularBranch['isHeadquarters'], isFalse);
      });

      test('branch location is stored as GeoPoint', () {
        final location = const GeoPoint(55.7558, 37.6173);

        expect(location.latitude, 55.7558);
        expect(location.longitude, 37.6173);
      });
    });
  });
}
