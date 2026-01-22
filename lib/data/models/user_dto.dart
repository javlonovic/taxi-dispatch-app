import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

/// User DTO for Firestore serialization
class UserDto {
  final String id;
  final String type;
  final String username;
  final String internalEmail;
  final String email; // Kept for backward compatibility
  final String phoneNumber;
  final String fullName;
  final String? profilePhotoUrl;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  UserDto({
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

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'username': username,
      'internalEmail': internalEmail,
      'email': email,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'profilePhotoUrl': profilePhotoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserDto.fromMap(String id, Map<String, dynamic> map) {
    // Handle backward compatibility - if username doesn't exist, extract from email
    String username = map['username'] as String? ?? 
      (map['email'] as String).split('@')[0];
    String internalEmail = map['internalEmail'] as String? ?? 
      map['email'] as String;
    
    return UserDto(
      id: id,
      type: map['type'] as String,
      username: username,
      internalEmail: internalEmail,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String,
      fullName: map['fullName'] as String,
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
    );
  }

  User toEntity() {
    UserType userType;
    switch (type) {
      case 'driver':
        userType = UserType.driver;
        break;
      case 'company':
        userType = UserType.company;
        break;
      case 'admin':
        userType = UserType.admin;
        break;
      default:
        userType = UserType.company;
    }
    
    return User(
      id: id,
      type: userType,
      username: username,
      internalEmail: internalEmail,
      email: email,
      phoneNumber: phoneNumber,
      fullName: fullName,
      profilePhotoUrl: profilePhotoUrl,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
    );
  }
}

/// Driver DTO for Firestore serialization
class DriverDto extends UserDto {
  final String firstName;
  final String lastName;
  final int age;
  final Map<String, dynamic> vehicleInfo;
  final String driverLicenseNumber;
  final String? driverLicensePhotoUrl;
  final String availabilityStatus;
  final GeoPoint? currentLocation;
  final double averageRating;
  final int totalRides;
  final String verificationStatus;
  final String? verificationNotes;
  final bool isActive;

  DriverDto({
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
    required this.averageRating,
    required this.totalRides,
    this.verificationStatus = 'pending',
    this.verificationNotes,
    this.isActive = false,
  }) : super(type: 'driver');

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'vehicleInfo': vehicleInfo,
      'driverLicenseNumber': driverLicenseNumber,
      'driverLicensePhotoUrl': driverLicensePhotoUrl,
      'availabilityStatus': availabilityStatus,
      'currentLocation': currentLocation,
      'averageRating': averageRating,
      'totalRides': totalRides,
      'verificationStatus': verificationStatus,
      'verificationNotes': verificationNotes,
      'isActive': isActive,
    });
    return map;
  }

  factory DriverDto.fromMap(String id, Map<String, dynamic> map) {
    // Handle backward compatibility
    String username = map['username'] as String? ?? 
      (map['email'] as String).split('@')[0];
    String internalEmail = map['internalEmail'] as String? ?? 
      map['email'] as String;
    
    return DriverDto(
      id: id,
      username: username,
      internalEmail: internalEmail,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String,
      fullName: map['fullName'] as String,
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
      firstName: map['firstName'] as String? ?? map['fullName'] as String,
      lastName: map['lastName'] as String? ?? '',
      age: map['age'] as int? ?? 18,
      vehicleInfo: map['vehicleInfo'] as Map<String, dynamic>,
      driverLicenseNumber: map['driverLicenseNumber'] as String,
      driverLicensePhotoUrl: map['driverLicensePhotoUrl'] as String?,
      availabilityStatus: map['availabilityStatus'] as String,
      currentLocation: map['currentLocation'] as GeoPoint?,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRides: map['totalRides'] as int? ?? 0,
      verificationStatus: map['verificationStatus'] as String? ?? 'pending',
      verificationNotes: map['verificationNotes'] as String?,
      isActive: map['isActive'] as bool? ?? false,
    );
  }

  factory DriverDto.fromEntity(Driver driver) {
    return DriverDto(
      id: driver.id,
      username: driver.username,
      internalEmail: driver.internalEmail,
      email: driver.email,
      phoneNumber: driver.phoneNumber,
      fullName: driver.fullName,
      profilePhotoUrl: driver.profilePhotoUrl,
      createdAt: Timestamp.fromDate(driver.createdAt),
      updatedAt: Timestamp.fromDate(driver.updatedAt),
      firstName: driver.firstName,
      lastName: driver.lastName,
      age: driver.age,
      vehicleInfo: {
        'make': driver.vehicleInfo.make,
        'model': driver.vehicleInfo.model,
        'licensePlate': driver.vehicleInfo.licensePlate,
        'color': driver.vehicleInfo.color,
        'year': driver.vehicleInfo.year,
      },
      driverLicenseNumber: driver.driverLicenseNumber,
      driverLicensePhotoUrl: driver.driverLicensePhotoUrl,
      availabilityStatus: _availabilityStatusToString(driver.availabilityStatus),
      currentLocation: driver.currentLocation,
      averageRating: driver.averageRating,
      totalRides: driver.totalRides,
      verificationStatus: _verificationStatusToString(driver.verificationStatus),
      verificationNotes: driver.verificationNotes,
      isActive: driver.isActive,
    );
  }

  @override
  Driver toEntity() {
    return Driver(
      id: id,
      username: username,
      internalEmail: internalEmail,
      email: email,
      phoneNumber: phoneNumber,
      fullName: fullName,
      profilePhotoUrl: profilePhotoUrl,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
      firstName: firstName,
      lastName: lastName,
      age: age,
      vehicleInfo: VehicleInfo(
        make: vehicleInfo['make'] as String,
        model: vehicleInfo['model'] as String,
        licensePlate: vehicleInfo['licensePlate'] as String,
        color: vehicleInfo['color'] as String,
        year: vehicleInfo['year'] as int,
      ),
      driverLicenseNumber: driverLicenseNumber,
      driverLicensePhotoUrl: driverLicensePhotoUrl,
      availabilityStatus: _parseAvailabilityStatus(availabilityStatus),
      currentLocation: currentLocation,
      averageRating: averageRating,
      totalRides: totalRides,
      verificationStatus: _parseVerificationStatus(verificationStatus),
      verificationNotes: verificationNotes,
      isActive: isActive,
    );
  }

  static AvailabilityStatus _parseAvailabilityStatus(String status) {
    switch (status) {
      case 'available':
        return AvailabilityStatus.available;
      case 'busy':
        return AvailabilityStatus.busy;
      case 'offline':
        return AvailabilityStatus.offline;
      default:
        return AvailabilityStatus.offline;
    }
  }

  static String _availabilityStatusToString(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return 'available';
      case AvailabilityStatus.busy:
        return 'busy';
      case AvailabilityStatus.offline:
        return 'offline';
    }
  }

  static VerificationStatus _parseVerificationStatus(String status) {
    switch (status) {
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'pending':
      default:
        return VerificationStatus.pending;
    }
  }

  static String _verificationStatusToString(VerificationStatus status) {
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

/// Company DTO for Firestore serialization
class CompanyDto extends UserDto {
  final String companyName;
  final String companyRegistrationNumber;
  final String businessAddress;
  final GeoPoint? headquartersLocation;
  final double averageRating;
  final int totalRides;
  final bool hasCompletedFirstOrder;
  final double balance;
  final double reservedBalance;

  CompanyDto({
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
  }) : super(type: 'company');

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'companyName': companyName,
      'companyRegistrationNumber': companyRegistrationNumber,
      'businessAddress': businessAddress,
      'headquartersLocation': headquartersLocation,
      'averageRating': averageRating,
      'totalRides': totalRides,
      'hasCompletedFirstOrder': hasCompletedFirstOrder,
      'balance': balance,
      'reservedBalance': reservedBalance,
    });
    return map;
  }

  factory CompanyDto.fromMap(String id, Map<String, dynamic> map) {
    // Handle backward compatibility
    String username = map['username'] as String? ?? 
      (map['email'] as String).split('@')[0];
    String internalEmail = map['internalEmail'] as String? ?? 
      map['email'] as String;
    
    return CompanyDto(
      id: id,
      username: username,
      internalEmail: internalEmail,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String,
      fullName: map['fullName'] as String,
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
      companyName: map['companyName'] as String,
      companyRegistrationNumber: map['companyRegistrationNumber'] as String,
      businessAddress: map['businessAddress'] as String,
      headquartersLocation: map['headquartersLocation'] as GeoPoint?,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRides: (map['totalRides'] as num?)?.toInt() ?? 0,
      hasCompletedFirstOrder: map['hasCompletedFirstOrder'] as bool? ?? false,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      reservedBalance: (map['reservedBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory CompanyDto.fromEntity(Company company) {
    return CompanyDto(
      id: company.id,
      username: company.username,
      internalEmail: company.internalEmail,
      email: company.email,
      phoneNumber: company.phoneNumber,
      fullName: company.fullName,
      profilePhotoUrl: company.profilePhotoUrl,
      createdAt: Timestamp.fromDate(company.createdAt),
      updatedAt: Timestamp.fromDate(company.updatedAt),
      companyName: company.companyName,
      companyRegistrationNumber: company.companyRegistrationNumber,
      businessAddress: company.businessAddress,
      headquartersLocation: company.headquartersLocation,
      averageRating: company.averageRating,
      totalRides: company.totalRides,
      hasCompletedFirstOrder: company.hasCompletedFirstOrder,
      balance: company.balance,
      reservedBalance: company.reservedBalance,
    );
  }

  @override
  Company toEntity() {
    return Company(
      id: id,
      username: username,
      internalEmail: internalEmail,
      email: email,
      phoneNumber: phoneNumber,
      fullName: fullName,
      profilePhotoUrl: profilePhotoUrl,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
      companyName: companyName,
      companyRegistrationNumber: companyRegistrationNumber,
      businessAddress: businessAddress,
      headquartersLocation: headquartersLocation,
      averageRating: averageRating,
      totalRides: totalRides,
      hasCompletedFirstOrder: hasCompletedFirstOrder,
      balance: balance,
      reservedBalance: reservedBalance,
    );
  }
}

/// Admin DTO for Firestore serialization
class AdminDto extends UserDto {
  final String adminName;
  final String role;
  final List<String> permissions;

  AdminDto({
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
  }) : super(type: 'admin');

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'adminName': adminName,
      'role': role,
      'permissions': permissions,
    });
    return map;
  }

  factory AdminDto.fromMap(String id, Map<String, dynamic> map) {
    String username = map['username'] as String? ?? 
      (map['email'] as String).split('@')[0];
    String internalEmail = map['internalEmail'] as String? ?? 
      map['email'] as String;
    
    return AdminDto(
      id: id,
      username: username,
      internalEmail: internalEmail,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String,
      fullName: map['fullName'] as String,
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp,
      adminName: map['adminName'] as String,
      role: map['role'] as String? ?? 'admin',
      permissions: (map['permissions'] as List<dynamic>?)?.cast<String>() ?? 
        ['balance_topup', 'view_users', 'view_transactions'],
    );
  }

  factory AdminDto.fromEntity(Admin admin) {
    return AdminDto(
      id: admin.id,
      username: admin.username,
      internalEmail: admin.internalEmail,
      email: admin.email,
      phoneNumber: admin.phoneNumber,
      fullName: admin.fullName,
      profilePhotoUrl: admin.profilePhotoUrl,
      createdAt: Timestamp.fromDate(admin.createdAt),
      updatedAt: Timestamp.fromDate(admin.updatedAt),
      adminName: admin.adminName,
      role: admin.role,
      permissions: admin.permissions,
    );
  }

  @override
  Admin toEntity() {
    return Admin(
      id: id,
      username: username,
      internalEmail: internalEmail,
      email: email,
      phoneNumber: phoneNumber,
      fullName: fullName,
      profilePhotoUrl: profilePhotoUrl,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
      adminName: adminName,
      role: role,
      permissions: permissions,
    );
  }
}
