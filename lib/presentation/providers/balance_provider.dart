import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/firestore_balance_datasource.dart';
import '../../domain/entities/balance_transaction.dart';

/// Provider for balance datasource
final balanceDatasourceProvider = Provider<FirestoreBalanceDatasource>((ref) {
  return FirestoreBalanceDatasource();
});

/// Provider for balance transaction history
final balanceHistoryProvider =
    StreamProvider.family<List<BalanceTransaction>, String>((ref, companyId) {
  final datasource = ref.watch(balanceDatasourceProvider);
  return datasource
      .getBalanceHistory(companyId)
      .map((dtos) => dtos.map((dto) => dto.toEntity()).toList());
});

/// Provider for balance transactions by type
final balanceHistoryByTypeProvider = StreamProvider.family<
    List<BalanceTransaction>,
    ({String companyId, String type})>((ref, params) {
  final datasource = ref.watch(balanceDatasourceProvider);
  return datasource
      .getTransactionsByType(params.companyId, params.type)
      .map((dtos) => dtos.map((dto) => dto.toEntity()).toList());
});

/// Provider for a single transaction
final transactionProvider =
    FutureProvider.family<BalanceTransaction?, String>((ref, transactionId) async {
  final datasource = ref.watch(balanceDatasourceProvider);
  final dto = await datasource.getTransaction(transactionId);
  return dto?.toEntity();
});
