import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../../l10n/app_localizations.dart';

/// OpenStreetMap picker widget for selecting branch location
class OSMBranchMapPicker extends StatefulWidget {
  final GeoPoint? initialLocation;
  final String? initialAddress;

  const OSMBranchMapPicker({
    super.key,
    this.initialLocation,
    this.initialAddress,
  });

  @override
  State<OSMBranchMapPicker> createState() => _OSMBranchMapPickerState();
}

class _OSMBranchMapPickerState extends State<OSMBranchMapPicker> {
  late final MapController _mapController;
  LatLng? _selectedPosition;
  bool _isLoading = false;

  // Default location (Tashkent, Uzbekistan)
  static const LatLng _defaultLocation = LatLng(41.2995, 69.2401);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    if (widget.initialLocation != null) {
      _selectedPosition = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      final position = await Geolocator.getCurrentPosition();
      final newPosition = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedPosition = newPosition;
      });

      _mapController.move(newPosition, 15);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedPosition = point;
    });
  }

  void _onConfirm() {
    if (_selectedPosition != null) {
      Navigator.of(context).pop(
        GeoPoint(_selectedPosition!.latitude, _selectedPosition!.longitude),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          if (_selectedPosition != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _onConfirm,
              tooltip: 'Confirm',
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPosition ?? _defaultLocation,
              initialZoom: 13.0,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.vezunchik.taxi_dispatch_app',
              ),
              if (_selectedPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPosition!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          // OSM Attribution
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              color: Colors.white.withOpacity(0.7),
              child: const Text(
                '© OpenStreetMap',
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          
          // Controls
          Positioned(
            right: 16,
            bottom: 80,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
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
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom - 1,
                    );
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'my_location',
                  mini: true,
                  onPressed: _getCurrentLocation,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
          
          // Info card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tap to select location',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_selectedPosition != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${_selectedPosition!.latitude.toStringAsFixed(6)}, ${_selectedPosition!.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedPosition != null
          ? FloatingActionButton.extended(
              onPressed: _onConfirm,
              icon: const Icon(Icons.check),
              label: const Text('Confirm'),
            )
          : null,
    );
  }
}
