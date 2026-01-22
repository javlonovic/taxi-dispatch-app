 import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/branch.dart';
import '../../providers/auth_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/branch_provider.dart';
import '../../widgets/osm_map_widget.dart';
import '../../widgets/company_bottom_nav.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/search_radius_info.dart';
import '../../widgets/location_map_picker.dart';
import '../../widgets/location_confirmation_dialog.dart';

/// Enhanced screen for company users to request rides with real-time driver tracking
class EnhancedRideRequestScreen extends ConsumerStatefulWidget {
  const EnhancedRideRequestScreen({super.key});

  @override
  ConsumerState<EnhancedRideRequestScreen> createState() =>
      _EnhancedRideRequestScreenState();
}

class _EnhancedRideRequestScreenState
    extends ConsumerState<EnhancedRideRequestScreen> {
  GeoPoint? _pickupLocation;
  String? _pickupAddress;
  GeoPoint? _destination;
  String? _destinationAddress;
  bool _isLoadingLocation = false;
  bool _isSearchingDrivers = false;
  bool _isSendingRequest = false;
  List<Map<String, dynamic>> _nearbyDrivers = [];
  double _searchRadius = AppConstants.defaultSearchRadiusKm;
  
  // Real-time driver tracking
  Stream<List<Map<String, dynamic>>>? _driverLocationStream;
  List<String> _trackedDriverIds = [];

  @override
  void initState() {
    super.initState();
    _requestLocationPermissionAndLoad();
  }

  @override
  void dispose() {
    // Clean up streams
    super.dispose();
  }

  Future<void> _requestLocationPermissionAndLoad() async {
    final locationService = ref.read(locationServiceProvider);
    final geocodingService = ref.read(geocodingServiceProvider);
    
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Request permission
      final hasPermission = await locationService.requestLocationPermission();
      
      if (!hasPermission) {
        if (mounted) {
          _showError('Для заказа поездки требуется разрешение на определение местоположения');
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
      
      // Get readable address using geocoding
      String address;
      try {
        address = await geocodingService.getAddressFromCoordinates(
          position.latitude, 
          position.longitude
        );
      } catch (e) {
        // Fallback to coordinates if geocoding fails
        address = 'Текущее местоположение (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
      }
      
      setState(() {
        _pickupLocation = geoPoint;
        _pickupAddress = address;
      });

      // Search for nearby drivers
      await _searchNearbyDrivers();
    } catch (e) {
      if (mounted) {
        _showError('Не удалось определить местоположение: $e');
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<bool> _showPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Требуется разрешение на местоположение'),
            content: const Text(
              'Приложению необходимо разрешение на определение местоположения для поиска водителей и указания места отправления. Открыть настройки?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Открыть настройки'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _searchNearbyDrivers() async {
    if (_pickupLocation == null) return;

    setState(() {
      _isSearchingDrivers = true;
      _nearbyDrivers = []; // Clear previous results
    });

    try {
      print('🔍 Searching for drivers near: ${_pickupLocation!.latitude}, ${_pickupLocation!.longitude}');
      print('📏 Search radius: $_searchRadius km');

      // Query ALL active drivers (no availability filter initially)
      final driversSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'driver')
          .where('isActive', isEqualTo: true)
          .get();

      print('📊 Found ${driversSnapshot.docs.length} active drivers in database');

      final List<Map<String, dynamic>> allDrivers = [];
      final List<Map<String, dynamic>> availableDrivers = [];
      
      for (var doc in driversSnapshot.docs) {
        final data = doc.data();
        final currentLocation = data['currentLocation'] as GeoPoint?;
        final availabilityStatus = data['availabilityStatus'] as String?;
        
        if (currentLocation != null) {
          // Calculate distance
          final distanceKm = _calculateDistance(
            _pickupLocation!.latitude,
            _pickupLocation!.longitude,
            currentLocation.latitude,
            currentLocation.longitude,
          );
          
          final driverData = {
            'id': doc.id,
            'fullName': data['fullName'] ?? 'Unknown Driver',
            'currentLocation': currentLocation,
            'distanceKm': distanceKm,
            'averageRating': (data['averageRating'] as num?)?.toDouble() ?? 0.0,
            'totalRides': data['totalRides'] ?? 0,
            'profilePhotoUrl': data['profilePhotoUrl'],
            'vehicleInfo': data['vehicleInfo'],
            'availabilityStatus': availabilityStatus ?? 'offline',
            'isActive': data['isActive'] ?? false,
          };

          allDrivers.add(driverData);

          // Only include available drivers within search radius
          if (availabilityStatus == 'available' && distanceKm <= _searchRadius) {
            availableDrivers.add(driverData);
            print('✅ Driver ${data['fullName']}: ${distanceKm.toStringAsFixed(2)}km - $availabilityStatus');
          } else {
            print('❌ Driver ${data['fullName']}: ${distanceKm.toStringAsFixed(2)}km - $availabilityStatus (excluded)');
          }
        } else {
          print('⚠️ Driver ${doc.id} has no location');
        }
      }

      // Sort by distance (closest first)
      availableDrivers.sort((a, b) => 
        (a['distanceKm'] as double).compareTo(b['distanceKm'] as double)
      );

      print('🎯 Found ${availableDrivers.length} available drivers within $_searchRadius km');

      setState(() {
        _nearbyDrivers = availableDrivers;
        _trackedDriverIds = availableDrivers.map((d) => d['id'] as String).toList();
      });

      // Start real-time location tracking
      if (_trackedDriverIds.isNotEmpty) {
        _startRealTimeTracking();
      }

      // Auto-expand search radius if no drivers found
      if (availableDrivers.isEmpty && _searchRadius < 50.0) {
        print('🔄 No drivers found, expanding search radius...');
        setState(() {
          _searchRadius = (_searchRadius * 1.5).clamp(5.0, 50.0);
        });
        // Recursively search with larger radius
        await Future.delayed(const Duration(milliseconds: 500));
        await _searchNearbyDrivers();
      }
    } catch (e, stackTrace) {
      print('❌ Error searching for drivers: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        _showError('Не удалось найти водителей: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingDrivers = false;
        });
      }
    }
  }

  // Calculate distance between two coordinates using Haversine formula
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

  void _startRealTimeTracking() {
    if (_trackedDriverIds.isEmpty) {
      print('⚠️ No drivers to track');
      return;
    }

    print('📡 Starting real-time tracking for ${_trackedDriverIds.length} drivers');

    // Create a stream that listens to location updates for tracked drivers
    _driverLocationStream = FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: _trackedDriverIds)
        .where('type', isEqualTo: 'driver')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final currentLocation = data['currentLocation'] as GeoPoint?;
        
        // Recalculate distance if location exists
        double? distanceKm;
        if (currentLocation != null && _pickupLocation != null) {
          distanceKm = _calculateDistance(
            _pickupLocation!.latitude,
            _pickupLocation!.longitude,
            currentLocation.latitude,
            currentLocation.longitude,
          );
        }
        
        return {
          'id': doc.id,
          'fullName': data['fullName'] ?? 'Unknown Driver',
          'currentLocation': currentLocation,
          'distanceKm': distanceKm,
          'averageRating': (data['averageRating'] as num?)?.toDouble() ?? 0.0,
          'totalRides': data['totalRides'] ?? 0,
          'profilePhotoUrl': data['profilePhotoUrl'],
          'vehicleInfo': data['vehicleInfo'],
          'availabilityStatus': data['availabilityStatus'] ?? 'offline',
          'isActive': data['isActive'] ?? false,
        };
      }).where((driver) {
        // Only include drivers with valid location and available status
        return driver['currentLocation'] != null &&
               driver['availabilityStatus'] == 'available' &&
               driver['isActive'] == true;
      }).toList();
    });

    // Listen to the stream and update UI
    _driverLocationStream!.listen(
      (updatedDrivers) {
        if (!mounted) return;

        print('🔄 Received location update for ${updatedDrivers.length} drivers');

        setState(() {
          // Update existing drivers or add new ones
          for (var updatedDriver in updatedDrivers) {
            final index = _nearbyDrivers.indexWhere(
              (d) => d['id'] == updatedDriver['id']
            );
            
            if (index != -1) {
              // Update existing driver
              _nearbyDrivers[index] = updatedDriver;
            } else {
              // Add new driver if within radius
              final distanceKm = updatedDriver['distanceKm'] as double?;
              if (distanceKm != null && distanceKm <= _searchRadius) {
                _nearbyDrivers.add(updatedDriver);
              }
            }
          }

          // Remove drivers that are no longer available
          _nearbyDrivers.removeWhere((driver) {
            final stillExists = updatedDrivers.any((d) => d['id'] == driver['id']);
            return !stillExists;
          });

          // Re-sort by distance
          _nearbyDrivers.sort((a, b) {
            final distA = (a['distanceKm'] as double?) ?? double.infinity;
            final distB = (b['distanceKm'] as double?) ?? double.infinity;
            return distA.compareTo(distB);
          });
        });
      },
      onError: (error) {
        print('❌ Error in real-time tracking: $error');
      },
    );
  }

  Future<void> _sendRideRequest() async {
    print('🚀 Starting ride request process...');

    // Validation
    if (_pickupLocation == null || _pickupAddress == null) {
      _showError('Пожалуйста, укажите место отправления');
      return;
    }

    if (_nearbyDrivers.isEmpty) {
      _showError('Нет доступных водителей поблизости. Попробуйте обновить поиск.');
      return;
    }

    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      _showError('Пользователь не авторизован');
      return;
    }

    setState(() {
      _isSendingRequest = true;
    });

    DocumentReference? rideDoc;
    int successfulNotifications = 0;

    try {
      print('📝 Creating ride document...');
      
      // Create ride document with all necessary fields
      rideDoc = await FirebaseFirestore.instance.collection('rides').add({
        'companyUserId': user.id,
        'companyName': user.fullName,
        'driverUserId': null,
        'driverName': null,
        'status': 'pending',
        'pickupLocation': _pickupLocation,
        'pickupAddress': _pickupAddress,
        'destination': _destination,
        'destinationAddress': _destinationAddress,
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
        'notifiedDrivers': _nearbyDrivers.map((d) => d['id']).toList(),
        'searchRadius': _searchRadius,
      });

      print('✅ Ride created with ID: ${rideDoc.id}');
      print('📢 Sending notifications to ${_nearbyDrivers.length} drivers...');

      // Send notifications to all nearby drivers
      final notificationService = ref.read(notificationServiceProvider);
      
      for (int i = 0; i < _nearbyDrivers.length; i++) {
        final driver = _nearbyDrivers[i];
        final driverId = driver['id'] as String;
        final driverName = driver['fullName'] as String;
        final distanceKm = driver['distanceKm'] as double?;
        
        try {
          print('📤 Sending notification to driver $driverName ($driverId)...');
          
          await notificationService.sendNotificationToUser(
            userId: driverId,
            title: 'Новый заказ',
            body: distanceKm != null
                ? 'Место отправления: $_pickupAddress (${distanceKm.toStringAsFixed(1)}км)'
                : 'Место отправления: $_pickupAddress',
            data: {
              'type': 'ride_request',
              'rideId': rideDoc.id,
              'pickupAddress': _pickupAddress!,
              'pickupLocation': '${_pickupLocation!.latitude},${_pickupLocation!.longitude}',
              'destinationAddress': _destinationAddress ?? '',
              'destination': _destination != null 
                  ? '${_destination!.latitude},${_destination!.longitude}'
                  : '',
              'companyName': user.fullName,
              'distance': distanceKm?.toStringAsFixed(1) ?? '0',
            },
          );
          
          successfulNotifications++;
          print('✅ Notification sent to $driverName');
          
          // Small delay between notifications to avoid rate limiting
          if (i < _nearbyDrivers.length - 1) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
        } catch (e) {
          print('❌ Failed to notify driver $driverName: $e');
          // Continue with other drivers even if one fails
        }
      }

      print('📊 Notifications sent: $successfulNotifications/${_nearbyDrivers.length}');

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successfulNotifications > 0
                  ? 'Заказ отправлен $successfulNotifications ${_getDriverWord(successfulNotifications)}!'
                  : 'Заказ создан, но не удалось отправить уведомления',
            ),
            backgroundColor: successfulNotifications > 0 ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
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
      
      // If ride was created but notifications failed, still navigate to tracking
      if (rideDoc != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successfulNotifications > 0
                  ? 'Заказ создан, уведомлено $successfulNotifications ${_getDriverWord(successfulNotifications)}'
                  : 'Заказ создан, но возникли проблемы с уведомлениями',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.push('${AppRoutes.tracking}?rideId=${rideDoc.id}');
        }
      } else if (mounted) {
        _showError('Не удалось отправить заказ: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingRequest = false;
        });
      }
    }
  }

  String _getDriverWord(int count) {
    if (count == 1) return 'водителю';
    if (count >= 2 && count <= 4) return 'водителям';
    return 'водителям';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _showLocationOptions({required bool isPickup}) async {
    if (isPickup) {
      // For pickup location, go directly to map picker
      await _selectLocationOnMap(isPickup);
    } else {
      // For destination, show options
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Выбрать место назначения'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.my_location, color: Colors.blue),
                title: const Text('Текущее местоположение'),
                subtitle: const Text('Использовать GPS'),
                onTap: () => Navigator.pop(context, 'current'),
              ),
              ListTile(
                leading: const Icon(Icons.business, color: Colors.green),
                title: const Text('Адрес филиала'),
                subtitle: const Text('Выбрать из ваших филиалов'),
                onTap: () => Navigator.pop(context, 'branch'),
              ),
              ListTile(
                leading: const Icon(Icons.map, color: Colors.orange),
                title: const Text('Выбрать на карте'),
                subtitle: const Text('Поиск и выбор на карте'),
                onTap: () => Navigator.pop(context, 'map'),
              ),
            ],
          ),
        ),
      );

      if (result == null) return;

      switch (result) {
        case 'current':
          await _useCurrentLocation(isPickup);
          break;
        case 'branch':
          await _selectBranchLocation(isPickup);
          break;
        case 'map':
          await _selectLocationOnMap(isPickup);
          break;
      }
    }
  }

  Future<void> _useCurrentLocation(bool isPickup) async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentLocation();
      
      setState(() {
        if (isPickup) {
          _pickupLocation = GeoPoint(position.latitude, position.longitude);
          _pickupAddress = 'Текущее местоположение';
        } else {
          _destination = GeoPoint(position.latitude, position.longitude);
          _destinationAddress = 'Текущее местоположение';
        }
      });

      if (isPickup) {
        await _searchNearbyDrivers();
      }
    } catch (e) {
      _showError('Не удалось получить местоположение: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _selectBranchLocation(bool isPickup) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final branchesAsync = ref.read(branchesStreamProvider);
    
    final branches = branchesAsync.when(
      data: (branches) => branches,
      loading: () => <Branch>[],
      error: (_, __) => <Branch>[],
    );

    if (branches.isEmpty) {
      _showError('У вас нет филиалов. Добавьте филиал в профиле компании.');
      return;
    }

    final selectedBranch = await showDialog<Branch>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите филиал'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];
              return ListTile(
                leading: Icon(
                  branch.isHeadquarters ? Icons.home_work : Icons.business,
                  color: branch.isHeadquarters ? Colors.blue : Colors.green,
                ),
                title: Text(branch.name),
                subtitle: Text(branch.address),
                trailing: branch.isHeadquarters
                    ? Chip(
                        label: const Text(
                          'Главный',
                          style: TextStyle(fontSize: 10),
                        ),
                        backgroundColor: Colors.blue.shade100,
                        padding: EdgeInsets.zero,
                      )
                    : null,
                onTap: () => Navigator.pop(context, branch),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );

    if (selectedBranch != null) {
      setState(() {
        if (isPickup) {
          _pickupLocation = selectedBranch.location;
          _pickupAddress = '${selectedBranch.name} - ${selectedBranch.address}';
        } else {
          _destination = selectedBranch.location;
          _destinationAddress = '${selectedBranch.name} - ${selectedBranch.address}';
        }
      });

      if (isPickup) {
        await _searchNearbyDrivers();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPickup
                ? 'Место отправления: ${selectedBranch.name}'
                : 'Место назначения: ${selectedBranch.name}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _selectLocationOnMap(bool isPickup) async {
    // Определяем начальное местоположение для карты
    GeoPoint? initialLocation;
    if (isPickup && _pickupLocation != null) {
      initialLocation = _pickupLocation;
    } else if (!isPickup && _destination != null) {
      initialLocation = _destination;
    } else if (_pickupLocation != null) {
      initialLocation = _pickupLocation;
    }

    // Открываем карту для выбора местоположения
    final result = await Navigator.of(context).push<SelectedLocation>(
      MaterialPageRoute(
        builder: (context) => LocationMapPicker(
          initialLocation: initialLocation,
          title: isPickup ? 'Выберите место отправления' : 'Выберите место назначения',
          confirmButtonText: 'Выбрать это место',
          onLocationSelected: (selectedLocation) {
            Navigator.of(context).pop(selectedLocation);
          },
        ),
      ),
    );

    if (result == null) return;

    // Показываем диалог подтверждения
    final confirmed = await showLocationConfirmationDialog(
      context: context,
      title: isPickup ? 'Подтвердите место отправления' : 'Подтвердите место назначения',
      address: result.address,
      location: result.geoPoint,
      subtitle: isPickup 
          ? 'Водители будут искать вас по этому адресу'
          : 'Водитель доставит вас по этому адресу',
    );

    if (confirmed) {
      setState(() {
        if (isPickup) {
          _pickupLocation = result.geoPoint;
          _pickupAddress = result.address;
        } else {
          _destination = result.geoPoint;
          _destinationAddress = result.address;
        }
      });

      if (isPickup) {
        await _searchNearbyDrivers();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPickup
                ? 'Место отправления выбрано'
                : 'Место назначения выбрано',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заказать поездку'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isSearchingDrivers ? null : _searchNearbyDrivers,
          ),
        ],
      ),
      body: _isLoadingLocation
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Определение вашего местоположения...'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Map section
                  SizedBox(
                    height: 250, // Reduced height to save space
                    child: OSMMapWidget(
                      pickupLocation: _pickupLocation,
                      destination: _destination,
                      nearbyDrivers: _nearbyDrivers
                          .map((driver) => DriverMarkerData(
                                id: driver['id'] as String,
                                name: driver['fullName'] as String,
                                location: driver['currentLocation'] as GeoPoint,
                                carModel:
                                    '${driver['vehicleInfo']?['make']} ${driver['vehicleInfo']?['model']}',
                                rating:
                                    (driver['averageRating'] as num?)?.toDouble() ??
                                        0.0,
                                availabilityStatus: driver['availabilityStatus'] as String? ?? 'offline',
                              ))
                          .toList(),
                    ),
                  ),

                  // Location details
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPickupLocationField(
                          value: _pickupAddress ?? 'Нажмите для выбора местоположения',
                          onTap: () => _showLocationOptions(isPickup: true),
                          isLoading: _isLoadingLocation,
                        ),
                        const SizedBox(height: 12),
                        _buildLocationField(
                          icon: Icons.location_on,
                          label: 'Место назначения (необязательно)',
                          value: _destinationAddress ?? 'Не указано',
                          onTap: () => _showLocationOptions(isPickup: false),
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Drivers section header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Доступные водители',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SearchRadiusInfo(
                          currentRadiusKm: _searchRadius,
                          driverCount: _nearbyDrivers.length,
                          isSearching: _isSearchingDrivers,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Available drivers list with fixed height
                  SizedBox(
                    height: 300, // Fixed height instead of Expanded
                    child: _nearbyDrivers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_taxi,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Нет доступных водителей',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Радиус поиска: ${_searchRadius.toStringAsFixed(1)} км',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: _searchNearbyDrivers,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Обновить поиск'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _nearbyDrivers.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              final driver = _nearbyDrivers[index];
                              return _buildDriverCard(driver);
                            },
                          ),
                  ),

                  // Cost and balance info
                  _buildCostInfo(context, ref),

                  // Send request button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AppButton(
                      text: _isSendingRequest
                          ? 'Отправка...'
                          : 'Заказать у ${_nearbyDrivers.length} ${_nearbyDrivers.length == 1 ? "водителя" : "водителей"}',
                      onPressed: _nearbyDrivers.isEmpty || _isSendingRequest
                          ? null
                          : _sendRideRequest,
                      isLoading: _isSendingRequest,
                    ),
                  ),
                  
                  // Add bottom padding to account for bottom navigation
                  const SizedBox(height: 80),
                ],
              ),
            ),
      bottomNavigationBar: const CompanyBottomNav(currentIndex: 0),
    );
  }

  Widget _buildPickupLocationField({
    required String value,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.shade50,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.my_location,
                color: Colors.blue.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Место отправления',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!isLoading)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Нажмите для изменения',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (isLoading)
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Определение местоположения...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                ],
              ),
            ),
            if (!isLoading)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.edit_location_alt,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    final distanceKm = driver['distanceKm'] as double?;
    final vehicleInfo = driver['vehicleInfo'] as Map<String, dynamic>?;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Driver photo
            CircleAvatar(
              radius: 30,
              backgroundImage: driver['profilePhotoUrl'] != null
                  ? NetworkImage(driver['profilePhotoUrl'] as String)
                  : null,
              child: driver['profilePhotoUrl'] == null
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
            const SizedBox(width: 12),

            // Driver details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver['fullName'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (vehicleInfo != null)
                    Text(
                      '${vehicleInfo['make']} ${vehicleInfo['model']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  if (vehicleInfo != null)
                    Text(
                      '${vehicleInfo['color']} • ${vehicleInfo['licensePlate']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ((driver['averageRating'] as num?)?.toDouble() ?? 0.0)
                            .toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${driver['totalRides'] ?? 0} rides)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Distance indicator
            if (distanceKm != null)
              Column(
                children: [
                  Icon(Icons.location_on, color: Colors.blue.shade700),
                  const SizedBox(height: 4),
                  Text(
                    '${distanceKm.toStringAsFixed(1)}km',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostInfo(BuildContext context, WidgetRef ref) {
    const rideCost = 25000.0; // Fixed cost per ride
    final user = ref.watch(currentUserProvider).value;
    
    if (user == null || user is! Company) {
      return const SizedBox.shrink();
    }

    final currentBalance = user.balance;
    final remainingBalance = currentBalance - rideCost;
    final balanceColor = remainingBalance >= 100000
        ? Colors.green
        : remainingBalance >= 50000
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Стоимость:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '25,000 сум',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Текущий баланс:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${currentBalance.toStringAsFixed(0)} сум',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Остаток после оплаты:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${remainingBalance.toStringAsFixed(0)} сум',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: balanceColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
