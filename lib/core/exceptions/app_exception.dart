/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Authentication related exceptions
class AuthException extends AppException {
  AuthException(super.message, [super.code]);

  @override
  String toString() => 'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException(super.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Location related exceptions
class LocationException extends AppException {
  LocationException(super.message);

  @override
  String toString() => 'LocationException: $message';
}

/// Payment related exceptions
class PaymentException extends AppException {
  PaymentException(super.message, [super.code]);

  @override
  String toString() => 'PaymentException: $message${code != null ? ' (code: $code)' : ''}';
}

/// General application exceptions
class GeneralException extends AppException {
  GeneralException(super.message, [super.code]);

  @override
  String toString() => 'GeneralException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Validation related exceptions
class ValidationException extends AppException {
  ValidationException(super.message, [super.code]);

  @override
  String toString() => 'ValidationException: $message${code != null ? ' (code: $code)' : ''}';
}
