import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/map_widget.dart';
import '../../widgets/company_bottom_nav.dart';
import '../../widgets/common/app_button.dart';

/// Provider to stream all drivers with their locations
final allDriversStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('type', isEqualTo: 'driver')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  });
});

/// Screen showing all drivers on map with editable pickup/destination
class DriverMapScreen extends ConsumerStatefulWidget {
  const DriverMapScreen({super.key});

  @override
  ConsumerState<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends ConsumerState<DriverMapScreen> {
  GeoPoint? _pickupLocation;
  String _pickupAddress = '';
  GeoPoint? _destination;
  String _destinationAddress = '';
  bool _isLoadingLocation = false;
  bool _isSendingRequest = false;

  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final locationService = ref.read(locationServiceProvider);
      
      // Request permission
      final hasPermission = await locationService.requestLocationPermission();
      if (!hasPermission) {
        if (mounted) {
          _showError('Location permission is required');
        }
        return;
      }

      // Get current location
      final position = await locationService.getCurrentLocation();
      setState(() {
        _pickupLocation = GeoPoint(position.latitude, position.longitude);
        _pickupAddress = 'Current Location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
        _pickupController.text = _pickupAddress;
      });
    } catch (e) {
      if (mounted) {
        _showError('Failed to get location: $e');
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _sendRideRequest() async {
    if (_pickupLocation == null || _pickupAddress.isEmpty) {
      _showError('Please set pickup location');
      return;
    }

    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      _showError('User not logged in');
      return;
    }

    setState(() => _isSendingRequest = true);

    try {
      final dispatchService = ref.read(rideDispatchServiceProvider);
      
      await dispatchService.createRideRequestAndNotify(
        companyUserId: user.id,
        pickupLocation: _pickupLocation!,
        pickupAddress: _pickupAddress,
        destination: _destination,
        destinationAddress: _destinationAddress.isEmpty ? null : _destinationAddress,
        searchRadiusKm: 100.0, // Large radius to notify all drivers
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride request sent to available drivers!'),
            backgroundColor: Colors.green,
          ),
        );
        context.push(AppRoutes.tracking);
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to send ride request: $e');
      }
    } finally {
      setState(() => _isSendingRequest = false);
    }
  }

  void _showLocationPicker(bool isPickup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPickup ? 'Set Pickup Location' : 'Set Destination'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Enter address or coordinates',
              ),
              onChanged: (value) {
                if (isPickup) {
                  _pickupAddress = value;
                } else {
                  _destinationAddress = value;
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap on the map to select location',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (isPickup) {
                _pickupController.text = _pickupAddress;
              } else {
                _destinationController.text = _destinationAddress;
              }
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(allDriversStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Drivers'),
        elevation: 0,
        actions: [
          if (_isLoadingLocation)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _getCurrentLocation,
            ),
        ],
      ),
      body: Column(
        children: [
          // Map section - takes most of the screen
          Expanded(
            child: driversAsync.when(
              data: (drivers) {
                // Filter drivers with valid locations
                final driversWithLocation = drivers.where((driver) {
                  return driver['currentLocation'] != null;
                }).toList();

                return Stack(
                  children: [
                    MapWidget(
                      pickupLocation: _pickupLocation,
                      destination: _destination,
                      nearbyDrivers: driversWithLocation
                          .map((driver) => DriverMarkerData(
                                id: driver['id'] as String,
                                name: driver['fullName'] as String,
                                location: driver['currentLocation'] as GeoPoint,
                                carModel: driver['vehicleInfo'] != null
                                    ? '${driver['vehicleInfo']['make']} ${driver['vehicleInfo']['model']}'
                                    : 'Unknown',
                                rating: (driver['averageRating'] as num?)?.toDouble() ?? 0.0,
                                availabilityStatus: driver['availabilityStatus'] as String? ?? 'offline',
                              ))
                          .toList(),
                      onMapTap: (location) {
                        // Allow setting pickup or destination by tapping map
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Set Location'),
                            content: const Text('What would you like to set?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _pickupLocation = location;
                                    _pickupAddress = 'Selected Location (${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)})';
                                    _pickupController.text = _pickupAddress;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text('Pickup'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _destination = location;
                                    _destinationAddress = 'Selected Location (${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)})';
                                    _destinationController.text = _destinationAddress;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text('Destination'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    // Driver count badge
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_taxi, size: 20, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              '${driversWithLocation.length} drivers',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Legend
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLegendItem(Colors.green, 'Available'),
                            const SizedBox(height: 4),
                            _buildLegendItem(Colors.orange, 'Busy'),
                            const SizedBox(height: 4),
                            _buildLegendItem(Colors.grey, 'Offline'),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading drivers: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(allDriversStreamProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Location input section - Fixed height to prevent overflow
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pickup location
                  TextField(
                    controller: _pickupController,
                    decoration: InputDecoration(
                      labelText: 'Pickup Location',
                      prefixIcon: const Icon(Icons.my_location, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.edit_location),
                        onPressed: () => _showLocationPicker(true),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    readOnly: true,
                    onTap: () => _showLocationPicker(true),
                  ),
                  const SizedBox(height: 12),

                  // Destination
                  TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      labelText: 'Destination (Optional)',
                      prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.edit_location),
                        onPressed: () => _showLocationPicker(false),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    readOnly: true,
                    onTap: () => _showLocationPicker(false),
                  ),
                  const SizedBox(height: 16),

                  // Request button
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: 'Request Ride',
                      onPressed: _pickupLocation == null || _isSendingRequest
                          ? null
                          : _sendRideRequest,
                      isLoading: _isSendingRequest,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CompanyBottomNav(currentIndex: 0),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
