import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Digital receipt widget
/// Requirements: 11.3, 11.4
class DigitalReceiptWidget extends StatelessWidget {
  final String receiptId;
  final String rideId;
  final double amount;
  final DateTime timestamp;
  final String? pickupAddress;
  final String? destinationAddress;
  final double? distance;
  final int? durationMinutes;

  const DigitalReceiptWidget({
    super.key,
    required this.receiptId,
    required this.rideId,
    required this.amount,
    required this.timestamp,
    this.pickupAddress,
    this.destinationAddress,
    this.distance,
    this.durationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy • hh:mm a');

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.receipt_long, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Digital Receipt',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Receipt details
            _ReceiptRow(label: 'Receipt ID', value: receiptId),
            const SizedBox(height: 12),
            _ReceiptRow(label: 'Ride ID', value: rideId),
            const SizedBox(height: 12),
            _ReceiptRow(label: 'Date', value: dateFormat.format(timestamp)),
            
            if (pickupAddress != null) ...[
              const SizedBox(height: 12),
              _ReceiptRow(label: 'Pickup', value: pickupAddress!),
            ],
            
            if (destinationAddress != null) ...[
              const SizedBox(height: 12),
              _ReceiptRow(label: 'Destination', value: destinationAddress!),
            ],
            
            if (distance != null) ...[
              const SizedBox(height: 12),
              _ReceiptRow(
                label: 'Distance',
                value: '${distance!.toStringAsFixed(2)} km',
              ),
            ],
            
            if (durationMinutes != null) ...[
              const SizedBox(height: 12),
              _ReceiptRow(
                label: 'Duration',
                value: '$durationMinutes minutes',
              ),
            ],

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Total amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Share receipt
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share receipt functionality')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Download receipt
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Download receipt functionality')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Show digital receipt dialog
Future<void> showDigitalReceipt({
  required BuildContext context,
  required String receiptId,
  required String rideId,
  required double amount,
  required DateTime timestamp,
  String? pickupAddress,
  String? destinationAddress,
  double? distance,
  int? durationMinutes,
}) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      child: SingleChildScrollView(
        child: DigitalReceiptWidget(
          receiptId: receiptId,
          rideId: rideId,
          amount: amount,
          timestamp: timestamp,
          pickupAddress: pickupAddress,
          destinationAddress: destinationAddress,
          distance: distance,
          durationMinutes: durationMinutes,
        ),
      ),
    ),
  );
}
