import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../providers/driver_filter_provider.dart';

/// Widget to display a list of drivers with filtering options
class DriverListWidget extends ConsumerWidget {
  final GeoPoint? userLocation;
  final AvailabilityStatus? filterStatus;
  final double? minimumRating;
  final bool showNearbyOnly;

  const DriverListWidget({
    super.key,
    this.userLocation,
    this.filterStatus,
    this.minimumRating,
    this.showNearbyOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use nearby drivers provider if location is provided and showNearbyOnly is true
    if (showNearbyOnly && userLocation != null) {
      final driversAsync = ref.watch(nearbyAvailableDriversProvider(userLocation!));
      
      return driversAsync.when(
        data: (drivers) => _buildDriverList(context, drivers),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading drivers: $error'),
        ),
      );
    }

    // Use filtered drivers provider with custom criteria
    final criteria = DriverFilterCriteria(
      status: filterStatus,
      minimumRating: minimumRating,
      location: userLocation,
      radiusKm: userLocation != null ? 5.0 : null,
      sortByDistance: userLocation != null,
    );

    final driversAsync = ref.watch(filteredDriversProvider(criteria));

    return driversAsync.when(
      data: (drivers) => _buildDriverList(context, drivers),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading drivers: $error'),
      ),
    );
  }

  Widget _buildDriverList(BuildContext context, List<Driver> drivers) {
    if (drivers.isEmpty) {
      return const Center(
        child: Text('No drivers found'),
      );
    }

    return ListView.builder(
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driver = drivers[index];
        return _buildDriverCard(context, driver);
      },
    );
  }

  Widget _buildDriverCard(BuildContext context, Driver driver) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: driver.profilePhotoUrl != null
              ? NetworkImage(driver.profilePhotoUrl!)
              : null,
          child: driver.profilePhotoUrl == null
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(driver.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${driver.vehicleInfo.make} ${driver.vehicleInfo.model} - ${driver.vehicleInfo.licensePlate}',
            ),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber[700],
                ),
                const SizedBox(width: 4),
                Text(
                  driver.averageRating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text('(${driver.totalRides} rides)'),
              ],
            ),
          ],
        ),
        trailing: _buildStatusChip(driver.availabilityStatus),
      ),
    );
  }

  Widget _buildStatusChip(AvailabilityStatus status) {
    Color color;
    String label;

    switch (status) {
      case AvailabilityStatus.available:
        color = Colors.green;
        label = 'Available';
        break;
      case AvailabilityStatus.busy:
        color = Colors.orange;
        label = 'Busy';
        break;
      case AvailabilityStatus.offline:
        color = Colors.grey;
        label = 'Offline';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
