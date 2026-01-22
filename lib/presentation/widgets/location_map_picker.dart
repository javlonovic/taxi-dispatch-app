import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Модель для выбранного местоположения
class SelectedLocation {
  final GeoPoint geoPoint;
  final String address;
  final String? name;

  const SelectedLocation({
    required this.geoPoint,
    required this.address,
    this.name,
  });
}

/// Виджет для выбора местоположения на карте с поиском адресов
class LocationMapPicker extends StatefulWidget {
  final GeoPoint? initialLocation;
  final String title;
  final String confirmButtonText;
  final Function(SelectedLocation) onLocationSelected;
  final VoidCallback? onCancel;

  const LocationMapPicker({
    super.key,
    this.initialLocation,
    this.title = 'Выберите местоположение',
    this.confirmButtonText = 'Подтвердить',
    required this.onLocationSelected,
    this.onCancel,
  });

  @override
  State<LocationMapPicker> createState() => _LocationMapPickerState();
}

class _LocationMapPickerState extends State<LocationMapPicker> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isGeocoding = false;
  bool _isSearching = false;
  List<Location> _searchResults = [];
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeLocation() {
    if (widget.initialLocation != null) {
      _selectedLocation = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _geocodeSelectedLocation();
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
      _geocodeSelectedLocation();
      _mapController.move(_selectedLocation!, 15.0);
    } catch (e) {
      // Fallback to Tashkent center if location access fails
      setState(() {
        _selectedLocation = const LatLng(41.2995, 69.2401);
      });
      _mapController.move(_selectedLocation!, 12.0);
    }
  }

  Future<void> _geocodeSelectedLocation() async {
    if (_selectedLocation == null) return;

    setState(() {
      _isGeocoding = true;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
        localeIdentifier: 'ru_RU',
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final addressParts = <String>[];

        if (placemark.street?.isNotEmpty == true) {
          addressParts.add(placemark.street!);
        }
        if (placemark.subThoroughfare?.isNotEmpty == true) {
          addressParts.add(placemark.subThoroughfare!);
        }
        if (placemark.locality?.isNotEmpty == true) {
          addressParts.add(placemark.locality!);
        }

        setState(() {
          _selectedAddress = addressParts.isNotEmpty
              ? addressParts.join(', ')
              : 'Координаты: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}';
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Координаты: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}';
      });
    } finally {
      setState(() {
        _isGeocoding = false;
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
      _selectedAddress = '';
      _searchResults.clear();
    });
    _geocodeSelectedLocation();
  }

  void _onSearchChanged(String query) {
    _searchTimer?.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _searchTimer = Timer(const Duration(milliseconds: 800), () {
      _searchLocation(query);
    });
  }

  Future<void> _searchLocation(String query) async {
    try {
      final locations = await locationFromAddress(
        query,
        localeIdentifier: 'ru_RU',
      );

      setState(() {
        _searchResults = locations.take(5).toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
    }
  }

  void _selectSearchResult(Location location) async {
    setState(() {
      _selectedLocation = LatLng(location.latitude, location.longitude);
      _searchResults.clear();
      _searchController.clear();
    });

    _mapController.move(_selectedLocation!, 16.0);
    await _geocodeSelectedLocation();
  }

  void _confirmSelection() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, выберите местоположение на карте'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedLocation = SelectedLocation(
      geoPoint: GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude),
      address: _selectedAddress.isNotEmpty 
          ? _selectedAddress 
          : 'Координаты: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
    );

    widget.onLocationSelected(selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск адреса...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchResults.clear();
                                  });
                                },
                              )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
                
                // Search results
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final location = _searchResults[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on, color: Colors.blue),
                          title: Text(
                            'Координаты: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () => _selectSearchResult(location),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation ?? const LatLng(41.2995, 69.2401),
                initialZoom: _selectedLocation != null ? 15.0 : 12.0,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.taxi_dispatch_app',
                ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation!,
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
          ),

          // Selected location info and confirm button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Выбранное местоположение:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (_isGeocoding)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedAddress.isNotEmpty
                      ? _selectedAddress
                      : _selectedLocation != null
                          ? 'Координаты: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}'
                          : 'Местоположение не выбрано',
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedAddress.isNotEmpty ? Colors.black87 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedLocation != null ? _confirmSelection : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.confirmButtonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}