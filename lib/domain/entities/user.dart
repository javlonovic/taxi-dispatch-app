import 'package:cloud_firestore/cloud_firestore.dart';

/// User type enumeration
enum UserType { driver, company, admin }

/// Base user entity
class User {
  final String id;
  final UserType type;
  final String username;
  final String internalEmail;
  final String email; // Kept for backward compatibility, will be deprecated
  final String phoneNumber;
  final String fullName;
  final String? profilePhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.type,
    required this.username,
    required this.internalEmail,
    String? email,
    required this.phoneNumber,
    required this.fullName,
    this.profilePhotoUrl,
    required this.createdAt,
    required this.updatedAt,
  }) : email = email ?? internalEmail;
}

/// Driver availability status
enum AvailabilityStatus { available, busy, offline }

/// Document verification status
enum VerificationStatus { pending, approved, rejected }

/// Vehicle information
class VehicleInfo {
  final String make;
  final String model;
  final String licensePlate;
  final String color;
  final int year;

  VehicleInfo({
    required this.make,
    required this.model,
    required this.licensePlate,
    required this.color,
    required this.year,
  });
}

/// Driver user entity
class Driver extends User {
  final String firstName;
  final String lastName;
  final int age;
  final VehicleInfo vehicleInfo;
  final String driverLicenseNumber;
  final String? driverLicensePhotoUrl;
  final AvailabilityStatus availabilityStatus;
  final GeoPoint? currentLocation;
  final double averageRating;
  final int totalRides;
  final VerificationStatus verificationStatus;
  final String? verificationNotes;
  final bool isActive;

  Driver({
    required super.id,
    required super.username,
    required super.internalEmail,
    super.email,
    required super.phoneNumber,
    required super.fullName,
    super.profilePhotoUrl,
    required super.createdAt,
    required super.updatedAt,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.vehicleInfo,
    required this.driverLicenseNumber,
    this.driverLicensePhotoUrl,
    required this.availabilityStatus,
    this.currentLocation,
    this.averageRating = 0.0,
    this.totalRides = 0,
    this.verificationStatus = VerificationStatus.pending,
    this.verificationNotes,
    this.isActive = false,
  }) : super(type: UserType.driver);
}

/// Company user entity
class Company extends User {
  final String companyName;
  final String companyRegistrationNumber;
  final String businessAddress;
  final GeoPoint? headquartersLocation;
  final double averageRating;
  final int totalRides;
  final bool hasCompletedFirstOrder;
  final double balance;
  final double reservedBalance;

  Company({
    required super.id,
    required super.username,
    required super.internalEmail,
    super.email,
    required super.phoneNumber,
    required super.fullName,
    super.profilePhotoUrl,
    required super.createdAt,
    required super.updatedAt,
    required this.companyName,
    required this.companyRegistrationNumber,
    required this.businessAddress,
    this.headquartersLocation,
    this.averageRating = 0.0,
    this.totalRides = 0,
    this.hasCompletedFirstOrder = false,
    this.balance = 0.0,
    this.reservedBalance = 0.0,
  }) : super(type: UserType.company);
}

/// Admin user entity
class Admin extends User {
  final String adminName;
  final String role;
  final List<String> permissions;

  Admin({
    required super.id,
    required super.username,
    required super.internalEmail,
    super.email,
    required super.phoneNumber,
    required super.fullName,
    super.profilePhotoUrl,
    required super.createdAt,
    required super.updatedAt,
    required this.adminName,
    this.role = 'admin',
    this.permissions = const ['balance_topup', 'view_users', 'view_transactions'],
  }) : super(type: UserType.admin);
  
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }
}
