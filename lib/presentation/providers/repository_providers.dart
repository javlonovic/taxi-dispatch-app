import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/fcm_notification_datasource.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firebase_storage_service.dart';
import '../../data/datasources/firestore_chat_datasource.dart';
import '../../data/datasources/firestore_location_datasource.dart';
import '../../data/datasources/firestore_rating_datasource.dart';
import '../../data/datasources/firestore_user_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../data/repositories/rating_repository_impl.dart';
import '../../data/repositories/ride_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/rating_repository.dart';
import '../../domain/repositories/ride_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/services/balance_service.dart';
import '../../domain/services/commission_service.dart';
import '../../domain/services/location_service.dart';
import '../../domain/services/maps_service.dart';
import '../../domain/services/notification_service.dart';
import '../../domain/services/ride_dispatch_service.dart';
import '../../domain/services/geocoding_service.dart';
import '../../data/datasources/firestore_ride_datasource.dart';

// ============================================================================
// Data Source Providers
// ============================================================================

/// Firebase Auth Data Source Provider
final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource();
});

/// Firestore User Data Source Provider
final firestoreUserDataSourceProvider = Provider<FirestoreUserDataSource>((ref) {
  return FirestoreUserDataSource();
});

/// Firebase Storage Service Provider
final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});

/// Firestore Location Data Source Provider
final firestoreLocationDataSourceProvider = Provider<FirestoreLocationDataSource>((ref) {
  return FirestoreLocationDataSource();
});

/// Firestore Chat Data Source Provider
final firestoreChatDataSourceProvider = Provider<FirestoreChatDataSource>((ref) {
  return FirestoreChatDataSource(firestore: FirebaseFirestore.instance);
});

/// FCM Notification Data Source Provider
final fcmNotificationDataSourceProvider = Provider<FCMNotificationDataSource>((ref) {
  return FCMNotificationDataSource();
});

/// Firestore Rating Data Source Provider
final firestoreRatingDataSourceProvider = Provider<FirestoreRatingDataSource>((ref) {
  return FirestoreRatingDataSource();
});

/// Firestore Ride Data Source Provider
final firestoreRideDataSourceProvider = Provider<FirestoreRideDataSource>((ref) {
  return FirestoreRideDataSource();
});

// ============================================================================
// Service Providers
// ============================================================================

/// Location Service Provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Maps Service Provider
final mapsServiceProvider = Provider<MapsService>((ref) {
  // TODO: Replace with actual API key from environment or config
  return MapsService(apiKey: 'YOUR_GOOGLE_MAPS_API_KEY');
});

/// Balance Service Provider
final balanceServiceProvider = Provider<BalanceService>((ref) {
  return BalanceService();
});

/// Commission Service Provider
final commissionServiceProvider = Provider<CommissionService>((ref) {
  return CommissionService();
});

/// Geocoding Service Provider
final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});

/// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  return NotificationService(notificationRepository);
});

/// Ride Dispatch Service Provider
final rideDispatchServiceProvider = Provider<RideDispatchService>((ref) {
  return RideDispatchService(
    locationDataSource: ref.watch(firestoreLocationDataSourceProvider),
    rideDataSource: ref.watch(firestoreRideDataSourceProvider),
    notificationService: ref.watch(notificationServiceProvider),
    locationService: ref.watch(locationServiceProvider),
  );
});

// ============================================================================
// Repository Providers
// ============================================================================

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authDataSource = ref.watch(firebaseAuthDataSourceProvider);
  return AuthRepositoryImpl(authDataSource: authDataSource);
});

/// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    userDataSource: ref.watch(firestoreUserDataSourceProvider),
    storageService: ref.watch(firebaseStorageServiceProvider),
  );
});

/// Ride Repository Provider
final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return RideRepositoryImpl(
    commissionService: ref.watch(commissionServiceProvider),
  );
});

/// Location Repository Provider
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(
    locationDataSource: ref.watch(firestoreLocationDataSourceProvider),
    locationService: ref.watch(locationServiceProvider),
    mapsService: ref.watch(mapsServiceProvider),
  );
});

/// Chat Repository Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dataSource = ref.watch(firestoreChatDataSourceProvider);
  return ChatRepositoryImpl(dataSource: dataSource);
});

/// Notification Repository Provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dataSource = ref.watch(fcmNotificationDataSourceProvider);
  return NotificationRepositoryImpl(dataSource: dataSource);
});

/// Rating Repository Provider
final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return RatingRepositoryImpl(
    ratingDataSource: ref.watch(firestoreRatingDataSourceProvider),
    userDataSource: ref.watch(firestoreUserDataSourceProvider),
  );
});

/// Payment Repository Provider
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl();
});
