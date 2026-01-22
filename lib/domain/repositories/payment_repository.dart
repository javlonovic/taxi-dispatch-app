/// Payment repository interface
abstract class PaymentRepository {
  /// Add a payment method
  Future<void> addPaymentMethod(PaymentMethod method);

  /// Get payment methods for a user
  Future<List<PaymentMethod>> getPaymentMethods(String userId);

  /// Process payment for a ride
  Future<Payment> processPayment(String rideId, double amount);

  /// Generate receipt
  Future<Receipt> generateReceipt(String paymentId);

  /// Get transaction history
  Future<List<Transaction>> getTransactionHistory(String userId);
}

/// Payment method
class PaymentMethod {
  final String id;
  final String type;
  final String last4;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.last4,
  });
}

/// Payment
class Payment {
  final String id;
  final String rideId;
  final double amount;
  final DateTime timestamp;

  Payment({
    required this.id,
    required this.rideId,
    required this.amount,
    required this.timestamp,
  });
}

/// Receipt
class Receipt {
  final String id;
  final String paymentId;
  final double amount;
  final DateTime timestamp;

  Receipt({
    required this.id,
    required this.paymentId,
    required this.amount,
    required this.timestamp,
  });
}

/// Transaction
class Transaction {
  final String id;
  final double amount;
  final DateTime timestamp;
  final String type;

  Transaction({
    required this.id,
    required this.amount,
    required this.timestamp,
    required this.type,
  });
}
