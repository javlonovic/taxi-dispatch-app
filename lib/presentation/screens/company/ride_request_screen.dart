import 'package:flutter/material.dart';
import 'improved_driver_map_screen.dart';

/// Screen for company users to request a ride
/// Now uses improved version with geocoding and ETA
class RideRequestScreen extends StatelessWidget {
  const RideRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImprovedDriverMapScreen();
  }
}
