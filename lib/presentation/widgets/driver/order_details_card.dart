import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/ride.dart';

/// Order details card widget for driver notifications
/// Displays comprehensive delivery information with accept/skip actions
class OrderDetailsCard extends StatelessWidget {
  final Ride order;
  final VoidCallback onSkip;
  final VoidCallback onAccept;

  const OrderDetailsCard({
    super.key,
    required this.order,
    required this.onSkip,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Новый заказ',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Company info
            _buildInfoRow(
              context,
              icon: Icons.business,
              label: 'Компания',
              value: order.companyName ?? 'Компания',
            ),
            _buildInfoRow(
              context,
              icon: Icons.phone,
              label: 'Телефон компании',
              value: order.companyPhone ?? '',
              isCallable: true,
            ),

            const SizedBox(height: 16),

            // Pickup info
            _buildInfoRow(
              context,
              icon: Icons.location_on,
              label: 'Откуда',
              value: order.pickupAddress,
            ),

            // Delivery info
            _buildInfoRow(
              context,
              icon: Icons.flag,
              label: 'Куда',
              value: order.destinationAddress ?? '',
            ),

            const SizedBox(height: 16),

            // Recipient info
            if (order.recipientName != null) ...[
              _buildInfoRow(
                context,
                icon: Icons.person,
                label: 'Получатель',
                value: order.recipientName!,
              ),
            ],
            if (order.recipientPhone != null) ...[
              _buildInfoRow(
                context,
                icon: Icons.phone,
                label: 'Телефон получателя',
                value: order.recipientPhone!,
                isCallable: true,
              ),
            ],

            // Scheduled time (if not immediate)
            if (order.readyInMinutes > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Готов через ${order.readyInMinutes} мин',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkip,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Пропустить'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Принять заказ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isCallable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isCallable && value.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _makeCall(value),
            ),
        ],
      ),
    );
  }

  void _makeCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
