import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/ride.dart';
import '../../../domain/entities/user.dart';
import '../../providers/ride_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/driver_bottom_nav.dart';
import '../../widgets/company_bottom_nav.dart';
import '../../../l10n/app_localizations.dart';

/// Enhanced screen to display ride history for both drivers and company users
/// with improved status badges, date/time display, and filtering
class RideHistoryScreen extends ConsumerStatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  ConsumerState<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends ConsumerState<RideHistoryScreen> {
  RideStatus? _statusFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider).value;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.history)),
        body: Center(child: Text(l10n.pleaseLogInToViewHistory)),
      );
    }

    final ridesAsync = ref.watch(rideHistoryProvider(user.id));
    final isDriver = user.type == UserType.driver;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: l10n.filter,
          ),
        ],
      ),
      body: ridesAsync.when(
        data: (rides) {
          // Sort by most recent first (Requirement 15.5)
          final sortedRides = List<Ride>.from(rides)
            ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
          
          final filteredRides = _applyFilters(sortedRides);
          
          if (filteredRides.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noRidesFound,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.yourRideHistoryWillAppearHere,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(rideHistoryProvider(user.id));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredRides.length,
              itemBuilder: (context, index) {
                final ride = filteredRides[index];
                return _buildRideCard(ride, user);
              },
            ),
          );
        },
        loading: () => Center(child: Text(l10n.loading)),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.errorLoadingRideHistory),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(rideHistoryProvider(user.id));
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isDriver
          ? const DriverBottomNav(currentIndex: 1)
          : const CompanyBottomNav(currentIndex: 1),
    );
  }

  /// Apply status and date range filters (Requirement 15.6)
  List<Ride> _applyFilters(List<Ride> rides) {
    var filtered = rides;

    // Filter by status
    if (_statusFilter != null) {
      filtered = filtered.where((ride) => ride.status == _statusFilter).toList();
    }

    // Filter by date range
    if (_startDate != null) {
      filtered = filtered
          .where((ride) => ride.requestedAt.isAfter(_startDate!))
          .toList();
    }
    if (_endDate != null) {
      filtered = filtered
          .where((ride) => ride.requestedAt.isBefore(_endDate!))
          .toList();
    }

    return filtered;
  }

  /// Show filter dialog with status and date range options (Requirement 15.6)
  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.filter),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deliveryStatus,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: Text(l10n.all),
                    selected: _statusFilter == null,
                    onSelected: (selected) {
                      setState(() {
                        _statusFilter = null;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.delivered),
                    avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    selected: _statusFilter == RideStatus.completed,
                    onSelected: (selected) {
                      setState(() {
                        _statusFilter = RideStatus.completed;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.cancelled),
                    avatar: const Icon(Icons.cancel, size: 16, color: Colors.red),
                    selected: _statusFilter == RideStatus.cancelled,
                    onSelected: (selected) {
                      setState(() {
                        _statusFilter = RideStatus.cancelled;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.searching),
                    avatar: const Icon(Icons.search, size: 16, color: Colors.orange),
                    selected: _statusFilter == RideStatus.pending,
                    onSelected: (selected) {
                      setState(() {
                        _statusFilter = RideStatus.pending;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.driverAssigned),
                    avatar: const Icon(Icons.person_pin_circle, size: 16, color: Colors.blue),
                    selected: _statusFilter == RideStatus.accepted,
                    onSelected: (selected) {
                      setState(() {
                        _statusFilter = RideStatus.accepted;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.driverOnTheWay),
                    avatar: const Icon(Icons.local_shipping, size: 16, color: Colors.purple),
                    selected: _statusFilter == RideStatus.enroute,
                    onSelected: (selected) {
                      setState(() {
                        _statusFilter = RideStatus.enroute;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.arrived),
                    avatar: const Icon(Icons.location_on, size: 16, color: Colors.teal),
                    selected: _statusFilter == RideStatus.arrived,
                    onSelected: (selected) {
                      setState(() {
                        _statusFilter = RideStatus.arrived;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.noDriverFound),
                    avatar: const Icon(Icons.error_outline, size: 16, color: Colors.deepOrange),
                    selected: _statusFilter == RideStatus.noDriverFound,
                    onSelected: (selected) {
                      setState(() {
                        _statusFilter = RideStatus.noDriverFound;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.dateRange,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text(_startDate != null
                    ? '${l10n.from}: ${DateFormat.yMMMd('ru').format(_startDate!)}'
                    : l10n.from),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    locale: const Locale('ru'),
                  );
                  if (date != null) {
                    setState(() {
                      _startDate = date;
                    });
                  }
                },
              ),
              ListTile(
                title: Text(_endDate != null
                    ? '${l10n.to}: ${DateFormat.yMMMd('ru').format(_endDate!)}'
                    : l10n.to),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: _startDate ?? DateTime(2020),
                    lastDate: DateTime.now(),
                    locale: const Locale('ru'),
                  );
                  if (date != null) {
                    setState(() {
                      _endDate = date;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _statusFilter = null;
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: Text(l10n.reset),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.apply),
          ),
        ],
      ),
    );
  }

  /// Build ride card with enhanced date/time and address display (Requirements 15.2, 15.3)
  Widget _buildRideCard(Ride ride, User user) {
    final l10n = AppLocalizations.of(context)!;
    final isDriver = user.type == UserType.driver;
    final dateFormat = DateFormat('d MMMM yyyy', 'ru');
    final timeFormat = DateFormat('HH:mm', 'ru');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showRideDetails(ride, isDriver),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date, time and status (Requirement 15.3)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(ride.requestedAt),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeFormat.format(ride.requestedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(ride.status),
                ],
              ),
              const SizedBox(height: 16),

              // Pickup location with label (Requirement 15.3)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.my_location,
                      size: 18,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.pickupAddress,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ride.pickupAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Destination (if available) with label (Requirement 15.3)
              if (ride.destinationAddress != null) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.deliveryAddress,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ride.destinationAddress!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Ride details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Distance
                  if (ride.distance != null)
                    Row(
                      children: [
                        Icon(Icons.straighten, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${(ride.distance! / 1000).toStringAsFixed(1)} км',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                  // Duration
                  if (ride.duration != null)
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${ride.duration!.inMinutes} ${l10n.minutes}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                  // Fare
                  if (ride.fare != null)
                    Text(
                      '₽${ride.fare!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),

              // Rating (if available)
              if (ride.rating != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                _buildRatingSection(ride, isDriver),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build enhanced status chip with icons (Requirement 15.2)
  /// Shows all delivery statuses: Delivered, Cancelled, No Driver Found, Searching, etc.
  Widget _buildStatusChip(RideStatus status) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case RideStatus.completed:
        // Delivered status - green with check icon
        color = Colors.green;
        label = l10n.delivered;
        icon = Icons.check_circle;
        break;
      case RideStatus.cancelled:
        // Cancelled status - red with cancel icon
        color = Colors.red;
        label = l10n.cancelled;
        icon = Icons.cancel;
        break;
      case RideStatus.noDriverFound:
        // No Driver Found status - red/orange with error icon
        color = Colors.deepOrange;
        label = l10n.noDriverFound;
        icon = Icons.error_outline;
        break;
      case RideStatus.pending:
        // Searching/Pending status - orange with search icon
        color = Colors.orange;
        label = l10n.searching;
        icon = Icons.search;
        break;
      case RideStatus.accepted:
        // Driver Assigned status - blue with person icon
        color = Colors.blue;
        label = l10n.driverAssigned;
        icon = Icons.person_pin_circle;
        break;
      case RideStatus.enroute:
        // On The Way status - purple with local shipping icon
        color = Colors.purple;
        label = l10n.driverOnTheWay;
        icon = Icons.local_shipping;
        break;
      case RideStatus.arrived:
        // Arrived status - teal with location icon
        color = Colors.teal;
        label = l10n.arrived;
        icon = Icons.location_on;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(Ride ride, bool isDriver) {
    final rating = isDriver
        ? ride.rating?.driverRating
        : ride.rating?.companyRating;
    final feedback = isDriver
        ? ride.rating?.driverFeedback
        : ride.rating?.companyFeedback;

    if (rating == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(Icons.star, size: 16, color: Colors.amber.shade700),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        if (feedback != null && feedback.isNotEmpty) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feedback,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  /// Show detailed ride information (Requirement 15.4)
  void _showRideDetails(Ride ride, bool isDriver) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.deliveryDetails,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildStatusChip(ride.status),
              const SizedBox(height: 24),
              _buildDetailRow(l10n.deliveryStatus, _getStatusText(ride.status)),
              _buildDetailRow(
                l10n.requestedAt,
                DateFormat('d MMMM yyyy • HH:mm', 'ru').format(ride.requestedAt),
              ),
              if (ride.acceptedAt != null)
                _buildDetailRow(
                  l10n.acceptedAt,
                  DateFormat('d MMMM yyyy • HH:mm', 'ru').format(ride.acceptedAt!),
                ),
              if (ride.completedAt != null)
                _buildDetailRow(
                  l10n.completedAt,
                  DateFormat('d MMMM yyyy • HH:mm', 'ru').format(ride.completedAt!),
                ),
              if (ride.cancelledAt != null) ...[
                _buildDetailRow(
                  l10n.cancelledAt,
                  DateFormat('d MMMM yyyy • HH:mm', 'ru').format(ride.cancelledAt!),
                ),
                if (ride.cancellationReason != null)
                  _buildDetailRow(l10n.cancellationReason, ride.cancellationReason!),
              ],
              const Divider(height: 32),
              _buildDetailRow(l10n.pickupAddress, ride.pickupAddress),
              if (ride.destinationAddress != null)
                _buildDetailRow(l10n.deliveryAddress, ride.destinationAddress!),
              if (ride.recipientName != null)
                _buildDetailRow(l10n.recipientName, ride.recipientName!),
              if (ride.recipientPhone != null)
                _buildDetailRow(l10n.recipientPhone, ride.recipientPhone!),
              const Divider(height: 32),
              if (ride.distance != null)
                _buildDetailRow(
                  l10n.distance,
                  '${(ride.distance! / 1000).toStringAsFixed(1)} км',
                ),
              if (ride.duration != null)
                _buildDetailRow(l10n.duration, '${ride.duration!.inMinutes} ${l10n.minutes}'),
              if (ride.fare != null)
                _buildDetailRow(l10n.amount, '₽${ride.fare!.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(RideStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case RideStatus.pending:
        return l10n.searching;
      case RideStatus.accepted:
        return l10n.driverAssigned;
      case RideStatus.enroute:
        return l10n.driverOnTheWay;
      case RideStatus.arrived:
        return l10n.arrived;
      case RideStatus.completed:
        return l10n.delivered;
      case RideStatus.cancelled:
        return l10n.cancelled;
      case RideStatus.noDriverFound:
        return l10n.noDriverFound;
    }
  }
}
