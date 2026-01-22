import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/balance_transaction.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/balance_provider.dart';
import '../../widgets/company/balance_transaction_card.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/shimmer_loading.dart';

/// Screen to display balance transaction history
class BalanceHistoryScreen extends ConsumerStatefulWidget {
  const BalanceHistoryScreen({super.key});

  @override
  ConsumerState<BalanceHistoryScreen> createState() =>
      _BalanceHistoryScreenState();
}

class _BalanceHistoryScreenState extends ConsumerState<BalanceHistoryScreen> {
  String? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null || user is! Company) {
          return _buildErrorState(context);
        }

        return _buildHistoryScreen(context, user);
      },
      loading: () => _buildLoadingState(context),
      error: (error, stack) => _buildErrorState(context),
    );
  }

  Widget _buildHistoryScreen(BuildContext context, Company company) {
    final transactionsAsync = _selectedFilter == null
        ? ref.watch(balanceHistoryProvider(company.id))
        : ref.watch(balanceHistoryByTypeProvider((
            companyId: company.id,
            type: _selectedFilter!,
          )));

    return Scaffold(
      appBar: AppBar(
        title: const Text('История баланса'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(balanceHistoryProvider(company.id));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance summary card
          _buildBalanceSummary(context, company),

          // Filter chips
          _buildFilterChips(context),

          const SizedBox(height: AppSpacing.sm),

          // Transaction list
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.history,
                    title: _selectedFilter == null
                        ? 'Нет транзакций'
                        : 'Нет транзакций этого типа',
                    message: 'История транзакций появится здесь',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(balanceHistoryProvider(company.id));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return BalanceTransactionCard(
                        transaction: transaction,
                        onTap: () => _showTransactionDetails(
                          context,
                          transaction,
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const ShimmerList(itemCount: 10),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Не удалось загрузить историю',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () {
                        ref.invalidate(balanceHistoryProvider(company.id));
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSummary(BuildContext context, Company company) {
    final balanceColor = _getBalanceColor(company.balance);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            balanceColor.withValues(alpha: 0.1),
            balanceColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: balanceColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Текущий баланс',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${company.balance.toStringAsFixed(0)} сум',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: balanceColor,
                ),
          ),
          if (company.reservedBalance > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Зарезервировано: ${company.reservedBalance.toStringAsFixed(0)} сум',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Все'),
            selected: _selectedFilter == null,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = null;
              });
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          FilterChip(
            label: const Text('Пополнения'),
            selected: _selectedFilter == 'topup',
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 'topup' : null;
              });
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          FilterChip(
            label: const Text('Списания'),
            selected: _selectedFilter == 'deduction',
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 'deduction' : null;
              });
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          FilterChip(
            label: const Text('Возвраты'),
            selected: _selectedFilter == 'refund',
            onSelected: (selected) {
              setState(() {
                _selectedFilter = selected ? 'refund' : null;
              });
            },
          ),
        ],
      ),
    );
  }

  Color _getBalanceColor(double balance) {
    if (balance >= 100000) {
      return Colors.green;
    } else if (balance >= 50000) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _showTransactionDetails(
    BuildContext context,
    BalanceTransaction transaction,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Детали транзакции',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildDetailRow(context, 'Тип', transaction.title),
            _buildDetailRow(
              context,
              'Сумма',
              '${transaction.isPositive ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} сум',
            ),
            _buildDetailRow(
              context,
              'Баланс до',
              '${transaction.balanceBefore.toStringAsFixed(0)} сум',
            ),
            _buildDetailRow(
              context,
              'Баланс после',
              '${transaction.balanceAfter.toStringAsFixed(0)} сум',
            ),
            if (transaction.rideId != null)
              _buildDetailRow(context, 'ID заказа', transaction.rideId!),
            if (transaction.notes != null)
              _buildDetailRow(context, 'Примечание', transaction.notes!),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История баланса'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История баланса'),
      ),
      body: const Center(
        child: Text('Ошибка загрузки'),
      ),
    );
  }
}
