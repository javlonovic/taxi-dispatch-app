import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../../core/constants/app_constants.dart';

/// Firestore data source for location operations
class FirestoreLocationDataSource {
  final FirebaseFirestore _firestore;
  
  // Cache for recent driver searches to reduce Firestore reads
  final Map<String, _CachedDriverSearch> _searchCache = {};
  static const _cacheDurationSeconds = 30; // Cache results for 30 seconds

  FirestoreLocationDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Update driver location in Firestore
  Future<void> updateDriverLocation(
    String driverId,
    Position position,
  ) async {
    try {
      final geoPoint = GeoPoint(position.latitude, position.longitude);
      
      // Create geohash for proximity queries
      final geoFirePoint = GeoFirePoint(GeoPoint(
        position.latitude,
        position.longitude,
      ));

      await _firestore.collection('users').doc(driverId).update({
        'currentLocation': geoPoint,
        'geohash': geoFirePoint.geohash,
        'geopoint': geoFirePoint.geopoint,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update driver location: $e');
    }
  }

  /// Watch driver location updates
  Stream<GeoPoint?> watchDriverLocation(String driverId) {
    return _firestore
        .collection('users')
        .doc(driverId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      return data?['currentLocation'] as GeoPoint?;
    });
  }

  /// Find drivers within radius using geohashing
  /// Default radius is 5.5km (range: 5-6km as per requirements 9.5, 10.1)
  /// Uses GeoFlutterFire for efficient geospatial queries with caching
  Future<List<Map<String, dynamic>>> findDriversWithinRadius(
    GeoPoint center,
    double radiusInKm,
  ) async {
    try {
      // Validate radius is within acceptable range
      final effectiveRadius = radiusInKm.clamp(
        AppConstants.minSearchRadiusKm,
        AppConstants.maxSearchRadiusKm * 3, // Allow expansion up to 3x max
      );

      // Check cache first to reduce Firestore reads
      final cacheKey = _generateCacheKey(center, effectiveRadius);
      final cachedResult = _getCachedResult(cacheKey);
      if (cachedResult != null) {
        return cachedResult;
      }

      final geoFirePoint = GeoFirePoint(center);
      
      // Query drivers within radius using geohashing for performance
      // GeoFlutterFire uses geohash indexing which is much faster than
      // calculating distances for all documents
      final collectionReference = _firestore.collection('users');
      
      final stream = GeoCollectionReference(collectionReference)
          .subscribeWithin(
            center: geoFirePoint,
            radiusInKm: effectiveRadius,
            field: 'geopoint',
            geopointFrom: (data) => data['geopoint'] as GeoPoint,
            strictMode: true,
          );

      // Get first result from stream with timeout
      List<DocumentSnapshot> results;
      try {
        results = await stream.first.timeout(
          const Duration(seconds: 10),
          onTimeout: () => [],
        );
      } catch (e) {
        // Fallback: If geohash query fails, use simple query
        print('Geohash query failed, using fallback: $e');
        final snapshot = await collectionReference
            .where('type', isEqualTo: 'driver')
            .where('isActive', isEqualTo: true)
            .where('availabilityStatus', isEqualTo: 'available')
            .get();
        results = snapshot.docs;
      }
      
      // Filter for available drivers only
      // These filters are applied in-memory after the geospatial query
      // to minimize Firestore query complexity
      final drivers = results
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) return false;
            
            // Must be a driver
            if (data['type'] != 'driver') return false;
            
            // Must be available
            if (data['availabilityStatus'] != 'available') return false;
            
            // Must be active (accepting orders)
            if (data['isActive'] != true) return false;
            
            // Must have a current location
            if (data['currentLocation'] == null) return false;
            
            // Calculate distance and filter by radius
            final location = data['currentLocation'] as GeoPoint;
            final distance = _calculateDistance(
              center.latitude,
              center.longitude,
              location.latitude,
              location.longitude,
            );
            
            // Filter by radius (convert km to meters)
            if (distance > effectiveRadius * 1000) return false;
            
            return true;
          })
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();

      // Cache the result
      _cacheResult(cacheKey, drivers);
      
      return drivers;
    } catch (e) {
      throw Exception('Failed to find drivers within radius: $e');
    }
  }

  /// Generate cache key for driver search
  String _generateCacheKey(GeoPoint center, double radius) {
    // Round coordinates to 3 decimal places (~111m precision)
    final lat = (center.latitude * 1000).round() / 1000;
    final lng = (center.longitude * 1000).round() / 1000;
    final rad = (radius * 10).round() / 10;
    return '$lat,$lng,$rad';
  }

  /// Get cached search result if still valid
  List<Map<String, dynamic>>? _getCachedResult(String key) {
    final cached = _searchCache[key];
    if (cached == null) return null;
    
    final age = DateTime.now().difference(cached.timestamp).inSeconds;
    if (age > _cacheDurationSeconds) {
      _searchCache.remove(key);
      return null;
    }
    
    return cached.drivers;
  }

  /// Cache search result
  void _cacheResult(String key, List<Map<String, dynamic>> drivers) {
    _searchCache[key] = _CachedDriverSearch(
      drivers: drivers,
      timestamp: DateTime.now(),
    );
    
    // Clean up old cache entries (keep only last 10)
    if (_searchCache.length > 10) {
      final oldestKey = _searchCache.entries
          .reduce((a, b) => a.value.timestamp.isBefore(b.value.timestamp) ? a : b)
          .key;
      _searchCache.remove(oldestKey);
    }
  }

  /// Clear the search cache (useful when driver availability changes)
  void clearSearchCache() {
    _searchCache.clear();
  }

  /// Get driver location by ID
  Future<GeoPoint?> getDriverLocation(String driverId) async {
    try {
      final doc = await _firestore.collection('users').doc(driverId).get();
      if (!doc.exists) return null;
      return doc.data()?['currentLocation'] as GeoPoint?;
    } catch (e) {
      throw Exception('Failed to get driver location: $e');
    }
  }

  /// Calculate distance between two points in meters (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000.0; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
}

/// Internal class for caching driver search results
class _CachedDriverSearch {
  final List<Map<String, dynamic>> drivers;
  final DateTime timestamp;

  _CachedDriverSearch({
    required this.drivers,
    required this.timestamp,
  });
}
