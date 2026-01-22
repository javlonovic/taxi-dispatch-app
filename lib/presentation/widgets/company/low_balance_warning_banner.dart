import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';

/// Warning banner displayed when company balance is low
/// Shows when balance < 50,000 сум
class LowBalanceWarningBanner extends StatelessWidget {
  final double balance;
  final VoidCallback? onTopUp;

  const LowBalanceWarningBanner({
    super.key,
    required this.balance,
    this.onTopUp,
  });

  @override
  Widget build(BuildContext context) {
    // Only show if balance is below 50,000
    if (balance >= 50000) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.orange.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
              size: 32,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Низкий баланс',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Ваш баланс ниже 50,000 сум. Пожалуйста, пополните счет для продолжения заказов.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade800,
                        ),
                  ),
                  if (onTopUp != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    TextButton.icon(
                      onPressed: onTopUp,
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Связаться с колл-центром'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange.shade900,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
