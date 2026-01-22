import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/firestore_location_datasource.dart';
import '../../data/datasources/firestore_ride_datasource.dart';
import '../../data/models/ride_dto.dart';
import '../entities/ride.dart';
import 'notification_service.dart';
import 'location_service.dart';

/// Service for dispatching rides to nearby drivers
class RideDispatchService {
  final FirestoreLocationDataSource _locationDataSource;
  final FirestoreRideDataSource _rideDataSource;
  final NotificationService _notificationService;
  final LocationService _locationService;

  RideDispatchService({
    required FirestoreLocationDataSource locationDataSource,
    required FirestoreRideDataSource rideDataSource,
    required NotificationService notificationService,
    required LocationService locationService,
  })  : _locationDataSource = locationDataSource,
        _rideDataSource = rideDataSource,
        _notificationService = notificationService,
        _locationService = locationService;

  /// Find nearby available drivers
  /// Default search radius is 5.5km (range: 5-6km as per requirements 9.5, 10.1)
  /// If radiusKm is >= 50, finds all active drivers regardless of location
  Future<List<Map<String, dynamic>>> findNearbyDrivers({
    required GeoPoint pickupLocation,
    double radiusKm = AppConstants.defaultSearchRadiusKm,
  }) async {
    try {
      List<Map<String, dynamic>> drivers;
      
      // If radius is very large (>= 50km), find all active drivers
      if (radiusKm >= 50) {
        drivers = await _findAllActiveDrivers(pickupLocation);
      } else {
        drivers = await _locationDataSource.findDriversWithinRadius(
          pickupLocation,
          radiusKm,
        );
      }

      // Calculate distance for each driver
      final driversWithDistance = drivers.map((driver) {
        final driverLocation = driver['currentLocation'] as GeoPoint?;
        if (driverLocation != null) {
          final distance = _locationService.calculateDistanceBetween(
            pickupLocation.latitude,
            pickupLocation.longitude,
            driverLocation.latitude,
            driverLocation.longitude,
          );
          return {
            ...driver,
            'distanceMeters': distance,
            'distanceKm': distance / 1000,
          };
        }
        return {
          ...driver,
          'distanceMeters': double.infinity,
          'distanceKm': double.infinity,
        };
      }).toList();

      // Sort by distance
      driversWithDistance.sort((a, b) {
        final distA = a['distanceMeters'] as double? ?? double.infinity;
        final distB = b['distanceMeters'] as double? ?? double.infinity;
        return distA.compareTo(distB);
      });

      return driversWithDistance;
    } catch (e) {
      throw Exception('Failed to find nearby drivers: $e');
    }
  }

  /// Find all active drivers regardless of location
  Future<List<Map<String, dynamic>>> _findAllActiveDrivers(GeoPoint pickupLocation) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('users')
          .where('type', isEqualTo: 'driver')
          .where('isActive', isEqualTo: true)
          .where('availabilityStatus', isEqualTo: 'available')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to find all active drivers: $e');
    }
  }

  /// Create ride request and notify nearby drivers
  /// Default search radius is 5.5km (range: 5-6km as per requirements 9.5, 10.1)
  Future<String> createRideRequestAndNotify({
    required String companyUserId,
    required GeoPoint pickupLocation,
    required String pickupAddress,
    GeoPoint? destination,
    String? destinationAddress,
    String? recipientName,
    String? recipientPhone,
    double searchRadiusKm = AppConstants.defaultSearchRadiusKm,
  }) async {
    try {
      // Find nearby drivers
      final nearbyDrivers = await findNearbyDrivers(
        pickupLocation: pickupLocation,
        radiusKm: searchRadiusKm,
      );

      if (nearbyDrivers.isEmpty) {
        throw Exception('No drivers available within ${searchRadiusKm}km');
      }

      // Create ride request
      final rideDto = RideDto(
        id: '', // Will be set by Firestore
        companyUserId: companyUserId,
        driverUserId: null,
        status: 'pending',
        pickupLocation: pickupLocation,
        pickupAddress: pickupAddress,
        destination: destination,
        destinationAddress: destinationAddress,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        requestedAt: Timestamp.now(),
        acceptedAt: null,
        arrivedAt: null,
        completedAt: null,
        fare: null,
        distance: null,
        durationSeconds: null,
        rating: null,
      );

      final createdRide = await _rideDataSource.createRide(rideDto);

      // Send notifications to nearby drivers
      await _notifyNearbyDrivers(
        rideId: createdRide.id,
        drivers: nearbyDrivers,
        pickupAddress: pickupAddress,
        destinationAddress: destinationAddress,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
      );

      return createdRide.id;
    } catch (e) {
      throw Exception('Failed to create ride request: $e');
    }
  }

  /// Notify nearby drivers about new ride request
  /// Note: Cloud Functions will automatically send notifications when ride is created
  /// This method is kept for logging/debugging but notifications are handled by Cloud Functions
  Future<void> _notifyNearbyDrivers({
    required String rideId,
    required List<Map<String, dynamic>> drivers,
    required String pickupAddress,
    String? destinationAddress,
    String? recipientName,
    String? recipientPhone,
  }) async {
    // Cloud Functions onRideCreated will automatically send notifications
    // to all available drivers within radius when the ride is created
    // We just log here for debugging
    
    int driversWithTokens = 0;
    for (final driver in drivers) {
      final driverId = driver['id'] as String;
      // Check if driver has FCM token (Cloud Functions will check this too)
      try {
        final driverDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(driverId)
            .get();
        final fcmToken = driverDoc.data()?['fcmToken'] as String?;
        if (fcmToken != null && fcmToken.isNotEmpty) {
          driversWithTokens++;
        }
      } catch (e) {
        // Skip if can't check
      }
    }
    
    debugPrint('📢 Ride $rideId created - Cloud Functions will notify $driversWithTokens/${drivers.length} drivers with FCM tokens');
    
    // Cloud Functions onRideCreated will handle the actual notification sending
    // No need to send manually from the app
  }

  /// Accept ride request (called by driver)
  Future<void> acceptRideRequest({
    required String rideId,
    required String driverId,
    required String companyUserId,
  }) async {
    try {
      // Update ride status
      await _rideDataSource.acceptRide(rideId, driverId);

      // Notify company that driver accepted
      await _notificationService.sendNotificationToUser(
        userId: companyUserId,
        title: 'Driver Accepted',
        body: 'A driver has accepted your ride request',
        data: {
          'type': 'ride_accepted',
          'rideId': rideId,
          'driverId': driverId,
        },
      );
    } catch (e) {
      throw Exception('Failed to accept ride: $e');
    }
  }

  /// Update ride status and notify relevant parties
  Future<void> updateRideStatus({
    required String rideId,
    required RideStatus status,
    required String companyUserId,
    String? driverId,
  }) async {
    try {
      await _rideDataSource.updateRideStatus(rideId, status);

      // Send appropriate notifications based on status
      switch (status) {
        case RideStatus.enroute:
          if (driverId != null) {
            await _notificationService.sendNotificationToUser(
              userId: companyUserId,
              title: 'Driver En Route',
              body: 'Your driver is on the way to pick you up',
              data: {'type': 'driver_enroute', 'rideId': rideId},
            );
          }
          break;

        case RideStatus.arrived:
          await _notificationService.sendNotificationToUser(
            userId: companyUserId,
            title: 'Driver Arrived',
            body: 'Your driver has arrived at the pickup location',
            data: {'type': 'driver_arrived', 'rideId': rideId},
          );
          break;

        case RideStatus.completed:
          // Notify both parties
          await _notificationService.sendNotificationToUser(
            userId: companyUserId,
            title: 'Ride Completed',
            body: 'Your ride has been completed. Please rate your driver.',
            data: {'type': 'ride_completed', 'rideId': rideId},
          );
          if (driverId != null) {
            await _notificationService.sendNotificationToUser(
              userId: driverId,
              title: 'Ride Completed',
              body: 'Ride completed successfully',
              data: {'type': 'ride_completed', 'rideId': rideId},
            );
          }
          break;

        case RideStatus.cancelled:
          // Notify the other party
          if (driverId != null) {
            await _notificationService.sendNotificationToUser(
              userId: driverId,
              title: 'Ride Cancelled',
              body: 'The ride has been cancelled',
              data: {'type': 'ride_cancelled', 'rideId': rideId},
            );
          }
          await _notificationService.sendNotificationToUser(
            userId: companyUserId,
            title: 'Ride Cancelled',
            body: 'The ride has been cancelled',
            data: {'type': 'ride_cancelled', 'rideId': rideId},
          );
          break;

        default:
          break;
      }
    } catch (e) {
      throw Exception('Failed to update ride status: $e');
    }
  }

  /// Start tracking driver location for active ride
  Stream<GeoPoint?> trackDriverLocation(String driverId) {
    return _locationDataSource.watchDriverLocation(driverId);
  }

  /// Clear the driver search cache
  /// Should be called when driver availability changes significantly
  void clearDriverSearchCache() {
    _locationDataSource.clearSearchCache();
  }

  /// Calculate estimated arrival time (simplified)
  Future<Duration> estimateArrivalTime({
    required GeoPoint driverLocation,
    required GeoPoint pickupLocation,
  }) async {
    final distance = _locationService.calculateDistanceBetween(
      driverLocation.latitude,
      driverLocation.longitude,
      pickupLocation.latitude,
      pickupLocation.longitude,
    );

    // Use configured average city speed for ETA calculations
    const averageSpeedKmh = AppConstants.averageCitySpeedKmh;
    final distanceKm = distance / 1000;
    final hours = distanceKm / averageSpeedKmh;
    final minutes = (hours * 60).round();

    return Duration(minutes: minutes);
  }
}
