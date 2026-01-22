import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../core/exceptions/app_exception.dart' show GeneralException;

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
}

/// FCM notification data source
class FCMNotificationDataSource {
  final FirebaseMessaging _messaging;
  final StreamController<RemoteMessage> _messageController;

  FCMNotificationDataSource({
    FirebaseMessaging? messaging,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _messageController = StreamController<RemoteMessage>.broadcast();

  /// Initialize FCM
  Future<void> initialize() async {
    try {
      // Request notification permissions
      final settings = await _requestPermission();
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted provisional notification permission');
      } else {
        debugPrint('User declined or has not accepted notification permission');
      }

      // Set up foreground notification presentation options
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Register background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Received foreground message: ${message.messageId}');
        debugPrint('Title: ${message.notification?.title}');
        debugPrint('Body: ${message.notification?.body}');
        debugPrint('Data: ${message.data}');
        
        _messageController.add(message);
      });

      // Listen to message opened app (from terminated state)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Message opened app: ${message.messageId}');
        _messageController.add(message);
      });

      // Check if app was opened from a notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App opened from notification: ${initialMessage.messageId}');
        _messageController.add(initialMessage);
      }
    } catch (e) {
      throw GeneralException('Failed to initialize FCM: $e');
    }
  }

  /// Request notification permissions
  Future<NotificationSettings> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      return settings;
    } catch (e) {
      throw GeneralException('Failed to request notification permission: $e');
    }
  }

  /// Get FCM device token
  Future<String> getDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) {
        throw GeneralException('Failed to get FCM token');
      }
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      throw GeneralException('Failed to get device token: $e');
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      throw GeneralException('Failed to subscribe to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      throw GeneralException('Failed to unsubscribe from topic: $e');
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      debugPrint('FCM token deleted');
    } catch (e) {
      throw GeneralException('Failed to delete token: $e');
    }
  }

  /// Stream of received messages
  Stream<RemoteMessage> get onMessageReceived => _messageController.stream;

  /// Dispose resources
  void dispose() {
    _messageController.close();
  }
}
