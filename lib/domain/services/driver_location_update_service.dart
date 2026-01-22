import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Service for updating driver location in real-time
/// Updates location every 10 seconds while driver has an active ride
class DriverLocationUpdateService {
  final FirebaseFirestore _firestore;
  Timer? _locationTimer;
  String? _currentDriverId;

  DriverLocationUpdateService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Start location updates for a driver
  /// Updates location every 10 seconds
  void startLocationUpdates(String driverId) {
    // Cancel any existing timer
    stopLocationUpdates();

    _currentDriverId = driverId;

    // Update immediately
    _updateLocation(driverId);

    // Set up periodic updates every 10 seconds
    _locationTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _updateLocation(driverId),
    );
  }

  /// Stop location updates
  void stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _currentDriverId = null;
  }

  /// Update driver location in Firestore
  Future<void> _updateLocation(String driverId) async {
    try {
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update in Firestore
      await _firestore.collection('users').doc(driverId).update({
        'currentLocation': GeoPoint(
          position.latitude,
          position.longitude,
        ),
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error but don't throw - we'll try again in 10 seconds
      debugPrint('Error updating driver location: $e');
    }
  }

  /// Check if location updates are active
  bool get isActive => _locationTimer != null && _locationTimer!.isActive;

  /// Get current driver ID being tracked
  String? get currentDriverId => _currentDriverId;

  /// Dispose of resources
  void dispose() {
    stopLocationUpdates();
  }
}
