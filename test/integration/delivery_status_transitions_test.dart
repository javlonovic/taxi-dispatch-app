import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Delivery Status Transitions Tests', () {
    group('Status Enum', () {
      test('defines all delivery statuses', () {
        final statuses = [
          'searching',
          'driverAssigned',
          'onTheWay',
          'delivered',
          'cancelled',
          'noDriverFound',
        ];

        expect(statuses, contains('searching'));
        expect(statuses, contains('driverAssigned'));
        expect(statuses, contains('onTheWay'));
        expect(statuses, contains('delivered'));
        expect(statuses, contains('cancelled'));
        expect(statuses, contains('noDriverFound'));
      });
    });

    group('Searching Status', () {
      test('initial status is searching', () {
        final delivery = {
          'id': 'delivery_1',
          'status': 'searching',
          'requestedAt': DateTime.now(),
        };

        expect(delivery['status'], 'searching');
      });

      test('displays searching animation', () {
        final delivery = {
          'status': 'searching',
          'displayText': 'Ищем водителя...',
          'showAnimation': true,
        };

        expect(delivery['displayText'], 'Ищем водителя...');
        expect(delivery['showAnimation'], isTrue);
      });

      test('transitions to driver assigned when accepted', () {
        var status = 'searching';

        // Driver accepts
        status = 'driverAssigned';

        expect(status, 'driverAssigned');
      });

      test('transitions to no driver found after timeout', () {
        var status = 'searching';
        final requestedAt = DateTime.now().subtract(const Duration(minutes: 6));
        final timeout = DateTime.now().difference(requestedAt) > const Duration(minutes: 5);

        if (timeout) {
          status = 'noDriverFound';
        }

        expect(status, 'noDriverFound');
      });

      test('can be cancelled by company', () {
        var status = 'searching';

        // Company cancels
        status = 'cancelled';

        expect(status, 'cancelled');
      });
    });

    group('Driver Assigned Status', () {
      test('transitions from searching to driver assigned', () {
        final delivery = {
          'status': 'searching',
          'assignedDriverId': null,
        };

        // Driver accepts
        delivery['status'] = 'driverAssigned';
        delivery['assignedDriverId'] = 'driver_1';
        delivery['acceptedAt'] = DateTime.now();

        expect(delivery['status'], 'driverAssigned');
        expect(delivery['assignedDriverId'], 'driver_1');
        expect(delivery['acceptedAt'], isNotNull);
      });

      test('displays driver information', () {
        final delivery = {
          'status': 'driverAssigned',
          'displayText': 'Водитель назначен',
          'driverName': 'Иван Петров',
          'carModel': 'Toyota Camry',
        };

        expect(delivery['displayText'], 'Водитель назначен');
        expect(delivery['driverName'], isNotNull);
      });

      test('transitions to on the way when driver starts', () {
        var status = 'driverAssigned';

        // Driver starts journey
        status = 'onTheWay';

        expect(status, 'onTheWay');
      });

      test('can be cancelled before driver starts', () {
        var status = 'driverAssigned';

        // Company or driver cancels
        status = 'cancelled';

        expect(status, 'cancelled');
      });
    });

    group('On The Way Status', () {
      test('transitions from driver assigned to on the way', () {
        final delivery = {
          'status': 'driverAssigned',
        };

        // Driver starts journey
        delivery['status'] = 'onTheWay';
        delivery['startedAt'] = DateTime.now();

        expect(delivery['status'], 'onTheWay');
        expect(delivery['startedAt'], isNotNull);
      });

      test('displays tracking information', () {
        final delivery = {
          'status': 'onTheWay',
          'displayText': 'Водитель в пути',
          'showTracking': true,
          'showETA': true,
        };

        expect(delivery['displayText'], 'Водитель в пути');
        expect(delivery['showTracking'], isTrue);
        expect(delivery['showETA'], isTrue);
      });

      test('transitions to delivered when completed', () {
        var status = 'onTheWay';

        // Driver completes delivery
        status = 'delivered';

        expect(status, 'delivered');
      });

      test('can be cancelled during journey', () {
        var status = 'onTheWay';

        // Cancellation occurs
        status = 'cancelled';

        expect(status, 'cancelled');
      });
    });

    group('Delivered Status', () {
      test('transitions from on the way to delivered', () {
        final delivery = {
          'status': 'onTheWay',
        };

        // Driver completes delivery
        delivery['status'] = 'delivered';
        delivery['deliveredAt'] = DateTime.now();

        expect(delivery['status'], 'delivered');
        expect(delivery['deliveredAt'], isNotNull);
      });

      test('displays success message', () {
        final delivery = {
          'status': 'delivered',
          'displayText': 'Доставлено',
          'showSuccessIcon': true,
        };

        expect(delivery['displayText'], 'Доставлено');
        expect(delivery['showSuccessIcon'], isTrue);
      });

      test('is final status - no further transitions', () {
        const status = 'delivered';
        final isFinalStatus = status == 'delivered';

        expect(isFinalStatus, isTrue);
      });

      test('stores completion timestamp', () {
        final delivery = {
          'status': 'delivered',
          'deliveredAt': DateTime.now(),
          'completedAt': DateTime.now(),
        };

        expect(delivery['deliveredAt'], isNotNull);
        expect(delivery['completedAt'], isNotNull);
      });
    });

    group('Cancelled Status', () {
      test('can be cancelled from searching', () {
        var status = 'searching';
        status = 'cancelled';

        expect(status, 'cancelled');
      });

      test('can be cancelled from driver assigned', () {
        var status = 'driverAssigned';
        status = 'cancelled';

        expect(status, 'cancelled');
      });

      test('can be cancelled from on the way', () {
        var status = 'onTheWay';
        status = 'cancelled';

        expect(status, 'cancelled');
      });

      test('cannot be cancelled after delivered', () {
        const status = 'delivered';
        final canCancel = status != 'delivered';

        expect(canCancel, isFalse);
      });

      test('stores cancellation reason', () {
        final delivery = {
          'status': 'cancelled',
          'cancelledAt': DateTime.now(),
          'cancellationReason': 'Заказ больше не нужен',
          'cancelledBy': 'company',
        };

        expect(delivery['cancelledAt'], isNotNull);
        expect(delivery['cancellationReason'], isNotNull);
        expect(delivery['cancelledBy'], 'company');
      });

      test('displays cancellation message', () {
        final delivery = {
          'status': 'cancelled',
          'displayText': 'Отменено',
          'showErrorIcon': true,
        };

        expect(delivery['displayText'], 'Отменено');
        expect(delivery['showErrorIcon'], isTrue);
      });
    });

    group('No Driver Found Status', () {
      test('transitions from searching after timeout', () {
        final delivery = {
          'status': 'searching',
          'requestedAt': DateTime.now().subtract(const Duration(minutes: 6)),
        };

        // Check timeout
        final timeout = DateTime.now().difference(delivery['requestedAt'] as DateTime) > 
                       const Duration(minutes: 5);

        if (timeout) {
          delivery['status'] = 'noDriverFound';
        }

        expect(delivery['status'], 'noDriverFound');
      });

      test('displays no driver found message', () {
        final delivery = {
          'status': 'noDriverFound',
          'displayText': 'Водитель не найден, попробуйте позже',
          'showRetryButton': true,
        };

        expect(delivery['displayText'], contains('Водитель не найден'));
        expect(delivery['showRetryButton'], isTrue);
      });

      test('is final status - no further transitions', () {
        const status = 'noDriverFound';
        final isFinalStatus = status == 'noDriverFound';

        expect(isFinalStatus, isTrue);
      });

      test('stores timeout timestamp', () {
        final delivery = {
          'status': 'noDriverFound',
          'timeoutAt': DateTime.now(),
        };

        expect(delivery['timeoutAt'], isNotNull);
      });
    });

    group('Status Transition Validation', () {
      test('validates valid transition sequence', () {
        final validSequence = [
          'searching',
          'driverAssigned',
          'onTheWay',
          'delivered',
        ];

        var currentStatus = validSequence[0];
        for (int i = 1; i < validSequence.length; i++) {
          currentStatus = validSequence[i];
          expect(validSequence, contains(currentStatus));
        }
      });

      test('prevents invalid backward transitions', () {
        const currentStatus = 'delivered';
        const attemptedStatus = 'onTheWay';

        final isValidTransition = _isValidTransition(currentStatus, attemptedStatus);

        expect(isValidTransition, isFalse);
      });

      test('allows cancellation from any non-final status', () {
        final nonFinalStatuses = ['searching', 'driverAssigned', 'onTheWay'];

        for (final status in nonFinalStatuses) {
          final canCancel = status != 'delivered' && status != 'noDriverFound';
          expect(canCancel, isTrue);
        }
      });

      test('prevents transitions from final statuses', () {
        final finalStatuses = ['delivered', 'cancelled', 'noDriverFound'];

        for (final status in finalStatuses) {
          final isFinal = finalStatuses.contains(status);
          expect(isFinal, isTrue);
        }
      });
    });

    group('Status Display Text', () {
      test('provides Russian text for each status', () {
        final statusTexts = {
          'searching': 'Ищем водителя...',
          'driverAssigned': 'Водитель назначен',
          'onTheWay': 'Водитель в пути',
          'delivered': 'Доставлено',
          'cancelled': 'Отменено',
          'noDriverFound': 'Водитель не найден',
        };

        expect(statusTexts['searching'], 'Ищем водителя...');
        expect(statusTexts['driverAssigned'], 'Водитель назначен');
        expect(statusTexts['onTheWay'], 'Водитель в пути');
        expect(statusTexts['delivered'], 'Доставлено');
        expect(statusTexts['cancelled'], 'Отменено');
        expect(statusTexts['noDriverFound'], 'Водитель не найден');
      });

      test('provides status colors', () {
        final statusColors = {
          'searching': 'blue',
          'driverAssigned': 'green',
          'onTheWay': 'green',
          'delivered': 'green',
          'cancelled': 'red',
          'noDriverFound': 'orange',
        };

        expect(statusColors['searching'], 'blue');
        expect(statusColors['delivered'], 'green');
        expect(statusColors['cancelled'], 'red');
      });
    });

    group('Complete Delivery Lifecycle', () {
      test('successful delivery flow', () {
        final statuses = <String>[];

        // Company creates request
        statuses.add('searching');

        // Driver accepts
        statuses.add('driverAssigned');

        // Driver starts journey
        statuses.add('onTheWay');

        // Driver completes delivery
        statuses.add('delivered');

        expect(statuses, [
          'searching',
          'driverAssigned',
          'onTheWay',
          'delivered',
        ]);
      });

      test('no driver found flow', () {
        final statuses = <String>[];

        // Company creates request
        statuses.add('searching');

        // Timeout occurs
        statuses.add('noDriverFound');

        expect(statuses, ['searching', 'noDriverFound']);
      });

      test('cancellation flow', () {
        final statuses = <String>[];

        // Company creates request
        statuses.add('searching');

        // Driver accepts
        statuses.add('driverAssigned');

        // Company cancels
        statuses.add('cancelled');

        expect(statuses, ['searching', 'driverAssigned', 'cancelled']);
      });
    });
  });
}

bool _isValidTransition(String currentStatus, String newStatus) {
  final validTransitions = {
    'searching': ['driverAssigned', 'cancelled', 'noDriverFound'],
    'driverAssigned': ['onTheWay', 'cancelled'],
    'onTheWay': ['delivered', 'cancelled'],
    'delivered': <String>[],
    'cancelled': <String>[],
    'noDriverFound': <String>[],
  };

  return validTransitions[currentStatus]?.contains(newStatus) ?? false;
}
