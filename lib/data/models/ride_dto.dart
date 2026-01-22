import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ride.dart';

/// Ride DTO for Firestore serialization
class RideDto {
  final String id;
  final String companyUserId;
  final String? driverUserId;
  final String status;
  final GeoPoint pickupLocation;
  final String pickupAddress;
  final GeoPoint? destination;
  final String? destinationAddress;
  final Timestamp requestedAt;
  final Timestamp? acceptedAt;
  final Timestamp? arrivedAt;
  final Timestamp? completedAt;
  final Timestamp? cancelledAt;
  final String? cancellationReason;
  final double? fare;
  final double? distance;
  final int? durationSeconds;
  final Map<String, dynamic>? rating;
  
  // Enhanced delivery request fields
  final String? branchId;
  final String? companyName;
  final String? companyPhone;
  final String? recipientName;
  final String? recipientPhone;
  final int readyInMinutes;
  final Timestamp? scheduledPickupTime;

  RideDto({
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
    this.durationSeconds,
    this.rating,
    this.branchId,
    this.companyName,
    this.companyPhone,
    this.recipientName,
    this.recipientPhone,
    this.readyInMinutes = 0,
    this.scheduledPickupTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyUserId': companyUserId,
      'driverUserId': driverUserId,
      'status': status,
      'pickupLocation': pickupLocation,
      'pickupAddress': pickupAddress,
      'destination': destination,
      'destinationAddress': destinationAddress,
      'requestedAt': requestedAt,
      'acceptedAt': acceptedAt,
      'arrivedAt': arrivedAt,
      'completedAt': completedAt,
      'cancelledAt': cancelledAt,
      'cancellationReason': cancellationReason,
      'fare': fare,
      'distance': distance,
      'durationSeconds': durationSeconds,
      'rating': rating,
      'branchId': branchId,
      'companyName': companyName,
      'companyPhone': companyPhone,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'readyInMinutes': readyInMinutes,
      'scheduledPickupTime': scheduledPickupTime,
    };
  }

  factory RideDto.fromMap(String id, Map<String, dynamic> map) {
    return RideDto(
      id: id,
      companyUserId: map['companyUserId'] as String,
      driverUserId: map['driverUserId'] as String?,
      status: map['status'] as String,
      pickupLocation: map['pickupLocation'] as GeoPoint,
      pickupAddress: map['pickupAddress'] as String,
      destination: map['destination'] as GeoPoint?,
      destinationAddress: map['destinationAddress'] as String?,
      requestedAt: map['requestedAt'] as Timestamp,
      acceptedAt: map['acceptedAt'] as Timestamp?,
      arrivedAt: map['arrivedAt'] as Timestamp?,
      completedAt: map['completedAt'] as Timestamp?,
      cancelledAt: map['cancelledAt'] as Timestamp?,
      cancellationReason: map['cancellationReason'] as String?,
      fare: (map['fare'] as num?)?.toDouble(),
      distance: (map['distance'] as num?)?.toDouble(),
      durationSeconds: map['durationSeconds'] as int?,
      rating: map['rating'] as Map<String, dynamic>?,
      branchId: map['branchId'] as String?,
      companyName: map['companyName'] as String?,
      companyPhone: map['companyPhone'] as String?,
      recipientName: map['recipientName'] as String?,
      recipientPhone: map['recipientPhone'] as String?,
      readyInMinutes: (map['readyInMinutes'] as int?) ?? 0,
      scheduledPickupTime: map['scheduledPickupTime'] as Timestamp?,
    );
  }

  factory RideDto.fromEntity(Ride ride) {
    return RideDto(
      id: ride.id,
      companyUserId: ride.companyUserId,
      driverUserId: ride.driverUserId,
      status: _rideStatusToString(ride.status),
      pickupLocation: ride.pickupLocation,
      pickupAddress: ride.pickupAddress,
      destination: ride.destination,
      destinationAddress: ride.destinationAddress,
      requestedAt: Timestamp.fromDate(ride.requestedAt),
      acceptedAt: ride.acceptedAt != null ? Timestamp.fromDate(ride.acceptedAt!) : null,
      arrivedAt: ride.arrivedAt != null ? Timestamp.fromDate(ride.arrivedAt!) : null,
      completedAt: ride.completedAt != null ? Timestamp.fromDate(ride.completedAt!) : null,
      cancelledAt: ride.cancelledAt != null ? Timestamp.fromDate(ride.cancelledAt!) : null,
      cancellationReason: ride.cancellationReason,
      fare: ride.fare,
      distance: ride.distance,
      durationSeconds: ride.duration?.inSeconds,
      rating: ride.rating != null ? _ratingToMap(ride.rating!) : null,
      branchId: ride.branchId,
      companyName: ride.companyName,
      companyPhone: ride.companyPhone,
      recipientName: ride.recipientName,
      recipientPhone: ride.recipientPhone,
      readyInMinutes: ride.readyInMinutes,
      scheduledPickupTime: ride.scheduledPickupTime != null 
          ? Timestamp.fromDate(ride.scheduledPickupTime!) 
          : null,
    );
  }

  Ride toEntity() {
    return Ride(
      id: id,
      companyUserId: companyUserId,
      driverUserId: driverUserId,
      status: _parseRideStatus(status),
      pickupLocation: pickupLocation,
      pickupAddress: pickupAddress,
      destination: destination,
      destinationAddress: destinationAddress,
      requestedAt: requestedAt.toDate(),
      acceptedAt: acceptedAt?.toDate(),
      arrivedAt: arrivedAt?.toDate(),
      completedAt: completedAt?.toDate(),
      cancelledAt: cancelledAt?.toDate(),
      cancellationReason: cancellationReason,
      fare: fare,
      distance: distance,
      duration: durationSeconds != null ? Duration(seconds: durationSeconds!) : null,
      rating: rating != null ? _parseRating(rating!) : null,
      branchId: branchId,
      companyName: companyName,
      companyPhone: companyPhone,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      readyInMinutes: readyInMinutes,
      scheduledPickupTime: scheduledPickupTime?.toDate(),
    );
  }

  static RideStatus _parseRideStatus(String status) {
    switch (status) {
      case 'pending':
        return RideStatus.pending;
      case 'accepted':
        return RideStatus.accepted;
      case 'enroute':
        return RideStatus.enroute;
      case 'arrived':
        return RideStatus.arrived;
      case 'completed':
        return RideStatus.completed;
      case 'cancelled':
        return RideStatus.cancelled;
      case 'noDriverFound':
        return RideStatus.noDriverFound;
      default:
        return RideStatus.pending;
    }
  }

  static String _rideStatusToString(RideStatus status) {
    switch (status) {
      case RideStatus.pending:
        return 'pending';
      case RideStatus.accepted:
        return 'accepted';
      case RideStatus.enroute:
        return 'enroute';
      case RideStatus.arrived:
        return 'arrived';
      case RideStatus.completed:
        return 'completed';
      case RideStatus.cancelled:
        return 'cancelled';
      case RideStatus.noDriverFound:
        return 'noDriverFound';
    }
  }

  static RideRating _parseRating(Map<String, dynamic> map) {
    return RideRating(
      driverRating: (map['driverRating'] as num?)?.toDouble(),
      companyRating: (map['companyRating'] as num?)?.toDouble(),
      driverFeedback: map['driverFeedback'] as String?,
      companyFeedback: map['companyFeedback'] as String?,
    );
  }

  static Map<String, dynamic> _ratingToMap(RideRating rating) {
    return {
      'driverRating': rating.driverRating,
      'companyRating': rating.companyRating,
      'driverFeedback': rating.driverFeedback,
      'companyFeedback': rating.companyFeedback,
    };
  }
}
