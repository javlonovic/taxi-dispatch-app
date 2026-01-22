import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/exceptions/app_exception.dart';
import '../datasources/firestore_user_datasource.dart';
import '../datasources/firebase_storage_service.dart';
import '../models/user_dto.dart';

/// User repository implementation
class UserRepositoryImpl implements UserRepository {
  final FirestoreUserDataSource _userDataSource;
  final FirebaseStorageService _storageService;

  UserRepositoryImpl({
    required FirestoreUserDataSource userDataSource,
    required FirebaseStorageService storageService,
  })  : _userDataSource = userDataSource,
        _storageService = storageService;

  @override
  Future<User?> getUserById(String userId) async {
    try {
      final userDto = await _userDataSource.getUserById(userId);
      if (userDto == null) {
        return null;
      }

      if (userDto is DriverDto) {
        return userDto.toEntity();
      } else if (userDto is CompanyDto) {
        return userDto.toEntity();
      } else {
        return userDto.toEntity();
      }
    } catch (e) {
      throw GeneralException('Failed to get user: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    try {
      await _userDataSource.updateUser(userId, updates);
    } catch (e) {
      throw GeneralException('Failed to update user profile: ${e.toString()}');
    }
  }

  @override
  Future<void> updateDriverAvailability(
      String driverId, AvailabilityStatus status) async {
    try {
      await _userDataSource.updateDriverAvailability(driverId, status);
    } catch (e) {
      throw GeneralException(
          'Failed to update driver availability: ${e.toString()}');
    }
  }

  @override
  Future<void> updateDriverLocation(String driverId, GeoPoint location) async {
    try {
      await _userDataSource.updateDriverLocation(driverId, location);
    } catch (e) {
      throw GeneralException('Failed to update driver location: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfilePhoto(String userId, String filePath) async {
    try {
      final downloadUrl =
          await _storageService.uploadProfilePhoto(userId, filePath);
      
      // Update user document with new photo URL
      await _userDataSource.updateUser(userId, {
        'profilePhotoUrl': downloadUrl,
      });
      
      return downloadUrl;
    } catch (e) {
      throw GeneralException('Failed to upload profile photo: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadDriverLicensePhoto(
      String userId, String filePath) async {
    try {
      final downloadUrl =
          await _storageService.uploadDriverLicensePhoto(userId, filePath);
      
      // Update driver document with new license photo URL
      await _userDataSource.updateUser(userId, {
        'driverLicensePhotoUrl': downloadUrl,
      });
      
      return downloadUrl;
    } catch (e) {
      throw GeneralException(
          'Failed to upload driver license photo: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      // Get user to delete their photos
      final user = await getUserById(userId);
      if (user != null) {
        if (user.profilePhotoUrl != null) {
          await _storageService.deleteFile(user.profilePhotoUrl!);
        }
        
        if (user is Driver && user.driverLicensePhotoUrl != null) {
          await _storageService.deleteFile(user.driverLicensePhotoUrl!);
        }
      }
      
      await _userDataSource.deleteUser(userId);
    } catch (e) {
      throw GeneralException('Failed to delete user: ${e.toString()}');
    }
  }

  @override
  Stream<User?> watchUser(String userId) {
    try {
      return _userDataSource.watchUser(userId).map((userDto) {
        if (userDto == null) {
          return null;
        }

        if (userDto is DriverDto) {
          return userDto.toEntity();
        } else if (userDto is CompanyDto) {
          return userDto.toEntity();
        } else {
          return userDto.toEntity();
        }
      });
    } catch (e) {
      throw GeneralException('Failed to watch user: ${e.toString()}');
    }
  }

  @override
  Future<List<Driver>> getDriversByAvailability(
      AvailabilityStatus status) async {
    try {
      final driverDtos =
          await _userDataSource.getDriversByAvailability(status);
      return driverDtos.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      throw GeneralException('Failed to get drivers: ${e.toString()}');
    }
  }

  @override
  Future<List<Driver>> getActiveDrivers() async {
    try {
      final driverDtos = await _userDataSource.getActiveDrivers();
      return driverDtos.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      throw GeneralException('Failed to get active drivers: ${e.toString()}');
    }
  }

  @override
  Future<List<Driver>> getActiveDriversByAvailability(
      AvailabilityStatus status) async {
    try {
      final driverDtos =
          await _userDataSource.getActiveDriversByAvailability(status);
      return driverDtos.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      throw GeneralException(
          'Failed to get active drivers by availability: ${e.toString()}');
    }
  }

  @override
  Future<void> updateDriverVerificationStatus(
    String driverId,
    VerificationStatus status,
    String? notes,
  ) async {
    try {
      await _userDataSource.updateUser(driverId, {
        'verificationStatus': _verificationStatusToString(status),
        'verificationNotes': notes,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw GeneralException(
          'Failed to update driver verification status: ${e.toString()}');
    }
  }

  @override
  Future<List<Driver>> getPendingDriverVerifications() async {
    try {
      final driverDtos = await _userDataSource.getDriversByVerificationStatus(
          VerificationStatus.pending);
      return driverDtos.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      throw GeneralException(
          'Failed to get pending driver verifications: ${e.toString()}');
    }
  }

  @override
  Future<void> markFirstOrderCompleted(String companyId) async {
    try {
      await _userDataSource.updateUser(companyId, {
        'hasCompletedFirstOrder': true,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw GeneralException(
          'Failed to mark first order as completed: ${e.toString()}');
    }
  }

  @override
  Future<void> updateDriverActiveStatus(String driverId, bool isActive) async {
    try {
      await _userDataSource.updateDriverActiveStatus(driverId, isActive);
    } catch (e) {
      throw GeneralException(
          'Failed to update driver active status: ${e.toString()}');
    }
  }

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
