/// Application-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ============================================================================
  // Driver Search Configuration
  // ============================================================================

  /// Default search radius for finding nearby drivers (in kilometers)
  /// As per requirements 9.5 and 10.1, the search radius should be 5-6 km
  static const double defaultSearchRadiusKm = 5.5;

  /// Minimum search radius (in kilometers)
  static const double minSearchRadiusKm = 5.0;

  /// Maximum search radius (in kilometers)
  static const double maxSearchRadiusKm = 6.0;

  /// Search radius increment when expanding search (in kilometers)
  static const double searchRadiusIncrementKm = 1.0;

  /// Maximum number of drivers to notify per ride request
  static const int maxDriversToNotify = 5;

  // ============================================================================
  // Location & Tracking Configuration
  // ============================================================================

  /// Location update interval for active drivers (in seconds)
  static const int locationUpdateIntervalSeconds = 10;

  /// Average city driving speed for ETA calculations (in km/h)
  static const double averageCitySpeedKmh = 30.0;

  // ============================================================================
  // Timeout Configuration
  // ============================================================================

  /// Timeout for finding a driver (in seconds)
  static const int driverSearchTimeoutSeconds = 120;

  /// Time to show "still searching" message (in seconds)
  static const int stillSearchingThresholdSeconds = 30;

  /// Time to show cancel button (in seconds)
  static const int showCancelButtonSeconds = 60;
}
