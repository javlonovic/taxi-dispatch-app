import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/ride.dart';
import '../../providers/ride_provider.dart';
import 'searching_animation.dart';
import 'driver_tracking_card.dart';
import 'success_card.dart';
import 'error_card.dart';

/// Widget that displays status-specific UI for delivery tracking
class DeliveryStatusWidget extends ConsumerWidget {
  final String deliveryId;
  final DeliveryStatus status;
  final DateTime requestedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? assignedDriverId;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;

  const DeliveryStatusWidget({
    Key? key,
    required this.deliveryId,
    required this.status,
    required this.requestedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
    this.assignedDriverId,
    this.onCancel,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (status) {
      case DeliveryStatus.searching:
        final searchDuration = DateTime.now().difference(requestedAt).inSeconds;
        return SearchingAnimation(
          searchDuration: searchDuration,
          onCancel: onCancel,
        );

      case DeliveryStatus.driverAssigned:
      case DeliveryStatus.onTheWay:
        if (assignedDriverId == null) {
          return const Center(
            child: Text('Ошибка: водитель не назначен'),
          );
        }
        
        // Fetch the full ride object to pass to DriverTrackingCard
        final rideAsync = ref.watch(rideByIdProvider(deliveryId));
        
        return rideAsync.when(
          data: (ride) {
            if (ride == null) {
              return const Center(
                child: Text('Ошибка: заказ не найден'),
              );
            }
            return DriverTrackingCard(ride: ride);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text('Ошибка загрузки данных: $error'),
          ),
        );

      case DeliveryStatus.delivered:
        return SuccessCard(
          icon: Icons.check_circle,
          title: 'Доставлено!',
          message: 'Заказ успешно доставлен',
          timestamp: deliveredAt,
        );

      case DeliveryStatus.noDriverFound:
        return ErrorCard(
          icon: Icons.error_outline,
          title: 'Водитель не найден',
          message: 'К сожалению, сейчас нет доступных водителей',
          subtitle: 'Попробуйте повторить заказ через несколько минут',
          actionLabel: 'Попробовать снова',
          onAction: onRetry,
        );

      case DeliveryStatus.cancelled:
        return ErrorCard(
          icon: Icons.cancel,
          title: 'Заказ отменен',
          message: cancellationReason ?? 'Заказ был отменен',
          timestamp: cancelledAt,
        );
    }
  }
}
