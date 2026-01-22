import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/balance_transaction_dto.dart';

/// Firestore datasource for balance transactions
class FirestoreBalanceDatasource {
  final FirebaseFirestore _firestore;

  FirestoreBalanceDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get balance transaction history for a company
  Stream<List<BalanceTransactionDto>> getBalanceHistory(String companyId) {
    return _firestore
        .collection('balanceTransactions')
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BalanceTransactionDto.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Get a single balance transaction
  Future<BalanceTransactionDto?> getTransaction(String transactionId) async {
    final doc = await _firestore
        .collection('balanceTransactions')
        .doc(transactionId)
        .get();

    if (!doc.exists) return null;

    return BalanceTransactionDto.fromMap(doc.id, doc.data()!);
  }

  /// Create a balance transaction record
  Future<String> createTransaction(BalanceTransactionDto transaction) async {
    final docRef = await _firestore
        .collection('balanceTransactions')
        .add(transaction.toMap());

    return docRef.id;
  }

  /// Get transactions by type
  Stream<List<BalanceTransactionDto>> getTransactionsByType(
    String companyId,
    String type,
  ) {
    return _firestore
        .collection('balanceTransactions')
        .where('companyId', isEqualTo: companyId)
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BalanceTransactionDto.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Get transactions for a specific ride
  Future<List<BalanceTransactionDto>> getTransactionsForRide(
    String rideId,
  ) async {
    final snapshot = await _firestore
        .collection('balanceTransactions')
        .where('rideId', isEqualTo: rideId)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => BalanceTransactionDto.fromMap(doc.id, doc.data()))
        .toList();
  }
}
