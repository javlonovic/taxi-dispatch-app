import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/notification_provider.dart';
import '../../data/models/notification_payload.dart';
import 'driver/order_details_dialog.dart';
import 'ride_request_dialog.dart';
import 'delivery_request_dialog.dart';

/// Widget that handles notification navigation and display
class NotificationHandler extends ConsumerStatefulWidget {
  final Widget child;

  const NotificationHandler({super.key, required this.child});

  @override
  ConsumerState<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends ConsumerState<NotificationHandler> {
  @override
  void initState() {
    super.initState();
    
    // Listen to notification state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNotificationListener();
    });
  }

  void _setupNotificationListener() {
    ref.listen<NotificationState>(
      notificationStateProvider,
      (previous, next) {
        if (next.lastNotification != null && previous?.lastNotification != next.lastNotification) {
          _handleNotification(next.lastNotification!);
        }
      },
    );
  }

  void _handleNotification(NotificationPayload payload) {
    // For ride requests, show dialog immediately
    if (payload.type == NotificationType.rideRequest && payload.rideId != null) {
      _showRideRequestDialog(payload);
    }
    // For delivery requests, show new delivery dialog
    else if (payload.type == NotificationType.deliveryRequest && payload.data?['deliveryId'] != null) {
      _showDeliveryRequestDialog(payload);
    } else {
      // Show in-app banner for other notifications
      _showNotificationBanner(payload);
    }
  }

  void _showDeliveryRequestDialog(NotificationPayload payload) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeliveryRequestDialog(
        deliveryId: payload.data!['deliveryId']!,
        pickupAddress: payload.data?['pickupAddress'] ?? 'Unknown',
        deliveryAddress: payload.data?['deliveryAddress'] ?? 'Unknown',
        itemDescription: payload.data?['itemDescription'] ?? 'Unknown',
        recipientName: payload.data?['recipientName'] ?? 'Unknown',
        recipientPhone: payload.data?['recipientPhone'] ?? 'Unknown',
        companyName: payload.data?['companyName'] ?? 'Unknown Company',
      ),
    );
  }

  void _showRideRequestDialog(NotificationPayload payload) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RideRequestDialog(
        rideId: payload.rideId!,
        pickupAddress: payload.data?['pickupAddress'] ?? 'Unknown',
        destinationAddress: payload.data?['destinationAddress'],
        distance: payload.data?['distance'],
        companyName: payload.data?['companyName'] ?? 'Unknown Company',
      ),
    );
  }

  void _showOrderDetailsDialog(String deliveryId) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OrderDetailsDialog(deliveryId: deliveryId),
    );
  }

  void _showNotificationBanner(NotificationPayload payload) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: InAppNotificationBanner(
          payload: payload,
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            _navigateToNotificationDestination(payload);
          },
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _navigateToNotificationDestination(NotificationPayload payload) {
    if (!mounted) return;

    switch (payload.type) {
      case NotificationType.rideRequest:
        // Navigate to active ride screen for drivers
        if (payload.rideId != null) {
          context.push('/active-ride?rideId=${payload.rideId}');
        }
        break;

      case NotificationType.deliveryRequest:
        // Show order details dialog for drivers
        if (payload.deliveryId != null) {
          _showOrderDetailsDialog(payload.deliveryId!);
        }
        break;

      case NotificationType.rideAccepted:
        // Navigate to tracking screen for company users
        if (payload.rideId != null) {
          context.push('/tracking?rideId=${payload.rideId}');
        }
        break;

      case NotificationType.driverArrived:
        // Navigate to tracking screen
        if (payload.rideId != null) {
          context.push('/tracking?rideId=${payload.rideId}');
        }
        break;

      case NotificationType.tripCompleted:
        // Navigate to rating screen
        if (payload.rideId != null) {
          final otherUserName = payload.data['otherUserName'] ?? 'User';
          final otherUserPhotoUrl = payload.data['otherUserPhotoUrl'];
          final isRatingDriver = payload.data['isRatingDriver'] == 'true';
          context.push(
            '/rating?rideId=${payload.rideId}&otherUserName=$otherUserName'
            '${otherUserPhotoUrl != null ? '&otherUserPhotoUrl=$otherUserPhotoUrl' : ''}'
            '&isRatingDriver=$isRatingDriver',
          );
        }
        break;

      case NotificationType.paymentConfirmed:
        // Navigate to transaction history
        context.push('/transaction-history');
        break;

      case NotificationType.newMessage:
        // Navigate to chat screen
        if (payload.rideId != null) {
          final otherUserId = payload.data['otherUserId'] ?? '';
          final otherUserName = payload.data['otherUserName'] ?? 'User';
          context.push(
            '/chat?rideId=${payload.rideId}&otherUserId=$otherUserId&otherUserName=$otherUserName',
          );
        }
        break;

      case NotificationType.ratingReceived:
        // Navigate to notifications screen to see all ratings
        context.push('/notifications');
        break;

      case NotificationType.general:
        // Navigate to notifications screen
        context.push('/notifications');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// In-app notification banner widget
class InAppNotificationBanner extends StatelessWidget {
  final NotificationPayload payload;
  final VoidCallback? onTap;

  const InAppNotificationBanner({
    super.key,
    required this.payload,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildIcon(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (payload.title != null)
                      Text(
                        payload.title!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (payload.body != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        payload.body!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (payload.type) {
      case NotificationType.rideRequest:
        iconData = Icons.local_taxi;
        iconColor = Colors.blue;
        break;
      case NotificationType.deliveryRequest:
        iconData = Icons.local_shipping;
        iconColor = Colors.blue;
        break;
      case NotificationType.rideAccepted:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case NotificationType.driverArrived:
        iconData = Icons.location_on;
        iconColor = Colors.orange;
        break;
      case NotificationType.tripCompleted:
        iconData = Icons.flag;
        iconColor = Colors.purple;
        break;
      case NotificationType.paymentConfirmed:
        iconData = Icons.payment;
        iconColor = Colors.teal;
        break;
      case NotificationType.newMessage:
        iconData = Icons.message;
        iconColor = Colors.indigo;
        break;
      case NotificationType.ratingReceived:
        iconData = Icons.star;
        iconColor = Colors.amber;
        break;
      case NotificationType.general:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }
}
