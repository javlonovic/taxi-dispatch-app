import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taxi_dispatch_app/data/models/ride_dto.dart';
import 'package:taxi_dispatch_app/domain/entities/ride.dart';

void main() {
  group('RideDto', () {
    test('toMap converts RideDto to Map correctly', () {
      final timestamp = Timestamp.now();
      final rideDto = RideDto(
        id: 'ride123',
        companyUserId: 'company123',
        driverUserId: 'driver123',
        status: 'accepted',
        pickupLocation: const GeoPoint(37.7749, -122.4194),
        pickupAddress: '123 Main St',
        destination: const GeoPoint(37.7849, -122.4294),
        destinationAddress: '456 Oak Ave',
        requestedAt: timestamp,
        acceptedAt: timestamp,
        fare: 25.50,
        distance: 5.2,
        durationSeconds: 900,
      );

      final map = rideDto.toMap();

      expect(map['companyUserId'], 'company123');
      expect(map['driverUserId'], 'driver123');
      expect(map['status'], 'accepted');
      expect(map['pickupAddress'], '123 Main St');
      expect(map['fare'], 25.50);
      expect(map['distance'], 5.2);
      expect(map['durationSeconds'], 900);
    });

    test('fromMap creates RideDto from Map correctly', () {
      final timestamp = Timestamp.now();
      final map = {
        'companyUserId': 'company123',
        'driverUserId': 'driver123',
        'status': 'completed',
        'pickupLocation': const GeoPoint(37.7749, -122.4194),
        'pickupAddress': '123 Main St',
        'destination': const GeoPoint(37.7849, -122.4294),
        'destinationAddress': '456 Oak Ave',
        'requestedAt': timestamp,
        'acceptedAt': timestamp,
        'completedAt': timestamp,
        'fare': 30.0,
        'distance': 6.5,
        'durationSeconds': 1200,
      };

      final rideDto = RideDto.fromMap('ride123', map);

      expect(rideDto.id, 'ride123');
      expect(rideDto.companyUserId, 'company123');
      expect(rideDto.status, 'completed');
      expect(rideDto.fare, 30.0);
      expect(rideDto.distance, 6.5);
    });

    test('toEntity converts RideDto to Ride entity correctly', () {
      final timestamp = Timestamp.now();
      final rideDto = RideDto(
        id: 'ride123',
        companyUserId: 'company123',
        driverUserId: 'driver123',
        status: 'accepted',
        pickupLocation: const GeoPoint(37.7749, -122.4194),
        pickupAddress: '123 Main St',
        requestedAt: timestamp,
        fare: 25.50,
        durationSeconds: 900,
      );

      final ride = rideDto.toEntity();

      expect(ride.id, 'ride123');
      expect(ride.companyUserId, 'company123');
      expect(ride.status, RideStatus.accepted);
      expect(ride.fare, 25.50);
      expect(ride.duration?.inSeconds, 900);
    });

    test('parses all ride statuses correctly', () {
      final statuses = [
        'pending',
        'accepted',
        'enroute',
        'arrived',
        'completed',
        'cancelled',
      ];

      final expectedStatuses = [
        RideStatus.pending,
        RideStatus.accepted,
        RideStatus.enroute,
        RideStatus.arrived,
        RideStatus.completed,
        RideStatus.cancelled,
      ];

      for (var i = 0; i < statuses.length; i++) {
        final timestamp = Timestamp.now();
        final rideDto = RideDto(
          id: 'ride$i',
          companyUserId: 'company123',
          status: statuses[i],
          pickupLocation: const GeoPoint(37.7749, -122.4194),
          pickupAddress: '123 Main St',
          requestedAt: timestamp,
        );

        final ride = rideDto.toEntity();
        expect(ride.status, expectedStatuses[i]);
      }
    });
  });
}
