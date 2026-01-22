import 'package:firebase_messaging/firebase_messaging.dart';

/// Notification payload model
class NotificationPayload {
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final NotificationType type;
  final String? rideId;
  final String? driverId;
  final String? companyId;
  
  // Enhanced delivery request fields
  final String? deliveryId;
  final String? companyName;
  final String? companyPhone;
  final String? pickupAddress;
  final String? deliveryAddress;
  final String? recipientName;
  final String? recipientPhone;
  final String? distance;
  final String? readyInMinutes;
  final String? scheduledPickupTime;

  NotificationPayload({
    this.title,
    this.body,
    required this.data,
    required this.type,
    this.rideId,
    this.driverId,
    this.companyId,
    this.deliveryId,
    this.companyName,
    this.companyPhone,
    this.pickupAddress,
    this.deliveryAddress,
    this.recipientName,
    this.recipientPhone,
    this.distance,
    this.readyInMinutes,
    this.scheduledPickupTime,
  });

  /// Create from RemoteMessage
  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final type = _parseNotificationType(data['type'] as String?);

    return NotificationPayload(
      title: message.notification?.title,
      body: message.notification?.body,
      data: data,
      type: type,
      rideId: data['rideId'] as String?,
      driverId: data['driverId'] as String?,
      companyId: data['companyId'] as String?,
      deliveryId: data['deliveryId'] as String?,
      companyName: data['companyName'] as String?,
      companyPhone: data['companyPhone'] as String?,
      pickupAddress: data['pickupAddress'] as String?,
      deliveryAddress: data['deliveryAddress'] as String?,
      recipientName: data['recipientName'] as String?,
      recipientPhone: data['recipientPhone'] as String?,
      distance: data['distance'] as String?,
      readyInMinutes: data['readyInMinutes'] as String?,
      scheduledPickupTime: data['scheduledPickupTime'] as String?,
    );
  }

  /// Create from data map
  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    final type = _parseNotificationType(map['type'] as String?);

    return NotificationPayload(
      title: map['title'] as String?,
      body: map['body'] as String?,
      data: map['data'] as Map<String, dynamic>? ?? {},
      type: type,
      rideId: map['rideId'] as String?,
      driverId: map['driverId'] as String?,
      companyId: map['companyId'] as String?,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'data': data,
      'type': type.name,
      'rideId': rideId,
      'driverId': driverId,
      'companyId': companyId,
      'deliveryId': deliveryId,
      'companyName': companyName,
      'companyPhone': companyPhone,
      'pickupAddress': pickupAddress,
      'deliveryAddress': deliveryAddress,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'distance': distance,
      'readyInMinutes': readyInMinutes,
      'scheduledPickupTime': scheduledPickupTime,
    };
  }

  /// Parse notification type from string
  static NotificationType _parseNotificationType(String? typeString) {
    if (typeString == null) return NotificationType.general;
    
    try {
      return NotificationType.values.firstWhere(
        (e) => e.name == typeString,
        orElse: () => NotificationType.general,
      );
    } catch (e) {
      return NotificationType.general;
    }
  }
}

/// Notification types
enum NotificationType {
  /// New ride request for drivers
  rideRequest,
  
  /// New delivery request for drivers (enhanced)
  deliveryRequest,
  
  /// Ride accepted by driver
  rideAccepted,
  
  /// Driver arrived at pickup
  driverArrived,
  
  /// Trip completed
  tripCompleted,
  
  /// Payment confirmed
  paymentConfirmed,
  
  /// New message in chat
  newMessage,
  
  /// Rating received
  ratingReceived,
  
  /// General notification
  general,
}

/// Extension for notification type display
extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.rideRequest:
        return 'New Ride Request';
      case NotificationType.deliveryRequest:
        return 'Новый заказ';
      case NotificationType.rideAccepted:
        return 'Ride Accepted';
      case NotificationType.driverArrived:
        return 'Driver Arrived';
      case NotificationType.tripCompleted:
        return 'Trip Completed';
      case NotificationType.paymentConfirmed:
        return 'Payment Confirmed';
      case NotificationType.newMessage:
        return 'New Message';
      case NotificationType.ratingReceived:
        return 'Rating Received';
      case NotificationType.general:
        return 'Notification';
    }
  }
}
