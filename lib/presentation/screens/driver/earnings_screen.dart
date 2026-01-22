import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/driver_bottom_nav.dart';
import '../../widgets/common/app_card.dart';

/// Enhanced earnings tracking screen for drivers
class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  String _selectedPeriod = 'today'; // today, week, month, year
  bool _isLoading = true;
  Map<String, dynamic> _earnings = {};

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) return;

      final now = DateTime.now();
      DateTime startDate;

      switch (_selectedPeriod) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 'year':
          startDate = now.subtract(const Duration(days: 365));
          break;
        default:
          startDate = DateTime(now.year, now.month, now.day);
      }

      // Query completed rides for the selected period
      final ridesSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('driverUserId', isEqualTo: user.id)
          .where('status', isEqualTo: 'completed')
          .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('completedAt', descending: true)
          .get();

      double totalEarnings = 0.0;
      double totalDistance = 0.0;
      int totalRides = ridesSnapshot.docs.length;
      int totalDuration = 0;
      List<Map<String, dynamic>> recentRides = [];
      Map<String, double> dailyEarnings = {};

      for (var doc in ridesSnapshot.docs) {
        final data = doc.data();
        final fare = (data['fare'] as num?)?.toDouble() ?? 0.0;
        final distance = (data['distance'] as num?)?.toDouble() ?? 0.0;
        final duration = (data['durationSeconds'] as num?)?.toInt() ?? 0;
        final completedAt = (data['completedAt'] as Timestamp?)?.toDate();

        // Driver gets 80% of fare (20% commission)
        final driverEarning = fare * 0.8;
        totalEarnings += driverEarning;
        totalDistance += distance;
        totalDuration += duration;

        // Group by day
        if (completedAt != null) {
          final dateKey = DateFormat('yyyy-MM-dd').format(completedAt);
          dailyEarnings[dateKey] = (dailyEarnings[dateKey] ?? 0.0) + driverEarning;
        }

        // Add to recent rides (limit to 10)
        if (recentRides.length < 10) {
          recentRides.add({
            'id': doc.id,
            'fare': fare,
            'driverEarning': driverEarning,
            'distance': distance,
            'duration': duration,
            'completedAt': completedAt,
            'pickupAddress': data['pickupAddress'] ?? 'Unknown',
            'destinationAddress': data['destinationAddress'] ?? 'Unknown',
          });
        }
      }

      // Calculate averages
      double avgEarningsPerRide = totalRides > 0 ? totalEarnings / totalRides : 0.0;
      double avgDistance = totalRides > 0 ? totalDistance / totalRides : 0.0;
      int avgDuration = totalRides > 0 ? totalDuration ~/ totalRides : 0;

      // Calculate earnings per hour
      double totalHours = totalDuration / 3600;
      double earningsPerHour = totalHours > 0 ? totalEarnings / totalHours : 0.0;

      setState(() {
        _earnings = {
          'totalEarnings': totalEarnings,
          'totalRides': totalRides,
          'totalDistance': totalDistance,
          'totalDuration': totalDuration,
          'avgEarningsPerRide': avgEarningsPerRide,
          'avgDistance': avgDistance,
          'avgDuration': avgDuration,
          'earningsPerHour': earningsPerHour,
          'recentRides': recentRides,
          'dailyEarnings': dailyEarnings,
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading earnings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заработки'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEarnings,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period selector
                    _buildPeriodSelector(),
                    const SizedBox(height: 20),

                    // Total earnings card
                    _buildTotalEarningsCard(),
                    const SizedBox(height: 20),

                    // Statistics cards
                    _buildStatisticsCards(),
                    const SizedBox(height: 20),

                    // Performance metrics
                    _buildPerformanceMetrics(),
                    const SizedBox(height: 20),

                    // Recent rides
                    _buildRecentRides(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const DriverBottomNav(currentIndex: 1),
    );
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPeriodChip('Сегодня', 'today'),
          const SizedBox(width: 8),
          _buildPeriodChip('Неделя', 'week'),
          const SizedBox(width: 8),
          _buildPeriodChip('Месяц', 'month'),
          const SizedBox(width: 8),
          _buildPeriodChip('Год', 'year'),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPeriod = period;
        });
        _loadEarnings();
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildTotalEarningsCard() {
    final totalEarnings = _earnings['totalEarnings'] ?? 0.0;
    final formatter = NumberFormat.currency(symbol: '₸', decimalDigits: 0);

    return AppCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white.withOpacity(0.9),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Общий заработок',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              formatter.format(totalEarnings),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_earnings['totalRides'] ?? 0} поездок',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'За поездку',
            NumberFormat.currency(symbol: '₸', decimalDigits: 0)
                .format(_earnings['avgEarningsPerRide'] ?? 0.0),
            Icons.local_taxi,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'В час',
            NumberFormat.currency(symbol: '₸', decimalDigits: 0)
                .format(_earnings['earningsPerHour'] ?? 0.0),
            Icons.access_time,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    final totalDistance = _earnings['totalDistance'] ?? 0.0;
    final totalDuration = _earnings['totalDuration'] ?? 0;
    final avgDistance = _earnings['avgDistance'] ?? 0.0;
    final avgDuration = _earnings['avgDuration'] ?? 0;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Показатели эффективности',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              'Общая дистанция',
              '${totalDistance.toStringAsFixed(1)} км',
              Icons.route,
            ),
            _buildMetricRow(
              'Общее время',
              '${(totalDuration / 3600).toStringAsFixed(1)} ч',
              Icons.timer,
            ),
            _buildMetricRow(
              'Средняя дистанция',
              '${avgDistance.toStringAsFixed(1)} км',
              Icons.straighten,
            ),
            _buildMetricRow(
              'Среднее время',
              '${(avgDuration / 60).toStringAsFixed(0)} мин',
              Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRides() {
    final recentRides = _earnings['recentRides'] as List<Map<String, dynamic>>? ?? [];

    if (recentRides.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'Нет завершенных поездок',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Последние поездки',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...recentRides.map((ride) => _buildRideTile(ride)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRideTile(Map<String, dynamic> ride) {
    final formatter = NumberFormat.currency(symbol: '₸', decimalDigits: 0);
    final completedAt = ride['completedAt'] as DateTime?;
    final timeStr = completedAt != null
        ? DateFormat('dd MMM, HH:mm').format(completedAt)
        : 'Unknown';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatter.format(ride['driverEarning']),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ride['distance'].toStringAsFixed(1)} км • ${(ride['duration'] / 60).toStringAsFixed(0)} мин',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
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
