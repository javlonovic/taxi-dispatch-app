import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/user.dart';

/// Service for filtering drivers based on various criteria
class DriverFilterService {
  /// Filter drivers by availability status
  static List<Driver> filterByAvailability(
    List<Driver> drivers,
    AvailabilityStatus status,
  ) {
    return drivers
        .where((driver) => driver.availabilityStatus == status)
        .toList();
  }

  /// Filter drivers by minimum rating
  static List<Driver> filterByMinimumRating(
    List<Driver> drivers,
    double minimumRating,
  ) {
    return drivers
        .where((driver) => driver.averageRating >= minimumRating)
        .toList();
  }

  /// Filter drivers by proximity to a location (in kilometers)
  static List<Driver> filterByProximity(
    List<Driver> drivers,
    GeoPoint targetLocation,
    double radiusKm,
  ) {
    return drivers.where((driver) {
      if (driver.currentLocation == null) return false;

      final distance = _calculateDistance(
        driver.currentLocation!,
        targetLocation,
      );

      return distance <= radiusKm;
    }).toList();
  }

  /// Filter available drivers within proximity
  static List<Driver> filterAvailableDriversNearby(
    List<Driver> drivers,
    GeoPoint targetLocation,
    double radiusKm,
  ) {
    return drivers.where((driver) {
      // Must be active (accepting orders)
      if (!driver.isActive) {
        return false;
      }

      // Must be available
      if (driver.availabilityStatus != AvailabilityStatus.available) {
        return false;
      }

      // Must have a current location
      if (driver.currentLocation == null) return false;

      // Must be within radius
      final distance = _calculateDistance(
        driver.currentLocation!,
        targetLocation,
      );

      return distance <= radiusKm;
    }).toList();
  }

  /// Filter only active drivers (those accepting orders)
  static List<Driver> filterActiveDrivers(List<Driver> drivers) {
    return drivers.where((driver) => driver.isActive).toList();
  }

  /// Sort drivers by rating (descending)
  static List<Driver> sortByRating(List<Driver> drivers) {
    final sortedDrivers = List<Driver>.from(drivers);
    sortedDrivers.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    return sortedDrivers;
  }

  /// Sort drivers by distance from a location (ascending)
  static List<Driver> sortByDistance(
    List<Driver> drivers,
    GeoPoint targetLocation,
  ) {
    final sortedDrivers = List<Driver>.from(drivers);
    sortedDrivers.sort((a, b) {
      if (a.currentLocation == null && b.currentLocation == null) return 0;
      if (a.currentLocation == null) return 1;
      if (b.currentLocation == null) return -1;

      final distanceA = _calculateDistance(a.currentLocation!, targetLocation);
      final distanceB = _calculateDistance(b.currentLocation!, targetLocation);

      return distanceA.compareTo(distanceB);
    });
    return sortedDrivers;
  }

  /// Calculate distance between two GeoPoints using Haversine formula
  /// Returns distance in kilometers
  static double _calculateDistance(GeoPoint point1, GeoPoint point2) {
    const double earthRadiusKm = 6371.0;

    final lat1Rad = _degreesToRadians(point1.latitude);
    final lat2Rad = _degreesToRadians(point2.latitude);
    final deltaLatRad = _degreesToRadians(point2.latitude - point1.latitude);
    final deltaLonRad = _degreesToRadians(point2.longitude - point1.longitude);

    final a = _sin(deltaLatRad / 2) * _sin(deltaLatRad / 2) +
        _cos(lat1Rad) *
            _cos(lat2Rad) *
            _sin(deltaLonRad / 2) *
            _sin(deltaLonRad / 2);

    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * 3.141592653589793 / 180.0;
  }

  static double _sin(double x) {
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }

  static double _cos(double x) {
    return 1 - (x * x) / 2 + (x * x * x * x) / 24;
  }

  static double _sqrt(double x) {
    if (x < 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static double _atan2(double y, double x) {
    if (x > 0) {
      return _atan(y / x);
    } else if (x < 0 && y >= 0) {
      return _atan(y / x) + 3.141592653589793;
    } else if (x < 0 && y < 0) {
      return _atan(y / x) - 3.141592653589793;
    } else if (x == 0 && y > 0) {
      return 3.141592653589793 / 2;
    } else if (x == 0 && y < 0) {
      return -3.141592653589793 / 2;
    }
    return 0;
  }

  static double _atan(double x) {
    return x - (x * x * x) / 3 + (x * x * x * x * x) / 5;
  }
}
