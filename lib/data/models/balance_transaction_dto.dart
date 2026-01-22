import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/balance_transaction.dart';

/// DTO for balance transaction Firestore serialization
class BalanceTransactionDto {
  final String id;
  final String companyId;
  final String type; // 'topup', 'deduction', 'refund', 'reservation'
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? rideId;
  final String? adminId;
  final String? notes;
  final Timestamp createdAt;

  BalanceTransactionDto({
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

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'type': type,
      'amount': amount,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'rideId': rideId,
      'adminId': adminId,
      'notes': notes,
      'createdAt': createdAt,
    };
  }

  factory BalanceTransactionDto.fromMap(String id, Map<String, dynamic> map) {
    return BalanceTransactionDto(
      id: id,
      companyId: map['companyId'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      balanceBefore: (map['balanceBefore'] as num).toDouble(),
      balanceAfter: (map['balanceAfter'] as num).toDouble(),
      rideId: map['rideId'] as String?,
      adminId: map['adminId'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  factory BalanceTransactionDto.fromEntity(BalanceTransaction transaction) {
    return BalanceTransactionDto(
      id: transaction.id,
      companyId: transaction.companyId,
      type: _transactionTypeToString(transaction.type),
      amount: transaction.amount,
      balanceBefore: transaction.balanceBefore,
      balanceAfter: transaction.balanceAfter,
      rideId: transaction.rideId,
      adminId: transaction.adminId,
      notes: transaction.notes,
      createdAt: Timestamp.fromDate(transaction.createdAt),
    );
  }

  BalanceTransaction toEntity() {
    return BalanceTransaction(
      id: id,
      companyId: companyId,
      type: _parseTransactionType(type),
      amount: amount,
      balanceBefore: balanceBefore,
      balanceAfter: balanceAfter,
      rideId: rideId,
      adminId: adminId,
      notes: notes,
      createdAt: createdAt.toDate(),
    );
  }

  static String _transactionTypeToString(BalanceTransactionType type) {
    switch (type) {
      case BalanceTransactionType.topup:
        return 'topup';
      case BalanceTransactionType.deduction:
        return 'deduction';
      case BalanceTransactionType.refund:
        return 'refund';
      case BalanceTransactionType.reservation:
        return 'reservation';
    }
  }

  static BalanceTransactionType _parseTransactionType(String type) {
    switch (type) {
      case 'topup':
        return BalanceTransactionType.topup;
      case 'deduction':
        return BalanceTransactionType.deduction;
      case 'refund':
        return BalanceTransactionType.refund;
      case 'reservation':
        return BalanceTransactionType.reservation;
      default:
        return BalanceTransactionType.deduction;
    }
  }
}
