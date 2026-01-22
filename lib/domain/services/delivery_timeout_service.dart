import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/error_logger.dart';

/// Service to handle delivery search timeouts
class DeliveryTimeoutService {
  final FirebaseFirestore _firestore;
  final Map<String, Timer> _activeTimers = {};
  
  // Timeout duration: 2 minutes
  static const Duration timeoutDuration = Duration(minutes: 2);

  DeliveryTimeoutService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Start a timeout timer for a delivery search
  void startDeliverySearchTimeout(String deliveryId) {
    // Cancel any existing timer for this delivery
    cancelTimeout(deliveryId);

    // Create new timer
    final timer = Timer(timeoutDuration, () async {
      await _handleTimeout(deliveryId);
    });

    _activeTimers[deliveryId] = timer;
    ErrorLogger.log('Started timeout timer for delivery: $deliveryId');
  }

  /// Handle timeout - update delivery status to noDriverFound
  Future<void> _handleTimeout(String deliveryId) async {
    try {
      final deliveryDoc = await _firestore
          .collection('deliveryRequests')
          .doc(deliveryId)
          .get();

      if (!deliveryDoc.exists) {
        ErrorLogger.log('Delivery not found for timeout: $deliveryId');
        return;
      }

      final data = deliveryDoc.data();
      final currentStatus = data?['status'] as String?;

      // Only update if still searching
      if (currentStatus == 'searching') {
        await _firestore
            .collection('deliveryRequests')
            .doc(deliveryId)
            .update({
          'status': 'noDriverFound',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ErrorLogger.log('Delivery timeout - no driver found: $deliveryId');
      }
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        e,
        stackTrace,
        context: 'Error handling delivery timeout',
      );
    } finally {
      // Clean up timer reference
      _activeTimers.remove(deliveryId);
    }
  }

  /// Cancel timeout for a delivery (when driver accepts)
  void cancelTimeout(String deliveryId) {
    final timer = _activeTimers[deliveryId];
    if (timer != null) {
      timer.cancel();
      _activeTimers.remove(deliveryId);
      ErrorLogger.log('Cancelled timeout timer for delivery: $deliveryId');
    }
  }

  /// Cancel all active timers (cleanup on app close)
  void cancelAllTimers() {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    ErrorLogger.log('Cancelled all delivery timeout timers');
  }

  /// Get number of active timers (for debugging)
  int get activeTimerCount => _activeTimers.length;
}
