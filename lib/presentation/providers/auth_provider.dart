import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/notification_service.dart';
import 'repository_providers.dart';

/// Provider for auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// Provider for current authenticated user (alias for authStateProvider)
final currentUserProvider = authStateProvider;

/// Provider for auth service (business logic)
final authServiceProvider = Provider<AuthService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return AuthService(authRepository, notificationService);
});

/// Auth service class for business logic
class AuthService {
  final AuthRepository _authRepository;
  final NotificationService _notificationService;

  AuthService(this._authRepository, this._notificationService);

  Future<User> login(String email, String password) async {
    final user = await _authRepository.login(email, password);
    
    // Initialize notifications for user
    await _notificationService.initializeForUser(user.id);
    await _notificationService.subscribeToUserTopic(user.id);
    
    // Subscribe to role-specific topics
    if (user.type == UserType.driver) {
      await _notificationService.subscribeToDriverTopics();
    } else {
      await _notificationService.subscribeToCompanyTopics();
    }
    
    return user;
  }

  Future<User> registerDriver(DriverRegistrationData data) async {
    final user = await _authRepository.registerDriver(data);
    // Send email verification after registration
    await _authRepository.sendEmailVerification();
    
    // Initialize notifications for user
    await _notificationService.initializeForUser(user.id);
    await _notificationService.subscribeToUserTopic(user.id);
    await _notificationService.subscribeToDriverTopics();
    
    return user;
  }

  Future<User> registerCompany(CompanyRegistrationData data) async {
    final user = await _authRepository.registerCompany(data);
    // Send email verification after registration
    await _authRepository.sendEmailVerification();
    
    // Initialize notifications for user
    await _notificationService.initializeForUser(user.id);
    await _notificationService.subscribeToUserTopic(user.id);
    await _notificationService.subscribeToCompanyTopics();
    
    return user;
  }

  Future<void> sendEmailVerification() async {
    await _authRepository.sendEmailVerification();
  }

  Future<void> sendPhoneVerification(String phoneNumber) async {
    await _authRepository.sendPhoneVerification(phoneNumber);
  }

  Future<bool> verifyOTP(String otp) async {
    return await _authRepository.verifyOTP(otp);
  }

  Future<void> logout() async {
    // Get current user before logout
    final authState = await _authRepository.authStateChanges.first;
    if (authState != null) {
      await _notificationService.cleanupForUser(authState.id);
    }
    
    await _authRepository.logout();
  }
}
