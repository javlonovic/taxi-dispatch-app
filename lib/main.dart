import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_dispatch_app/l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/repository_providers.dart';
import 'presentation/providers/onboarding_provider.dart';
import 'presentation/widgets/notification_handler.dart';
import 'core/router/app_router.dart';
import 'core/services/crashlytics_service.dart';
import 'domain/services/deep_link_service.dart';
import 'domain/entities/user.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/localization_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Crashlytics
  final crashlyticsService = CrashlyticsService();
  await crashlyticsService.initialize();
  
  // Initialize SharedPreferences for localization
  final sharedPreferences = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const TaxiDispatchApp(),
    ),
  );
}

class AppInitializer extends ConsumerStatefulWidget {
  final Widget child;
  final GoRouter router;

  const AppInitializer({
    super.key,
    required this.child,
    required this.router,
  });

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Initialize FCM and deep linking when app starts
    Future.microtask(() async {
      // Initialize FCM
      await ref.read(notificationRepositoryProvider).initializeNotifications();
      
      // Initialize notifications for current user if logged in
      final authState = ref.read(authStateProvider);
      authState.whenData((user) async {
        if (user != null) {
          try {
            final notificationService = ref.read(notificationServiceProvider);
            await notificationService.initializeForUser(user.id);
            await notificationService.subscribeToUserTopic(user.id);
            
            // Subscribe to role-specific topics
            if (user.type == UserType.driver) {
              await notificationService.subscribeToDriverTopics();
            } else if (user.type == UserType.company) {
              await notificationService.subscribeToCompanyTopics();
            }
          } catch (e) {
            debugPrint('Failed to initialize notifications for user: $e');
          }
        }
      });
      
      // Initialize deep linking
      DeepLinkService.initialize(widget.router);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Provider for the app router to prevent recreation on every build
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider);
  return createAppRouter(authState, hasSeenOnboarding: hasSeenOnboarding);
});

class TaxiDispatchApp extends ConsumerWidget {
  const TaxiDispatchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final currentLocale = ref.watch(currentLocaleProvider);

    return AppInitializer(
      router: router,
      child: NotificationHandler(
        child: MaterialApp.router(
          title: 'Vezunchik',
          theme: AppTheme.lightTheme,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          // Localization configuration
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ru', ''), // Russian (default)
            Locale('en', ''), // English
          ],
          locale: currentLocale, // Use locale from provider
        ),
      ),
    );
  }
}
