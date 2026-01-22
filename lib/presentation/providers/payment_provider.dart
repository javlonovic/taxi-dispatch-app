import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../data/repositories/payment_repository_impl.dart';
import 'repository_providers.dart';

/// Payment methods provider
final paymentMethodsProvider = FutureProvider.family<List<PaymentMethod>, String>((ref, userId) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return await repository.getPaymentMethods(userId);
});

/// Transaction history provider
final transactionHistoryProvider = FutureProvider.family<List<Transaction>, String>((ref, userId) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return await repository.getTransactionHistory(userId);
});

/// Driver earnings provider
final driverEarningsProvider = FutureProvider.family<double, String>((ref, driverId) async {
  final repository = ref.watch(paymentRepositoryProvider) as PaymentRepositoryImpl;
  return await repository.getDriverEarnings(driverId);
});
