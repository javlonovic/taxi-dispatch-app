import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_spacing.dart';

/// Dialog shown when company has insufficient balance to create a delivery request
/// Displays call center contact information for balance top-up
class InsufficientBalanceDialog extends StatelessWidget {
  final double currentBalance;
  final double requiredAmount;
  final String callCenterPhone;

  const InsufficientBalanceDialog({
    super.key,
    required this.currentBalance,
    required this.requiredAmount,
    this.callCenterPhone = '+998 XX XXX XX XX',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 28,
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text('Недостаточно средств'),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ваш текущий баланс недостаточен для создания заказа.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildBalanceInfo(
            context,
            'Текущий баланс:',
            '${currentBalance.toStringAsFixed(0)} сум',
            Colors.red,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildBalanceInfo(
            context,
            'Требуется:',
            '${requiredAmount.toStringAsFixed(0)} сум',
            Colors.grey,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.shade200,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Колл-центр',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Для пополнения баланса свяжитесь с нашим колл-центром:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade800,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                InkWell(
                  onTap: () => _copyPhoneNumber(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          callCenterPhone,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          Icons.copy,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }

  Widget _buildBalanceInfo(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
      ],
    );
  }

  void _copyPhoneNumber(BuildContext context) {
    Clipboard.setData(ClipboardData(text: callCenterPhone));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Номер телефона скопирован'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Show the insufficient balance dialog
  static Future<void> show(
    BuildContext context, {
    required double currentBalance,
    required double requiredAmount,
    String callCenterPhone = '+998 XX XXX XX XX',
  }) {
    return showDialog(
      context: context,
      builder: (context) => InsufficientBalanceDialog(
        currentBalance: currentBalance,
        requiredAmount: requiredAmount,
        callCenterPhone: callCenterPhone,
      ),
    );
  }
}
