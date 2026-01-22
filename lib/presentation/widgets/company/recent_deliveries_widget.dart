import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taxi_dispatch_app/l10n/app_localizations.dart';
import '../../../domain/entities/ride.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../common/status_badge.dart';
import '../common/empty_state_widget.dart';

/// Widget that displays recent deliveries on the company dashboard
/// Shows a summary of the last few deliveries with status badges
class RecentDeliveriesWidget extends StatelessWidget {
  final List<Ride> deliveries;
  final VoidCallback? onViewAll;

  const RecentDeliveriesWidget({
    super.key,
    required this.deliveries,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (deliveries.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.history,
        title: l10n.noOrdersYet,
        message: 'Ваши заказы появятся здесь после создания',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentOrders,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: Text(l10n.viewDetails),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...deliveries.map((delivery) => DeliveryCard(
              delivery: delivery,
              onTap: () => _navigateToDetails(context, delivery),
            )),
      ],
    );
  }

  void _navigateToDetails(BuildContext context, Ride delivery) {
    // Navigate to delivery details screen
    // This will be implemented when the details screen is created
  }
}

/// Card widget for displaying a single delivery in the list
class DeliveryCard extends StatelessWidget {
  final Ride delivery;
  final VoidCallback? onTap;

  const DeliveryCard({
    super.key,
    required this.delivery,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM, HH:mm', 'ru_RU');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dateFormat.format(delivery.requestedAt),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  StatusBadge.ride(delivery.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildAddressRow(
                context,
                Icons.location_on_outlined,
                delivery.pickupAddress,
                AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.xs),
              _buildAddressRow(
                context,
                Icons.location_on,
                delivery.destinationAddress ?? 'Не указан',
                AppColors.error,
              ),
              if (delivery.fare != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Стоимость:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${delivery.fare!.toStringAsFixed(0)} ₽',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressRow(
    BuildContext context,
    IconData icon,
    String address,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            address,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
