import 'package:flutter/foundation.dart';
import '../repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';

/// Service for managing notifications
class NotificationService {
  final NotificationRepository _repository;

  NotificationService(this._repository);

  /// Initialize notifications and save token for user
  Future<void> initializeForUser(String userId) async {
    try {
      await _repository.initializeNotifications();
      
      // Save FCM token to user document
      if (_repository is NotificationRepositoryImpl) {
        await (_repository as NotificationRepositoryImpl).saveTokenToUser(userId);
      }
    } catch (e) {
      // Log error but don't throw - notifications are not critical
      // TODO: Use proper logging service
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  /// Remove token when user logs out
  Future<void> cleanupForUser(String userId) async {
    try {
      if (_repository is NotificationRepositoryImpl) {
        await (_repository as NotificationRepositoryImpl).removeTokenFromUser(userId);
      }
    } catch (e) {
      debugPrint('Failed to cleanup notifications: $e');
    }
  }

  /// Subscribe to user-specific topic
  Future<void> subscribeToUserTopic(String userId) async {
    try {
      await _repository.subscribeToTopic('user_$userId');
    } catch (e) {
      debugPrint('Failed to subscribe to user topic: $e');
    }
  }

  /// Subscribe to driver-specific topics
  Future<void> subscribeToDriverTopics() async {
    try {
      await _repository.subscribeToTopic('drivers');
      await _repository.subscribeToTopic('ride_requests');
    } catch (e) {
      debugPrint('Failed to subscribe to driver topics: $e');
    }
  }

  /// Subscribe to company-specific topics
  Future<void> subscribeToCompanyTopics() async {
    try {
      await _repository.subscribeToTopic('companies');
    } catch (e) {
      debugPrint('Failed to subscribe to company topics: $e');
    }
  }

  /// Send notification to a specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationData = NotificationData(
        title: title,
        body: body,
        data: data,
      );
      await _repository.sendNotification(userId, notificationData);
    } catch (e) {
      debugPrint('Failed to send notification to user $userId: $e');
    }
  }
}
