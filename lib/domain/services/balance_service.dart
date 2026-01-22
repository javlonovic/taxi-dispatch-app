import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/exceptions/app_exception.dart';

/// Service for managing company balance operations
/// Handles balance checks, reservations, deductions, and additions
class BalanceService {
  final FirebaseFirestore _firestore;

  BalanceService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Check if company has sufficient balance for a transaction
  /// Returns true if balance >= amount
  Future<bool> hasSufficientBalance(String companyId, double amount) async {
    try {
      final doc = await _firestore.collection('users').doc(companyId).get();
      
      if (!doc.exists) {
        throw GeneralException('Company not found');
      }

      final data = doc.data()!;
      final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
      
      return balance >= amount;
    } catch (e) {
      throw GeneralException('Failed to check balance: $e');
    }
  }

  /// Get current balance for a company
  Future<double> getBalance(String companyId) async {
    try {
      final doc = await _firestore.collection('users').doc(companyId).get();
      
      if (!doc.exists) {
        throw GeneralException('Company not found');
      }

      final data = doc.data()!;
      return (data['balance'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw GeneralException('Failed to get balance: $e');
    }
  }

  /// Get reserved balance for a company
  Future<double> getReservedBalance(String companyId) async {
    try {
      final doc = await _firestore.collection('users').doc(companyId).get();
      
      if (!doc.exists) {
        throw GeneralException('Company not found');
      }

      final data = doc.data()!;
      return (data['reservedBalance'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw GeneralException('Failed to get reserved balance: $e');
    }
  }

  /// Reserve balance for a pending transaction
  /// Decreases balance and increases reservedBalance atomically
  Future<void> reserveBalance(String companyId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection('users').doc(companyId);
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw GeneralException('Company not found');
        }

        final data = doc.data()!;
        final currentBalance = (data['balance'] as num?)?.toDouble() ?? 0.0;
        final currentReserved = (data['reservedBalance'] as num?)?.toDouble() ?? 0.0;

        if (currentBalance < amount) {
          throw GeneralException('Insufficient balance');
        }

        transaction.update(docRef, {
          'balance': currentBalance - amount,
          'reservedBalance': currentReserved + amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      if (e is GeneralException) rethrow;
      throw GeneralException('Failed to reserve balance: $e');
    }
  }

  /// Deduct from reserved balance (when transaction completes)
  /// Decreases reservedBalance only
  Future<void> deductReservedBalance(String companyId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection('users').doc(companyId);
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw GeneralException('Company not found');
        }

        final data = doc.data()!;
        final currentReserved = (data['reservedBalance'] as num?)?.toDouble() ?? 0.0;

        if (currentReserved < amount) {
          throw GeneralException('Insufficient reserved balance');
        }

        transaction.update(docRef, {
          'reservedBalance': currentReserved - amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      if (e is GeneralException) rethrow;
      throw GeneralException('Failed to deduct reserved balance: $e');
    }
  }

  /// Refund reserved balance (when transaction is cancelled)
  /// Increases balance and decreases reservedBalance atomically
  Future<void> refundReservedBalance(String companyId, double amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection('users').doc(companyId);
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw GeneralException('Company not found');
        }

        final data = doc.data()!;
        final currentBalance = (data['balance'] as num?)?.toDouble() ?? 0.0;
        final currentReserved = (data['reservedBalance'] as num?)?.toDouble() ?? 0.0;

        if (currentReserved < amount) {
          throw GeneralException('Insufficient reserved balance to refund');
        }

        transaction.update(docRef, {
          'balance': currentBalance + amount,
          'reservedBalance': currentReserved - amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      if (e is GeneralException) rethrow;
      throw GeneralException('Failed to refund reserved balance: $e');
    }
  }

  /// Add balance to company account (admin top-up)
  /// Increases balance only
  Future<void> addBalance(String companyId, double amount) async {
    if (amount <= 0) {
      throw GeneralException('Amount must be positive');
    }

    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection('users').doc(companyId);
        final doc = await transaction.get(docRef);

        if (!doc.exists) {
          throw GeneralException('Company not found');
        }

        final data = doc.data()!;
        final currentBalance = (data['balance'] as num?)?.toDouble() ?? 0.0;

        transaction.update(docRef, {
          'balance': currentBalance + amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      if (e is GeneralException) rethrow;
      throw GeneralException('Failed to add balance: $e');
    }
  }

  /// Get available balance (balance - reservedBalance)
  /// This is the amount that can be used for new transactions
  Future<double> getAvailableBalance(String companyId) async {
    try {
      final doc = await _firestore.collection('users').doc(companyId).get();
      
      if (!doc.exists) {
        throw GeneralException('Company not found');
      }

      final data = doc.data()!;
      final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
      
      return balance;
    } catch (e) {
      throw GeneralException('Failed to get available balance: $e');
    }
  }
}
