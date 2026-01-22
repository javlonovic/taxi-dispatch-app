import '../services/crashlytics_service.dart';
import '../exceptions/app_exception.dart';

/// Global error logger utility
class ErrorLogger {
  static final CrashlyticsService _crashlytics = CrashlyticsService();

  /// Log an error to Crashlytics
  static Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    bool fatal = false,
  }) async {
    // Log to console in debug mode
    // ignore: avoid_print
    print('Error in $context: $error');
    if (stackTrace != null) {
      // ignore: avoid_print
      print('Stack trace: $stackTrace');
    }

    // Log to Crashlytics
    await _crashlytics.logError(
      error,
      stackTrace,
      reason: context,
      fatal: fatal,
    );
  }

  /// Log a message to Crashlytics
  static Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  /// Set user context for error tracking
  static Future<void> setUserContext(String userId, String userType) async {
    await _crashlytics.setUserId(userId);
    await _crashlytics.setCustomKey('user_type', userType);
  }

  /// Set custom key-value for error context
  static Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// Log app exception with additional context
  static Future<void> logAppException(
    AppException exception,
    StackTrace? stackTrace, {
    String? additionalContext,
  }) async {
    final context = additionalContext ?? exception.runtimeType.toString();
    await logError(
      exception,
      stackTrace,
      context: context,
      fatal: false,
    );
  }
}
