import 'package:flutter/material.dart';
import 'package:taxi_dispatch_app/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Banner widget that displays guidance for first-time company users
/// Shows helpful information about how to order their first delivery
class FirstTimeUserBanner extends StatelessWidget {
  final VoidCallback? onDismiss;
  final VoidCallback? onLearnMore;

  const FirstTimeUserBanner({
    super.key,
    this.onDismiss,
    this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.info.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.firstTimeUserBanner,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Нажмите кнопку "Найти такси" ниже, чтобы создать ваш первый заказ. Мы поможем вам на каждом шаге!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
              ),
            ),
            if (onLearnMore != null) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: onLearnMore,
                icon: const Icon(Icons.help_outline, size: 18),
                label: Text(l10n.howToOrder),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.info,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
