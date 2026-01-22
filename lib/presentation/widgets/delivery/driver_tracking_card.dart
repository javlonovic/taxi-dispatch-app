import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../domain/entities/ride.dart';
import '../../../domain/entities/user.dart';
import '../../providers/user_provider.dart';
import '../../providers/location_provider.dart';
import '../common/status_badge.dart';

/// Widget that displays driver tracking information with real-time location updates
class DriverTrackingCard extends ConsumerStatefulWidget {
  final Ride ride;

  const DriverTrackingCard({
    super.key,
    required this.ride,
  });

  @override
  ConsumerState<DriverTrackingCard> createState() => _DriverTrackingCardState();
}

class _DriverTrackingCardState extends ConsumerState<DriverTrackingCard> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  int _calculateETA(GeoPoint from, GeoPoint to) {
    // Calculate distance in km using Haversine formula
    final distance = _calculateDistance(from, to);
    // Assume average speed of 30 km/h in city
    final hours = distance / 30;
    return (hours * 60).ceil(); // Convert to minutes
  }

  double _calculateDistance(GeoPoint from, GeoPoint to) {
    // Haversine formula for distance calculation
    const double earthRadius = 6371; // km
    
    final lat1 = from.latitude * (math.pi / 180);
    final lat2 = to.latitude * (math.pi / 180);
    final dLat = (to.latitude - from.latitude) * (math.pi / 180);
    final dLon = (to.longitude - from.longitude) * (math.pi / 180);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  void _updateMarkers(GeoPoint driverLocation, Driver driver) {
    // Determine destination point
    final destinationPoint = widget.ride.destination ?? widget.ride.pickupLocation;
    
    setState(() {
      _markers = {
        // Driver marker (blue)
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(
            driverLocation.latitude,
            driverLocation.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: InfoWindow(
            title: 'Водитель',
            snippet: '${driver.firstName} ${driver.lastName}',
          ),
        ),
        // Pickup marker (green)
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(
            widget.ride.pickupLocation.latitude,
            widget.ride.pickupLocation.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: 'Откуда',
            snippet: widget.ride.pickupAddress,
          ),
        ),
        // Delivery marker (red) - if destination exists
        if (widget.ride.destination != null)
          Marker(
            markerId: const MarkerId('delivery'),
            position: LatLng(
              widget.ride.destination!.latitude,
              widget.ride.destination!.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: 'Куда',
              snippet: widget.ride.destinationAddress ?? '',
            ),
          ),
      };

      // Draw route polyline from driver to destination
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(driverLocation.latitude, driverLocation.longitude),
            LatLng(destinationPoint.latitude, destinationPoint.longitude),
          ],
          color: Colors.blue,
          width: 3,
        ),
      };
    });

    // Update camera to show all markers
    if (_mapController != null) {
      _updateCameraBounds(driverLocation, destinationPoint);
    }
  }

  void _updateCameraBounds(GeoPoint driverLocation, GeoPoint destination) {
    final bounds = LatLngBounds(
      southwest: LatLng(
        driverLocation.latitude < destination.latitude
            ? driverLocation.latitude
            : destination.latitude,
        driverLocation.longitude < destination.longitude
            ? driverLocation.longitude
            : destination.longitude,
      ),
      northeast: LatLng(
        driverLocation.latitude > destination.latitude
            ? driverLocation.latitude
            : destination.latitude,
        driverLocation.longitude > destination.longitude
            ? driverLocation.longitude
            : destination.longitude,
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ride.driverUserId == null) {
      return const Card(
        elevation: 4,
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Водитель не назначен'),
        ),
      );
    }

    final driverAsync = ref.watch(driverProvider(widget.ride.driverUserId!));
    final driverLocationAsync = ref.watch(
      driverGeoPointStreamProvider(widget.ride.driverUserId!),
    );

    return driverAsync.when(
      data: (driver) {
        if (driver == null) {
          return const Card(
            elevation: 4,
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Информация о водителе недоступна'),
            ),
          );
        }

        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Driver info header
              _buildDriverInfoHeader(driver),
              
              const Divider(height: 1),
              
              // Map showing driver location
              driverLocationAsync.when(
                data: (location) {
                  // Update markers when location changes
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateMarkers(location, driver);
                  });

                  return SizedBox(
                    height: 250,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          location.latitude,
                          location.longitude,
                        ),
                        zoom: 14,
                      ),
                      markers: _markers,
                      polylines: _polylines,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 250,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SizedBox(
                  height: 250,
                  child: Center(
                    child: Text('Ошибка загрузки карты: $error'),
                  ),
                ),
              ),
              
              const Divider(height: 1),
              
              // ETA and status
              _buildETAAndStatus(driverLocationAsync),
            ],
          ),
        );
      },
      loading: () => const Card(
        elevation: 4,
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Ошибка загрузки данных водителя: $error'),
        ),
      ),
    );
  }

  Widget _buildDriverInfoHeader(Driver driver) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: driver.profilePhotoUrl != null
                  ? NetworkImage(driver.profilePhotoUrl!)
                  : null,
              child: driver.profilePhotoUrl == null
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
            title: Text(
              '${driver.firstName} ${driver.lastName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              '${driver.vehicleInfo.model} • ${driver.vehicleInfo.color}',
              style: const TextStyle(fontSize: 14),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  driver.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Car number chip
          Chip(
            avatar: const Icon(Icons.directions_car, size: 18),
            label: Text(
              driver.vehicleInfo.licensePlate,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildETAAndStatus(AsyncValue<GeoPoint> driverLocationAsync) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Статус:',
                style: TextStyle(fontSize: 16),
              ),
              StatusBadge.ride(widget.ride.status),
            ],
          ),
          const SizedBox(height: 12),
          driverLocationAsync.when(
            data: (location) {
              final destination = widget.ride.destination ?? widget.ride.pickupLocation;
              final eta = _calculateETA(location, destination);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Прибытие через:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '$eta мин',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('—'),
          ),
        ],
      ),
    );
  }
}
