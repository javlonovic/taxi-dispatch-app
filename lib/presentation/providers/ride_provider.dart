import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ride.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/ride_repository.dart';
import '../../data/models/ride_dto.dart';
import 'repository_providers.dart';

/// Provider for creating a ride request
final createRideRequestProvider = FutureProvider.family<Ride, RideRequest>(
  (ref, request) async {
    final repository = ref.read(rideRepositoryProvider);
    return await repository.createRideRequest(request);
  },
);

/// Provider for watching active ride
final activeRideProvider = StreamProvider.family<Ride?, String>(
  (ref, userId) {
    final repository = ref.read(rideRepositoryProvider);
    return repository.watchActiveRide(userId);
  },
);

/// Provider for ride history
final rideHistoryProvider = FutureProvider.family<List<Ride>, String>(
  (ref, userId) async {
    final repository = ref.read(rideRepositoryProvider);
    return await repository.getRideHistory(userId);
  },
);

/// Provider for getting a ride by ID
final rideByIdProvider = StreamProvider.family<Ride?, String>(
  (ref, rideId) {
    final firestore = FirebaseFirestore.instance;
    return firestore
        .collection('rides')
        .doc(rideId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      final rideDto = RideDto.fromMap(doc.id, doc.data()!);
      return rideDto.toEntity();
    });
  },
);

/// Provider for finding available drivers
final availableDriversProvider = FutureProvider.family<List<Driver>, DriverSearchParams>(
  (ref, params) async {
    final repository = ref.read(rideRepositoryProvider);
    return await repository.findAvailableDrivers(
      params.location,
      params.radiusKm,
    );
  },
);

/// Parameters for driver search
class DriverSearchParams {
  final GeoPoint location;
  final double radiusKm;

  DriverSearchParams({
    required this.location,
    this.radiusKm = 5.0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverSearchParams &&
          runtimeType == other.runtimeType &&
          location.latitude == other.location.latitude &&
          location.longitude == other.location.longitude &&
          radiusKm == other.radiusKm;

  @override
  int get hashCode =>
      location.latitude.hashCode ^
      location.longitude.hashCode ^
      radiusKm.hashCode;
}

/// State notifier for ride management
class RideNotifier extends StateNotifier<AsyncValue<Ride?>> {
  final RideRepository _repository;

  RideNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createRideRequest(RideRequest request) async {
    state = const AsyncValue.loading();
    try {
      final ride = await _repository.createRideRequest(request);
      state = AsyncValue.data(ride);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> acceptRide(String rideId, String driverId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.acceptRide(rideId, driverId);
      // Refresh ride data
      final ride = await _repository.watchActiveRide(driverId).first;
      state = AsyncValue.data(ride);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateRideStatus(String rideId, RideStatus status) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateRideStatus(rideId, status);
      state = state;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> completeRide(String rideId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.completeRide(rideId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> cancelRide(String rideId, String reason) async {
    state = const AsyncValue.loading();
    try {
      await _repository.cancelRide(rideId, reason);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider for ride notifier
final rideNotifierProvider = StateNotifierProvider<RideNotifier, AsyncValue<Ride?>>(
  (ref) {
    final repository = ref.read(rideRepositoryProvider);
    return RideNotifier(repository);
  },
);
