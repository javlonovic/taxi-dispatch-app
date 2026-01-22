import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/repository_providers.dart';

/// Payment confirmation dialog
/// Requirements: 11.3
class PaymentConfirmationDialog extends ConsumerStatefulWidget {
  final String rideId;
  final double amount;
  final VoidCallback onSuccess;

  const PaymentConfirmationDialog({
    super.key,
    required this.rideId,
    required this.amount,
    required this.onSuccess,
  });

  @override
  ConsumerState<PaymentConfirmationDialog> createState() => _PaymentConfirmationDialogState();
}

class _PaymentConfirmationDialogState extends ConsumerState<PaymentConfirmationDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Подтвердить оплату'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Стоимость поездки',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Оплата будет обработана с использованием вашего способа оплаты по умолчанию.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _processPayment,
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Подтвердить оплату'),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      final repository = ref.read(paymentRepositoryProvider);
      await repository.processPayment(widget.rideId, widget.amount);

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Оплата успешно обработана'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка оплаты: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Show payment confirmation dialog
Future<void> showPaymentConfirmationDialog({
  required BuildContext context,
  required String rideId,
  required double amount,
  required VoidCallback onSuccess,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PaymentConfirmationDialog(
      rideId: rideId,
      amount: amount,
      onSuccess: onSuccess,
    ),
  );
}
