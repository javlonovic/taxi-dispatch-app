import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/models/notification_payload.dart';
import 'repository_providers.dart';

/// Stream provider for received messages
final notificationStreamProvider = StreamProvider<RemoteMessage>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.onMessageReceived;
});

/// State notifier for notification handling
class NotificationState {
  final NotificationPayload? lastNotification;
  final bool hasUnread;
  final List<NotificationPayload> notifications;

  NotificationState({
    this.lastNotification,
    this.hasUnread = false,
    this.notifications = const [],
  });

  NotificationState copyWith({
    NotificationPayload? lastNotification,
    bool? hasUnread,
    List<NotificationPayload>? notifications,
  }) {
    return NotificationState(
      lastNotification: lastNotification ?? this.lastNotification,
      hasUnread: hasUnread ?? this.hasUnread,
      notifications: notifications ?? this.notifications,
    );
  }
}

/// Notification state notifier
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository) : super(NotificationState()) {
    _listenToNotifications();
  }

  void _listenToNotifications() {
    _repository.onMessageReceived.listen((message) {
      final payload = NotificationPayload.fromRemoteMessage(message);
      
      // Add to notifications list
      final updatedNotifications = [...state.notifications, payload];
      
      state = state.copyWith(
        lastNotification: payload,
        hasUnread: true,
        notifications: updatedNotifications,
      );
    });
  }

  /// Mark notifications as read
  void markAsRead() {
    state = state.copyWith(hasUnread: false);
  }

  /// Clear all notifications
  void clearNotifications() {
    state = NotificationState();
  }

  /// Remove a specific notification
  void removeNotification(NotificationPayload notification) {
    final updatedNotifications = state.notifications
        .where((n) => n != notification)
        .toList();
    
    state = state.copyWith(notifications: updatedNotifications);
  }
}

/// Notification state provider
final notificationStateProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repository);
});

/// Device token provider
final deviceTokenProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return await repository.getDeviceToken();
});
