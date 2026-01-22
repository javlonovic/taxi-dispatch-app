import 'package:firebase_analytics/firebase_analytics.dart';

/// Service for tracking analytics events throughout the app
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  // Screen tracking
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // Authentication events
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  // Ride events
  Future<void> logRideRequested({
    required String rideId,
    required String pickupAddress,
  }) async {
    await _analytics.logEvent(
      name: 'ride_requested',
      parameters: {
        'ride_id': rideId,
        'pickup_address': pickupAddress,
      },
    );
  }

  Future<void> logRideAccepted({
    required String rideId,
    required String driverId,
  }) async {
    await _analytics.logEvent(
      name: 'ride_accepted',
      parameters: {
        'ride_id': rideId,
        'driver_id': driverId,
      },
    );
  }

  Future<void> logRideCompleted({
    required String rideId,
    required double fare,
    required double distance,
  }) async {
    await _analytics.logEvent(
      name: 'ride_completed',
      parameters: {
        'ride_id': rideId,
        'fare': fare,
        'distance': distance,
      },
    );
  }

  Future<void> logRideCancelled({
    required String rideId,
    required String reason,
  }) async {
    await _analytics.logEvent(
      name: 'ride_cancelled',
      parameters: {
        'ride_id': rideId,
        'reason': reason,
      },
    );
  }

  // Driver availability events
  Future<void> logDriverAvailabilityChanged({
    required String driverId,
    required String status,
  }) async {
    await _analytics.logEvent(
      name: 'driver_availability_changed',
      parameters: {
        'driver_id': driverId,
        'status': status,
      },
    );
  }

  // Payment events
  Future<void> logPaymentProcessed({
    required String rideId,
    required double amount,
    required String paymentMethod,
  }) async {
    await _analytics.logEvent(
      name: 'payment_processed',
      parameters: {
        'ride_id': rideId,
        'amount': amount,
        'payment_method': paymentMethod,
      },
    );
  }

  // Rating events
  Future<void> logRatingSubmitted({
    required String rideId,
    required double rating,
    required String raterType,
  }) async {
    await _analytics.logEvent(
      name: 'rating_submitted',
      parameters: {
        'ride_id': rideId,
        'rating': rating,
        'rater_type': raterType,
      },
    );
  }

  // Chat events
  Future<void> logMessageSent({
    required String rideId,
    required String senderType,
  }) async {
    await _analytics.logEvent(
      name: 'message_sent',
      parameters: {
        'ride_id': rideId,
        'sender_type': senderType,
      },
    );
  }

  // Profile events
  Future<void> logProfileUpdated(String userType) async {
    await _analytics.logEvent(
      name: 'profile_updated',
      parameters: {
        'user_type': userType,
      },
    );
  }

  // User properties
  Future<void> setUserType(String userType) async {
    await _analytics.setUserProperty(name: 'user_type', value: userType);
  }

  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }
}
