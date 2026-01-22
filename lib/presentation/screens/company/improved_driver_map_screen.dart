import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/osm_map_widget.dart';
import '../../widgets/company_bottom_nav.dart';


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

/// Improved screen with geocoding and ETA
class ImprovedDriverMapScreen extends ConsumerStatefulWidget {
  const ImprovedDriverMapScreen({super.key});

  @override
  ConsumerState<ImprovedDriverMapScreen> createState() => _ImprovedDriverMapScreenState();
}

class _ImprovedDriverMapScreenState extends ConsumerState<ImprovedDriverMapScreen> {
  GeoPoint? _pickupLocation;
  String _pickupAddress = 'Getting your location...';
  GeoPoint? _destination;
  String _destinationAddress = '';
  bool _isLoadingLocation = false;
  bool _isGeocodingPickup = false;
  bool _isGeocodingDestination = false;
  bool _isSendingRequest = false;
  String? _estimatedTime;
  double? _estimatedDistance;

  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndGeocode();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocationAndGeocode() async {
    setState(() => _isLoadingLocation = true);

    try {
      final locationService = ref.read(locationServiceProvider);
      
      // Request permission
      final hasPermission = await locationService.requestLocationPermission();
      if (!hasPermission) {
        if (mounted) {
          _showError('Location permission is required');
          final shouldOpenSettings = await _showPermissionDialog();
          if (shouldOpenSettings) {
            await locationService.openLocationSettings();
          }
        }
        return;
      }

      // Get current location
      final position = await locationService.getCurrentLocation();
      final geoPoint = GeoPoint(position.latitude, position.longitude);
      
      setState(() {
        _pickupLocation = geoPoint;
        _pickupAddress = 'Loading address...';
        _pickupController.text = _pickupAddress;
      });

      // Geocode the location to get address
      await _geocodeLocation(geoPoint, true);
      
    } catch (e) {
      if (mounted) {
        _showError('Failed to get location: $e');
        setState(() {
          _pickupAddress = 'Location unavailable';
          _pickupController.text = _pickupAddress;
        });
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _geocodeLocation(GeoPoint location, bool isPickup) async {
    setState(() {
      if (isPickup) {
        _isGeocodingPickup = true;
      } else {
        _isGeocodingDestination = true;
      }
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = _formatAddress(place);
        
        setState(() {
          if (isPickup) {
            _pickupAddress = address;
            _pickupController.text = address;
          } else {
            _destinationAddress = address;
            _destinationController.text = address;
          }
        });

        // Calculate ETA if both locations are set
        if (_pickupLocation != null && _destination != null) {
          _calculateETA();
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      final fallbackAddress = '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
      setState(() {
        if (isPickup) {
          _pickupAddress = fallbackAddress;
          _pickupController.text = fallbackAddress;
        } else {
          _destinationAddress = fallbackAddress;
          _destinationController.text = fallbackAddress;
        }
      });
    } finally {
      setState(() {
        if (isPickup) {
          _isGeocodingPickup = false;
        } else {
          _isGeocodingDestination = false;
        }
      });
    }
  }

  String _formatAddress(Placemark place) {
    final parts = <String>[];
    
    if (place.street != null && place.street!.isNotEmpty) {
      parts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      parts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }
    
    return parts.isEmpty ? 'Unknown location' : parts.join(', ');
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2));
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  void _calculateETA() {
    if (_pickupLocation == null || _destination == null) return;

    final distanceKm = _calculateDistance(
      _pickupLocation!.latitude,
      _pickupLocation!.longitude,
      _destination!.latitude,
      _destination!.longitude,
    );
    
    // Assume average speed of 30 km/h in city
    final hours = distanceKm / 30;
    final minutes = (hours * 60).round();

    setState(() {
      _estimatedDistance = distanceKm;
      _estimatedTime = minutes < 60 
          ? '$minutes min' 
          : '${(minutes / 60).toStringAsFixed(1)} hr';
    });
  }

  Future<bool> _showPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'This app needs location permission to show your current location and find nearby drivers.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _sendRideRequest() async {
    if (_pickupLocation == null || _pickupAddress.isEmpty) {
      _showError('Пожалуйста, укажите место отправления');
      return;
    }

    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      _showError('Пользователь не авторизован');
      return;
    }

    setState(() => _isSendingRequest = true);

    DocumentReference? rideDoc;
    int successfulNotifications = 0;

    try {
      // Create ride document directly
      rideDoc = await FirebaseFirestore.instance.collection('rides').add({
        'companyUserId': user.id,
        'companyName': user.fullName,
        'driverUserId': null,
        'driverName': null,
        'status': 'pending',
        'pickupLocation': _pickupLocation,
        'pickupAddress': _pickupAddress,
        'destination': _destination,
        'destinationAddress': _destinationAddress.isEmpty ? null : _destinationAddress,
        'requestedAt': FieldValue.serverTimestamp(),
        'acceptedAt': null,
        'arrivedAt': null,
        'startedAt': null,
        'completedAt': null,
        'cancelledAt': null,
        'fare': null,
        'distance': null,
        'durationSeconds': null,
        'rating': null,
        'searchRadius': 100.0,
      });

      // Get all active available drivers
      final driversSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'driver')
          .where('isActive', isEqualTo: true)
          .where('availabilityStatus', isEqualTo: 'available')
          .get();

      if (driversSnapshot.docs.isEmpty) {
        throw Exception('Нет доступных водителей поблизости');
      }

      // Send notifications to all available drivers
      final notificationService = ref.read(notificationServiceProvider);
      
      for (var driverDoc in driversSnapshot.docs) {
        final driverId = driverDoc.id;
        
        try {
          await notificationService.sendNotificationToUser(
            userId: driverId,
            title: 'Новый заказ',
            body: 'Место отправления: $_pickupAddress',
            data: {
              'type': 'ride_request',
              'rideId': rideDoc.id,
              'pickupAddress': _pickupAddress,
              'pickupLocation': '${_pickupLocation!.latitude},${_pickupLocation!.longitude}',
              'destinationAddress': _destinationAddress.isEmpty ? '' : _destinationAddress,
              'destination': _destination != null 
                  ? '${_destination!.latitude},${_destination!.longitude}'
                  : '',
              'companyName': user.fullName,
            },
          );
          
          successfulNotifications++;
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          // Continue with other drivers
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successfulNotifications > 0
                  ? 'Заказ отправлен $successfulNotifications водителям!'
                  : 'Заказ создан, но не удалось отправить уведомления',
            ),
            backgroundColor: successfulNotifications > 0 ? Colors.green : Colors.orange,
          ),
        );
        
        // Navigate to tracking screen
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.push('${AppRoutes.tracking}?rideId=${rideDoc.id}');
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error sending ride request: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        _showError('Не удалось отправить заказ: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingRequest = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _showLocationSetDialog(GeoPoint location) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Location'),
        content: const Text('What would you like to set this location as?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'pickup'),
            child: const Text('Pickup Location'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'destination'),
            child: const Text('Destination'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result == 'pickup') {
      setState(() {
        _pickupLocation = location;
        _pickupAddress = 'Loading address...';
      });
      await _geocodeLocation(location, true);
    } else if (result == 'destination') {
      setState(() {
        _destination = location;
        _destinationAddress = 'Loading address...';
      });
      await _geocodeLocation(location, false);
    }
  }

  void _showDriverInfo(DriverMarkerData driver) {
    // Calculate distance from pickup location
    double? distanceKm;
    if (_pickupLocation != null) {
      distanceKm = _calculateDistance(
        _pickupLocation!.latitude,
        _pickupLocation!.longitude,
        driver.location.latitude,
        driver.location.longitude,
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getDriverStatusColor(driver.availabilityStatus),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          driver.carModel,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDriverStatusColor(driver.availabilityStatus),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      driver.availabilityStatus.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Rating
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${driver.rating.toStringAsFixed(1)} Rating',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Distance
              if (distanceKm != null) ...[
                Row(
                  children: [
                    const Icon(Icons.straighten, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${distanceKm.toStringAsFixed(1)} km away',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: driver.availabilityStatus == 'available'
                          ? () {
                              Navigator.pop(context);
                              _showDeliveryFormForDriver(driver);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Request'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDriverStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'busy':
        return Colors.orange;
      case 'offline':
      default:
        return Colors.grey;
    }
  }

  Future<void> _showDeliveryForm() async {
    final TextEditingController destinationController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.local_shipping, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Where should we deliver?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Current location info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pickup from:',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              _pickupAddress,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Destination input
                TextField(
                  controller: destinationController,
                  decoration: InputDecoration(
                    labelText: 'Delivery Address *',
                    hintText: 'Enter where to deliver...',
                    prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Notes input
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Special Instructions (Optional)',
                    hintText: 'Any special delivery instructions...',
                    prefixIcon: const Icon(Icons.note, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          final destination = destinationController.text.trim();
                          if (destination.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter delivery address'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          Navigator.pop(context, {
                            'destination': destination,
                            'notes': notesController.text.trim(),
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Request Delivery'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      final destination = result['destination']!;
      final notes = result['notes'] ?? '';
      
      // Set the destination and send request
      setState(() {
        _destinationAddress = destination;
        _isSendingRequest = true;
      });
      
      await _sendDeliveryRequest(destination, notes);
    }
  }

  Future<void> _sendDeliveryRequest(String destinationAddress, String notes) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      _showError('Пользователь не авторизован');
      return;
    }

    try {
      // Create ride document
      final rideDoc = await FirebaseFirestore.instance.collection('rides').add({
        'companyUserId': user.id,
        'companyName': user.fullName,
        'driverUserId': null,
        'driverName': null,
        'status': 'pending',
        'pickupLocation': _pickupLocation,
        'pickupAddress': _pickupAddress,
        'destination': null, // Will be geocoded by driver
        'destinationAddress': destinationAddress,
        'specialInstructions': notes.isNotEmpty ? notes : null,
        'requestedAt': FieldValue.serverTimestamp(),
        'acceptedAt': null,
        'arrivedAt': null,
        'startedAt': null,
        'completedAt': null,
        'cancelledAt': null,
        'fare': null,
        'distance': null,
        'durationSeconds': null,
        'rating': null,
        'searchRadius': 100.0,
        'type': 'delivery', // Mark as delivery request
      });

      // Get all active available drivers
      final driversSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'driver')
          .where('isActive', isEqualTo: true)
          .where('availabilityStatus', isEqualTo: 'available')
          .get();

      if (driversSnapshot.docs.isEmpty) {
        throw Exception('Нет доступных водителей поблизости');
      }

      // Send notifications to all available drivers
      final notificationService = ref.read(notificationServiceProvider);
      int successfulNotifications = 0;
      
      for (var driverDoc in driversSnapshot.docs) {
        final driverId = driverDoc.id;
        
        try {
          await notificationService.sendNotificationToUser(
            userId: driverId,
            title: '🚚 Новый заказ доставки',
            body: 'Забрать: $_pickupAddress\nДоставить: $destinationAddress',
            data: {
              'type': 'delivery_request',
              'rideId': rideDoc.id,
              'pickupAddress': _pickupAddress,
              'pickupLocation': '${_pickupLocation!.latitude},${_pickupLocation!.longitude}',
              'destinationAddress': destinationAddress,
              'specialInstructions': notes,
              'companyName': user.fullName,
            },
          );
          
          successfulNotifications++;
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          // Continue with other drivers
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successfulNotifications > 0
                  ? '🚚 Заказ доставки отправлен $successfulNotifications водителям!'
                  : 'Заказ создан, но не удалось отправить уведомления',
            ),
            backgroundColor: successfulNotifications > 0 ? Colors.green : Colors.orange,
          ),
        );
        
        // Navigate to tracking screen
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.push('${AppRoutes.tracking}?rideId=${rideDoc.id}');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Не удалось отправить заказ доставки: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingRequest = false);
      }
    }
  }

  Future<void> _showDeliveryFormForDriver(DriverMarkerData driver) async {
    final TextEditingController destinationController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with driver info
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request delivery from ${driver.name}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '⭐ ${driver.rating.toStringAsFixed(1)} • ${driver.carModel}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Current location info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pickup from:',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              _pickupAddress,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Destination input
                TextField(
                  controller: destinationController,
                  decoration: InputDecoration(
                    labelText: 'Delivery Address *',
                    hintText: 'Enter where to deliver...',
                    prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Notes input
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Special Instructions (Optional)',
                    hintText: 'Any special delivery instructions...',
                    prefixIcon: const Icon(Icons.note, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          final destination = destinationController.text.trim();
                          if (destination.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter delivery address'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          Navigator.pop(context, {
                            'destination': destination,
                            'notes': notesController.text.trim(),
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Send to Driver'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      final destination = result['destination']!;
      final notes = result['notes'] ?? '';
      
      // Send request to specific driver
      await _sendDeliveryRequestToSpecificDriver(driver, destination, notes);
    }
  }

  Future<void> _sendDeliveryRequestToSpecificDriver(DriverMarkerData driver, String destinationAddress, String notes) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      _showError('Пользователь не авторизован');
      return;
    }

    setState(() => _isSendingRequest = true);

    try {
      // Create delivery document
      final rideDoc = await FirebaseFirestore.instance.collection('rides').add({
        'companyUserId': user.id,
        'companyName': user.fullName,
        'driverUserId': null,
        'driverName': null,
        'status': 'pending',
        'pickupLocation': _pickupLocation,
        'pickupAddress': _pickupAddress,
        'destination': null, // Will be geocoded by driver
        'destinationAddress': destinationAddress,
        'specialInstructions': notes.isNotEmpty ? notes : null,
        'requestedAt': FieldValue.serverTimestamp(),
        'acceptedAt': null,
        'arrivedAt': null,
        'startedAt': null,
        'completedAt': null,
        'cancelledAt': null,
        'fare': null,
        'distance': null,
        'durationSeconds': null,
        'rating': null,
        'searchRadius': 100.0,
        'preferredDriverId': driver.id, // Mark as preferred driver
        'type': 'delivery', // Mark as delivery request
      });

      // Send notification to specific driver
      final notificationService = ref.read(notificationServiceProvider);
      
      await notificationService.sendNotificationToUser(
        userId: driver.id,
        title: '🚚 Новый заказ доставки для вас!',
        body: 'Забрать: $_pickupAddress\nДоставить: $destinationAddress',
        data: {
          'type': 'delivery_request',
          'rideId': rideDoc.id,
          'pickupAddress': _pickupAddress,
          'pickupLocation': '${_pickupLocation!.latitude},${_pickupLocation!.longitude}',
          'destinationAddress': destinationAddress,
          'specialInstructions': notes,
          'companyName': user.fullName,
          'isDirectRequest': 'true',
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚚 Заказ доставки отправлен водителю ${driver.name}!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to tracking screen
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.push('${AppRoutes.tracking}?rideId=${rideDoc.id}');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Не удалось отправить заказ доставки: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingRequest = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(allDriversStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Drivers'),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
              icon: const Icon(Icons.my_location),
              onPressed: _getCurrentLocationAndGeocode,
              tooltip: 'Refresh location',
            ),
        ],
      ),
      body: driversAsync.when(
        data: (drivers) {
          final driversWithLocation = drivers.where((driver) {
            return driver['currentLocation'] != null;
          }).toList();

          return Stack(
            children: [
              // Map Widget - Full screen
              _pickupLocation != null
                  ? OSMMapWidget(
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
                      onMapTap: _showLocationSetDialog,
                      onDriverTap: _showDriverInfo,
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          const Text('Getting your location...'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _getCurrentLocationAndGeocode,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
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
                        color: Colors.black.withValues(alpha: 0.1),
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
                        color: Colors.black.withValues(alpha: 0.1),
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
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(allDriversStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      
      // Floating Action Button for showing delivery form
      floatingActionButton: _pickupLocation != null
          ? FloatingActionButton.extended(
              onPressed: _showDeliveryForm,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.local_shipping),
              label: const Text('Request Delivery'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
