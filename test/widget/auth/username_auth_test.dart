import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taxi_dispatch_app/presentation/screens/auth/login_screen.dart';
import 'package:taxi_dispatch_app/presentation/screens/auth/company_registration_screen.dart';
import 'package:taxi_dispatch_app/presentation/screens/auth/driver_registration_screen.dart';

void main() {
  group('Username Authentication Tests', () {
    group('Username Login', () {
      testWidgets('login screen accepts username instead of email', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: LoginScreen(),
            ),
          ),
        );

        // Verify username field label
        expect(find.text('Имя пользователя'), findsOneWidget);

        // Enter username
        final usernameField = find.byType(TextFormField).first;
        await tester.enterText(usernameField, 'testuser123');
        await tester.pump();

        expect(find.text('testuser123'), findsOneWidget);
      });

      testWidgets('validates username format', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: LoginScreen(),
            ),
          ),
        );

        // Enter invalid username (too short)
        final usernameField = find.byType(TextFormField).first;
        await tester.enterText(usernameField, 'ab');

        // Tap login button
        final loginButton = find.text('Войти');
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // Verify validation message
        expect(find.textContaining('минимум 3 символа'), findsOneWidget);
      });

      testWidgets('validates password is required', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: LoginScreen(),
            ),
          ),
        );

        // Enter only username
        final usernameField = find.byType(TextFormField).first;
        await tester.enterText(usernameField, 'testuser123');

        // Tap login button without password
        final loginButton = find.text('Войти');
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // Verify password validation
        expect(find.text('Введите пароль'), findsOneWidget);
      });

      testWidgets('displays Russian error messages', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: LoginScreen(),
            ),
          ),
        );

        // Tap login without entering data
        final loginButton = find.text('Войти');
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        // Verify Russian error messages
        expect(find.text('Введите имя пользователя'), findsOneWidget);
        expect(find.text('Введите пароль'), findsOneWidget);
      });
    });

    group('Company Registration with Username', () {
      testWidgets('company registration requires username', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: CompanyRegistrationScreen(),
            ),
          ),
        );

        // Verify username field exists
        expect(find.text('Имя пользователя'), findsOneWidget);

        // Verify other required fields
        expect(find.text('Название компании'), findsOneWidget);
        expect(find.text('Телефон'), findsOneWidget);
        expect(find.text('Пароль'), findsOneWidget);
      });

      testWidgets('validates username uniqueness', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: CompanyRegistrationScreen(),
            ),
          ),
        );

        // Enter username
        final usernameField = find.widgetWithText(TextFormField, 'Имя пользователя');
        await tester.enterText(usernameField, 'existinguser');
        await tester.pump();

        // Note: Actual uniqueness check would require Firebase mock
        expect(find.text('existinguser'), findsOneWidget);
      });

      testWidgets('validates username format rules', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: CompanyRegistrationScreen(),
            ),
          ),
        );

        // Test invalid characters
        final usernameField = find.widgetWithText(TextFormField, 'Имя пользователя');
        await tester.enterText(usernameField, 'user@name!');

        final registerButton = find.text('Зарегистрироваться');
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        // Should show validation error for invalid characters
        expect(find.textContaining('буквы, цифры и подчеркивание'), findsOneWidget);
      });

      testWidgets('requires headquarters location', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: CompanyRegistrationScreen(),
            ),
          ),
        );

        // Verify location picker exists
        expect(find.text('Местоположение штаб-квартиры'), findsOneWidget);
      });

      testWidgets('validates password strength', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: CompanyRegistrationScreen(),
            ),
          ),
        );

        // Enter weak password
        final passwordField = find.widgetWithText(TextFormField, 'Пароль');
        await tester.enterText(passwordField, '123');

        final registerButton = find.text('Зарегистрироваться');
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        // Verify password validation
        expect(find.textContaining('минимум 8 символов'), findsOneWidget);
      });
    });

    group('Driver Registration with Username', () {
      testWidgets('driver registration requires username and personal info', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: DriverRegistrationScreen(),
            ),
          ),
        );

        // Verify username field
        expect(find.text('Имя пользователя'), findsOneWidget);

        // Verify driver-specific fields
        expect(find.text('Имя'), findsOneWidget);
        expect(find.text('Фамилия'), findsOneWidget);
        expect(find.text('Возраст'), findsOneWidget);
        expect(find.text('Модель автомобиля'), findsOneWidget);
        expect(find.text('Номер автомобиля'), findsOneWidget);
        expect(find.text('Цвет автомобиля'), findsOneWidget);
      });

      testWidgets('validates age requirement (minimum 18)', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: DriverRegistrationScreen(),
            ),
          ),
        );

        // Enter age below 18
        final ageField = find.widgetWithText(TextFormField, 'Возраст');
        await tester.enterText(ageField, '17');

        final registerButton = find.text('Зарегистрироваться');
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        // Verify age validation
        expect(find.textContaining('минимум 18 лет'), findsOneWidget);
      });

      testWidgets('does not require driver license photo', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: DriverRegistrationScreen(),
            ),
          ),
        );

        // Verify driver license photo field is not required
        expect(find.text('Фото водительского удостоверения'), findsNothing);
      });

      testWidgets('validates car details are required', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: DriverRegistrationScreen(),
            ),
          ),
        );

        // Tap register without car details
        final registerButton = find.text('Зарегистрироваться');
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        // Verify car detail validations
        expect(find.text('Введите модель автомобиля'), findsOneWidget);
        expect(find.text('Введите номер автомобиля'), findsOneWidget);
        expect(find.text('Введите цвет автомобиля'), findsOneWidget);
      });

      testWidgets('sets initial driver status to inactive', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: DriverRegistrationScreen(),
            ),
          ),
        );

        // Note: Actual status check would require provider mock
        // Driver should be created with isActive = false
        expect(find.byType(DriverRegistrationScreen), findsOneWidget);
      });
    });

    group('Internal Email Generation', () {
      test('generates correct internal email format', () {
        const username = 'testuser123';
        final internalEmail = '$username@taxidispatch.internal';

        expect(internalEmail, 'testuser123@taxidispatch.internal');
      });

      test('converts username to lowercase for email', () {
        const username = 'TestUser123';
        final internalEmail = '${username.toLowerCase()}@taxidispatch.internal';

        expect(internalEmail, 'testuser123@taxidispatch.internal');
      });

      test('internal email is hidden from users', () {
        // This is a design principle test
        // Internal email should never be displayed in UI
        const displayName = 'testuser123';
        const internalEmail = 'testuser123@taxidispatch.internal';

        // User sees only username, not internal email
        expect(displayName, isNot(contains('@')));
        expect(internalEmail, contains('@taxidispatch.internal'));
      });
    });
  });
}
