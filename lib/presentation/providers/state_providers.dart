import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/ride.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/ride_repository.dart';
import '../../domain/repositories/user_repository.dart';
import 'repository_providers.dart';

// ============================================================================
// Auth State Providers
// ============================================================================

/// Auth state stream provider - provides current authenticated user
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// Current user ID provider - extracts user ID from auth state
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user?.id,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Is authenticated provider - checks if user is logged in
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Current user type provider - extracts user type from auth state
final currentUserTypeProvider = Provider<UserType?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user?.type,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Is driver provider - checks if current user is a driver
final isDriverProvider = Provider<bool>((ref) {
  final userType = ref.watch(currentUserTypeProvider);
  return userType == UserType.driver;
});

/// Is company provider - checks if current user is a company
final isCompanyProvider = Provider<bool>((ref) {
  final userType = ref.watch(currentUserTypeProvider);
  return userType == UserType.company;
});

// ============================================================================
// Auth State Notifier
// ============================================================================

/// Auth state with loading and error states
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Auth state notifier for managing authentication operations
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthStateNotifier(this._authRepository) : super(const AuthState()) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authRepository.authStateChanges.listen((user) {
      state = AuthState(user: user, isLoading: false);
    });
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.login(email, password);
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> registerDriver(DriverRegistrationData data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.registerDriver(data);
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> registerCompany(CompanyRegistrationData data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authRepository.registerCompany(data);
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.logout();
      state = const AuthState(isLoading: false);
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth state notifier provider
final authStateNotifierProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(authRepository);
});

// ============================================================================
// Ride State Providers
// ============================================================================

/// Active ride stream provider for a specific user
final activeRideStreamProvider = StreamProvider.family<Ride?, String>((ref, userId) {
  final repository = ref.watch(rideRepositoryProvider);
  return repository.watchActiveRide(userId);
});

/// Ride history provider for a specific user
final rideHistoryProvider = FutureProvider.family<List<Ride>, String>((ref, userId) async {
  final repository = ref.watch(rideRepositoryProvider);
  return await repository.getRideHistory(userId);
});

// ============================================================================
// Ride State Notifier
// ============================================================================

/// Ride state with loading and error states
class RideState {
  final Ride? currentRide;
  final List<Ride> rideHistory;
  final bool isLoading;
  final String? error;

  const RideState({
    this.currentRide,
    this.rideHistory = const [],
    this.isLoading = false,
    this.error,
  });

  RideState copyWith({
    Ride? currentRide,
    List<Ride>? rideHistory,
    bool? isLoading,
    String? error,
  }) {
    return RideState(
      currentRide: currentRide ?? this.currentRide,
      rideHistory: rideHistory ?? this.rideHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Ride state notifier for managing ride operations
class RideStateNotifier extends StateNotifier<RideState> {
  final RideRepository _rideRepository;

  RideStateNotifier(this._rideRepository) : super(const RideState());

  Future<void> createRideRequest(RideRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final ride = await _rideRepository.createRideRequest(request);
      state = RideState(currentRide: ride, isLoading: false);
    } catch (e) {
      state = RideState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> acceptRide(String rideId, String driverId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _rideRepository.acceptRide(rideId, driverId);
      // Ride will be updated via stream
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateRideStatus(String rideId, RideStatus status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _rideRepository.updateRideStatus(rideId, status);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> completeRide(String rideId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _rideRepository.completeRide(rideId);
      state = const RideState(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> loadRideHistory(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final history = await _rideRepository.getRideHistory(userId);
      state = state.copyWith(rideHistory: history, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void setCurrentRide(Ride? ride) {
    state = state.copyWith(currentRide: ride);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Ride state notifier provider
final rideStateNotifierProvider = StateNotifierProvider<RideStateNotifier, RideState>((ref) {
  final rideRepository = ref.watch(rideRepositoryProvider);
  return RideStateNotifier(rideRepository);
});

// ============================================================================
// Location State Providers
// ============================================================================

/// Current location provider
final currentLocationProvider = FutureProvider<Position>((ref) async {
  // Get current position using geolocator
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
});

/// Location permission status provider
final locationPermissionProvider = FutureProvider<LocationPermission>((ref) async {
  return await Geolocator.checkPermission();
});

/// Driver location stream provider
final driverLocationStreamProvider = StreamProvider.family<Position, String>((ref, driverId) {
  final repository = ref.watch(locationRepositoryProvider);
  return repository.watchDriverLocation(driverId);
});

// ============================================================================
// Location State Notifier
// ============================================================================

/// Location state with loading and error states
class LocationState {
  final Position? currentPosition;
  final Map<String, Position> driverLocations;
  final bool isLoading;
  final bool isTracking;
  final String? error;

  const LocationState({
    this.currentPosition,
    this.driverLocations = const {},
    this.isLoading = false,
    this.isTracking = false,
    this.error,
  });

  LocationState copyWith({
    Position? currentPosition,
    Map<String, Position>? driverLocations,
    bool? isLoading,
    bool? isTracking,
    String? error,
  }) {
    return LocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      driverLocations: driverLocations ?? this.driverLocations,
      isLoading: isLoading ?? this.isLoading,
      isTracking: isTracking ?? this.isTracking,
      error: error,
    );
  }
}

/// Location state notifier for managing location operations
class LocationStateNotifier extends StateNotifier<LocationState> {
  final LocationRepository _locationRepository;
  final UserRepository _userRepository;

  LocationStateNotifier(this._locationRepository, this._userRepository)
      : super(const LocationState());

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      state = state.copyWith(currentPosition: position, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateDriverLocation(String driverId, Position position) async {
    try {
      await _locationRepository.updateDriverLocation(driverId, position);
      
      // Also update in Firestore via user repository
      final geoPoint = GeoPoint(position.latitude, position.longitude);
      await _userRepository.updateDriverLocation(driverId, geoPoint);
      
      // Update local state
      final updatedLocations = Map<String, Position>.from(state.driverLocations);
      updatedLocations[driverId] = position;
      state = state.copyWith(driverLocations: updatedLocations);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> startLocationTracking(String driverId) async {
    state = state.copyWith(isTracking: true, error: null);
    try {
      // Start listening to location updates
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((position) {
        updateDriverLocation(driverId, position);
      });
    } catch (e) {
      state = state.copyWith(isTracking: false, error: e.toString());
      rethrow;
    }
  }

  void stopLocationTracking() {
    state = state.copyWith(isTracking: false);
  }

  Future<double> calculateDistance(GeoPoint start, GeoPoint end) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final distance = await _locationRepository.calculateDistance(start, end);
      state = state.copyWith(isLoading: false);
      return distance;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Duration> calculateETA(GeoPoint start, GeoPoint end) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final eta = await _locationRepository.calculateETA(start, end);
      state = state.copyWith(isLoading: false);
      return eta;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Location state notifier provider
final locationStateNotifierProvider = StateNotifierProvider<LocationStateNotifier, LocationState>((ref) {
  final locationRepository = ref.watch(locationRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return LocationStateNotifier(locationRepository, userRepository);
});

// ============================================================================
// User State Notifier
// ============================================================================

/// User state with loading and error states
class UserState {
  final User? user;
  final bool isLoading;
  final String? error;

  const UserState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// User state notifier for managing user profile operations
class UserStateNotifier extends StateNotifier<UserState> {
  final UserRepository _userRepository;

  UserStateNotifier(this._userRepository) : super(const UserState());

  Future<void> loadUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _userRepository.getUserById(userId);
      state = UserState(user: user, isLoading: false);
    } catch (e) {
      state = UserState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _userRepository.updateUserProfile(userId, updates);
      // Reload user data
      await loadUser(userId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateDriverAvailability(String driverId, AvailabilityStatus status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _userRepository.updateDriverAvailability(driverId, status);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// User state notifier provider
final userStateNotifierProvider = StateNotifierProvider<UserStateNotifier, UserState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserStateNotifier(userRepository);
});
