import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/ride.dart';

/// Reusable status badge widget
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSpacing.iconXs, color: color),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Factory constructor for availability status
  factory StatusBadge.availability(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return const StatusBadge(
          text: 'Available',
          color: AppColors.available,
          icon: Icons.check_circle,
        );
      case AvailabilityStatus.busy:
        return const StatusBadge(
          text: 'Busy',
          color: AppColors.busy,
          icon: Icons.access_time,
        );
      case AvailabilityStatus.offline:
        return const StatusBadge(
          text: 'Offline',
          color: AppColors.offline,
          icon: Icons.cancel,
        );
    }
  }

  /// Factory constructor for ride status
  factory StatusBadge.ride(RideStatus status) {
    switch (status) {
      case RideStatus.pending:
        return const StatusBadge(
          text: 'Pending',
          color: AppColors.pending,
          icon: Icons.hourglass_empty,
        );
      case RideStatus.accepted:
        return const StatusBadge(
          text: 'Accepted',
          color: AppColors.accepted,
          icon: Icons.check,
        );
      case RideStatus.enroute:
        return const StatusBadge(
          text: 'En Route',
          color: AppColors.enroute,
          icon: Icons.directions_car,
        );
      case RideStatus.arrived:
        return const StatusBadge(
          text: 'Arrived',
          color: AppColors.arrived,
          icon: Icons.location_on,
        );
      case RideStatus.completed:
        return const StatusBadge(
          text: 'Completed',
          color: AppColors.completed,
          icon: Icons.check_circle,
        );
      case RideStatus.cancelled:
        return const StatusBadge(
          text: 'Cancelled',
          color: AppColors.cancelled,
          icon: Icons.cancel,
        );
      case RideStatus.noDriverFound:
        return const StatusBadge(
          text: 'No Driver Found',
          color: AppColors.error,
          icon: Icons.error_outline,
        );
    }
  }
}
