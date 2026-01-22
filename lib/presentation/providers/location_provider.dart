import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/services/driver_location_update_service.dart';
import 'repository_providers.dart';

/// Provider for current location
final currentLocationProvider = FutureProvider<Position>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getCurrentLocation();
});

/// Provider for location permission status
final locationPermissionProvider = FutureProvider<bool>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.hasLocationPermission();
});

/// Provider for watching driver location (returns Position from repository)
final driverLocationStreamProvider = StreamProvider.family<Position, String>(
  (ref, driverId) {
    final repository = ref.watch(locationRepositoryProvider);
    return repository.watchDriverLocation(driverId);
  },
);

/// Provider for watching driver location as GeoPoint (real-time Firestore updates)
final driverGeoPointStreamProvider = StreamProvider.family<GeoPoint, String>(
  (ref, driverId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(driverId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      return data?['currentLocation'] as GeoPoint? ?? 
        GeoPoint(0, 0); // Fallback to default location
    });
  },
);

/// Provider for calculating distance
final distanceProvider = FutureProvider.family<double, DistanceParams>(
  (ref, params) async {
    final repository = ref.watch(locationRepositoryProvider);
    return await repository.calculateDistance(params.start, params.end);
  },
);

/// Provider for calculating ETA
final etaProvider = FutureProvider.family<Duration, DistanceParams>(
  (ref, params) async {
    final repository = ref.watch(locationRepositoryProvider);
    return await repository.calculateETA(params.start, params.end);
  },0
);

/// Provider for getting route
final routeProvider = FutureProvider.family<List<LatLng>, DistanceParams>(
  (ref, params) async {
    final repository = ref.watch(locationRepositoryProvider);
    return await repository.getRoute(params.start, params.end);
  },
);

/// Parameters for distance/ETA/route calculations
class DistanceParams {
  final GeoPoint start;
  final GeoPoint end;

  const DistanceParams({
    required this.start,
    required this.end,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistanceParams &&
          runtimeType == other.runtimeType &&
          start.latitude == other.start.latitude &&
          start.longitude == other.start.longitude &&
          end.latitude == other.end.latitude &&
          end.longitude == other.end.longitude;

  @override
  int get hashCode =>
      start.latitude.hashCode ^
      start.longitude.hashCode ^
      end.latitude.hashCode ^
      end.longitude.hashCode;
}

/// Parameters for nearby drivers query
class NearbyDriversParams {
  final GeoPoint center;
  final double radiusInKm;

  const NearbyDriversParams({
    required this.center,
    required this.radiusInKm,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyDriversParams &&
          runtimeType == other.runtimeType &&
          center.latitude == other.center.latitude &&
          center.longitude == other.center.longitude &&
          radiusInKm == other.radiusInKm;

  @override
  int get hashCode =>
      center.latitude.hashCode ^
      center.longitude.hashCode ^
      radiusInKm.hashCode;
}

/// Provider for finding nearby drivers (uses LocationRepositoryImpl directly)
final nearbyDriversProvider = FutureProvider.family<List<Map<String, dynamic>>, NearbyDriversParams>(
  (ref, params) async {
    final repository = ref.watch(locationRepositoryProvider) as LocationRepositoryImpl;
    return await repository.findDriversWithinRadius(
      params.center,
      params.radiusInKm,
    );
  },
);

/// Provider for driver location update service
final driverLocationUpdateServiceProvider = Provider<DriverLocationUpdateService>((ref) {
  final service = DriverLocationUpdateService();
  ref.onDispose(() => service.dispose());
  return service;
});
