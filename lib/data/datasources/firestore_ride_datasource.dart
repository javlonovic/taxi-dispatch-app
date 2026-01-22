import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_dto.dart';
import '../../domain/entities/ride.dart';

/// Firestore data source for ride operations
class FirestoreRideDataSource {
  final FirebaseFirestore _firestore;
  static const String _ridesCollection = 'rides';

  FirestoreRideDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create a new ride document
  Future<RideDto> createRide(RideDto rideDto) async {
    final docRef = _firestore.collection(_ridesCollection).doc();
    final newRide = RideDto(
      id: docRef.id,
      companyUserId: rideDto.companyUserId,
      driverUserId: rideDto.driverUserId,
      status: rideDto.status,
      pickupLocation: rideDto.pickupLocation,
      pickupAddress: rideDto.pickupAddress,
      destination: rideDto.destination,
      destinationAddress: rideDto.destinationAddress,
      requestedAt: rideDto.requestedAt,
      acceptedAt: rideDto.acceptedAt,
      arrivedAt: rideDto.arrivedAt,
      completedAt: rideDto.completedAt,
      fare: rideDto.fare,
      distance: rideDto.distance,
      durationSeconds: rideDto.durationSeconds,
      rating: rideDto.rating,
    );
    
    await docRef.set(newRide.toMap());
    return newRide;
  }

  /// Get ride by ID
  Future<RideDto?> getRideById(String rideId) async {
    final doc = await _firestore.collection(_ridesCollection).doc(rideId).get();

    if (!doc.exists) {
      return null;
    }

    return RideDto.fromMap(doc.id, doc.data()!);
  }

  /// Update ride document
  Future<void> updateRide(String rideId, Map<String, dynamic> updates) async {
    await _firestore.collection(_ridesCollection).doc(rideId).update(updates);
  }

  /// Delete ride document
  Future<void> deleteRide(String rideId) async {
    await _firestore.collection(_ridesCollection).doc(rideId).delete();
  }

  /// Update ride status
  Future<void> updateRideStatus(String rideId, RideStatus status) async {
    final updates = <String, dynamic>{
      'status': _rideStatusToString(status),
    };

    // Add timestamp based on status
    switch (status) {
      case RideStatus.accepted:
        updates['acceptedAt'] = FieldValue.serverTimestamp();
        break;
      case RideStatus.arrived:
        updates['arrivedAt'] = FieldValue.serverTimestamp();
        break;
      case RideStatus.completed:
        updates['completedAt'] = FieldValue.serverTimestamp();
        break;
      default:
        break;
    }

    await _firestore.collection(_ridesCollection).doc(rideId).update(updates);
  }

  /// Accept ride and assign driver
  Future<void> acceptRide(String rideId, String driverId) async {
    await _firestore.collection(_ridesCollection).doc(rideId).update({
      'driverUserId': driverId,
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream ride changes
  Stream<RideDto?> watchRide(String rideId) {
    return _firestore
        .collection(_ridesCollection)
        .doc(rideId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return null;
      }
      return RideDto.fromMap(doc.id, doc.data()!);
    });
  }

  /// Get active ride for a user (driver or company)
  Stream<RideDto?> watchActiveRide(String userId) {
    return _firestore
        .collection(_ridesCollection)
        .where('status', whereIn: ['pending', 'accepted', 'enroute', 'arrived'])
        .snapshots()
        .map((snapshot) {
      // Find ride where user is either driver or company
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['companyUserId'] == userId || data['driverUserId'] == userId) {
          return RideDto.fromMap(doc.id, data);
        }
      }
      return null;
    });
  }

  /// Get ride history for a user
  Future<List<RideDto>> getRideHistory(String userId, {
    DateTime? startDate,
    DateTime? endDate,
    List<RideStatus>? statusFilter,
  }) async {
    Query query = _firestore.collection(_ridesCollection);

    // If no status filter provided, get all rides
    final statusStrings = statusFilter?.map(_rideStatusToString).toList();
    
    QuerySnapshot snapshot;
    if (statusStrings != null && statusStrings.isNotEmpty) {
      snapshot = await query
          .where('status', whereIn: statusStrings)
          .orderBy('requestedAt', descending: true)
          .get();
    } else {
      // Get all rides, ordered by requestedAt
      snapshot = await query
          .orderBy('requestedAt', descending: true)
          .get();
    }

    final rides = snapshot.docs
        .map((doc) => RideDto.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .where((ride) => 
            ride.companyUserId == userId || ride.driverUserId == userId)
        .toList();

    // Apply date filters if provided
    if (startDate != null) {
      rides.removeWhere((ride) => 
          ride.requestedAt.toDate().isBefore(startDate));
    }
    if (endDate != null) {
      rides.removeWhere((ride) => 
          ride.requestedAt.toDate().isAfter(endDate));
    }

    return rides;
  }

  /// Get rides by company user
  Future<List<RideDto>> getRidesByCompany(String companyUserId) async {
    final snapshot = await _firestore
        .collection(_ridesCollection)
        .where('companyUserId', isEqualTo: companyUserId)
        .orderBy('requestedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => RideDto.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Get rides by driver
  Future<List<RideDto>> getRidesByDriver(String driverId) async {
    final snapshot = await _firestore
        .collection(_ridesCollection)
        .where('driverUserId', isEqualTo: driverId)
        .orderBy('requestedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => RideDto.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Update ride fare
  Future<void> updateRideFare(String rideId, double fare) async {
    await _firestore.collection(_ridesCollection).doc(rideId).update({
      'fare': fare,
    });
  }

  /// Cancel ride with reason
  Future<void> cancelRide(String rideId, String reason) async {
    await _firestore.collection(_ridesCollection).doc(rideId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
      'cancellationReason': reason,
    });
  }

  /// Helper method to convert ride status to string
  String _rideStatusToString(RideStatus status) {
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
}
