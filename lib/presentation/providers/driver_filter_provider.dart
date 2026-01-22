import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/services/driver_filter_service.dart';
import 'user_provider.dart';

/// Filter criteria for drivers
class DriverFilterCriteria {
  final AvailabilityStatus? status;
  final double? minimumRating;
  final GeoPoint? location;
  final double? radiusKm;
  final bool sortByRating;
  final bool sortByDistance;

  const DriverFilterCriteria({
    this.status,
    this.minimumRating,
    this.location,
    this.radiusKm,
    this.sortByRating = false,
    this.sortByDistance = false,
  });

  DriverFilterCriteria copyWith({
    AvailabilityStatus? status,
    double? minimumRating,
    GeoPoint? location,
    double? radiusKm,
    bool? sortByRating,
    bool? sortByDistance,
  }) {
    return DriverFilterCriteria(
      status: status ?? this.status,
      minimumRating: minimumRating ?? this.minimumRating,
      location: location ?? this.location,
      radiusKm: radiusKm ?? this.radiusKm,
      sortByRating: sortByRating ?? this.sortByRating,
      sortByDistance: sortByDistance ?? this.sortByDistance,
    );
  }
}

/// Filtered drivers provider based on criteria
final filteredDriversProvider =
    FutureProvider.family<List<Driver>, DriverFilterCriteria>(
  (ref, criteria) async {
    // Get drivers by availability status if specified
    List<Driver> drivers;
    
    if (criteria.status != null) {
      drivers = await ref.watch(driverAvailabilityProvider(criteria.status!).future);
    } else {
      // Get all available drivers by default
      drivers = await ref.watch(availableDriversProvider.future);
    }

    // Apply minimum rating filter
    if (criteria.minimumRating != null) {
      drivers = DriverFilterService.filterByMinimumRating(
        drivers,
        criteria.minimumRating!,
      );
    }

    // Apply proximity filter
    if (criteria.location != null && criteria.radiusKm != null) {
      drivers = DriverFilterService.filterByProximity(
        drivers,
        criteria.location!,
        criteria.radiusKm!,
      );
    }

    // Apply sorting
    if (criteria.sortByRating) {
      drivers = DriverFilterService.sortByRating(drivers);
    } else if (criteria.sortByDistance && criteria.location != null) {
      drivers = DriverFilterService.sortByDistance(drivers, criteria.location!);
    }

    return drivers;
  },
);

/// Provider for available drivers within configured radius (5.5km default, range 5-6km)
/// As per requirements 9.5 and 10.1
final nearbyAvailableDriversProvider =
    FutureProvider.family<List<Driver>, GeoPoint>(
  (ref, location) async {
    final availableDrivers = await ref.watch(availableDriversProvider.future);
    
    // Filter by configured default radius and sort by distance
    final nearbyDrivers = DriverFilterService.filterAvailableDriversNearby(
      availableDrivers,
      location,
      AppConstants.defaultSearchRadiusKm,
    );
    
    return DriverFilterService.sortByDistance(nearbyDrivers, location);
  },
);
