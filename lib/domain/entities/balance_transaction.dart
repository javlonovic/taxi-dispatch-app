/// Balance transaction types
enum BalanceTransactionType {
  topup,      // Admin adds balance
  deduction,  // Balance deducted for completed ride
  refund,     // Balance refunded for cancelled ride
  reservation // Balance reserved for pending ride
}

/// Balance transaction entity
class BalanceTransaction {
  final String id;
  final String companyId;
  final BalanceTransactionType type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? rideId;
  final String? adminId;
  final String? notes;
  final DateTime createdAt;

  BalanceTransaction({
    required this.id,
    required this.companyId,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.rideId,
    this.adminId,
    this.notes,
    required this.createdAt,
  });

  /// Get display title based on transaction type
  String get title {
    switch (type) {
      case BalanceTransactionType.topup:
        return 'Пополнение баланса';
      case BalanceTransactionType.deduction:
        return 'Оплата заказа';
      case BalanceTransactionType.refund:
        return 'Возврат средств';
      case BalanceTransactionType.reservation:
        return 'Резервирование';
    }
  }

  /// Get icon based on transaction type
  String get icon {
    switch (type) {
      case BalanceTransactionType.topup:
        return '↑';
      case BalanceTransactionType.deduction:
        return '↓';
      case BalanceTransactionType.refund:
        return '↑';
      case BalanceTransactionType.reservation:
        return '⊙';
    }
  }

  /// Check if transaction increases balance
  bool get isPositive {
    return type == BalanceTransactionType.topup || 
           type == BalanceTransactionType.refund;
  }
}
