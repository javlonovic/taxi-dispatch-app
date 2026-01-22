import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/entities/ride.dart';
import '../../../domain/entities/user.dart';
import '../../providers/ride_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/osm_map_widget.dart';
import '../shared/rating_screen.dart';
import '../shared/chat_screen.dart';
import '../../widgets/unread_messages_badge.dart';

/// Screen for company users to track their active ride
class TrackingScreen extends ConsumerStatefulWidget {
  final String rideId;

  const TrackingScreen({
    super.key,
    required this.rideId,
  });

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  Timer? _locationUpdateTimer;
  GeoPoint? _driverLocation;
  Duration? _eta;
  double? _distance;
  List<LatLng>? _routePolyline;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    // Update location every 15 seconds
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _updateDriverLocation(),
    );
    
    // Initial update
    _updateDriverLocation();
  }

  Future<void> _updateDriverLocation() async {
    final rideAsync = ref.read(rideByIdProvider(widget.rideId));
    
    rideAsync.whenData((ride) async {
      if (ride != null && ride.driverUserId != null) {
        try {
          // Get driver location stream
          final locationStream = ref.read(locationRepositoryProvider)
              .watchDriverLocation(ride.driverUserId!);
          
          locationStream.listen((position) {
            if (mounted) {
              setState(() {
                _driverLocation = GeoPoint(
                  position.latitude,
                  position.longitude,
                );
              });
              
              // Calculate ETA and route
              _calculateETAAndRoute(ride);
            }
          });
        } catch (e) {
          // Handle error silently or show notification
        }
      }
    });
  }

  Future<void> _calculateETAAndRoute(Ride ride) async {
    if (_driverLocation == null) return;

    try {
      final locationRepo = ref.read(locationRepositoryProvider);
      
      // Calculate distance
      final distance = await locationRepo.calculateDistance(
        _driverLocation!,
        ride.pickupLocation,
      );
      
      // Calculate ETA
      final eta = await locationRepo.calculateETA(
        _driverLocation!,
        ride.pickupLocation,
      );
      
      // Get route
      final route = await locationRepo.getRoute(
        _driverLocation!,
        ride.pickupLocation,
      );

      if (mounted) {
        setState(() {
          _distance = distance;
          _eta = eta;
          _routePolyline = route;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _showRatingScreen(Ride ride) async {
    if (ride.driverUserId == null) return;
    
    try {
      // Get driver user info
      final driverUser = await ref.read(userRepositoryProvider).getUserById(ride.driverUserId!);
      
      if (driverUser != null && mounted) {
        // Pop the tracking screen first
        Navigator.pop(context);
        
        // Show rating screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RatingScreen(
              rideId: ride.id,
              otherUserName: driverUser.fullName,
              otherUserPhotoUrl: driverUser.profilePhotoUrl,
              isRatingDriver: true,
            ),
          ),
        );
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _handleFindNewDriver(Ride ride) async {
    // Pop the tracking screen and navigate back to ride request screen
    Navigator.pop(context);
    
    // Show confirmation that they can create a new request
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Вы можете создать новый запрос на доставку'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use rideByIdProvider with the rideId from route parameters
    final rideAsync = ref.watch(rideByIdProvider(widget.rideId));

    // Listen for ride completion to show rating screen
    ref.listen<AsyncValue<Ride?>>(
      rideByIdProvider(widget.rideId),
      (previous, next) {
        next.whenData((ride) {
          if (ride?.status == RideStatus.completed && 
              previous?.value?.status != RideStatus.completed) {
            // Ride just completed, show rating screen
            _showRatingScreen(ride!);
          }
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Отслеживание заказа'),
        elevation: 0,
      ),
      body: rideAsync.when(
        data: (ride) {
          if (ride == null) {
            return const Center(
              child: Text('Активный заказ не найден'),
            );
          }
          return _buildTrackingContent(ride);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Ошибка загрузки заказа: $error',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Retry loading
                  ref.invalidate(rideByIdProvider(widget.rideId));
                },
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingContent(Ride ride) {
    return Column(
      children: [
        // Map section with real-time tracking
        Expanded(
          child: Stack(
            children: [
              OSMMapWidget(
                driverLocation: _driverLocation,
                pickupLocation: ride.pickupLocation,
                destination: ride.destination,
                routePolyline: _routePolyline,
              ),
              
              // ETA and distance overlay
              if (_eta != null || _distance != null)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _buildETACard(),
                ),
            ],
          ),
        ),

        // Ride details section
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildStatusIndicator(ride.status),
              _buildRideDetails(ride),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildETACard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (_eta != null)
              Column(
                children: [
                  const Icon(Icons.access_time, color: Colors.blue),
                  const SizedBox(height: 4),
                  Text(
                    '${_eta!.inMinutes} min',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Время',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            if (_distance != null)
              Column(
                children: [
                  const Icon(Icons.straighten, color: Colors.blue),
                  const SizedBox(height: 4),
                  Text(
                    '${(_distance! / 1000).toStringAsFixed(1)} км',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Расстояние',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            Column(
              children: [
                const Icon(Icons.refresh, color: Colors.blue),
                const SizedBox(height: 4),
                const Text(
                  'Онлайн',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Обновления',
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
    );
  }

  Widget _buildStatusIndicator(RideStatus status) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case RideStatus.accepted:
        statusText = 'Водитель в пути';
        statusColor = Colors.blue;
        statusIcon = Icons.directions_car;
        break;
      case RideStatus.enroute:
        statusText = 'Водитель едет';
        statusColor = Colors.orange;
        statusIcon = Icons.navigation;
        break;
      case RideStatus.arrived:
        statusText = 'Водитель прибыл';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case RideStatus.cancelled:
        statusText = 'Заказ отменен';
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case RideStatus.pending:
        statusText = 'Ожидание водителя';
        statusColor = Colors.grey;
        statusIcon = Icons.pending;
        break;
      default:
        statusText = 'Ожидание водителя';
        statusColor = Colors.grey;
        statusIcon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: statusColor, width: 2),
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideDetails(Ride ride) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show cancellation reason if ride is cancelled
          if (ride.status == RideStatus.cancelled && ride.cancellationReason != null)
            _buildCancellationInfo(ride.cancellationReason!),
          
          // Driver info (if available and not cancelled)
          if (ride.driverUserId != null && ride.status != RideStatus.cancelled)
            _buildDriverInfo(ride.driverUserId!),
          
          const SizedBox(height: 16),

          // Pickup location
          _buildLocationRow(
            icon: Icons.my_location,
            label: 'Место отправления',
            address: ride.pickupAddress,
          ),
          
          const SizedBox(height: 12),

          // Destination (if available)
          if (ride.destinationAddress != null)
            _buildLocationRow(
              icon: Icons.location_on,
              label: 'Место доставки',
              address: ride.destinationAddress!,
            ),

          const SizedBox(height: 16),

          // Action buttons
          _buildActionButtons(ride),
        ],
      ),
    );
  }

  Widget _buildCancellationInfo(String reason) {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade200, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'Причина отмены',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reason,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfo(String driverId) {
    // In production, fetch driver details
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              child: Icon(Icons.person, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ваш водитель',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Загрузка...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      const Text(
                        '0.0',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String label,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Ride ride) {
    final user = ref.watch(currentUserProvider).value;
    
    return Column(
      children: [
        // Show "Find New Driver" button if ride is cancelled
        if (ride.status == RideStatus.cancelled)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleFindNewDriver(ride),
              icon: const Icon(Icons.search),
              label: const Text('Найти нового водителя'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        
        // Chat button (only show if not cancelled and driver is assigned)
        if (ride.status != RideStatus.cancelled && ride.driverUserId != null)
          SizedBox(
            width: double.infinity,
            child: FutureBuilder<User?>(
              future: ref.read(userRepositoryProvider).getUserById(ride.driverUserId!),
              builder: (context, snapshot) {
                final driverUser = snapshot.data;
                return ElevatedButton.icon(
                  onPressed: driverUser != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                rideId: ride.id,
                                otherUserId: ride.driverUserId!,
                                otherUserName: driverUser.fullName,
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: user != null
                      ? UnreadMessagesBadge(
                          rideId: ride.id,
                          userId: user.id,
                          child: const Icon(Icons.chat, color: Colors.white),
                        )
                      : const Icon(Icons.chat, color: Colors.white),
                  label: const Text('Открыть чат'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
