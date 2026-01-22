import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/exceptions/app_exception.dart';

/// Error dialog widget with retry mechanism
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final IconData? icon;

  const ErrorDialog({
    Key? key,
    this.title = 'Error',
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: AppSpacing.iconXl,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDismiss != null)
                  TextButton(
                    onPressed: onDismiss ?? () => Navigator.of(context).pop(),
                    child: const Text('Dismiss'),
                  ),
                if (onRetry != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRetry?.call();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show error dialog
  static Future<void> show(
    BuildContext context, {
    String title = 'Error',
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    IconData? icon,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        onRetry: onRetry,
        onDismiss: onDismiss,
        icon: icon,
      ),
    );
  }

  /// Show error dialog from exception
  static Future<void> showFromException(
    BuildContext context,
    Exception exception, {
    VoidCallback? onRetry,
  }) {
    String title = 'Error';
    String message = 'An unexpected error occurred. Please try again.';
    IconData icon = Icons.error_outline;

    if (exception is AppException) {
      message = exception.message;
      
      if (exception is AuthException) {
        title = 'Authentication Error';
        icon = Icons.lock_outline;
      } else if (exception is NetworkException) {
        title = 'Network Error';
        message = 'Please check your internet connection and try again.';
        icon = Icons.wifi_off;
      } else if (exception is LocationException) {
        title = 'Location Error';
        icon = Icons.location_off;
      } else if (exception is PaymentException) {
        title = 'Payment Error';
        icon = Icons.payment;
      }
    }

    return show(
      context,
      title: title,
      message: message,
      onRetry: onRetry,
      icon: icon,
    );
  }
}

/// Confirmation dialog with custom actions
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          style: isDestructive
              ? ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                )
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// Show confirmation dialog
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDestructive: isDestructive,
      ),
    );
  }
}
