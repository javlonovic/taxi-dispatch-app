import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Widget for displaying OpenStreetMap with markers and routes
class OSMMapWidget extends StatefulWidget {
  final GeoPoint? driverLocation;
  final GeoPoint? pickupLocation;
  final GeoPoint? destination;
  final List<LatLng>? routePolyline;
  final List<DriverMarkerData>? nearbyDrivers;
  final Function(MapController)? onMapCreated;
  final Function(GeoPoint)? onMapTap;
  final Function(DriverMarkerData)? onDriverTap;
  final double initialZoom;
  final bool showMyLocationButton;

  const OSMMapWidget({
    super.key,
    this.driverLocation,
    this.pickupLocation,
    this.destination,
    this.routePolyline,
    this.nearbyDrivers,
    this.onMapCreated,
    this.onMapTap,
    this.onDriverTap,
    this.initialZoom = 14.0,
    this.showMyLocationButton = true,
  });

  @override
  State<OSMMapWidget> createState() => _OSMMapWidgetState();
}

class _OSMMapWidgetState extends State<OSMMapWidget> {
  late final MapController _mapController;
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _updateMapElements();
    
    // Notify parent that map is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMapCreated?.call(_mapController);
      _fitMapBounds();
    });
  }

  @override
  void didUpdateWidget(OSMMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.driverLocation != widget.driverLocation ||
        oldWidget.pickupLocation != widget.pickupLocation ||
        oldWidget.destination != widget.destination ||
        oldWidget.routePolyline != widget.routePolyline ||
        oldWidget.nearbyDrivers != widget.nearbyDrivers) {
      _updateMapElements();
      _fitMapBounds();
    }
  }

  void _updateMapElements() {
    _markers = [];
    _polylines = [];

    // Add driver marker (blue car icon)
    if (widget.driverLocation != null) {
      _markers.add(
        Marker(
          point: LatLng(
            widget.driverLocation!.latitude,
            widget.driverLocation!.longitude,
          ),
          width: 40,
          height: 40,
          child: const Icon(
            Icons.local_taxi,
            color: Colors.blue,
            size: 40,
          ),
        ),
      );
    }

    // Add pickup marker (green pin)
    if (widget.pickupLocation != null) {
      _markers.add(
        Marker(
          point: LatLng(
            widget.pickupLocation!.latitude,
            widget.pickupLocation!.longitude,
          ),
          width: 40,
          height: 40,
          child: const Icon(
            Icons.location_on,
            color: Colors.green,
            size: 40,
          ),
        ),
      );
    }

    // Add destination marker (red pin)
    if (widget.destination != null) {
      _markers.add(
        Marker(
          point: LatLng(
            widget.destination!.latitude,
            widget.destination!.longitude,
          ),
          width: 40,
          height: 40,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    }

    // Add nearby drivers markers
    if (widget.nearbyDrivers != null) {
      for (var driver in widget.nearbyDrivers!) {
        Color markerColor;
        switch (driver.availabilityStatus) {
          case 'available':
            markerColor = Colors.green;
            break;
          case 'busy':
            markerColor = Colors.orange;
            break;
          case 'offline':
          default:
            markerColor = Colors.grey;
            break;
        }

        _markers.add(
          Marker(
            point: LatLng(
              driver.location.latitude,
              driver.location.longitude,
            ),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => widget.onDriverTap?.call(driver),
              child: Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: markerColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_taxi,
                      color: markerColor,
                      size: 24,
                    ),
                  ),
                  // Rating badge
                  if (driver.rating > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: markerColor, width: 1),
                        ),
                        child: Text(
                          driver.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // Add route polyline
    if (widget.routePolyline != null && widget.routePolyline!.isNotEmpty) {
      _polylines.add(
        Polyline(
          points: widget.routePolyline!,
          color: Colors.blue,
          strokeWidth: 4.0,
          isDotted: true,
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _fitMapBounds() {
    if (_markers.isEmpty) return;

    try {
      final points = _markers.map((m) => m.point).toList();
      
      if (points.length == 1) {
        // Single point - just center on it
        _mapController.move(points.first, widget.initialZoom);
        return;
      }

      // Calculate bounds
      double minLat = points.first.latitude;
      double maxLat = points.first.latitude;
      double minLng = points.first.longitude;
      double maxLng = points.first.longitude;

      for (var point in points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      final bounds = LatLngBounds(
        LatLng(minLat, minLng),
        LatLng(maxLat, maxLng),
      );

      // Fit bounds with padding
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    } catch (e) {
      // If fitting fails, just center on first marker
      if (_markers.isNotEmpty) {
        _mapController.move(_markers.first.point, widget.initialZoom);
      }
    }
  }

  LatLng _getInitialPosition() {
    if (widget.pickupLocation != null) {
      return LatLng(
        widget.pickupLocation!.latitude,
        widget.pickupLocation!.longitude,
      );
    } else if (widget.driverLocation != null) {
      return LatLng(
        widget.driverLocation!.latitude,
        widget.driverLocation!.longitude,
      );
    } else if (widget.destination != null) {
      return LatLng(
        widget.destination!.latitude,
        widget.destination!.longitude,
      );
    } else if (widget.nearbyDrivers != null && widget.nearbyDrivers!.isNotEmpty) {
      return LatLng(
        widget.nearbyDrivers!.first.location.latitude,
        widget.nearbyDrivers!.first.location.longitude,
      );
    }
    // Default to Tashkent, Uzbekistan
    return const LatLng(41.2995, 69.2401);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _getInitialPosition(),
            initialZoom: widget.initialZoom,
            minZoom: 5.0,
            maxZoom: 18.0,
            onTap: (tapPosition, point) {
              if (widget.onMapTap != null) {
                widget.onMapTap!(GeoPoint(point.latitude, point.longitude));
              }
            },
          ),
          children: [
            // OpenStreetMap tile layer
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.vezunchik.taxi_dispatch_app',
              maxZoom: 19,
              // Add attribution as required by OpenStreetMap
              tileBuilder: (context, widget, tile) {
                return ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.transparent,
                    BlendMode.multiply,
                  ),
                  child: widget,
                );
              },
            ),
            
            // Polylines layer (routes)
            if (_polylines.isNotEmpty)
              PolylineLayer(
                polylines: _polylines,
              ),
            
            // Markers layer
            if (_markers.isNotEmpty)
              MarkerLayer(
                markers: _markers,
              ),
          ],
        ),
        
        // Attribution (required by OpenStreetMap)
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            color: Colors.white.withValues(alpha: 0.7),
            child: const Text(
              '© OpenStreetMap',
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
        
        // Zoom controls
        Positioned(
          right: 10,
          top: 10,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'zoom_in',
                onPressed: () {
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(
                    _mapController.camera.center,
                    currentZoom + 1,
                  );
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'zoom_out',
                onPressed: () {
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(
                    _mapController.camera.center,
                    currentZoom - 1,
                  );
                },
                child: const Icon(Icons.remove),
              ),
              if (widget.showMyLocationButton) ...[
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'my_location',
                  onPressed: () {
                    // Center on pickup location or first marker
                    if (widget.pickupLocation != null) {
                      _mapController.move(
                        LatLng(
                          widget.pickupLocation!.latitude,
                          widget.pickupLocation!.longitude,
                        ),
                        widget.initialZoom,
                      );
                    } else if (_markers.isNotEmpty) {
                      _mapController.move(
                        _markers.first.point,
                        widget.initialZoom,
                      );
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

/// Data class for driver marker information
class DriverMarkerData {
  final String id;
  final String name;
  final GeoPoint location;
  final String carModel;
  final double rating;
  final String availabilityStatus; // 'available', 'busy', 'offline'

  const DriverMarkerData({
    required this.id,
    required this.name,
    required this.location,
    required this.carModel,
    required this.rating,
    this.availabilityStatus = 'offline',
  });
}
