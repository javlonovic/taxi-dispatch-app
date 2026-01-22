import 'package:flutter/material.dart';

/// Confirmation dialog for driver status changes
class DriverStatusConfirmationDialog extends StatelessWidget {
  final bool newStatus;
  final VoidCallback onConfirm;

  const DriverStatusConfirmationDialog({
    super.key,
    required this.newStatus,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Изменить статус?'),
      content: Text(
        newStatus
            ? 'Вы начнете получать уведомления о новых заказах в радиусе 5-6 км'
            : 'Вы перестанете получать заказы. Вы сможете включить статус в любое время.',
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: newStatus ? Colors.green : Colors.grey,
          ),
          child: const Text('Подтвердить'),
        ),
      ],
    );
  }

  /// Show the confirmation dialog
  static Future<bool?> show(
    BuildContext context,
    bool newStatus,
    VoidCallback onConfirm,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DriverStatusConfirmationDialog(
        newStatus: newStatus,
        onConfirm: onConfirm,
      ),
    );
  }
}
