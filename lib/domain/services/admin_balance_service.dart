import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/exceptions/app_exception.dart';
import '../../data/models/top_up_record_dto.dart';
import '../../data/models/payment_dto.dart';
import 'balance_service.dart';

/// Service for admin balance operations
/// Handles balance top-ups, transaction logging, and notifications
class AdminBalanceService {
  final FirebaseFirestore _firestore;
  final BalanceService _balanceService;

  AdminBalanceService({
    FirebaseFirestore? firestore,
    BalanceService? balanceService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _balanceService = balanceService ?? BalanceService();

  /// Top up company balance
  /// Records transaction, creates top-up record, and sends notification
  Future<void> topUpBalance({
    required String companyId,
    required String adminId,
    required double amount,
    String? notes,
    String? adminName,
    String? companyName,
  }) async {
    // Validate amount
    if (amount < 10000) {
      throw ValidationException('Минимальная сумма пополнения: 10,000 сум');
    }
    if (amount > 10000000) {
      throw ValidationException('Максимальная сумма пополнения: 10,000,000 сум');
    }

    try {
      // Get current balance before top-up
      final oldBalance = await _balanceService.getBalance(companyId);

      // Add balance using BalanceService
      await _balanceService.addBalance(companyId, amount);

      // Create top-up record
      await _createTopUpRecord(
        companyId: companyId,
        adminId: adminId,
        amount: amount,
        notes: notes,
        adminName: adminName,
        companyName: companyName,
      );

      // Record transaction in company transaction history
      await _recordTransaction(
        companyId: companyId,
        amount: amount,
        oldBalance: oldBalance,
        newBalance: oldBalance + amount,
        adminName: adminName,
      );

      // Send notification to company
      await _sendTopUpNotification(
        companyId: companyId,
        amount: amount,
        newBalance: oldBalance + amount,
      );

      // Log admin activity
      await _logAdminActivity(
        adminId: adminId,
        action: 'balance_topup',
        companyId: companyId,
        amount: amount,
        notes: notes,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw GeneralException('Не удалось пополнить баланс: $e');
    }
  }

  /// Create top-up record in Firestore
  Future<void> _createTopUpRecord({
    required String companyId,
    required String adminId,
    required double amount,
    String? notes,
    String? adminName,
    String? companyName,
  }) async {
    final record = TopUpRecordDto(
      id: '',
      companyId: companyId,
      adminId: adminId,
      amount: amount,
      timestamp: Timestamp.now(),
      notes: notes,
      adminName: adminName,
      companyName: companyName,
    );

    await _firestore.collection('topUpRecords').add(record.toFirestore());
  }

  /// Record transaction in company transaction history
  Future<void> _recordTransaction({
    required String companyId,
    required double amount,
    required double oldBalance,
    required double newBalance,
    String? adminName,
  }) async {
    final transaction = TransactionDto(
      id: '',
      userId: companyId,
      amount: amount,
      timestamp: DateTime.now(),
      type: 'balance_topup',
      description: 'Пополнение баланса${adminName != null ? ' (Администратор: $adminName)' : ''}. Старый баланс: ${oldBalance.toStringAsFixed(0)} сум, Новый баланс: ${newBalance.toStringAsFixed(0)} сум',
    );

    await _firestore
        .collection('users')
        .doc(companyId)
        .collection('transactions')
        .add(transaction.toFirestore());
  }

  /// Send notification to company about balance top-up
  Future<void> _sendTopUpNotification({
    required String companyId,
    required double amount,
    required double newBalance,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': companyId,
      'type': 'balance_topup',
      'title': 'Баланс пополнен',
      'body': 'Ваш баланс пополнен на ${amount.toStringAsFixed(0)} сум. Текущий баланс: ${newBalance.toStringAsFixed(0)} сум',
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'data': {
        'amount': amount,
        'newBalance': newBalance,
      },
    });
  }

  /// Log admin activity
  Future<void> _logAdminActivity({
    required String adminId,
    required String action,
    required String companyId,
    required double amount,
    String? notes,
  }) async {
    await _firestore.collection('adminActivityLog').add({
      'adminId': adminId,
      'action': action,
      'companyId': companyId,
      'amount': amount,
      'notes': notes,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Get top-up records for a company
  Future<List<TopUpRecord>> getCompanyTopUpRecords(String companyId) async {
    try {
      final snapshot = await _firestore
          .collection('topUpRecords')
          .where('companyId', isEqualTo: companyId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TopUpRecordDto.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw GeneralException('Не удалось загрузить записи пополнения: $e');
    }
  }

  /// Get all top-up records (admin view)
  Future<List<TopUpRecord>> getAllTopUpRecords({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('topUpRecords')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => TopUpRecordDto.fromFirestore(doc).toEntity())
          .toList();
    } catch (e) {
      throw GeneralException('Не удалось загрузить записи пополнения: $e');
    }
  }

  /// Get admin activity log
  Future<List<Map<String, dynamic>>> getAdminActivityLog({
    String? adminId,
    int limit = 100,
  }) async {
    try {
      var query = _firestore
          .collection('adminActivityLog')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (adminId != null) {
        query = query.where('adminId', isEqualTo: adminId);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw GeneralException('Не удалось загрузить журнал активности: $e');
    }
  }

  /// Search companies by name or username
  Future<List<Map<String, dynamic>>> searchCompanies(String query) async {
    try {
      if (query.isEmpty) {
        // Return recent companies if no query
        final snapshot = await _firestore
            .collection('users')
            .where('type', isEqualTo: 'company')
            .orderBy('createdAt', descending: true)
            .limit(20)
            .get();

        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      }

      // Search by company name or username
      final queryLower = query.toLowerCase();
      
      final snapshot = await _firestore
          .collection('users')
          .where('type', isEqualTo: 'company')
          .get();

      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            final companyName = (data['companyName'] as String?)?.toLowerCase() ?? '';
            final username = (data['username'] as String?)?.toLowerCase() ?? '';
            return companyName.contains(queryLower) || username.contains(queryLower);
          })
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .take(20)
          .toList();
    } catch (e) {
      throw GeneralException('Не удалось найти компании: $e');
    }
  }
}
