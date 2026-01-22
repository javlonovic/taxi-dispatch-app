import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user.dart';
import '../../presentation/screens/onboarding/delivery_onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/role_selection_screen.dart';
import '../../presentation/screens/auth/driver_registration_screen.dart';
import '../../presentation/screens/auth/company_registration_screen.dart';
import '../../presentation/screens/auth/phone_verification_screen.dart';
import '../../presentation/screens/auth/email_verification_screen.dart';
import '../../presentation/screens/driver/driver_dashboard_screen.dart';
import '../../presentation/screens/driver/active_ride_screen.dart';
import '../../presentation/screens/company/company_dashboard_screen.dart';
import '../../presentation/screens/company/enhanced_ride_request_screen.dart';
import '../../presentation/screens/company/delivery_request_screen.dart';
import '../../presentation/screens/company/tracking_screen.dart';
import '../../presentation/screens/profile/driver_profile_screen.dart';
import '../../presentation/screens/profile/company_profile_screen.dart';
import '../../presentation/screens/profile/settings_screen.dart';
import '../../presentation/screens/shared/notifications_screen.dart';
import '../../presentation/screens/shared/ride_history_screen.dart';
import '../../presentation/screens/shared/chat_screen.dart';
import '../../presentation/screens/shared/rating_screen.dart';
import '../../presentation/screens/shared/help_center_screen.dart';
import '../../presentation/screens/payment/payment_screen.dart';
import '../../presentation/screens/payment/transaction_history_screen.dart';
import '../../presentation/screens/company/balance_history_screen.dart';
import '../../presentation/screens/company/analytics_dashboard_screen.dart';
import '../../presentation/screens/driver/earnings_screen.dart';
import '../../presentation/screens/admin/driver_verification_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/balance_topup_screen.dart';
import '../../presentation/screens/demo/map_picker_demo_screen.dart';
import 'route_guards.dart';

/// Route names for easy navigation
class AppRoutes {
  // Onboarding route
  static const onboarding = '/onboarding';
  
  // Auth routes
  static const login = '/login';
  static const roleSelection = '/role-selection';
  static const driverRegistration = '/driver-registration';
  static const companyRegistration = '/company-registration';
  static const phoneVerification = '/phone-verification';
  static const emailVerification = '/email-verification';
  
  // Driver routes
  static const driverDashboard = '/driver-dashboard';
  static const activeRide = '/active-ride';
  static const driverProfile = '/driver-profile';
  static const earnings = '/earnings';
  
  // Company routes
  static const companyDashboard = '/company-dashboard';
  static const rideRequest = '/ride-request';
  static const deliveryRequest = '/delivery-request';
  static const tracking = '/tracking';
  static const companyProfile = '/company-profile';
  static const analytics = '/analytics';
  
  // Shared routes
  static const notifications = '/notifications';
  static const rideHistory = '/ride-history';
  static const chat = '/chat';
  static const rating = '/rating';
  static const helpCenter = '/help-center';
  static const settings = '/settings';
  
  // Payment routes
  static const payment = '/payment';
  static const transactionHistory = '/transaction-history';
  static const balanceHistory = '/balance-history';
  
  // Admin routes
  static const driverVerification = '/driver-verification';
  static const adminDashboard = '/admin-dashboard';
  static const balanceTopUp = '/balance-topup';
  
  // Demo routes
  static const mapPickerDemo = '/map-picker-demo';
}

/// Creates the app router with auth-based guards and deep linking support
GoRouter createAppRouter(AsyncValue<User?> authState, {bool hasSeenOnboarding = true}) {
  return GoRouter(
    initialLocation: hasSeenOnboarding ? AppRoutes.login : AppRoutes.onboarding,
    redirect: (context, state) {
      final redirect = handleAuthRedirect(authState, state, hasSeenOnboarding);
      // Debug logging to help identify redirect loops
      if (redirect != null && redirect != state.matchedLocation) {
        debugPrint('Router redirect: ${state.matchedLocation} -> $redirect');
      }
      return redirect;
    },
    // Enable deep linking
    debugLogDiagnostics: true,
    // Error handling for page not found
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      // Onboarding route
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const DeliveryOnboardingScreen(),
      ),
      
      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverRegistration,
        builder: (context, state) => const DriverRegistrationScreen(),
      ),
      GoRoute(
        path: AppRoutes.companyRegistration,
        builder: (context, state) => const CompanyRegistrationScreen(),
      ),
      GoRoute(
        path: AppRoutes.phoneVerification,
        builder: (context, state) {
          final phoneNumber = state.uri.queryParameters['phoneNumber'] ?? '';
          return PhoneVerificationScreen(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: AppRoutes.emailVerification,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return EmailVerificationScreen(email: email);
        },
      ),
      
      // Driver routes
      GoRoute(
        path: AppRoutes.driverDashboard,
        builder: (context, state) => const DriverDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.activeRide,
        builder: (context, state) {
          final rideId = state.uri.queryParameters['rideId'];
          return ActiveRideScreen(rideId: rideId ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.driverProfile,
        builder: (context, state) => const DriverProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.earnings,
        builder: (context, state) => const EarningsScreen(),
      ),
      
      // Company routes
      GoRoute(
        path: AppRoutes.companyDashboard,
        builder: (context, state) => const CompanyDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.rideRequest,
        builder: (context, state) => const EnhancedRideRequestScreen(),
      ),
      GoRoute(
        path: AppRoutes.deliveryRequest,
        builder: (context, state) => const DeliveryRequestScreen(),
      ),
      GoRoute(
        path: AppRoutes.tracking,
        builder: (context, state) {
          final rideId = state.uri.queryParameters['rideId'];
          return TrackingScreen(rideId: rideId ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.companyProfile,
        builder: (context, state) => const CompanyProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),
      
      // Shared routes
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.rideHistory,
        builder: (context, state) => const RideHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final rideId = state.uri.queryParameters['rideId'];
          final otherUserId = state.uri.queryParameters['otherUserId'];
          final otherUserName = state.uri.queryParameters['otherUserName'];
          return ChatScreen(
            rideId: rideId ?? '',
            otherUserId: otherUserId ?? '',
            otherUserName: otherUserName ?? 'User',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.rating,
        builder: (context, state) {
          final rideId = state.uri.queryParameters['rideId'] ?? '';
          final otherUserName = state.uri.queryParameters['otherUserName'] ?? 'User';
          final otherUserPhotoUrl = state.uri.queryParameters['otherUserPhotoUrl'];
          final isRatingDriver = state.uri.queryParameters['isRatingDriver'] == 'true';
          return RatingScreen(
            rideId: rideId,
            otherUserName: otherUserName,
            otherUserPhotoUrl: otherUserPhotoUrl,
            isRatingDriver: isRatingDriver,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.helpCenter,
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // Payment routes
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: AppRoutes.transactionHistory,
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.balanceHistory,
        builder: (context, state) => const BalanceHistoryScreen(),
      ),
      
      // Admin routes
      GoRoute(
        path: AppRoutes.driverVerification,
        builder: (context, state) => const DriverVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.balanceTopUp,
        builder: (context, state) => const BalanceTopUpScreen(),
      ),
      
      // Demo routes
      GoRoute(
        path: AppRoutes.mapPickerDemo,
        builder: (context, state) => const MapPickerDemoScreen(),
      ),
    ],
  );
}
