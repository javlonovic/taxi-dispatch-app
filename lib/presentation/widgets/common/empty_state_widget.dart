import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Reusable empty state widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: AppTextStyles.h5,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: onAction,
                  child: Text(actionText!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Empty state for ride history
  factory EmptyStateWidget.rideHistory({VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.history,
      title: 'No Ride History',
      message: 'You haven\'t completed any rides yet. Your ride history will appear here.',
      actionText: onAction != null ? 'Request a Ride' : null,
      onAction: onAction,
    );
  }

  /// Empty state for notifications
  factory EmptyStateWidget.notifications() {
    return const EmptyStateWidget(
      icon: Icons.notifications_none,
      title: 'No Notifications',
      message: 'You\'re all caught up! New notifications will appear here.',
    );
  }

  /// Empty state for available drivers
  factory EmptyStateWidget.noDrivers({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Drivers Available',
      message: 'There are no drivers available in your area right now. Please try again later.',
      actionText: onRefresh != null ? 'Refresh' : null,
      onAction: onRefresh,
    );
  }

  /// Empty state for messages
  factory EmptyStateWidget.messages() {
    return const EmptyStateWidget(
      icon: Icons.chat_bubble_outline,
      title: 'No Messages',
      message: 'Start a conversation to see messages here.',
    );
  }

  /// Empty state for search results
  factory EmptyStateWidget.searchResults({VoidCallback? onClear}) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: 'We couldn\'t find any matches for your search. Try different keywords.',
      actionText: onClear != null ? 'Clear Search' : null,
      onAction: onClear,
    );
  }

  /// Empty state for earnings
  factory EmptyStateWidget.earnings() {
    return const EmptyStateWidget(
      icon: Icons.account_balance_wallet_outlined,
      title: 'No Earnings Yet',
      message: 'Complete rides to start earning. Your earnings will be displayed here.',
    );
  }

  /// Empty state for payment methods
  factory EmptyStateWidget.paymentMethods({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      icon: Icons.credit_card,
      title: 'No Payment Methods',
      message: 'Add a payment method to start requesting rides.',
      actionText: onAdd != null ? 'Add Payment Method' : null,
      onAction: onAdd,
    );
  }

  /// Empty state for active rides
  factory EmptyStateWidget.activeRides({VoidCallback? onRequest}) {
    return EmptyStateWidget(
      icon: Icons.directions_car_outlined,
      title: 'No Active Rides',
      message: 'You don\'t have any active rides at the moment.',
      actionText: onRequest != null ? 'Request a Ride' : null,
      onAction: onRequest,
    );
  }
}

/// Compact empty state for lists
class CompactEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const CompactEmptyState({
    Key? key,
    required this.icon,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
