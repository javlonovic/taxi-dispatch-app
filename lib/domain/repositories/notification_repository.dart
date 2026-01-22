import 'package:firebase_messaging/firebase_messaging.dart';

/// Notification repository interface
abstract class NotificationRepository {
  /// Initialize notifications
  Future<void> initializeNotifications();

  /// Get device FCM token
  Future<String> getDeviceToken();

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic);

  /// Send notification to a user
  Future<void> sendNotification(String userId, NotificationData data);

  /// Stream of received messages
  Stream<RemoteMessage> get onMessageReceived;
}

/// Notification data
class NotificationData {
  final String title;
  final String body;
  final Map<String, dynamic>? data;

  NotificationData({
    required this.title,
    required this.body,
    this.data,
  });
}
