import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../models/user_dto.dart';
import '../../core/exceptions/app_exception.dart';

/// Concrete implementation of AuthRepository using Firebase
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _authDataSource;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  
  String? _verificationId;

  AuthRepositoryImpl({
    required FirebaseAuthDataSource authDataSource,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _authDataSource = authDataSource,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<User> login(String username, String password) async {
    try {
      // Convert username to internal email
      final internalEmail = '${username.toLowerCase()}@taxidispatch.internal';
      
      final firebaseUser = await _authDataSource.login(internalEmail, password);
      
      // Fetch user data from Firestore with retry logic
      final userDoc = await _fetchUserDocWithRetry(firebaseUser.uid);
      
      if (!userDoc.exists) {
        throw AuthException('User data not found. Please complete registration.');
      }
      
      final userData = userDoc.data()!;
      final userType = userData['type'] as String;
      
      if (userType == 'driver') {
        final driverDto = DriverDto.fromMap(firebaseUser.uid, userData);
        return driverDto.toEntity();
      } else {
        final companyDto = CompanyDto.fromMap(firebaseUser.uid, userData);
        return companyDto.toEntity();
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final normalizedUsername = username.toLowerCase();
      
      // Query Firestore to check if username exists
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: normalizedUsername)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw AuthException('Username validation failed: ${e.toString()}');
    }
  }

  /// Fetch user document with retry logic for transient Firestore errors
  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserDocWithRetry(
    String uid, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int retryCount = 0;
    Duration delay = initialDelay;
    
    while (true) {
      try {
        return await _firestore.collection('users').doc(uid).get();
      } catch (e) {
        retryCount++;
        
        // Check if it's a transient error and we haven't exceeded max retries
        final isTransientError = e.toString().contains('unavailable') ||
            e.toString().contains('UNAVAILABLE') ||
            e.toString().contains('deadline-exceeded');
        
        if (isTransientError && retryCount < maxRetries) {
          // Wait before retrying with exponential backoff
          await Future.delayed(delay);
          delay *= 2; // Exponential backoff
          continue;
        }
        
        // If not transient or max retries exceeded, rethrow
        rethrow;
      }
    }
  }

  @override
  Future<User> registerDriver(DriverRegistrationData data) async {
    try {
      // Check username availability
      final isAvailable = await isUsernameAvailable(data.username);
      if (!isAvailable) {
        throw AuthException('Username already taken');
      }
      
      // Create Firebase auth user with internal email
      final firebaseUser = await _authDataSource.register(
        data.internalEmail,
        data.password,
      );
      
      // Upload photos if provided
      String? profilePhotoUrl;
      String? licensePhotoUrl;
      
      if (data.profilePhotoPath != null) {
        profilePhotoUrl = await _uploadFile(
          firebaseUser.uid,
          data.profilePhotoPath!,
          'profile_photos',
        );
      }
      
      if (data.driverLicensePhotoPath != null) {
        licensePhotoUrl = await _uploadFile(
          firebaseUser.uid,
          data.driverLicensePhotoPath!,
          'license_photos',
        );
      }
      
      // Create driver document in Firestore
      final now = Timestamp.now();
      final driverDto = DriverDto(
        id: firebaseUser.uid,
        username: data.username.toLowerCase(),
        internalEmail: data.internalEmail,
        phoneNumber: data.phoneNumber,
        fullName: data.fullName,
        profilePhotoUrl: profilePhotoUrl,
        createdAt: now,
        updatedAt: now,
        firstName: data.firstName,
        lastName: data.lastName,
        age: data.age,
        vehicleInfo: {
          'make': data.vehicleInfo.make,
          'model': data.vehicleInfo.model,
          'licensePlate': data.vehicleInfo.licensePlate,
          'color': data.vehicleInfo.color,
          'year': data.vehicleInfo.year,
        },
        driverLicenseNumber: data.driverLicenseNumber,
        driverLicensePhotoUrl: licensePhotoUrl,
        availabilityStatus: 'offline',
        currentLocation: null,
        averageRating: 0.0,
        totalRides: 0,
        isActive: false,
      );
      
      await _firestore.collection('users').doc(firebaseUser.uid).set(driverDto.toMap());
      
      return driverDto.toEntity();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Driver registration failed: ${e.toString()}');
    }
  }

  @override
  Future<User> registerCompany(CompanyRegistrationData data) async {
    try {
      // Check username availability
      final isAvailable = await isUsernameAvailable(data.username);
      if (!isAvailable) {
        throw AuthException('Username already taken');
      }
      
      // Create Firebase auth user with internal email
      final firebaseUser = await _authDataSource.register(
        data.internalEmail,
        data.password,
      );
      
      // Upload profile photo if provided
      String? profilePhotoUrl;
      if (data.profilePhotoPath != null) {
        profilePhotoUrl = await _uploadFile(
          firebaseUser.uid,
          data.profilePhotoPath!,
          'profile_photos',
        );
      }
      
      // Create headquarters location if provided
      GeoPoint? headquartersLocation;
      if (data.headquartersLatitude != null && data.headquartersLongitude != null) {
        headquartersLocation = GeoPoint(
          data.headquartersLatitude!,
          data.headquartersLongitude!,
        );
      }
      
      // Create company document in Firestore
      final now = Timestamp.now();
      final companyDto = CompanyDto(
        id: firebaseUser.uid,
        username: data.username.toLowerCase(),
        internalEmail: data.internalEmail,
        phoneNumber: data.phoneNumber,
        fullName: data.fullName,
        profilePhotoUrl: profilePhotoUrl,
        createdAt: now,
        updatedAt: now,
        companyName: data.companyName,
        companyRegistrationNumber: data.companyRegistrationNumber,
        businessAddress: data.businessAddress,
        headquartersLocation: headquartersLocation,
      );
      
      await _firestore.collection('users').doc(firebaseUser.uid).set(companyDto.toMap());
      
      return companyDto.toEntity();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Company registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    await _authDataSource.sendEmailVerification();
  }

  @override
  Future<void> sendPhoneVerification(String phoneNumber) async {
    final completer = Completer<void>();
    
    await _authDataSource.sendPhoneVerification(
      phoneNumber,
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        completer.complete();
      },
      verificationFailed: (error) {
        completer.completeError(AuthException(error.message ?? 'Phone verification failed', error.code));
      },
      verificationCompleted: (credential) {
        // Auto-verification completed
        completer.complete();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
    
    return completer.future;
  }

  @override
  Future<bool> verifyOTP(String otp) async {
    if (_verificationId == null) {
      throw AuthException('No verification in progress');
    }
    
    return await _authDataSource.verifyOTP(_verificationId!, otp);
  }

  @override
  Future<void> logout() async {
    await _authDataSource.logout();
  }

  @override
  Stream<User?> get authStateChanges {
    return _authDataSource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      try {
        final userDoc = await _fetchUserDocWithRetry(firebaseUser.uid);
        
        if (!userDoc.exists) return null;
        
        final userData = userDoc.data()!;
        final userType = userData['type'] as String;
        
        if (userType == 'driver') {
          final driverDto = DriverDto.fromMap(firebaseUser.uid, userData);
          return driverDto.toEntity();
        } else {
          final companyDto = CompanyDto.fromMap(firebaseUser.uid, userData);
          return companyDto.toEntity();
        }
      } catch (e) {
        return null;
      }
    });
  }

  /// Upload file to Firebase Storage
  Future<String> _uploadFile(String userId, String filePath, String folder) async {
    try {
      final file = File(filePath);
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
      final ref = _storage.ref().child('$folder/$fileName');
      
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw AuthException('File upload failed: ${e.toString()}');
    }
  }
}
