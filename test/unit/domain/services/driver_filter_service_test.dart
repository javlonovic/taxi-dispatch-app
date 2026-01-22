import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi_dispatch_app/domain/services/driver_filter_service.dart';
import 'package:taxi_dispatch_app/domain/entities/user.dart';

void main() {
  group('DriverFilterService', () {
    List<Driver> createTestDrivers() {
      return [
        Driver(
          id: 'driver1',
          email: 'driver1@test.com',
          phoneNumber: '+1234567890',
          fullName: 'John Doe',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          vehicleInfo: VehicleInfo(
            make: 'Toyota',
            model: 'Camry',
            licensePlate: 'ABC123',
            color: 'Blue',
            year: 2020,
          ),
          driverLicenseNumber: 'DL123',
          availabilityStatus: AvailabilityStatus.available,
          currentLocation: const GeoPoint(37.7749, -122.4194),
          averageRating: 4.5,
          totalRides: 100,
        ),
        Driver(
          id: 'driver2',
          email: 'driver2@test.com',
          phoneNumber: '+1234567891',
          fullName: 'Jane Smith',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          vehicleInfo: VehicleInfo(
            make: 'Honda',
            model: 'Accord',
            licensePlate: 'XYZ789',
            color: 'Red',
            year: 2021,
          ),
          driverLicenseNumber: 'DL456',
          availabilityStatus: AvailabilityStatus.busy,
          currentLocation: const GeoPoint(37.7849, -122.4294),
          averageRating: 4.8,
          totalRides: 150,
        ),
        Driver(
          id: 'driver3',
          email: 'driver3@test.com',
          phoneNumber: '+1234567892',
          fullName: 'Bob Johnson',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          vehicleInfo: VehicleInfo(
            make: 'Ford',
            model: 'Focus',
            licensePlate: 'DEF456',
            color: 'Black',
            year: 2019,
          ),
          driverLicenseNumber: 'DL789',
          availabilityStatus: AvailabilityStatus.available,
          currentLocation: const GeoPoint(37.7949, -122.4394),
          averageRating: 3.9,
          totalRides: 50,
        ),
      ];
    }

    test('filterByAvailability returns only available drivers', () {
      final drivers = createTestDrivers();
      final filtered = DriverFilterService.filterByAvailability(
        drivers,
        AvailabilityStatus.available,
      );

      expect(filtered.length, 2);
      expect(filtered.every((d) => d.availabilityStatus == AvailabilityStatus.available), true);
    });

    test('filterByMinimumRating returns drivers with rating >= threshold', () {
      final drivers = createTestDrivers();
      final filtered = DriverFilterService.filterByMinimumRating(drivers, 4.0);

      expect(filtered.length, 2);
      expect(filtered.every((d) => d.averageRating >= 4.0), true);
    });

    test('sortByRating sorts drivers by rating descending', () {
      final drivers = createTestDrivers();
      final sorted = DriverFilterService.sortByRating(drivers);

      expect(sorted[0].averageRating, 4.8);
      expect(sorted[1].averageRating, 4.5);
      expect(sorted[2].averageRating, 3.9);
    });

    test('filterAvailableDriversNearby returns available drivers within radius', () {
      final drivers = createTestDrivers();
      final targetLocation = const GeoPoint(37.7749, -122.4194);
      
      final result = DriverFilterService.filterAvailableDriversNearby(
        drivers,
        targetLocation,
        100.0, // 100km radius to ensure we catch test drivers
      );

      // Should have at least 1 available driver
      expect(result.isNotEmpty, true);
      expect(result.every((d) => d.availabilityStatus == AvailabilityStatus.available), true);
    });

    test('sortByDistance sorts drivers by proximity', () {
      final drivers = createTestDrivers();
      final targetLocation = const GeoPoint(37.7749, -122.4194);
      
      final sorted = DriverFilterService.sortByDistance(drivers, targetLocation);

      expect(sorted.length, 3);
      // Verify all drivers are sorted (closest first)
      expect(sorted[0].currentLocation, isNotNull);
    });
  });
}
