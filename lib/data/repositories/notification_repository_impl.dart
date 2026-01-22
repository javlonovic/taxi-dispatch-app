import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/fcm_notification_datasource.dart';
import '../../core/exceptions/app_exception.dart' show GeneralException;

/// Notification repository implementation
class NotificationRepositoryImpl implements NotificationRepository {
  final FCMNotificationDataSource _dataSource;
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl({
    required FCMNotificationDataSource dataSource,
    FirebaseFirestore? firestore,
  })  : _dataSource = dataSource,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> initializeNotifications() async {
    try {
      await _dataSource.initialize();
    } catch (e) {
      throw GeneralException('Failed to initialize notifications: $e');
    }
  }

  @override
  Future<String> getDeviceToken() async {
    try {
      return await _dataSource.getDeviceToken();
    } catch (e) {
      throw GeneralException('Failed to get device token: $e');
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _dataSource.subscribeToTopic(topic);
    } catch (e) {
      throw GeneralException('Failed to subscribe to topic: $e');
    }
  }

  @override
  Future<void> sendNotification(String userId, NotificationData data) async {
    try {
      // Get user's FCM token from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        debugPrint('⚠️ User $userId not found for notification');
        return; // Don't throw, just skip
      }

      final fcmToken = userDoc.data()?['fcmToken'] as String?;
      
      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('⚠️ User $userId does not have FCM token - notification skipped');
        return; // Don't throw, just skip - token will be saved on next app start
      }

      // Store notification in Firestore for Cloud Function to process
      // The processNotifications Cloud Function will send it
      await _firestore.collection('notifications').add({
        'userId': userId,
        'fcmToken': fcmToken,
        'title': data.title,
        'body': data.body,
        'data': data.data ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'sent': false,
      });
      
      debugPrint('📤 Notification queued for user $userId (Cloud Function will send)');
    } catch (e) {
      debugPrint('❌ Failed to send notification to user $userId: $e');
      // Don't throw - notifications are not critical for app functionality
    }
  }

  @override
  Stream<RemoteMessage> get onMessageReceived => _dataSource.onMessageReceived;

  /// Save FCM token to user document
  Future<void> saveTokenToUser(String userId) async {
    try {
      final token = await getDeviceToken();
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw GeneralException('Failed to save FCM token: $e');
    }
  }

  /// Remove FCM token from user document
  Future<void> removeTokenFromUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.delete(),
      });
      await _dataSource.deleteToken();
    } catch (e) {
      throw GeneralException('Failed to remove FCM token: $e');
    }
  }
}
