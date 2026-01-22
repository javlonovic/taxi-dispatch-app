import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

/// Map picker for selecting delivery address
class DeliveryAddressMapPicker extends StatefulWidget {
  final GeoPoint? initialLocation;
  final String? initialAddress;

  const DeliveryAddressMapPicker({
    super.key,
    this.initialLocation,
    this.initialAddress,
  });

  @override
  State<DeliveryAddressMapPicker> createState() =>
      _DeliveryAddressMapPickerState();

  /// Show the map picker as a full screen dialog
  static Future<MapPickerResult?> show(
    BuildContext context, {
    GeoPoint? initialLocation,
    String? initialAddress,
  }) {
    return Navigator.of(context).push<MapPickerResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => DeliveryAddressMapPicker(
          initialLocation: initialLocation,
          initialAddress: initialAddress,
        ),
      ),
    );
  }
}

class _DeliveryAddressMapPickerState extends State<DeliveryAddressMapPicker> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _selectedAddress = widget.initialAddress ?? '';
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Доступ к местоположению запрещен');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Доступ к местоположению запрещен навсегда. Включите в настройках.',
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      // Move camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Default to Moscow center if location fails
      setState(() {
        _selectedLocation = const LatLng(55.7558, 37.6173);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите адрес доставки'),
        actions: [
          TextButton(
            onPressed: _selectedLocation != null ? _confirmSelection : null,
            child: const Text(
              'Готово',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          if (_selectedLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation!,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: (latLng) {
                setState(() {
                  _selectedLocation = latLng;
                  _selectedAddress = ''; // Clear address, will be geocoded
                });
              },
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: const MarkerId('delivery'),
                        position: _selectedLocation!,
                        draggable: true,
                        onDragEnd: (latLng) {
                          setState(() {
                            _selectedLocation = latLng;
                            _selectedAddress = ''; // Clear address
                          });
                        },
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      ),
                    }
                  : {},
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Address input card at bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Адрес доставки',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Введите адрес или выберите на карте',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            // TODO: Implement address search/geocoding
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Поиск адреса будет добавлен в следующей версии',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedAddress = value;
                        });
                      },
                      controller: TextEditingController(text: _selectedAddress),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Перетащите маркер или нажмите на карту для выбора точного местоположения',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSelection() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, выберите местоположение на карте'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedAddress.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, введите адрес'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = MapPickerResult(
      location: GeoPoint(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      ),
      address: _selectedAddress.trim(),
    );

    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

/// Result from the map picker
class MapPickerResult {
  final GeoPoint location;
  final String address;

  MapPickerResult({
    required this.location,
    required this.address,
  });
}
