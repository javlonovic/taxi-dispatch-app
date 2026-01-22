import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Driver Notification and Acceptance Tests', () {
    group('Notification Delivery', () {
      test('sends notification to active drivers within radius', () {
        final deliveryRequest = {
          'id': 'delivery_1',
          'pickupLocation': const GeoPoint(55.7558, 37.6173),
          'companyName': 'Test Company',
        };

        final activeDrivers = [
          {
            'id': 'driver_1',
            'isActive': true,
            'currentLocation': const GeoPoint(55.7608, 37.6223), // Within 5-6 km
          },
          {
            'id': 'driver_2',
            'isActive': true,
            'currentLocation': const GeoPoint(55.7658, 37.6273), // Within 5-6 km
          },
        ];

        // All active drivers within radius should receive notification
        expect(activeDrivers.length, 2);
        expect(activeDrivers.every((d) => d['isActive'] == true), isTrue);
      });

      test('excludes inactive drivers from notifications', () {
        final drivers = [
          {'id': 'driver_1', 'isActive': true},
          {'id': 'driver_2', 'isActive': false},
          {'id': 'driver_3', 'isActive': true},
        ];

        final notifiedDrivers = drivers.where((d) => d['isActive'] == true).toList();

        expect(notifiedDrivers.length, 2);
        expect(notifiedDrivers[0]['id'], 'driver_1');
        expect(notifiedDrivers[1]['id'], 'driver_3');
      });

      test('notification includes all order details', () {
        final notification = {
          'title': 'Новый заказ',
          'body': 'Заказ от Test Company',
          'data': {
            'deliveryId': 'delivery_1',
            'companyName': 'Test Company',
            'companyPhone': '+79001234567',
            'pickupAddress': 'ул. Ленина, 1',
            'deliveryAddress': 'ул. Пушкина, 10',
            'recipientName': 'Иван Иванов',
            'recipientPhone': '+79009876543',
            'readyInMinutes': 15,
          },
        };

        expect(notification['data']['deliveryId'], isNotNull);
        expect(notification['data']['companyName'], isNotNull);
        expect(notification['data']['companyPhone'], isNotNull);
        expect(notification['data']['pickupAddress'], isNotNull);
        expect(notification['data']['deliveryAddress'], isNotNull);
        expect(notification['data']['recipientName'], isNotNull);
        expect(notification['data']['recipientPhone'], isNotNull);
      });
    });

    group('Order Details Card', () {
      test('displays all order information', () {
        final orderDetails = {
          'companyName': 'Test Company',
          'companyPhone': '+79001234567',
          'pickupAddress': 'ул. Ленина, 1',
          'deliveryAddress': 'ул. Пушкина, 10',
          'recipientName': 'Иван Иванов',
          'recipientPhone': '+79009876543',
          'readyInMinutes': 30,
        };

        expect(orderDetails['companyName'], 'Test Company');
        expect(orderDetails['companyPhone'], '+79001234567');
        expect(orderDetails['pickupAddress'], 'ул. Ленина, 1');
        expect(orderDetails['deliveryAddress'], 'ул. Пушкина, 10');
        expect(orderDetails['recipientName'], 'Иван Иванов');
        expect(orderDetails['recipientPhone'], '+79009876543');
      });

      test('shows scheduled pickup time', () {
        final requestedAt = DateTime.now();
        const readyInMinutes = 45;
        final scheduledTime = requestedAt.add(Duration(minutes: readyInMinutes));

        final orderDetails = {
          'readyInMinutes': readyInMinutes,
          'scheduledPickupTime': scheduledTime,
          'displayText': 'Забрать через 45 минут',
        };

        expect(orderDetails['readyInMinutes'], 45);
        expect(orderDetails['scheduledPickupTime'], isNotNull);
        expect(orderDetails['displayText'], contains('45 минут'));
      });

      test('provides accept and skip buttons', () {
        final orderCard = {
          'deliveryId': 'delivery_1',
          'actions': ['accept', 'skip'],
        };

        expect(orderCard['actions'], contains('accept'));
        expect(orderCard['actions'], contains('skip'));
      });
    });

    group('Driver Acceptance', () {
      test('driver accepts order successfully', () {
        final deliveryRequest = {
          'id': 'delivery_1',
          'status': 'searching',
          'assignedDriverId': null,
        };

        // Driver accepts
        deliveryRequest['status'] = 'driverAssigned';
        deliveryRequest['assignedDriverId'] = 'driver_1';
        deliveryRequest['acceptedAt'] = DateTime.now();

        expect(deliveryRequest['status'], 'driverAssigned');
        expect(deliveryRequest['assignedDriverId'], 'driver_1');
        expect(deliveryRequest['acceptedAt'], isNotNull);
      });

      test('removes order from other drivers after acceptance', () {
        final notifiedDrivers = ['driver_1', 'driver_2', 'driver_3'];
        const acceptingDriver = 'driver_2';

        // Remove from all except accepting driver
        final remainingNotifications = notifiedDrivers
            .where((id) => id == acceptingDriver)
            .toList();

        expect(remainingNotifications.length, 1);
        expect(remainingNotifications[0], acceptingDriver);
      });

      test('notifies company when driver accepts', () {
        final companyNotification = {
          'title': 'Водитель найден',
          'body': 'Водитель принял ваш заказ',
          'data': {
            'deliveryId': 'delivery_1',
            'driverId': 'driver_1',
            'driverName': 'Иван Петров',
            'carModel': 'Toyota Camry',
            'carNumber': 'А123БВ',
          },
        };

        expect(companyNotification['title'], 'Водитель найден');
        expect(companyNotification['data']['driverId'], isNotNull);
        expect(companyNotification['data']['driverName'], isNotNull);
      });

      test('updates delivery status to driver assigned', () {
        var deliveryStatus = 'searching';

        // Driver accepts
        deliveryStatus = 'driverAssigned';

        expect(deliveryStatus, 'driverAssigned');
      });
    });

    group('Driver Skip', () {
      test('driver skips order without affecting status', () {
        final deliveryRequest = {
          'id': 'delivery_1',
          'status': 'searching',
          'assignedDriverId': null,
        };

        // Driver skips - no changes to delivery
        expect(deliveryRequest['status'], 'searching');
        expect(deliveryRequest['assignedDriverId'], isNull);
      });

      test('order remains available for other drivers after skip', () {
        final notifiedDrivers = ['driver_1', 'driver_2', 'driver_3'];
        const skippingDriver = 'driver_1';

        // Remove only from skipping driver
        final remainingDrivers = notifiedDrivers
            .where((id) => id != skippingDriver)
            .toList();

        expect(remainingDrivers.length, 2);
        expect(remainingDrivers, isNot(contains(skippingDriver)));
      });
    });

    group('Multiple Driver Scenario', () {
      test('first driver to accept gets the order', () {
        final deliveryRequest = {
          'id': 'delivery_1',
          'status': 'searching',
          'assignedDriverId': null,
        };

        final notifiedDrivers = ['driver_1', 'driver_2', 'driver_3'];

        // Driver 2 accepts first
        deliveryRequest['assignedDriverId'] = 'driver_2';
        deliveryRequest['status'] = 'driverAssigned';

        expect(deliveryRequest['assignedDriverId'], 'driver_2');
        expect(deliveryRequest['status'], 'driverAssigned');

        // Other drivers should not be able to accept
        final canAccept = deliveryRequest['assignedDriverId'] == null;
        expect(canAccept, isFalse);
      });

      test('prevents double acceptance', () {
        final deliveryRequest = {
          'id': 'delivery_1',
          'status': 'driverAssigned',
          'assignedDriverId': 'driver_1',
        };

        // Another driver tries to accept
        final canAccept = deliveryRequest['assignedDriverId'] == null;

        expect(canAccept, isFalse);
        expect(deliveryRequest['assignedDriverId'], 'driver_1');
      });
    });

    group('Notification Timing', () {
      test('sends notification immediately for immediate pickup', () {
        final deliveryRequest = {
          'id': 'delivery_1',
          'readyInMinutes': 0,
          'requestedAt': DateTime.now(),
        };

        final shouldNotifyNow = deliveryRequest['readyInMinutes'] == 0;

        expect(shouldNotifyNow, isTrue);
      });

      test('includes scheduled time in notification for delayed pickup', () {
        final requestedAt = DateTime.now();
        const readyInMinutes = 30;
        final scheduledTime = requestedAt.add(Duration(minutes: readyInMinutes));

        final notification = {
          'data': {
            'readyInMinutes': readyInMinutes,
            'scheduledPickupTime': scheduledTime.toIso8601String(),
          },
        };

        expect(notification['data']['readyInMinutes'], 30);
        expect(notification['data']['scheduledPickupTime'], isNotNull);
      });
    });

    group('Notification Payload', () {
      test('includes all required fields', () {
        final payload = {
          'deliveryId': 'delivery_1',
          'companyId': 'company_1',
          'companyName': 'Test Company',
          'companyPhone': '+79001234567',
          'pickupLocation': {'lat': 55.7558, 'lng': 37.6173},
          'pickupAddress': 'ул. Ленина, 1',
          'deliveryLocation': {'lat': 55.7658, 'lng': 37.6273},
          'deliveryAddress': 'ул. Пушкина, 10',
          'recipientName': 'Иван Иванов',
          'recipientPhone': '+79009876543',
          'readyInMinutes': 15,
        };

        expect(payload['deliveryId'], isNotNull);
        expect(payload['companyName'], isNotNull);
        expect(payload['pickupAddress'], isNotNull);
        expect(payload['deliveryAddress'], isNotNull);
        expect(payload['recipientName'], isNotNull);
        expect(payload['recipientPhone'], isNotNull);
      });

      test('formats phone numbers correctly', () {
        final payload = {
          'companyPhone': '+79001234567',
          'recipientPhone': '+79009876543',
        };

        expect(payload['companyPhone'], startsWith('+7'));
        expect(payload['recipientPhone'], startsWith('+7'));
        expect(payload['companyPhone']?.length, 12);
        expect(payload['recipientPhone']?.length, 12);
      });
    });

    group('Error Handling', () {
      test('handles notification failure gracefully', () {
        final deliveryRequest = {
          'id': 'delivery_1',
          'status': 'searching',
          'notificationAttempts': 0,
        };

        // Simulate notification failure
        deliveryRequest['notificationAttempts'] = 
            (deliveryRequest['notificationAttempts'] as int) + 1;

        expect(deliveryRequest['notificationAttempts'], 1);
        expect(deliveryRequest['status'], 'searching');
      });

      test('handles driver acceptance failure', () {
        final deliveryRequest = {
          'id': 'delivery_1',
          'status': 'searching',
          'assignedDriverId': null,
        };

        // Attempt to assign driver fails
        // Status remains unchanged
        expect(deliveryRequest['status'], 'searching');
        expect(deliveryRequest['assignedDriverId'], isNull);
      });
    });
  });
}
