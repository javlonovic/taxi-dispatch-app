import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/ride.dart';
import '../../providers/ride_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/repository_providers.dart';
import 'order_details_card.dart';

/// Dialog that shows order details and handles driver acceptance
class OrderDetailsDialog extends ConsumerStatefulWidget {
  final String deliveryId;

  const OrderDetailsDialog({
    super.key,
    required this.deliveryId,
  });

  @override
  ConsumerState<OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends ConsumerState<OrderDetailsDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(rideByIdProvider(widget.deliveryId));

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: rideAsync.when(
        data: (ride) {
          if (ride == null) {
            return _buildErrorContent(context, 'Заказ не найден');
          }

          // Check if order is still available
          if (ride.status != RideStatus.pending) {
            return _buildErrorContent(
              context,
              'Этот заказ уже принят другим водителем',
            );
          }

          return OrderDetailsCard(
            order: ride,
            onSkip: _isProcessing ? () {} : () => _handleSkip(context),
            onAccept: _isProcessing ? () {} : () => _handleAccept(context, ride),
          );
        },
        loading: () => _buildLoadingContent(context),
        error: (error, stack) => _buildErrorContent(
          context,
          'Ошибка загрузки заказа',
        ),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Загрузка заказа...'),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _handleSkip(BuildContext context) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Заказ пропущен'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleAccept(BuildContext context, Ride ride) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Get current user
      final currentUser = await ref.read(currentUserProvider.future);
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Accept the delivery
      await ref.read(rideRepositoryProvider).acceptRide(
            ride.id,
            currentUser.id,
          );

      if (!mounted) return;

      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заказ принят!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to active ride screen
      // Note: Navigation will be handled by the notification handler
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      // Check if order was already accepted by another driver
      final errorMessage = e.toString().contains('already accepted')
          ? 'Этот заказ уже принят другим водителем'
          : 'Не удалось принять заказ. Попробуйте снова.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
