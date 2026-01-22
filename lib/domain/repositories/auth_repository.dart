import '../entities/user.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Login with username and password
  Future<User> login(String username, String password);

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username);

  /// Register a new driver user
  Future<User> registerDriver(DriverRegistrationData data);

  /// Register a new company user
  Future<User> registerCompany(CompanyRegistrationData data);

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Send phone verification OTP
  Future<void> sendPhoneVerification(String phoneNumber);

  /// Verify OTP code
  Future<bool> verifyOTP(String otp);

  /// Logout current user
  Future<void> logout();

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;
}

/// Driver registration data
class DriverRegistrationData {
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final int age;
  final String phoneNumber;
  final VehicleInfo vehicleInfo;
  final String driverLicenseNumber;
  final String? profilePhotoPath;
  final String? driverLicensePhotoPath;

  DriverRegistrationData({
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.phoneNumber,
    required this.vehicleInfo,
    required this.driverLicenseNumber,
    this.profilePhotoPath,
    this.driverLicensePhotoPath,
  });

  /// Generate internal email from username
  String get internalEmail => '${username.toLowerCase()}@taxidispatch.internal';

  /// Generate full name from first and last name
  String get fullName => '$firstName $lastName';
}

/// Company registration data
class CompanyRegistrationData {
  final String username;
  final String password;
  final String fullName;
  final String phoneNumber;
  final String companyName;
  final String companyRegistrationNumber;
  final String businessAddress;
  final double? headquartersLatitude;
  final double? headquartersLongitude;
  final String? profilePhotoPath;

  CompanyRegistrationData({
    required this.username,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
    required this.companyName,
    required this.companyRegistrationNumber,
    required this.businessAddress,
    this.headquartersLatitude,
    this.headquartersLongitude,
    this.profilePhotoPath,
  });

  /// Generate internal email from username
  String get internalEmail => '${username.toLowerCase()}@taxidispatch.internal';
}
