import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/services/location_service.dart';
import 'repository_providers.dart';

/// Driver availability state notifier with automatic location tracking
class DriverAvailabilityNotifier extends StateNotifier<AsyncValue<AvailabilityStatus>> {
  final UserRepository _userRepository;
  final LocationService _locationService;
  final String _driverId;
  StreamSubscription? _locationSubscription;

  DriverAvailabilityNotifier(
    this._userRepository,
    this._locationService,
    this._driverId,
  ) : super(const AsyncValue.loading());

  @override
  void dispose() {
    _stopLocationTracking();
    super.dispose();
  }

  /// Update driver availability status and manage location tracking
  Future<void> updateAvailability(AvailabilityStatus status) async {
    state = const AsyncValue.loading();
    
    try {
      await _userRepository.updateDriverAvailability(_driverId, status);
      state = AsyncValue.data(status);

      // Start or stop location tracking based on status
      if (status == AvailabilityStatus.available) {
        await _startLocationTracking();
      } else {
        _stopLocationTracking();
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Set driver as active and start location tracking
  Future<void> setActive(bool isActive) async {
    try {
      // Update isActive status in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_driverId)
          .update({'isActive': isActive});

      if (isActive) {
        // Set availability to available and start tracking
        await updateAvailability(AvailabilityStatus.available);
      } else {
        // Set availability to offline and stop tracking
        await updateAvailability(AvailabilityStatus.offline);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Start location tracking for active driver
  Future<void> _startLocationTracking() async {
    try {
      // Request location permission
      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }

      // Start tracking location
      _locationSubscription = _locationService.startLocationTracking(
        distanceFilter: 10, // Update every 10 meters
        timeInterval: 10000, // Or every 10 seconds
      ).listen(
        (position) async {
          // Update driver location in Firestore with geohash
          try {
            final geoPoint = GeoPoint(position.latitude, position.longitude);
            
            // Calculate geohash for proximity queries
            final geohash = _calculateGeohash(position.latitude, position.longitude);
            
            await FirebaseFirestore.instance
                .collection('users')
                .doc(_driverId)
                .update({
              'currentLocation': geoPoint,
              'geopoint': geoPoint,
              'geohash': geohash,
              'lastLocationUpdate': FieldValue.serverTimestamp(),
            });
          } catch (e) {
            print('Failed to update location: $e');
          }
        },
        onError: (error) {
          print('Location tracking error: $error');
        },
      );
    } catch (e) {
      print('Failed to start location tracking: $e');
    }
  }

  /// Stop location tracking
  void _stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  /// Set initial status from current user data
  void setInitialStatus(AvailabilityStatus status) {
    state = AsyncValue.data(status);
  }

  /// Calculate geohash for a location (simple implementation)
  String _calculateGeohash(double latitude, double longitude, {int precision = 9}) {
    const base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
    var latRange = [-90.0, 90.0];
    var lonRange = [-180.0, 180.0];
    var geohash = '';
    var isEven = true;
    var bit = 0;
    var ch = 0;

    while (geohash.length < precision) {
      if (isEven) {
        final mid = (lonRange[0] + lonRange[1]) / 2;
        if (longitude > mid) {
          ch |= (1 << (4 - bit));
          lonRange[0] = mid;
        } else {
          lonRange[1] = mid;
        }
      } else {
        final mid = (latRange[0] + latRange[1]) / 2;
        if (latitude > mid) {
          ch |= (1 << (4 - bit));
          latRange[0] = mid;
        } else {
          latRange[1] = mid;
        }
      }

      isEven = !isEven;
      bit++;

      if (bit == 5) {
        geohash += base32[ch];
        bit = 0;
        ch = 0;
      }
    }

    return geohash;
  }
}

/// Driver availability state notifier provider
final driverAvailabilityNotifierProvider = StateNotifierProvider.family<
    DriverAvailabilityNotifier, AsyncValue<AvailabilityStatus>, String>(
  (ref, driverId) {
    final repository = ref.watch(userRepositoryProvider);
    final locationService = ref.watch(locationServiceProvider);
    return DriverAvailabilityNotifier(repository, locationService, driverId);
  },
);
