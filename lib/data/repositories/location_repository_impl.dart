import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/services/location_service.dart';
import '../../domain/services/maps_service.dart';
import '../datasources/firestore_location_datasource.dart';
import '../../core/exceptions/app_exception.dart';

/// Implementation of LocationRepository
class LocationRepositoryImpl implements LocationRepository {
  final FirestoreLocationDataSource _locationDataSource;
  final LocationService _locationService;
  final MapsService _mapsService;

  LocationRepositoryImpl({
    FirestoreLocationDataSource? locationDataSource,
    LocationService? locationService,
    MapsService? mapsService,
  })  : _locationDataSource =
            locationDataSource ?? FirestoreLocationDataSource(),
        _locationService = locationService ?? LocationService(),
        _mapsService = mapsService ?? MapsService(apiKey: 'YOUR_GOOGLE_MAPS_API_KEY');

  @override
  Stream<Position> watchDriverLocation(String driverId) {
    try {
      // Return stream of GeoPoint from Firestore and convert to Position
      return _locationDataSource.watchDriverLocation(driverId).asyncMap(
        (geoPoint) async {
          if (geoPoint == null) {
            throw LocationException('Driver location not found');
          }
          
          // Convert GeoPoint to Position
          return Position(
            latitude: geoPoint.latitude,
            longitude: geoPoint.longitude,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        },
      );
    } catch (e) {
      throw LocationException('Failed to watch driver location: $e');
    }
  }

  @override
  Future<void> updateDriverLocation(String driverId, Position position) async {
    try {
      await _locationDataSource.updateDriverLocation(driverId, position);
    } catch (e) {
      throw LocationException('Failed to update driver location: $e');
    }
  }

  @override
  Future<double> calculateDistance(GeoPoint start, GeoPoint end) async {
    try {
      final distance = _locationService.calculateDistanceBetween(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );
      return distance;
    } catch (e) {
      throw LocationException('Failed to calculate distance: $e');
    }
  }

  @override
  Future<Duration> calculateETA(GeoPoint start, GeoPoint end) async {
    try {
      final directions = await _mapsService.getDirections(start, end);
      final durationInSeconds = directions['durationInTraffic'] as int;
      return Duration(seconds: durationInSeconds);
    } catch (e) {
      throw LocationException('Failed to calculate ETA: $e');
    }
  }

  @override
  Future<List<LatLng>> getRoute(GeoPoint start, GeoPoint end) async {
    try {
      final directions = await _mapsService.getDirections(start, end);
      final polyline = directions['polyline'] as String;
      return _mapsService.decodePolyline(polyline);
    } catch (e) {
      throw LocationException('Failed to get route: $e');
    }
  }

  /// Find available drivers within radius
  Future<List<Map<String, dynamic>>> findDriversWithinRadius(
    GeoPoint center,
    double radiusInKm,
  ) async {
    try {
      return await _locationDataSource.findDriversWithinRadius(
        center,
        radiusInKm,
      );
    } catch (e) {
      throw LocationException('Failed to find drivers within radius: $e');
    }
  }
}
