import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/ride.dart';
import '../../../domain/entities/user.dart';
import '../../providers/ride_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/osm_map_widget.dart';
import '../shared/rating_screen.dart';
import '../shared/chat_screen.dart';
import '../../widgets/unread_messages_badge.dart';

/// Screen for drivers to manage their active ride
class ActiveRideScreen extends ConsumerStatefulWidget {
  final String rideId;

  const ActiveRideScreen({
    super.key,
    required this.rideId,
  });

  @override
  ConsumerState<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends ConsumerState<ActiveRideScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleIAmHere() async {
    try {
      await ref.read(rideNotifierProvider.notifier).updateRideStatus(
            widget.rideId,
            RideStatus.arrived,
          );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company notified of your arrival')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  Future<void> _handleCompleteOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Завершить заказ'),
        content: const Text('Вы уверены, что хотите завершить этот заказ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Завершить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(rideNotifierProvider.notifier).completeRide(widget.rideId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Заказ успешно завершен!')),
          );
          Navigator.pop(context);
          
          // Show rating screen
          final ride = ref.read(activeRideProvider(widget.rideId)).value;
          if (ride != null) {
            // Get company user info
            final companyUser = await ref.read(userRepositoryProvider).getUserById(ride.companyUserId);
            if (companyUser != null && mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RatingScreen(
                    rideId: widget.rideId,
                    otherUserName: companyUser.fullName,
                    otherUserPhotoUrl: companyUser.profilePhotoUrl,
                    isRatingDriver: false,
                  ),
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось завершить заказ: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleCancelOrder() async {
    // Show cancellation dialog with reason selection
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _CancellationDialog(),
    );

    if (result != null && result['reason'] != null) {
      try {
        // Cancel the ride with the provided reason
        await ref.read(rideNotifierProvider.notifier).cancelRide(
          widget.rideId,
          result['reason']!,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Заказ успешно отменен')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось отменить заказ: $e')),
          );
        }
      }
    }
  }

  Future<void> _openNavigation(GeoPoint destination) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}',
    );
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open navigation')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final rideAsync = ref.watch(activeRideProvider(user?.id ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Ride'),
        elevation: 0,
      ),
      body: rideAsync.when(
        data: (ride) {
          if (ride == null) {
            return const Center(
              child: Text('No active ride found'),
            );
          }
          return _buildRideContent(ride);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading ride: $error'),
        ),
      ),
    );
  }

  Widget _buildRideContent(Ride ride) {
    final user = ref.watch(currentUserProvider).value;
    
    return Column(
      children: [
        // Map section
        SizedBox(
          height: 300,
          child: OSMMapWidget(
            driverLocation: user is Driver ? user.currentLocation : null,
            pickupLocation: ride.pickupLocation,
            destination: ride.destination,
          ),
        ),

        // Ride details
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                _buildStatusCard(ride.status),
                const SizedBox(height: 16),

                // Pickup location
                _buildLocationCard(
                  icon: Icons.my_location,
                  title: 'Pickup Location',
                  address: ride.pickupAddress,
                  location: ride.pickupLocation,
                  onNavigate: () => _openNavigation(ride.pickupLocation),
                ),
                const SizedBox(height: 12),

                // Destination (if available)
                if (ride.destination != null && ride.destinationAddress != null)
                  _buildLocationCard(
                    icon: Icons.location_on,
                    title: 'Destination',
                    address: ride.destinationAddress!,
                    location: ride.destination!,
                    onNavigate: () => _openNavigation(ride.destination!),
                  ),

                const SizedBox(height: 24),

                // Action buttons
                _buildActionButtons(ride),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(RideStatus status) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case RideStatus.accepted:
        statusText = 'Ride Accepted - Navigate to Pickup';
        statusColor = Colors.blue;
        statusIcon = Icons.directions_car;
        break;
      case RideStatus.enroute:
        statusText = 'En Route to Pickup';
        statusColor = Colors.orange;
        statusIcon = Icons.navigation;
        break;
      case RideStatus.arrived:
        statusText = 'Arrived at Pickup';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusText = 'Pending';
        statusColor = Colors.grey;
        statusIcon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
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

  Widget _buildLocationCard({
    required IconData icon,
    required String title,
    required String address,
    required GeoPoint location,
    required VoidCallback onNavigate,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              address,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onNavigate,
                icon: const Icon(Icons.navigation),
                label: const Text('Navigate'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Ride ride) {
    final user = ref.watch(currentUserProvider).value;
    
    return Column(
      children: [
        // "I Am Here" button - show when accepted or enroute
        if (ride.status == RideStatus.accepted || ride.status == RideStatus.enroute)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleIAmHere,
              icon: const Icon(Icons.location_on),
              label: const Text('I Am Here'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),

        const SizedBox(height: 12),

        // "Complete Order" button - show when onTheWay (enroute) or arrived
        if (ride.status == RideStatus.enroute || ride.status == RideStatus.arrived)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleCompleteOrder,
              icon: const Icon(Icons.check_circle),
              label: const Text('Завершить заказ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),

        const SizedBox(height: 12),

        // "Cancel Order" button - show when accepted or enroute (driverAssigned or onTheWay)
        if (ride.status == RideStatus.accepted || ride.status == RideStatus.enroute)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _handleCancelOrder,
              icon: const Icon(Icons.cancel),
              label: const Text('Отменить заказ'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),

        const SizedBox(height: 12),

        // Chat button
        FutureBuilder<User?>(
          future: ref.read(userRepositoryProvider).getUserById(ride.companyUserId),
          builder: (context, snapshot) {
            final companyUser = snapshot.data;
            return SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: companyUser != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              rideId: ride.id,
                              otherUserId: ride.companyUserId,
                              otherUserName: companyUser.fullName,
                            ),
                          ),
                        );
                      }
                    : null,
                icon: user != null
                    ? UnreadMessagesBadge(
                        rideId: ride.id,
                        userId: user.id,
                        child: const Icon(Icons.chat),
                      )
                    : const Icon(Icons.chat),
                label: const Text('Chat with Company'),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        // Emergency contact button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Emergency Contact'),
                    ],
                  ),
                  content: const Text(
                    'This will call emergency services (911). '
                    'Only use in case of real emergency.\n\n'
                    'Do you want to proceed?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Call 911'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                final url = Uri.parse('tel:911');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not make emergency call')),
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.emergency),
            label: const Text('Emergency Contact'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Dialog for driver to cancel order with reason selection
class _CancellationDialog extends StatefulWidget {
  @override
  State<_CancellationDialog> createState() => _CancellationDialogState();
}

class _CancellationDialogState extends State<_CancellationDialog> {
  String? _selectedReason;
  final List<String> _cancellationReasons = [
    'Не могу найти адрес',
    'Проблемы с автомобилем',
    'Личные обстоятельства',
    'Другое',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Отменить заказ'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите причину отмены:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ..._cancellationReasons.map((reason) => RadioListTile<String>(
            title: Text(reason),
            value: reason,
            groupValue: _selectedReason,
            onChanged: (value) {
              setState(() {
                _selectedReason = value;
              });
            },
            contentPadding: EdgeInsets.zero,
            dense: true,
          )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _selectedReason != null
              ? () => Navigator.pop(context, {'reason': _selectedReason})
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Подтвердить отмену'),
        ),
      ],
    );
  }
}
