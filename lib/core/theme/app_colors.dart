import 'package:flutter/material.dart';

/// App-wide color scheme
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2196F3); // Blue
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  
  // Secondary colors
  static const Color secondary = Color(0xFFFF9800); // Orange
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFF57C00);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color error = Color(0xFFF44336); // Red
  static const Color info = Color(0xFF2196F3); // Blue
  
  // Neutral colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // Availability status colors
  static const Color available = Color(0xFF4CAF50); // Green
  static const Color busy = Color(0xFFFF9800); // Orange
  static const Color offline = Color(0xFF9E9E9E); // Grey
  
  // Ride status colors
  static const Color pending = Color(0xFFFFC107); // Amber
  static const Color accepted = Color(0xFF2196F3); // Blue
  static const Color enroute = Color(0xFF9C27B0); // Purple
  static const Color arrived = Color(0xFF00BCD4); // Cyan
  static const Color completed = Color(0xFF4CAF50); // Green
  static const Color cancelled = Color(0xFFF44336); // Red
  
  // Overlay colors
  static const Color overlay = Color(0x80000000); // 50% black
  static const Color overlayLight = Color(0x40000000); // 25% black
  
  // Shimmer colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
