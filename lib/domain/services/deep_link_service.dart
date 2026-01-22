import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Service to handle deep links from notifications and external sources
class DeepLinkService {
  static const platform = MethodChannel('com.taxidispatch.app/deeplink');
  
  /// Initialize deep link handling
  static Future<void> initialize(GoRouter router) async {
    // Handle initial deep link when app is opened from terminated state
    try {
      final String? initialLink = await platform.invokeMethod('getInitialLink');
      if (initialLink != null) {
        _handleDeepLink(initialLink, router);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error getting initial link: $e');
    }
    
    // Listen for deep links when app is in background or foreground
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink') {
        final String? link = call.arguments as String?;
        if (link != null) {
          _handleDeepLink(link, router);
        }
      }
    });
  }
  
  /// Parse and navigate to the appropriate screen based on deep link
  static void _handleDeepLink(String link, GoRouter router) {
    final uri = Uri.parse(link);
    
    // Handle custom scheme: taxidispatch://
    // Handle universal links: https://taxidispatch.app/
    
    final path = uri.path;
    final queryParams = uri.queryParameters;
    
    // Build the route with query parameters
    final routeBuffer = StringBuffer(path);
    if (queryParams.isNotEmpty) {
      routeBuffer.write('?');
      routeBuffer.write(
        queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&'),
      );
    }
    
    // Navigate to the route
    router.push(routeBuffer.toString());
  }
  
  /// Create a deep link URL for sharing
  static String createDeepLink(String path, {Map<String, String>? queryParams}) {
    final uri = Uri(
      scheme: 'taxidispatch',
      path: path,
      queryParameters: queryParams,
    );
    return uri.toString();
  }
  
  /// Create a universal link URL for sharing
  static String createUniversalLink(String path, {Map<String, String>? queryParams}) {
    final uri = Uri(
      scheme: 'https',
      host: 'taxidispatch.app',
      path: path,
      queryParameters: queryParams,
    );
    return uri.toString();
  }
}
