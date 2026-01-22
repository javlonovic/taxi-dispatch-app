import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/ride.dart';
import '../entities/user.dart';

/// Ride repository interface
abstract class RideRepository {
  /// Create a new ride request
  Future<Ride> createRideRequest(RideRequest request);

  /// Accept a ride
  Future<void> acceptRide(String rideId, String driverId);

  /// Update ride status
  Future<void> updateRideStatus(String rideId, RideStatus status);

  /// Complete a ride
  Future<void> completeRide(String rideId);

  /// Cancel a ride
  Future<void> cancelRide(String rideId, String reason);

  /// Watch active ride for a user
  Stream<Ride?> watchActiveRide(String userId);

  /// Get ride history for a user
  Future<List<Ride>> getRideHistory(String userId);

  /// Find available drivers within radius
  Future<List<Driver>> findAvailableDrivers(GeoPoint location, double radiusKm);
}

/// Ride request data
class RideRequest {
  final String companyUserId;
  final GeoPoint pickupLocation;
  final String pickupAddress;
  final GeoPoint? destination;
  final String? destinationAddress;
  
  // Enhanced delivery request fields
  final String? branchId;
  final String? companyName;
  final String? companyPhone;
  final String? recipientName;
  final String? recipientPhone;
  final int readyInMinutes;

  RideRequest({
    required this.companyUserId,
    required this.pickupLocation,
    required this.pickupAddress,
    this.destination,
    this.destinationAddress,
    this.branchId,
    this.companyName,
    this.companyPhone,
    this.recipientName,
    this.recipientPhone,
    this.readyInMinutes = 0,
  });
}
