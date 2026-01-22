import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi_dispatch_app/data/models/user_dto.dart';
import 'package:taxi_dispatch_app/domain/entities/user.dart';

void main() {
  group('DriverDto', () {
    test('toMap converts DriverDto to Map correctly', () {
      final timestamp = Timestamp.now();
      final driverDto = DriverDto(
        id: 'driver123',
        email: 'driver@test.com',
        phoneNumber: '+1234567890',
        fullName: 'John Driver',
        profilePhotoUrl: 'https://example.com/photo.jpg',
        createdAt: timestamp,
        updatedAt: timestamp,
        vehicleInfo: {
          'make': 'Toyota',
          'model': 'Camry',
          'licensePlate': 'ABC123',
          'color': 'Blue',
          'year': 2020,
        },
        driverLicenseNumber: 'DL123456',
        driverLicensePhotoUrl: 'https://example.com/license.jpg',
        availabilityStatus: 'available',
        currentLocation: const GeoPoint(37.7749, -122.4194),
        averageRating: 4.5,
        totalRides: 100,
      );

      final map = driverDto.toMap();

      expect(map['type'], 'driver');
      expect(map['email'], 'driver@test.com');
      expect(map['phoneNumber'], '+1234567890');
      expect(map['fullName'], 'John Driver');
      expect(map['vehicleInfo']['make'], 'Toyota');
      expect(map['availabilityStatus'], 'available');
      expect(map['averageRating'], 4.5);
      expect(map['totalRides'], 100);
    });

    test('fromMap creates DriverDto from Map correctly', () {
      final timestamp = Timestamp.now();
      final map = {
        'type': 'driver',
        'email': 'driver@test.com',
        'phoneNumber': '+1234567890',
        'fullName': 'John Driver',
        'profilePhotoUrl': 'https://example.com/photo.jpg',
        'createdAt': timestamp,
        'updatedAt': timestamp,
        'vehicleInfo': {
          'make': 'Toyota',
          'model': 'Camry',
          'licensePlate': 'ABC123',
          'color': 'Blue',
          'year': 2020,
        },
        'driverLicenseNumber': 'DL123456',
        'driverLicensePhotoUrl': 'https://example.com/license.jpg',
        'availabilityStatus': 'available',
        'currentLocation': const GeoPoint(37.7749, -122.4194),
        'averageRating': 4.5,
        'totalRides': 100,
      };

      final driverDto = DriverDto.fromMap('driver123', map);

      expect(driverDto.id, 'driver123');
      expect(driverDto.email, 'driver@test.com');
      expect(driverDto.vehicleInfo['make'], 'Toyota');
      expect(driverDto.availabilityStatus, 'available');
      expect(driverDto.averageRating, 4.5);
    });

    test('toEntity converts DriverDto to Driver entity correctly', () {
      final timestamp = Timestamp.now();
      final driverDto = DriverDto(
        id: 'driver123',
        email: 'driver@test.com',
        phoneNumber: '+1234567890',
        fullName: 'John Driver',
        createdAt: timestamp,
        updatedAt: timestamp,
        vehicleInfo: {
          'make': 'Toyota',
          'model': 'Camry',
          'licensePlate': 'ABC123',
          'color': 'Blue',
          'year': 2020,
        },
        driverLicenseNumber: 'DL123456',
        availabilityStatus: 'available',
        averageRating: 4.5,
        totalRides: 100,
      );

      final driver = driverDto.toEntity();

      expect(driver.id, 'driver123');
      expect(driver.email, 'driver@test.com');
      expect(driver.type, UserType.driver);
      expect(driver.vehicleInfo.make, 'Toyota');
      expect(driver.availabilityStatus, AvailabilityStatus.available);
      expect(driver.averageRating, 4.5);
    });
  });

  group('CompanyDto', () {
    test('toMap converts CompanyDto to Map correctly', () {
      final timestamp = Timestamp.now();
      final companyDto = CompanyDto(
        id: 'company123',
        email: 'company@test.com',
        phoneNumber: '+1234567890',
        fullName: 'John Company',
        createdAt: timestamp,
        updatedAt: timestamp,
        companyName: 'Test Company',
        companyRegistrationNumber: 'REG123',
        businessAddress: '123 Main St',
        averageRating: 4.8,
        totalRides: 50,
      );

      final map = companyDto.toMap();

      expect(map['type'], 'company');
      expect(map['email'], 'company@test.com');
      expect(map['companyName'], 'Test Company');
      expect(map['companyRegistrationNumber'], 'REG123');
      expect(map['averageRating'], 4.8);
    });

    test('toEntity converts CompanyDto to Company entity correctly', () {
      final timestamp = Timestamp.now();
      final companyDto = CompanyDto(
        id: 'company123',
        email: 'company@test.com',
        phoneNumber: '+1234567890',
        fullName: 'John Company',
        createdAt: timestamp,
        updatedAt: timestamp,
        companyName: 'Test Company',
        companyRegistrationNumber: 'REG123',
        businessAddress: '123 Main St',
      );

      final company = companyDto.toEntity();

      expect(company.id, 'company123');
      expect(company.type, UserType.company);
      expect(company.companyName, 'Test Company');
      expect(company.companyRegistrationNumber, 'REG123');
    });
  });
}
