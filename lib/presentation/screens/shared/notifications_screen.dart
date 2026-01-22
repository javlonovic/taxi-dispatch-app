import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notification_provider.dart';
import '../../../data/models/notification_payload.dart';

/// Screen to display all notifications
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notificationState.notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                ref.read(notificationStateProvider.notifier).clearNotifications();
              },
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: notificationState.notifications.isEmpty
          ? _buildEmptyState(context)
          : _buildNotificationList(context, ref, notificationState.notifications),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see notifications here when you receive them',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    WidgetRef ref,
    List<NotificationPayload> notifications,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final notification = notifications[notifications.length - 1 - index];
        return _NotificationCard(
          notification: notification,
          onDismiss: () {
            ref.read(notificationStateProvider.notifier).removeNotification(notification);
          },
        );
      },
    );
  }
}

/// Individual notification card
class _NotificationCard extends StatelessWidget {
  final NotificationPayload notification;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.data.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            // Handle notification tap - could navigate to relevant screen
            _handleNotificationTap(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(context),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.type.displayName,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Text(
                            _formatTime(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                          ),
                        ],
                      ),
                      if (notification.title != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.title!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                      if (notification.body != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.body!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.rideRequest:
        iconData = Icons.local_taxi;
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
      case NotificationType.deliveryRequest:
        // TODO: Handle this case.
        throw UnimplementedError();
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

  String _formatTime() {
    // Since we don't have timestamp in payload, show "Just now"
    // In a real app, you'd add timestamp to NotificationPayload
    return 'Just now';
  }

  void _handleNotificationTap(BuildContext context) {
    // Navigation logic would go here
    // Similar to NotificationHandler._navigateToNotificationDestination
  }
}
