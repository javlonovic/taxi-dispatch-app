import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/user.dart';
import '../../providers/payment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart' as user_provider;
import '../../widgets/driver_bottom_nav.dart';
import '../../widgets/company_bottom_nav.dart';

/// Transaction history screen
/// Requirements: 11.4
class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Пожалуйста, войдите в систему')),
          );
        }

        final currentUserAsync = ref.watch(user_provider.currentUserProvider(user.id));
        final transactionsAsync = ref.watch(transactionHistoryProvider(user.id));

        return currentUserAsync.when(
          data: (currentUser) {
            if (currentUser == null) {
              return const Scaffold(
                body: Center(child: Text('Пользователь не найден')),
              );
            }

            final isDriver = currentUser.type == UserType.driver;

            return Scaffold(
              appBar: AppBar(
                title: const Text('История транзакций'),
              ),
              body: transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Пока нет транзакций',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _TransactionCard(transaction: transaction);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Ошибка: ${error.toString()}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(transactionHistoryProvider(user.id)),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          ),
              bottomNavigationBar: isDriver
                  ? const DriverBottomNav(currentIndex: 1)
                  : const CompanyBottomNav(currentIndex: 1),
            );
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            body: Center(child: Text('Ошибка: ${error.toString()}')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Ошибка: ${error.toString()}')),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final dynamic transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.amount >= 0;
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPositive ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            isPositive ? Icons.arrow_downward : Icons.arrow_upward,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          _getTransactionTitle(transaction.type),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(dateFormat.format(transaction.timestamp)),
        trailing: Text(
          '${isPositive ? '+' : ''}\${transaction.amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
        onTap: () => _showTransactionDetails(context, transaction),
      ),
    );
  }

  String _getTransactionTitle(String type) {
    switch (type.toLowerCase()) {
      case 'earning':
        return 'Заработок за поездку';
      case 'payment':
        return 'Оплата поездки';
      case 'refund':
        return 'Возврат';
      case 'withdrawal':
        return 'Вывод средств';
      default:
        return type;
    }
  }

  void _showTransactionDetails(BuildContext context, dynamic transaction) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _TransactionDetailsSheet(transaction: transaction),
    );
  }
}

class _TransactionDetailsSheet extends StatelessWidget {
  final dynamic transaction;

  const _TransactionDetailsSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy • hh:mm a');
    final isPositive = transaction.amount >= 0;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Детали транзакции',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _DetailRow(
            label: 'Сумма',
            value: '${isPositive ? '+' : ''}\${transaction.amount.abs().toStringAsFixed(2)}',
            valueColor: isPositive ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          _DetailRow(
            label: 'Тип',
            value: _getTransactionTitle(transaction.type),
          ),
          const SizedBox(height: 16),
          _DetailRow(
            label: 'Дата',
            value: dateFormat.format(transaction.timestamp),
          ),
          const SizedBox(height: 16),
          _DetailRow(
            label: 'ID транзакции',
            value: transaction.id,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Функция загрузки чека')),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Скачать чек'),
            ),
          ),
        ],
      ),
    );
  }

  String _getTransactionTitle(String type) {
    switch (type.toLowerCase()) {
      case 'earning':
        return 'Заработок за поездку';
      case 'payment':
        return 'Оплата поездки';
      case 'refund':
        return 'Возврат';
      case 'withdrawal':
        return 'Вывод средств';
      default:
        return type;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
