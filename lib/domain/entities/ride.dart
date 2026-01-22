import 'package:cloud_firestore/cloud_firestore.dart';

/// Ride status enumeration
enum RideStatus {
  pending,
  accepted,
  enroute,
  arrived,
  completed,
  cancelled,
  noDriverFound,  // Водитель не найден
}

/// Delivery status enumeration for enhanced tracking
enum DeliveryStatus {
  searching,      // Ищем водителя
  driverAssigned, // Водитель назначен
  onTheWay,       // В пути
  delivered,      // Доставлено
  cancelled,      // Отменено
  noDriverFound,  // Водитель не найден
}

/// Ride rating information
class RideRating {
  final double? driverRating;
  final double? companyRating;
  final String? driverFeedback;
  final String? companyFeedback;

  RideRating({
    this.driverRating,
    this.companyRating,
    this.driverFeedback,
    this.companyFeedback,
  });
}

/// Ride entity
class Ride {
  final String id;
  final String companyUserId;
  final String? driverUserId;
  final RideStatus status;
  final GeoPoint pickupLocation;
  final String pickupAddress;
  final GeoPoint? destination;
  final String? destinationAddress;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final double? fare;
  final double? distance;
  final Duration? duration;
  final RideRating? rating;
  
  // Enhanced delivery request fields
  final String? branchId;
  final String? companyName;
  final String? companyPhone;
  final String? recipientName;
  final String? recipientPhone;
  final int readyInMinutes;
  final DateTime? scheduledPickupTime;

  Ride({
    required this.id,
    required this.companyUserId,
    this.driverUserId,
    required this.status,
    required this.pickupLocation,
    required this.pickupAddress,
    this.destination,
    this.destinationAddress,
    required this.requestedAt,
    this.acceptedAt,
    this.arrivedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.fare,
    this.distance,
    this.duration,
    this.rating,
    this.branchId,
    this.companyName,
    this.companyPhone,
    this.recipientName,
    this.recipientPhone,
    this.readyInMinutes = 0,
    this.scheduledPickupTime,
  });
  
  /// Calculate the effective pickup time based on requested time and ready minutes
  DateTime get effectivePickupTime {
    return requestedAt.add(Duration(minutes: readyInMinutes));
  }
  
  /// Check if pickup is immediate (ready now)
  bool get isImmediatePickup => readyInMinutes == 0;
}
