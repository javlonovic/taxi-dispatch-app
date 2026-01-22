import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/error_logger.dart';
import '../entities/ride.dart';

/// Service to manage delivery status updates in Firestore
class DeliveryStatusService {
  final FirebaseFirestore _firestore;

  DeliveryStatusService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Update delivery status to searching (initial state)
  Future<void> startDeliverySearch(String deliveryId) async {
    try {
      await _firestore.collection('deliveryRequests').doc(deliveryId).update({
        'status': 'searching',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      ErrorLogger.log('Delivery search started: $deliveryId');
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        e,
        stackTrace,
        context: 'Error starting delivery search',
      );
      rethrow;
    }
  }

  /// Update delivery status when driver accepts
  Future<void> assignDriver(String deliveryId, String driverId) async {
    try {
      await _firestore.collection('deliveryRequests').doc(deliveryId).update({
        'status': 'driverAssigned',
        'assignedDriverId': driverId,
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      ErrorLogger.log('Driver assigned to delivery: $deliveryId');
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        e,
        stackTrace,
        context: 'Error assigning driver',
      );
      rethrow;
    }
  }

  /// Update delivery status when driver starts journey
  Future<void> startDelivery(String deliveryId) async {
    try {
      await _firestore.collection('deliveryRequests').doc(deliveryId).update({
        'status': 'onTheWay',
        'pickedUpAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      ErrorLogger.log('Delivery started: $deliveryId');
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        e,
        stackTrace,
        context: 'Error starting delivery',
      );
      rethrow;
    }
  }

  /// Update delivery status when delivery is completed
  Future<void> completeDelivery(String deliveryId) async {
    try {
      await _firestore.collection('deliveryRequests').doc(deliveryId).update({
        'status': 'delivered',
        'deliveredAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Mark company's first order as complete if applicable
      final deliveryDoc = await _firestore
          .collection('deliveryRequests')
          .doc(deliveryId)
          .get();
      
      if (deliveryDoc.exists) {
        final companyId = deliveryDoc.data()?['companyId'] as String?;
        if (companyId != null) {
          await _markFirstOrderComplete(companyId);
        }
      }
      
      ErrorLogger.log('Delivery completed: $deliveryId');
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        e,
        stackTrace,
        context: 'Error completing delivery',
      );
      rethrow;
    }
  }

  /// Update delivery status when cancelled
  Future<void> cancelDelivery(
    String deliveryId, {
    String? reason,
  }) async {
    try {
      await _firestore.collection('deliveryRequests').doc(deliveryId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancellationReason': reason ?? 'Заказ отменен',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      ErrorLogger.log('Delivery cancelled: $deliveryId');
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        e,
        stackTrace,
        context: 'Error cancelling delivery',
      );
      rethrow;
    }
  }

  /// Update delivery status when no driver found (timeout)
  Future<void> markNoDriverFound(String deliveryId) async {
    try {
      await _firestore.collection('deliveryRequests').doc(deliveryId).update({
        'status': 'noDriverFound',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      ErrorLogger.log('No driver found for delivery: $deliveryId');
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        e,
        stackTrace,
        context: 'Error marking no driver found',
      );
      rethrow;
    }
  }

  /// Mark company's first order as complete
  Future<void> _markFirstOrderComplete(String companyId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(companyId).get();
      
      if (userDoc.exists) {
        final hasCompletedFirstOrder = 
            userDoc.data()?['hasCompletedFirstOrder'] as bool? ?? false;
        
        if (!hasCompletedFirstOrder) {
          await _firestore.collection('users').doc(companyId).update({
            'hasCompletedFirstOrder': true,
            'firstOrderCompletedAt': FieldValue.serverTimestamp(),
          });
          
          ErrorLogger.log('First order completed for company: $companyId');
        }
      }
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        e,
        stackTrace,
        context: 'Error marking first order complete',
      );
      // Don't rethrow - this is a non-critical operation
    }
  }

  /// Get current delivery status
  Future<DeliveryStatus?> getDeliveryStatus(String deliveryId) async {
    try {
      final doc = await _firestore
          .collection('deliveryRequests')
          .doc(deliveryId)
          .get();
      
      if (!doc.exists) {
        return null;
      }
      
      final statusString = doc.data()?['status'] as String?;
      return _parseDeliveryStatus(statusString);
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        e,
        stackTrace,
        context: 'Error getting delivery status',
      );
      return null;
    }
  }

  /// Parse string status to DeliveryStatus enum
  DeliveryStatus? _parseDeliveryStatus(String? status) {
    if (status == null) return null;
    
    switch (status) {
      case 'searching':
        return DeliveryStatus.searching;
      case 'driverAssigned':
        return DeliveryStatus.driverAssigned;
      case 'onTheWay':
        return DeliveryStatus.onTheWay;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'cancelled':
        return DeliveryStatus.cancelled;
      case 'noDriverFound':
        return DeliveryStatus.noDriverFound;
      default:
        return null;
    }
  }

  /// Convert DeliveryStatus enum to string for Firestore
  static String statusToString(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.searching:
        return 'searching';
      case DeliveryStatus.driverAssigned:
        return 'driverAssigned';
      case DeliveryStatus.onTheWay:
        return 'onTheWay';
      case DeliveryStatus.delivered:
        return 'delivered';
      case DeliveryStatus.cancelled:
        return 'cancelled';
      case DeliveryStatus.noDriverFound:
        return 'noDriverFound';
    }
  }
}
