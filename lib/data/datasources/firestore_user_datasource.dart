import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_dto.dart';
import '../../domain/entities/user.dart';

/// Firestore data source for user operations
class FirestoreUserDataSource {
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';

  FirestoreUserDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create a new user document
  Future<void> createUser(UserDto userDto) async {
    await _firestore
        .collection(_usersCollection)
        .doc(userDto.id)
        .set(userDto.toMap());
  }

  /// Get user by ID
  Future<UserDto?> getUserById(String userId) async {
    final doc =
        await _firestore.collection(_usersCollection).doc(userId).get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data()!;
    final type = data['type'] as String;

    if (type == 'driver') {
      return DriverDto.fromMap(doc.id, data);
    } else {
      return CompanyDto.fromMap(doc.id, data);
    }
  }

  /// Update user document
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection(_usersCollection).doc(userId).update(updates);
  }

  /// Delete user document
  Future<void> deleteUser(String userId) async {
    await _firestore.collection(_usersCollection).doc(userId).delete();
  }

  /// Update driver availability status
  Future<void> updateDriverAvailability(
      String driverId, AvailabilityStatus status) async {
    await _firestore.collection(_usersCollection).doc(driverId).update({
      'availabilityStatus': _availabilityStatusToString(status),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update driver location
  Future<void> updateDriverLocation(
      String driverId, GeoPoint location) async {
    await _firestore.collection(_usersCollection).doc(driverId).update({
      'currentLocation': location,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update driver active status
  Future<void> updateDriverActiveStatus(String driverId, bool isActive) async {
    await _firestore.collection(_usersCollection).doc(driverId).update({
      'isActive': isActive,
      'lastStatusChange': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream user changes
  Stream<UserDto?> watchUser(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      final type = data['type'] as String;

      if (type == 'driver') {
        return DriverDto.fromMap(doc.id, data);
      } else {
        return CompanyDto.fromMap(doc.id, data);
      }
    });
  }

  /// Get all drivers with specific availability status
  Future<List<DriverDto>> getDriversByAvailability(
      AvailabilityStatus status) async {
    final querySnapshot = await _firestore
        .collection(_usersCollection)
        .where('type', isEqualTo: 'driver')
        .where('availabilityStatus',
            isEqualTo: _availabilityStatusToString(status))
        .get();

    return querySnapshot.docs
        .map((doc) => DriverDto.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Get all active drivers (those accepting orders)
  Future<List<DriverDto>> getActiveDrivers() async {
    final querySnapshot = await _firestore
        .collection(_usersCollection)
        .where('type', isEqualTo: 'driver')
        .where('isActive', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => DriverDto.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Get active drivers with specific availability status
  Future<List<DriverDto>> getActiveDriversByAvailability(
      AvailabilityStatus status) async {
    final querySnapshot = await _firestore
        .collection(_usersCollection)
        .where('type', isEqualTo: 'driver')
        .where('isActive', isEqualTo: true)
        .where('availabilityStatus',
            isEqualTo: _availabilityStatusToString(status))
        .get();

    return querySnapshot.docs
        .map((doc) => DriverDto.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Get all drivers with specific verification status
  Future<List<DriverDto>> getDriversByVerificationStatus(
      VerificationStatus status) async {
    final querySnapshot = await _firestore
        .collection(_usersCollection)
        .where('type', isEqualTo: 'driver')
        .where('verificationStatus',
            isEqualTo: _verificationStatusToString(status))
        .get();

    return querySnapshot.docs
        .map((doc) => DriverDto.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Helper method to convert availability status to string
  String _availabilityStatusToString(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return 'available';
      case AvailabilityStatus.busy:
        return 'busy';
      case AvailabilityStatus.offline:
        return 'offline';
    }
  }

  /// Helper method to convert verification status to string
  String _verificationStatusToString(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.approved:
        return 'approved';
      case VerificationStatus.rejected:
        return 'rejected';
      case VerificationStatus.pending:
        return 'pending';
    }
  }
}
