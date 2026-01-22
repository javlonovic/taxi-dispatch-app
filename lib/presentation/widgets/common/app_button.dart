import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';

/// Reusable primary button widget
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  const AppButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = isLoading
        ? ElevatedButton(
            onPressed: null,
            child: const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          )
        : icon != null
            ? ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(text),
              )
            : ElevatedButton(
                onPressed: onPressed,
                child: Text(text),
              );

    return fullWidth
        ? SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: button,
          )
        : SizedBox(
            height: AppSpacing.buttonHeight,
            child: button,
          );
  }
}

/// Reusable secondary button widget
class AppOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  const AppOutlinedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = isLoading
        ? OutlinedButton(
            onPressed: null,
            child: const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        : icon != null
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(text),
              )
            : OutlinedButton(
                onPressed: onPressed,
                child: Text(text),
              );

    return fullWidth
        ? SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: button,
          )
        : SizedBox(
            height: AppSpacing.buttonHeight,
            child: button,
          );
  }
}

/// Reusable text button widget
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const AppTextButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return icon != null
        ? TextButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(text),
          )
        : TextButton(
            onPressed: onPressed,
            child: Text(text),
          );
  }
}
