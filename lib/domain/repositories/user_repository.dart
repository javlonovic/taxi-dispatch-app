import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/user.dart';

/// User repository interface
abstract class UserRepository {
  /// Get user by ID
  Future<User?> getUserById(String userId);

  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates);

  /// Update driver availability status
  Future<void> updateDriverAvailability(
      String driverId, AvailabilityStatus status);

  /// Update driver location
  Future<void> updateDriverLocation(String driverId, GeoPoint location);

  /// Upload profile photo
  Future<String> uploadProfilePhoto(String userId, String filePath);

  /// Upload driver license photo
  Future<String> uploadDriverLicensePhoto(String userId, String filePath);

  /// Delete user
  Future<void> deleteUser(String userId);

  /// Watch user changes
  Stream<User?> watchUser(String userId);

  /// Get drivers by availability status
  Future<List<Driver>> getDriversByAvailability(AvailabilityStatus status);

  /// Get all active drivers (those accepting orders)
  Future<List<Driver>> getActiveDrivers();

  /// Get active drivers with specific availability status
  Future<List<Driver>> getActiveDriversByAvailability(AvailabilityStatus status);

  /// Update driver verification status (admin only)
  Future<void> updateDriverVerificationStatus(
    String driverId,
    VerificationStatus status,
    String? notes,
  );

  /// Get all pending driver verifications (admin only)
  Future<List<Driver>> getPendingDriverVerifications();

  /// Mark company's first order as completed
  Future<void> markFirstOrderCompleted(String companyId);

  /// Update driver active status
  Future<void> updateDriverActiveStatus(String driverId, bool isActive);
}

/// Driver profile update data
class DriverProfileUpdateData {
  final String? fullName;
  final String? phoneNumber;
  final VehicleInfo? vehicleInfo;
  final String? driverLicenseNumber;
  final String? profilePhotoPath;
  final String? driverLicensePhotoPath;

  DriverProfileUpdateData({
    this.fullName,
    this.phoneNumber,
    this.vehicleInfo,
    this.driverLicenseNumber,
    this.profilePhotoPath,
    this.driverLicensePhotoPath,
  });
}

/// Company profile update data
class CompanyProfileUpdateData {
  final String? fullName;
  final String? phoneNumber;
  final String? companyName;
  final String? companyRegistrationNumber;
  final String? businessAddress;
  final String? profilePhotoPath;

  CompanyProfileUpdateData({
    this.fullName,
    this.phoneNumber,
    this.companyName,
    this.companyRegistrationNumber,
    this.businessAddress,
    this.profilePhotoPath,
  });
}
