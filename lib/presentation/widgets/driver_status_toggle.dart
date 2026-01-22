import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';

/// Widget for toggling driver active/inactive status
class DriverStatusToggle extends ConsumerWidget {
  final Driver driver;
  final Function(bool) onStatusChanged;

  const DriverStatusToggle({
    super.key,
    required this.driver,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = driver.isActive;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        title: Text(
          'Статус работы',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          isActive
              ? 'Активен - вы получаете заказы'
              : 'Неактивен - вы не получаете заказы',
          style: TextStyle(
            fontSize: 14,
            color: isActive ? Colors.green[700] : Colors.grey[600],
          ),
        ),
        value: isActive,
        activeColor: Colors.green,
        onChanged: (value) => onStatusChanged(value),
        secondary: Icon(
          isActive ? Icons.check_circle : Icons.cancel,
          color: isActive ? Colors.green : Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}
