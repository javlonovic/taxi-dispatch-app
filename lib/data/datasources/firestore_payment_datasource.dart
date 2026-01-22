import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/payment_dto.dart';

/// Firestore payment data source
class FirestorePaymentDataSource {
  final FirebaseFirestore _firestore;

  FirestorePaymentDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Save payment method
  Future<void> savePaymentMethod(String userId, PaymentMethodDto method) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .doc(method.id)
          .set(method.toFirestore());
    } catch (e) {
      throw PaymentException('Failed to save payment method: ${e.toString()}');
    }
  }

  /// Get payment methods
  Future<List<PaymentMethodDto>> getPaymentMethods(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .get();

      return snapshot.docs
          .map((doc) => PaymentMethodDto.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw PaymentException('Failed to get payment methods: ${e.toString()}');
    }
  }

  /// Delete payment method
  Future<void> deletePaymentMethod(String userId, String methodId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .doc(methodId)
          .delete();
    } catch (e) {
      throw PaymentException('Failed to delete payment method: ${e.toString()}');
    }
  }

  /// Create payment record
  Future<String> createPayment(PaymentDto payment) async {
    try {
      final docRef = await _firestore
          .collection('payments')
          .add(payment.toFirestore());
      return docRef.id;
    } catch (e) {
      throw PaymentException('Failed to create payment: ${e.toString()}');
    }
  }

  /// Update payment status
  Future<void> updatePaymentStatus(String paymentId, String status) async {
    try {
      await _firestore
          .collection('payments')
          .doc(paymentId)
          .update({'status': status});
    } catch (e) {
      throw PaymentException('Failed to update payment status: ${e.toString()}');
    }
  }

  /// Get payment by ID
  Future<PaymentDto?> getPayment(String paymentId) async {
    try {
      final doc = await _firestore
          .collection('payments')
          .doc(paymentId)
          .get();

      if (!doc.exists) return null;
      return PaymentDto.fromFirestore(doc);
    } catch (e) {
      throw PaymentException('Failed to get payment: ${e.toString()}');
    }
  }

  /// Create receipt
  Future<String> createReceipt(ReceiptDto receipt) async {
    try {
      final docRef = await _firestore
          .collection('receipts')
          .add(receipt.toFirestore());
      return docRef.id;
    } catch (e) {
      throw PaymentException('Failed to create receipt: ${e.toString()}');
    }
  }

  /// Get receipt by payment ID
  Future<ReceiptDto?> getReceiptByPaymentId(String paymentId) async {
    try {
      final snapshot = await _firestore
          .collection('receipts')
          .where('paymentId', isEqualTo: paymentId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return ReceiptDto.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw PaymentException('Failed to get receipt: ${e.toString()}');
    }
  }

  /// Create transaction
  Future<String> createTransaction(TransactionDto transaction) async {
    try {
      final docRef = await _firestore
          .collection('transactions')
          .add(transaction.toFirestore());
      return docRef.id;
    } catch (e) {
      throw PaymentException('Failed to create transaction: ${e.toString()}');
    }
  }

  /// Get transaction history
  Future<List<TransactionDto>> getTransactionHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TransactionDto.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw PaymentException('Failed to get transaction history: ${e.toString()}');
    }
  }

  /// Get earnings for driver
  Future<double> getDriverEarnings(String driverId) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: driverId)
          .where('type', isEqualTo: 'earning')
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        total += (data['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      throw PaymentException('Failed to get driver earnings: ${e.toString()}');
    }
  }
}
