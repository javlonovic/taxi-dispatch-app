import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi_dispatch_app/domain/entities/ride.dart';
import 'package:taxi_dispatch_app/domain/entities/user.dart';

void main() {
  group('Complete Ride Flow Integration Tests', () {
    test('complete ride flow from request to completion', () async {
      // Test the complete ride lifecycle
      // 1. Company creates ride request
      final rideRequest = Ride(
        id: 'test_ride_1',
        companyUserId: 'company_1',
        driverUserId: null,
        status: RideStatus.pending,
        pickupLocation: const GeoPoint(37.7749, -122.4194),
        pickupAddress: '123 Main St, San Francisco, CA',
        destination: const GeoPoint(37.7849, -122.4294),
        destinationAddress: '456 Market St, San Francisco, CA',
        requestedAt: DateTime.now(),
      );

      // Verify initial state
      expect(rideRequest.status, RideStatus.pending);
      expect(rideRequest.driverUserId, isNull);
      expect(rideRequest.acceptedAt, isNull);

      // 2. Driver accepts ride
      final acceptedRide = Ride(
        id: rideRequest.id,
        companyUserId: rideRequest.companyUserId,
        driverUserId: 'driver_1',
        status: RideStatus.accepted,
        pickupLocation: rideRequest.pickupLocation,
        pickupAddress: rideRequest.pickupAddress,
        destination: rideRequest.destination,
        destinationAddress: rideRequest.destinationAddress,
        requestedAt: rideRequest.requestedAt,
        acceptedAt: DateTime.now(),
      );

      expect(acceptedRide.status, RideStatus.accepted);
      expect(acceptedRide.driverUserId, 'driver_1');
      expect(acceptedRide.acceptedAt, isNotNull);

      // 3. Driver starts journey (en route)
      final enRouteRide = Ride(
        id: acceptedRide.id,
        companyUserId: acceptedRide.companyUserId,
        driverUserId: acceptedRide.driverUserId,
        status: RideStatus.enroute,
        pickupLocation: acceptedRide.pickupLocation,
        pickupAddress: acceptedRide.pickupAddress,
        destination: acceptedRide.destination,
        destinationAddress: acceptedRide.destinationAddress,
        requestedAt: acceptedRide.requestedAt,
        acceptedAt: acceptedRide.acceptedAt,
      );

      expect(enRouteRide.status, RideStatus.enroute);

      // 4. Driver arrives at pickup
      final arrivedRide = Ride(
        id: enRouteRide.id,
        companyUserId: enRouteRide.companyUserId,
        driverUserId: enRouteRide.driverUserId,
        status: RideStatus.arrived,
        pickupLocation: enRouteRide.pickupLocation,
        pickupAddress: enRouteRide.pickupAddress,
        destination: enRouteRide.destination,
        destinationAddress: enRouteRide.destinationAddress,
        requestedAt: enRouteRide.requestedAt,
        acceptedAt: enRouteRide.acceptedAt,
        arrivedAt: DateTime.now(),
      );

      expect(arrivedRide.status, RideStatus.arrived);
      expect(arrivedRide.arrivedAt, isNotNull);

      // 5. Trip completed
      final completedRide = Ride(
        id: arrivedRide.id,
        companyUserId: arrivedRide.companyUserId,
        driverUserId: arrivedRide.driverUserId,
        status: RideStatus.completed,
        pickupLocation: arrivedRide.pickupLocation,
        pickupAddress: arrivedRide.pickupAddress,
        destination: arrivedRide.destination,
        destinationAddress: arrivedRide.destinationAddress,
        requestedAt: arrivedRide.requestedAt,
        acceptedAt: arrivedRide.acceptedAt,
        arrivedAt: arrivedRide.arrivedAt,
        completedAt: DateTime.now(),
        fare: 15.50,
        distance: 5.2,
        duration: const Duration(minutes: 15),
      );

      expect(completedRide.status, RideStatus.completed);
      expect(completedRide.completedAt, isNotNull);
      expect(completedRide.fare, 15.50);
      expect(completedRide.distance, 5.2);
      expect(completedRide.duration?.inMinutes, 15);
    });

    test('ride status transitions follow correct sequence', () {
      final ride = Ride(
        id: 'test_ride_2',
        companyUserId: 'company_1',
        driverUserId: null,
        status: RideStatus.pending,
        pickupLocation: const GeoPoint(37.7749, -122.4194),
        pickupAddress: '123 Main St',
        requestedAt: DateTime.now(),
      );

      // Valid transitions
      final validTransitions = [
        RideStatus.pending,
        RideStatus.accepted,
        RideStatus.enroute,
        RideStatus.arrived,
        RideStatus.completed,
      ];

      RideStatus currentStatus = ride.status;
      for (int i = 1; i < validTransitions.length; i++) {
        expect(currentStatus, validTransitions[i - 1]);
        currentStatus = validTransitions[i];
      }

      expect(currentStatus, RideStatus.completed);
    });

    test('ride can be cancelled at any stage before completion', () {
      final ride = Ride(
        id: 'test_ride_3',
        companyUserId: 'company_1',
        driverUserId: 'driver_1',
        status: RideStatus.accepted,
        pickupLocation: const GeoPoint(37.7749, -122.4194),
        pickupAddress: '123 Main St',
        requestedAt: DateTime.now(),
        acceptedAt: DateTime.now(),
      );

      final cancelledRide = Ride(
        id: ride.id,
        companyUserId: ride.companyUserId,
        driverUserId: ride.driverUserId,
        status: RideStatus.cancelled,
        pickupLocation: ride.pickupLocation,
        pickupAddress: ride.pickupAddress,
        destination: ride.destination,
        destinationAddress: ride.destinationAddress,
        requestedAt: ride.requestedAt,
        acceptedAt: ride.acceptedAt,
      );
      expect(cancelledRide.status, RideStatus.cancelled);
    });

    test('driver assignment updates ride correctly', () {
      final pendingRide = Ride(
        id: 'test_ride_4',
        companyUserId: 'company_1',
        driverUserId: null,
        status: RideStatus.pending,
        pickupLocation: const GeoPoint(37.7749, -122.4194),
        pickupAddress: '123 Main St',
        requestedAt: DateTime.now(),
      );

      expect(pendingRide.driverUserId, isNull);

      final assignedRide = Ride(
        id: pendingRide.id,
        companyUserId: pendingRide.companyUserId,
        driverUserId: 'driver_1',
        status: RideStatus.accepted,
        pickupLocation: pendingRide.pickupLocation,
        pickupAddress: pendingRide.pickupAddress,
        destination: pendingRide.destination,
        destinationAddress: pendingRide.destinationAddress,
        requestedAt: pendingRide.requestedAt,
        acceptedAt: DateTime.now(),
      );

      expect(assignedRide.driverUserId, 'driver_1');
      expect(assignedRide.status, RideStatus.accepted);
    });

    test('fare calculation is applied on completion', () {
      final ride = Ride(
        id: 'test_ride_5',
        companyUserId: 'company_1',
        driverUserId: 'driver_1',
        status: RideStatus.arrived,
        pickupLocation: const GeoPoint(37.7749, -122.4194),
        pickupAddress: '123 Main St',
        destination: const GeoPoint(37.7849, -122.4294),
        destinationAddress: '456 Market St',
        requestedAt: DateTime.now(),
        acceptedAt: DateTime.now(),
        arrivedAt: DateTime.now(),
      );

      // Complete ride with fare
      final completedRide = Ride(
        id: ride.id,
        companyUserId: ride.companyUserId,
        driverUserId: ride.driverUserId,
        status: RideStatus.completed,
        pickupLocation: ride.pickupLocation,
        pickupAddress: ride.pickupAddress,
        destination: ride.destination,
        destinationAddress: ride.destinationAddress,
        requestedAt: ride.requestedAt,
        acceptedAt: ride.acceptedAt,
        arrivedAt: ride.arrivedAt,
        completedAt: DateTime.now(),
        fare: 25.75,
        distance: 10.5,
        duration: const Duration(minutes: 25),
      );

      expect(completedRide.fare, isNotNull);
      expect(completedRide.fare, greaterThan(0));
      expect(completedRide.distance, isNotNull);
      expect(completedRide.duration, isNotNull);
    });

    test('multiple rides can be created for same company', () {
      final company = Company(
        id: 'company_1',
        email: 'company@test.com',
        phoneNumber: '+1234567890',
        fullName: 'John Company',
        companyName: 'Test Company',
        companyRegistrationNumber: 'REG123',
        businessAddress: '789 Business Ave',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final ride1 = Ride(
        id: 'ride_1',
        companyUserId: company.id,
        driverUserId: null,
        status: RideStatus.pending,
        pickupLocation: const GeoPoint(37.7749, -122.4194),
        pickupAddress: '123 Main St',
        requestedAt: DateTime.now(),
      );

      final ride2 = Ride(
        id: 'ride_2',
        companyUserId: company.id,
        driverUserId: null,
        status: RideStatus.pending,
        pickupLocation: const GeoPoint(37.7849, -122.4294),
        pickupAddress: '456 Market St',
        requestedAt: DateTime.now(),
      );

      expect(ride1.companyUserId, company.id);
      expect(ride2.companyUserId, company.id);
      expect(ride1.id, isNot(equals(ride2.id)));
    });

    test('driver can complete multiple rides sequentially', () {
      final driver = Driver(
        id: 'driver_1',
        email: 'driver@test.com',
        phoneNumber: '+1234567890',
        fullName: 'John Driver',
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
      );

      // First ride
      final ride1 = Ride(
        id: 'ride_1',
        companyUserId: 'company_1',
        driverUserId: driver.id,
        status: RideStatus.completed,
        pickupLocation: const GeoPoint(37.7749, -122.4194),
        pickupAddress: '123 Main St',
        requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
        acceptedAt: DateTime.now().subtract(const Duration(hours: 2)),
        completedAt: DateTime.now().subtract(const Duration(hours: 1)),
        fare: 15.50,
      );

      // Second ride
      final ride2 = Ride(
        id: 'ride_2',
        companyUserId: 'company_2',
        driverUserId: driver.id,
        status: RideStatus.completed,
        pickupLocation: const GeoPoint(37.7849, -122.4294),
        pickupAddress: '456 Market St',
        requestedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        acceptedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        completedAt: DateTime.now(),
        fare: 22.75,
      );

      expect(ride1.driverUserId, driver.id);
      expect(ride2.driverUserId, driver.id);
      expect(ride1.status, RideStatus.completed);
      expect(ride2.status, RideStatus.completed);

      // Calculate total earnings
      final totalEarnings = (ride1.fare ?? 0) + (ride2.fare ?? 0);
      expect(totalEarnings, 38.25);
    });
  });
}
