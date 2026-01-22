import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/utils/error_logger.dart';

/// Commission service for handling balance deductions and driver earnings
/// Fixed rates: 25,000 сум per delivery, 20% commission (5,000 сум), 80% driver earnings (20,000 сум)
class CommissionService {
  final FirebaseFirestore _firestore;

  // Fixed rates in сум (Uzbekistan currency)
  static const double deliveryFee = 25000.0;
  static const double commissionRate = 0.20; // 20%
  static const double commissionAmount = 5000.0; // 20% of 25,000
  static const double driverEarningsAmount = 20000.0; // 80% of 25,000

  CommissionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Calculate commission for a delivery
  /// Returns a map with total, commission, and driver earnings
  Map<String, double> calculateCommission() {
    return {
      'total': deliveryFee,
      'commission': commissionAmount,
      'driverEarnings': driverEarningsAmount,
    };
  }

  /// Reserve balance from company when delivery request is created
  /// Deducts from balance and adds to reservedBalance
  Future<void> reserveBalance({
    required String companyId,
    required String rideId,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(companyId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        
        if (!snapshot.exists) {
          throw PaymentException('Company not found');
        }

        final data = snapshot.data()!;
        final currentBalance = (data['balance'] as num?)?.toDouble() ?? 0.0;
        final currentReserved = (data['reservedBalance'] as num?)?.toDouble() ?? 0.0;

        // Check if company has sufficient balance
        if (currentBalance < deliveryFee) {
          throw InsufficientBalanceException(
            'Insufficient balance. Required: $deliveryFee сум, Available: $currentBalance сум'
          );
        }

        // Update balances: deduct from balance, add to reserved
        transaction.update(userRef, {
          'balance': currentBalance - deliveryFee,
          'reservedBalance': currentReserved + deliveryFee,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      // Log the reservation
      await _logBalanceReservation(
        companyId: companyId,
        rideId: rideId,
        amount: deliveryFee,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw PaymentException('Failed to reserve balance: ${e.toString()}');
    }
  }

  /// Deduct reserved balance on delivery completion
  /// Removes from reservedBalance and processes commission
  /// Implements retry logic for transient failures with exponential backoff
  /// Sends error notifications to company and driver on failure
  Future<void> deductReservedBalance({
    required String companyId,
    required String driverId,
    required String rideId,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    Exception? lastError;

    // Log the start of balance deduction
    await ErrorLogger.log(
      'Starting balance deduction for ride $rideId (company: $companyId, driver: $driverId)'
    );

    while (attempts < maxRetries) {
      try {
        attempts++;
        
        // Log retry attempt
        if (attempts > 1) {
          await ErrorLogger.log(
            'Balance deduction retry attempt $attempts/$maxRetries for ride $rideId'
          );
        }

        // Use transaction to ensure atomicity
        await _firestore.runTransaction((transaction) async {
          final companyRef = _firestore.collection('users').doc(companyId);
          final driverRef = _firestore.collection('users').doc(driverId);

          // Get current balances
          final companySnapshot = await transaction.get(companyRef);
          final driverSnapshot = await transaction.get(driverRef);

          if (!companySnapshot.exists) {
            throw PaymentException('Company not found');
          }
          if (!driverSnapshot.exists) {
            throw PaymentException('Driver not found');
          }

          final companyData = companySnapshot.data()!;
          final driverData = driverSnapshot.data()!;

          final currentReserved = (companyData['reservedBalance'] as num?)?.toDouble() ?? 0.0;
          final driverBalance = (driverData['balance'] as num?)?.toDouble() ?? 0.0;

          // Verify sufficient reserved balance
          if (currentReserved < deliveryFee) {
            throw PaymentException(
              'Insufficient reserved balance. Required: $deliveryFee сум, Reserved: $currentReserved сум'
            );
          }

          // Update company reserved balance (deduct)
          transaction.update(companyRef, {
            'reservedBalance': currentReserved - deliveryFee,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Add earnings to driver balance
          transaction.update(driverRef, {
            'balance': driverBalance + driverEarningsAmount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        });

        // Create commission record
        await _createCommissionRecord(
          companyId: companyId,
          driverId: driverId,
          rideId: rideId,
        );

        // Update transaction histories
        await Future.wait([
          _createCompanyTransaction(companyId: companyId, rideId: rideId),
          _createDriverTransaction(driverId: driverId, rideId: rideId),
        ]);

        // Success - log and exit retry loop
        await ErrorLogger.log(
          'Balance deduction successful for ride $rideId after $attempts attempt(s)'
        );
        return;
      } catch (e, stackTrace) {
        lastError = e is Exception ? e : Exception(e.toString());
        
        // Log the error
        await ErrorLogger.logError(
          e,
          stackTrace,
          context: 'Balance deduction attempt $attempts for ride $rideId',
        );

        // Check if it's a non-retryable error
        if (e is PaymentException) {
          final isNonRetryable = e.message.contains('not found') || 
              e.message.contains('Insufficient reserved balance');
          
          if (isNonRetryable) {
            // Log non-retryable error
            await ErrorLogger.log(
              'Non-retryable error in balance deduction for ride $rideId: ${e.message}'
            );
            
            // Send error notifications
            await _sendBalanceDeductionErrorNotification(
              companyId: companyId,
              driverId: driverId,
              rideId: rideId,
              error: e.message,
              attemptNumber: attempts,
            );
            rethrow;
          }
        }

        // If we've exhausted retries, break the loop
        if (attempts >= maxRetries) {
          break;
        }

        // Wait before retry (exponential backoff: 200ms, 400ms, 800ms)
        final delayMs = 100 * (1 << attempts);
        await ErrorLogger.log(
          'Retrying balance deduction for ride $rideId after ${delayMs}ms delay'
        );
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    // All retries failed - log and notify
    final errorMessage = 'Failed to deduct reserved balance after $maxRetries attempts: ${lastError.toString()}';
    
    await ErrorLogger.logError(
      lastError ?? Exception(errorMessage),
      StackTrace.current,
      context: 'Balance deduction final failure for ride $rideId',
      fatal: true,
    );

    await _sendBalanceDeductionErrorNotification(
      companyId: companyId,
      driverId: driverId,
      rideId: rideId,
      error: errorMessage,
      attemptNumber: attempts,
    );
    
    if (lastError is AppException) {
      throw lastError;
    }
    throw PaymentException(errorMessage);
  }

  /// Send error notification when balance deduction fails
  /// Notifies both company and driver, and logs error for admin review
  Future<void> _sendBalanceDeductionErrorNotification({
    required String companyId,
    required String driverId,
    required String rideId,
    required String error,
    required int attemptNumber,
  }) async {
    try {
      final timestamp = FieldValue.serverTimestamp();
      
      // Notify company with detailed error information
      await _firestore.collection('notifications').add({
        'userId': companyId,
        'title': 'Ошибка обработки платежа',
        'body': 'Произошла ошибка при обработке платежа за доставку. Пожалуйста, свяжитесь с поддержкой.',
        'data': {
          'type': 'payment_error',
          'rideId': rideId,
          'error': error,
          'attemptNumber': attemptNumber,
          'severity': 'high',
        },
        'createdAt': timestamp,
        'read': false,
        'sent': false,
      });

      // Notify driver with detailed error information
      await _firestore.collection('notifications').add({
        'userId': driverId,
        'title': 'Ошибка обработки платежа',
        'body': 'Произошла ошибка при начислении заработка. Пожалуйста, свяжитесь с поддержкой.',
        'data': {
          'type': 'payment_error',
          'rideId': rideId,
          'error': error,
          'attemptNumber': attemptNumber,
          'severity': 'high',
        },
        'createdAt': timestamp,
        'read': false,
        'sent': false,
      });

      // Log error for admin review with comprehensive details
      await _firestore.collection('paymentErrors').add({
        'companyId': companyId,
        'driverId': driverId,
        'rideId': rideId,
        'error': error,
        'attemptNumber': attemptNumber,
        'amount': deliveryFee,
        'commission': commissionAmount,
        'driverEarnings': driverEarningsAmount,
        'timestamp': timestamp,
        'resolved': false,
        'requiresManualIntervention': true,
      });

      // Log successful notification
      await ErrorLogger.log(
        'Error notifications sent for ride $rideId (company: $companyId, driver: $driverId)'
      );
    } catch (notificationError, stackTrace) {
      // Log but don't throw - notification failure shouldn't block the main error
      await ErrorLogger.logError(
        notificationError,
        stackTrace,
        context: 'Failed to send balance deduction error notification for ride $rideId',
      );
    }
  }

  /// Refund reserved balance if order is cancelled
  /// Returns money from reservedBalance back to balance
  Future<void> refundReservedBalance({
    required String companyId,
    required String rideId,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(companyId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        
        if (!snapshot.exists) {
          throw PaymentException('Company not found');
        }

        final data = snapshot.data()!;
        final currentBalance = (data['balance'] as num?)?.toDouble() ?? 0.0;
        final currentReserved = (data['reservedBalance'] as num?)?.toDouble() ?? 0.0;

        // Verify sufficient reserved balance
        if (currentReserved < deliveryFee) {
          // If not enough reserved, log warning and continue
          await ErrorLogger.log(
            'Warning: Insufficient reserved balance for refund. Reserved: $currentReserved сум, Required: $deliveryFee сум'
          );
          return;
        }

        // Update balances: add back to balance, deduct from reserved
        transaction.update(userRef, {
          'balance': currentBalance + deliveryFee,
          'reservedBalance': currentReserved - deliveryFee,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      // Log the refund
      await _logBalanceRefund(
        companyId: companyId,
        rideId: rideId,
        amount: deliveryFee,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw PaymentException('Failed to refund reserved balance: ${e.toString()}');
    }
  }

  /// Create commission record in Firestore
  Future<void> _createCommissionRecord({
    required String companyId,
    required String driverId,
    required String rideId,
  }) async {
    await _firestore.collection('commissionRecords').add({
      'rideId': rideId,
      'companyId': companyId,
      'driverId': driverId,
      'amount': deliveryFee,
      'commission': commissionAmount,
      'driverEarnings': driverEarningsAmount,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Create company transaction record (deduction)
  Future<void> _createCompanyTransaction({
    required String companyId,
    required String rideId,
  }) async {
    await _firestore
        .collection('users')
        .doc(companyId)
        .collection('transactions')
        .add({
      'type': 'deduction',
      'amount': -deliveryFee, // Negative for deduction
      'rideId': rideId,
      'description': 'Оплата доставки',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Create driver transaction record (earnings)
  Future<void> _createDriverTransaction({
    required String driverId,
    required String rideId,
  }) async {
    await _firestore
        .collection('users')
        .doc(driverId)
        .collection('transactions')
        .add({
      'type': 'earning',
      'amount': driverEarningsAmount, // Positive for earnings
      'rideId': rideId,
      'description': 'Заработок за доставку',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Log balance reservation
  Future<void> _logBalanceReservation({
    required String companyId,
    required String rideId,
    required double amount,
  }) async {
    await _firestore
        .collection('users')
        .doc(companyId)
        .collection('transactions')
        .add({
      'type': 'reservation',
      'amount': -amount, // Negative for reservation
      'rideId': rideId,
      'description': 'Резервирование средств для доставки',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Log balance refund
  Future<void> _logBalanceRefund({
    required String companyId,
    required String rideId,
    required double amount,
  }) async {
    await _firestore
        .collection('users')
        .doc(companyId)
        .collection('transactions')
        .add({
      'type': 'refund',
      'amount': amount, // Positive for refund
      'rideId': rideId,
      'description': 'Возврат средств (отмена заказа)',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Check if company has sufficient balance for a delivery
  Future<bool> hasSufficientBalance(String companyId) async {
    try {
      final snapshot = await _firestore.collection('users').doc(companyId).get();
      
      if (!snapshot.exists) {
        return false;
      }

      final data = snapshot.data()!;
      final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
      
      return balance >= deliveryFee;
    } catch (e) {
      throw PaymentException('Failed to check balance: ${e.toString()}');
    }
  }

  /// Get company available balance
  Future<double> getAvailableBalance(String companyId) async {
    try {
      final snapshot = await _firestore.collection('users').doc(companyId).get();
      
      if (!snapshot.exists) {
        return 0.0;
      }

      final data = snapshot.data()!;
      return (data['balance'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw PaymentException('Failed to get balance: ${e.toString()}');
    }
  }
}

/// Exception for insufficient balance
class InsufficientBalanceException extends AppException {
  InsufficientBalanceException(super.message);
}
