import 'package:firebase_performance/firebase_performance.dart';
import 'package:http/http.dart' as http;

/// Service for monitoring app performance
class PerformanceService {
  final FirebasePerformance _performance = FirebasePerformance.instance;

  /// Create a custom trace for monitoring specific operations
  Future<Trace> startTrace(String traceName) async {
    final trace = _performance.newTrace(traceName);
    await trace.start();
    return trace;
  }

  /// Stop a trace
  Future<void> stopTrace(Trace trace) async {
    await trace.stop();
  }

  /// Create and execute a traced operation
  Future<T> traceOperation<T>(
    String traceName,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) async {
    final trace = await startTrace(traceName);
    
    // Add custom attributes if provided
    if (attributes != null) {
      for (final entry in attributes.entries) {
        trace.putAttribute(entry.key, entry.value);
      }
    }

    try {
      final result = await operation();
      await stopTrace(trace);
      return result;
    } catch (e) {
      // Increment error metric
      trace.incrementMetric('errors', 1);
      await stopTrace(trace);
      rethrow;
    }
  }

  /// Monitor HTTP requests
  Future<http.Response> monitorHttpRequest(
    String url,
    Future<http.Response> Function() request,
  ) async {
    final metric = _performance.newHttpMetric(url, HttpMethod.Get);
    await metric.start();

    try {
      final response = await request();
      
      metric.responseContentType = response.headers['content-type'];
      metric.httpResponseCode = response.statusCode;
      metric.responsePayloadSize = response.contentLength;
      
      await metric.stop();
      return response;
    } catch (e) {
      await metric.stop();
      rethrow;
    }
  }

  /// Monitor POST requests
  Future<http.Response> monitorHttpPost(
    String url,
    Future<http.Response> Function() request,
  ) async {
    final metric = _performance.newHttpMetric(url, HttpMethod.Post);
    await metric.start();

    try {
      final response = await request();
      
      metric.responseContentType = response.headers['content-type'];
      metric.httpResponseCode = response.statusCode;
      metric.responsePayloadSize = response.contentLength;
      
      await metric.stop();
      return response;
    } catch (e) {
      await metric.stop();
      rethrow;
    }
  }

  /// Common traces for the app

  /// Trace ride request creation
  Future<T> traceRideRequest<T>(Future<T> Function() operation) async {
    return traceOperation('ride_request_creation', operation);
  }

  /// Trace ride acceptance
  Future<T> traceRideAcceptance<T>(Future<T> Function() operation) async {
    return traceOperation('ride_acceptance', operation);
  }

  /// Trace location updates
  Future<T> traceLocationUpdate<T>(Future<T> Function() operation) async {
    return traceOperation('location_update', operation);
  }

  /// Trace payment processing
  Future<T> tracePaymentProcessing<T>(Future<T> Function() operation) async {
    return traceOperation('payment_processing', operation);
  }

  /// Trace authentication operations
  Future<T> traceAuthentication<T>(
    String authType,
    Future<T> Function() operation,
  ) async {
    return traceOperation(
      'authentication',
      operation,
      attributes: {'auth_type': authType},
    );
  }

  /// Trace database operations
  Future<T> traceDatabaseOperation<T>(
    String operationType,
    Future<T> Function() operation,
  ) async {
    return traceOperation(
      'database_operation',
      operation,
      attributes: {'operation_type': operationType},
    );
  }

  /// Trace screen rendering
  Future<T> traceScreenLoad<T>(
    String screenName,
    Future<T> Function() operation,
  ) async {
    return traceOperation(
      'screen_load',
      operation,
      attributes: {'screen_name': screenName},
    );
  }

  /// Enable/disable performance monitoring
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    await _performance.setPerformanceCollectionEnabled(enabled);
  }

  /// Check if performance monitoring is enabled
  Future<bool> isPerformanceCollectionEnabled() async {
    return await _performance.isPerformanceCollectionEnabled();
  }
}
