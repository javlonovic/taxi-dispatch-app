import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user.dart';
import 'app_router.dart';

/// Handles authentication-based redirects
String? handleAuthRedirect(AsyncValue<User?> authState, GoRouterState state, bool hasSeenOnboarding) {
  final isLoading = authState.isLoading;
  final user = authState.value;
  final isLoggedIn = user != null;
  final currentLocation = state.matchedLocation;

  // Show loading screen while checking auth state
  if (isLoading) {
    return null;
  }

  // Prevent redirect loops by checking if we're already at the target
  final targetLocation = state.uri.queryParameters['from'];
  if (targetLocation == currentLocation) {
    return null;
  }

  // If user hasn't seen onboarding and not on onboarding screen, redirect to onboarding
  if (!hasSeenOnboarding && currentLocation != AppRoutes.onboarding) {
    return AppRoutes.onboarding;
  }

  // If user has seen onboarding and is on onboarding screen, redirect to login
  if (hasSeenOnboarding && currentLocation == AppRoutes.onboarding) {
    return AppRoutes.login;
  }

  // Define public routes that don't require authentication
  final publicRoutes = [
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.roleSelection,
    AppRoutes.driverRegistration,
    AppRoutes.companyRegistration,
    AppRoutes.phoneVerification,
    AppRoutes.emailVerification,
  ];

  // Define auth flow routes that should be accessible even when logged in
  // (for users who are in the middle of registration/verification)
  final authFlowRoutes = [
    AppRoutes.roleSelection,
    AppRoutes.driverRegistration,
    AppRoutes.companyRegistration,
    AppRoutes.phoneVerification,
    AppRoutes.emailVerification,
  ];

  final isPublicRoute = publicRoutes.contains(currentLocation);
  final isAuthFlowRoute = authFlowRoutes.contains(currentLocation);

  // Redirect to appropriate dashboard if logged in and trying to access login/onboarding
  // But allow access to registration/verification screens
  if (isLoggedIn && isPublicRoute && !isAuthFlowRoute) {
    return _getHomePage(user);
  }

  // Redirect to login if not logged in and trying to access protected routes
  if (!isLoggedIn && !isPublicRoute) {
    return AppRoutes.login;
  }

  // Check role-based access
  if (isLoggedIn) {
    final roleViolation = _checkRoleAccess(user, currentLocation);
    if (roleViolation != null) {
      return roleViolation;
    }
  }

  return null;
}

/// Returns the home page based on user type
String _getHomePage(User user) {
  switch (user.type) {
    case UserType.driver:
      return AppRoutes.driverDashboard;
    case UserType.company:
      return AppRoutes.companyDashboard;
    case UserType.admin:
      return AppRoutes.adminDashboard;
  }
}

/// Checks if user has access to the requested route based on their role
String? _checkRoleAccess(User user, String location) {
  // Driver-only routes
  final driverOnlyRoutes = [
    AppRoutes.driverDashboard,
    AppRoutes.activeRide,
    AppRoutes.driverProfile,
  ];

  // Company-only routes
  final companyOnlyRoutes = [
    AppRoutes.companyDashboard,
    AppRoutes.rideRequest,
    AppRoutes.tracking,
    AppRoutes.companyProfile,
  ];

  // Admin-only routes
  final adminOnlyRoutes = [
    AppRoutes.adminDashboard,
    AppRoutes.balanceTopUp,
  ];

  // Check if non-admin is trying to access admin routes
  if (user.type != UserType.admin && adminOnlyRoutes.contains(location)) {
    return _getHomePage(user);
  }

  // Check if driver is trying to access company routes
  if (user.type == UserType.driver && companyOnlyRoutes.contains(location)) {
    return AppRoutes.driverDashboard;
  }

  // Check if company is trying to access driver routes
  if (user.type == UserType.company && driverOnlyRoutes.contains(location)) {
    return AppRoutes.companyDashboard;
  }

  // Check if admin is trying to access driver/company routes
  if (user.type == UserType.admin && 
      (driverOnlyRoutes.contains(location) || companyOnlyRoutes.contains(location))) {
    return AppRoutes.adminDashboard;
  }

  return null;
}
