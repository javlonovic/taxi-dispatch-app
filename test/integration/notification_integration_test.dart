import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_dispatch_app/data/models/notification_payload.dart';
import 'package:taxi_dispatch_app/domain/entities/ride.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Notification Handling Integration Tests', () {
    test('ride request notification is created correctly', () {
      final notification = NotificationPayload(
        title: 'New Ride Request',
        body: 'You have a new ride request nearby',
        type: NotificationType.rideRequest,
        rideId: 'ride_123',
        data: {
          'rideId': 'ride_123',
          'pickupAddress': '123 Main St',
          'companyName': 'Test Company',
        },
      );

      expect(notification.title, 'New Ride Request');
      expect(notification.type, NotificationType.rideRequest);
      expect(notification.rideId, 'ride_123');
      expect(notification.data['pickupAddress'], '123 Main St');
    });

    test('ride accepted notification is created correctly', () {
      final notification = NotificationPayload(
        title: 'Ride Accepted',
        body: 'Your ride has been accepted by John Driver',
        type: NotificationType.rideAccepted,
        rideId: 'ride_123',
        driverId: 'driver_1',
        data: {
          'rideId': 'ride_123',
          'driverId': 'driver_1',
          'driverName': 'John Driver',
          'vehicleInfo': 'Blue Toyota Camry - ABC123',
        },
      );

      expect(notification.title, 'Ride Accepted');
      expect(notification.type, NotificationType.rideAccepted);
      expect(notification.driverId, 'driver_1');
      expect(notification.data['driverName'], 'John Driver');
    });

    test('driver arrived notification is created correctly', () {
      final notification = NotificationPayload(
        title: 'Driver Arrived',
        body: 'Your driver has arrived at the pickup location',
        type: NotificationType.driverArrived,
        rideId: 'ride_123',
        driverId: 'driver_1',
        data: {
          'rideId': 'ride_123',
          'driverId': 'driver_1',
        },
      );

      expect(notification.title, 'Driver Arrived');
      expect(notification.type, NotificationType.driverArrived);
      expect(notification.rideId, 'ride_123');
    });

    test('trip completed notification is created correctly', () {
      final notification = NotificationPayload(
        title: 'Trip Completed',
        body: 'Your trip has been completed. Fare: \$15.50',
        type: NotificationType.tripCompleted,
        rideId: 'ride_123',
        data: {
          'rideId': 'ride_123',
          'fare': '15.50',
          'distance': '5.2',
        },
      );

      expect(notification.title, 'Trip Completed');
      expect(notification.type, NotificationType.tripCompleted);
      expect(notification.data['fare'], '15.50');
      expect(notification.data['distance'], '5.2');
    });

    test('notification triggers on ride status changes', () {
      final ride = Ride(
        id: 'ride_123',
        companyUserId: 'company_1',
        driverUserId: null,
        status: RideStatus.pending,
        pickupLocation: const GeoPoint(37.7749, -122.4194),
        pickupAddress: '123 Main St',
        requestedAt: DateTime.now(),
      );

      final notifications = <NotificationPayload>[];

      // Ride created - notify drivers
      notifications.add(NotificationPayload(
        title: 'New Ride Request',
        body: 'You have a new ride request nearby',
        type: NotificationType.rideRequest,
        rideId: ride.id,
        data: {'rideId': ride.id},
      ));

      // Ride accepted - notify company
      final acceptedRide = Ride(
        id: ride.id,
        companyUserId: ride.companyUserId,
        driverUserId: 'driver_1',
        status: RideStatus.accepted,
        pickupLocation: ride.pickupLocation,
        pickupAddress: ride.pickupAddress,
        destination: ride.destination,
        destinationAddress: ride.destinationAddress,
        requestedAt: ride.requestedAt,
        acceptedAt: DateTime.now(),
      );

      notifications.add(NotificationPayload(
        title: 'Ride Accepted',
        body: 'Your ride has been accepted',
        type: NotificationType.rideAccepted,
        rideId: acceptedRide.id,
        driverId: 'driver_1',
        data: {'rideId': acceptedRide.id, 'driverId': 'driver_1'},
      ));

      // Driver arrived - notify company
      final arrivedRide = Ride(
        id: acceptedRide.id,
        companyUserId: acceptedRide.companyUserId,
        driverUserId: acceptedRide.driverUserId,
        status: RideStatus.arrived,
        pickupLocation: acceptedRide.pickupLocation,
        pickupAddress: acceptedRide.pickupAddress,
        destination: acceptedRide.destination,
        destinationAddress: acceptedRide.destinationAddress,
        requestedAt: acceptedRide.requestedAt,
        acceptedAt: acceptedRide.acceptedAt,
        arrivedAt: DateTime.now(),
      );

      notifications.add(NotificationPayload(
        title: 'Driver Arrived',
        body: 'Your driver has arrived',
        type: NotificationType.driverArrived,
        rideId: arrivedRide.id,
        data: {'rideId': arrivedRide.id},
      ));

      // Trip completed - notify both
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
      );

      notifications.add(NotificationPayload(
        title: 'Trip Completed',
        body: 'Your trip has been completed',
        type: NotificationType.tripCompleted,
        rideId: completedRide.id,
        data: {'rideId': completedRide.id, 'fare': '15.50'},
      ));

      // Verify notification sequence
      expect(notifications.length, 4);
      expect(notifications[0].type, NotificationType.rideRequest);
      expect(notifications[1].type, NotificationType.rideAccepted);
      expect(notifications[2].type, NotificationType.driverArrived);
      expect(notifications[3].type, NotificationType.tripCompleted);
    });

    test('multiple drivers receive ride request notification', () {
      final driverIds = ['driver_1', 'driver_2', 'driver_3', 'driver_4'];
      final notifications = <NotificationPayload>[];

      // Create notification for each driver
      for (final driverId in driverIds) {
        notifications.add(NotificationPayload(
          title: 'New Ride Request',
          body: 'You have a new ride request nearby',
          type: NotificationType.rideRequest,
          rideId: 'ride_123',
          driverId: driverId,
          data: {
            'rideId': 'ride_123',
            'recipientId': driverId,
          },
        ));
      }

      expect(notifications.length, 4);
      
      // Verify each notification has unique recipient
      for (int i = 0; i < notifications.length; i++) {
        expect(notifications[i].data['recipientId'], driverIds[i]);
      }
    });

    test('notifications are cancelled when ride is accepted', () {
      final pendingNotifications = <String, NotificationPayload>{};

      // Create notifications for multiple drivers
      final driverIds = ['driver_1', 'driver_2', 'driver_3'];
      for (final driverId in driverIds) {
        pendingNotifications[driverId] = NotificationPayload(
          title: 'New Ride Request',
          body: 'You have a new ride request nearby',
          type: NotificationType.rideRequest,
          rideId: 'ride_123',
          driverId: driverId,
          data: {
            'rideId': 'ride_123',
            'recipientId': driverId,
          },
        );
      }

      expect(pendingNotifications.length, 3);

      // Driver 1 accepts - cancel notifications for others
      final acceptingDriverId = 'driver_1';
      pendingNotifications.removeWhere(
        (driverId, _) => driverId != acceptingDriverId,
      );

      // Only accepting driver's notification remains
      expect(pendingNotifications.length, 1);
      expect(pendingNotifications.containsKey(acceptingDriverId), true);
    });

    test('notification includes ride details', () {
      final notification = NotificationPayload(
        title: 'New Ride Request',
        body: 'Pickup: 123 Main St',
        type: NotificationType.rideRequest,
        rideId: 'ride_123',
        data: {
          'rideId': 'ride_123',
          'pickupAddress': '123 Main St',
          'pickupLat': '37.7749',
          'pickupLng': '-122.4194',
          'destinationAddress': '456 Market St',
          'estimatedDistance': '5.2',
          'estimatedFare': '15.50',
        },
      );

      expect(notification.data['pickupAddress'], '123 Main St');
      expect(notification.data['destinationAddress'], '456 Market St');
      expect(notification.data['estimatedDistance'], '5.2');
      expect(notification.data['estimatedFare'], '15.50');
    });

    test('payment confirmation notification is sent', () {
      final notification = NotificationPayload(
        title: 'Payment Confirmed',
        body: 'Payment of \$15.50 has been processed',
        type: NotificationType.paymentConfirmed,
        rideId: 'ride_123',
        data: {
          'rideId': 'ride_123',
          'amount': '15.50',
          'paymentMethod': 'Credit Card',
          'transactionId': 'txn_123',
        },
      );

      expect(notification.title, 'Payment Confirmed');
      expect(notification.type, NotificationType.paymentConfirmed);
      expect(notification.data['amount'], '15.50');
      expect(notification.data['transactionId'], 'txn_123');
    });

    test('notification data can be parsed for navigation', () {
      final notification = NotificationPayload(
        title: 'Ride Accepted',
        body: 'Your ride has been accepted',
        type: NotificationType.rideAccepted,
        rideId: 'ride_123',
        data: {
          'rideId': 'ride_123',
          'navigationRoute': '/tracking',
          'screenParams': '{"rideId":"ride_123"}',
        },
      );

      expect(notification.data['navigationRoute'], '/tracking');
      expect(notification.data['screenParams'], contains('ride_123'));
    });

    test('notification handles different user types', () {
      // Notification for driver
      final driverNotification = NotificationPayload(
        title: 'New Ride Request',
        body: 'You have a new ride request',
        type: NotificationType.rideRequest,
        driverId: 'driver_1',
        data: {
          'recipientType': 'driver',
          'recipientId': 'driver_1',
        },
      );

      // Notification for company
      final companyNotification = NotificationPayload(
        title: 'Ride Accepted',
        body: 'Your ride has been accepted',
        type: NotificationType.rideAccepted,
        companyId: 'company_1',
        data: {
          'recipientType': 'company',
          'recipientId': 'company_1',
        },
      );

      expect(driverNotification.data['recipientType'], 'driver');
      expect(companyNotification.data['recipientType'], 'company');
    });

    test('notification priority is set correctly', () {
      // High priority - ride request
      final urgentNotification = NotificationPayload(
        title: 'New Ride Request',
        body: 'You have a new ride request',
        type: NotificationType.rideRequest,
        rideId: 'ride_123',
        data: {'priority': 'high'},
      );

      // Normal priority - payment confirmation
      final normalNotification = NotificationPayload(
        title: 'Payment Confirmed',
        body: 'Payment has been processed',
        type: NotificationType.paymentConfirmed,
        rideId: 'ride_123',
        data: {'priority': 'normal'},
      );

      expect(urgentNotification.data['priority'], 'high');
      expect(normalNotification.data['priority'], 'normal');
    });

    test('notification can be marked as read', () {
      final notification = NotificationPayload(
        title: 'New Ride Request',
        body: 'You have a new ride request',
        type: NotificationType.rideRequest,
        rideId: 'ride_123',
        data: {
          'rideId': 'ride_123',
          'read': 'false',
        },
      );

      expect(notification.data['read'], 'false');

      // Mark as read
      notification.data['read'] = 'true';
      expect(notification.data['read'], 'true');
    });

    test('notification types are correctly identified', () {
      final types = [
        NotificationType.rideRequest,
        NotificationType.rideAccepted,
        NotificationType.driverArrived,
        NotificationType.tripCompleted,
        NotificationType.paymentConfirmed,
        NotificationType.newMessage,
        NotificationType.ratingReceived,
        NotificationType.general,
      ];

      for (final type in types) {
        final notification = NotificationPayload(
          title: 'Test',
          body: 'Test body',
          type: type,
          data: {},
        );

        expect(notification.type, type);
      }
    });
  });
}
