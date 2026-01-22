import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/crashlytics_service.dart';
import '../../core/services/performance_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

final crashlyticsServiceProvider = Provider<CrashlyticsService>((ref) {
  return CrashlyticsService();
});

final performanceServiceProvider = Provider<PerformanceService>((ref) {
  return PerformanceService();
});
