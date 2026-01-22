import 'package:flutter/material.dart';

/// Widget for selecting when the delivery will be ready for pickup
/// Provides options: Now, 15 min, 30 min, 45 min, 60 min
class ReadyTimeSelector extends StatelessWidget {
  final List<int> options = const [0, 15, 30, 45, 60]; // minutes
  final int selectedMinutes;
  final ValueChanged<int> onSelected;

  const ReadyTimeSelector({
    super.key,
    required this.selectedMinutes,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Когда готов к отправке?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((minutes) {
            final isSelected = selectedMinutes == minutes;
            return ChoiceChip(
              label: Text(
                minutes == 0 ? 'Сейчас' : '$minutes мин',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onSelected(minutes);
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
            );
          }).toList(),
        ),
        if (selectedMinutes > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Водитель будет уведомлен о времени готовности',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }
}
