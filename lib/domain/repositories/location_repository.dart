import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Location repository interface
abstract class LocationRepository {
  /// Watch driver location updates
  Stream<Position> watchDriverLocation(String driverId);

  /// Update driver location
  Future<void> updateDriverLocation(String driverId, Position position);

  /// Calculate distance between two points
  Future<double> calculateDistance(GeoPoint start, GeoPoint end);

  /// Calculate estimated time of arrival
  Future<Duration> calculateETA(GeoPoint start, GeoPoint end);

  /// Get route between two points
  Future<List<LatLng>> getRoute(GeoPoint start, GeoPoint end);
}
