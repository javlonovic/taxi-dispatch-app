import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/company_bottom_nav.dart';
import '../../widgets/common/app_card.dart';

/// Analytics dashboard screen for company users
class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen> {
  String _selectedPeriod = 'week'; // week, month, year
  bool _isLoading = true;
  Map<String, dynamic> _analytics = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) return;

      final now = DateTime.now();
      DateTime startDate;

      switch (_selectedPeriod) {
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
          startDate = now.subtract(const Duration(days: 7));
      }

      // Query rides for the selected period
      final ridesSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('companyUserId', isEqualTo: user.id)
          .where('requestedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      int totalRides = ridesSnapshot.docs.length;
      int completedRides = 0;
      int cancelledRides = 0;
      double totalSpent = 0.0;
      double totalDistance = 0.0;
      int totalDuration = 0;
      Map<String, int> driverRideCount = {};
      Map<String, double> driverRatings = {};
      List<double> allRatings = [];

      for (var doc in ridesSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;

        if (status == 'completed') {
          completedRides++;
          totalSpent += (data['fare'] as num?)?.toDouble() ?? 0.0;
          totalDistance += (data['distance'] as num?)?.toDouble() ?? 0.0;
          totalDuration += (data['durationSeconds'] as num?)?.toInt() ?? 0;

          final driverId = data['driverUserId'] as String?;
          if (driverId != null) {
            driverRideCount[driverId] = (driverRideCount[driverId] ?? 0) + 1;
          }

          final rating = data['rating'];
          if (rating != null && rating is Map) {
            final driverRating = (rating['driverRating'] as num?)?.toDouble();
            if (driverRating != null) {
              allRatings.add(driverRating);
              if (driverId != null) {
                driverRatings[driverId] = driverRating;
              }
            }
          }
        } else if (status == 'cancelled') {
          cancelledRides++;
        }
      }

      // Calculate averages
      double avgRating = allRatings.isEmpty
          ? 0.0
          : allRatings.reduce((a, b) => a + b) / allRatings.length;
      double avgFare = completedRides > 0 ? totalSpent / completedRides : 0.0;
      double avgDistance =
          completedRides > 0 ? totalDistance / completedRides : 0.0;
      int avgDuration = completedRides > 0 ? totalDuration ~/ completedRides : 0;

      // Get top drivers
      List<MapEntry<String, int>> topDrivers = driverRideCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topDrivers = topDrivers.take(5).toList();

      // Fetch driver details
      List<Map<String, dynamic>> topDriversDetails = [];
      for (var entry in topDrivers) {
        try {
          final driverDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(entry.key)
              .get();
          if (driverDoc.exists) {
            final driverData = driverDoc.data()!;
            topDriversDetails.add({
              'id': entry.key,
              'name': driverData['fullName'] ?? 'Unknown',
              'rideCount': entry.value,
              'rating': driverRatings[entry.key] ?? 0.0,
              'photoUrl': driverData['profilePhotoUrl'],
            });
          }
        } catch (e) {
          print('Error fetching driver ${entry.key}: $e');
        }
      }

      setState(() {
        _analytics = {
          'totalRides': totalRides,
          'completedRides': completedRides,
          'cancelledRides': cancelledRides,
          'totalSpent': totalSpent,
          'avgRating': avgRating,
          'avgFare': avgFare,
          'avgDistance': avgDistance,
          'avgDuration': avgDuration,
          'topDrivers': topDriversDetails,
        };
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналитика'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period selector
                    _buildPeriodSelector(),
                    const SizedBox(height: 20),

                    // Summary cards
                    _buildSummaryCards(),
                    const SizedBox(height: 20),

                    // Ride statistics
                    _buildRideStatistics(),
                    const SizedBox(height: 20),

                    // Financial overview
                    _buildFinancialOverview(),
                    const SizedBox(height: 20),

                    // Top drivers
                    _buildTopDrivers(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const CompanyBottomNav(currentIndex: 1),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildPeriodButton('Неделя', 'week'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPeriodButton('Месяц', 'month'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPeriodButton('Год', 'year'),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedPeriod = period;
        });
        _loadAnalytics();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: isSelected ? 2 : 0,
      ),
      child: Text(label),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Всего поездок',
            '${_analytics['totalRides'] ?? 0}',
            Icons.local_taxi,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Завершено',
            '${_analytics['completedRides'] ?? 0}',
            Icons.check_circle,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideStatistics() {
    final completedRides = _analytics['completedRides'] ?? 0;
    final cancelledRides = _analytics['cancelledRides'] ?? 0;
    final totalRides = _analytics['totalRides'] ?? 1;
    final completionRate =
        totalRides > 0 ? (completedRides / totalRides * 100).toStringAsFixed(1) : '0.0';

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Статистика поездок',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Процент завершения', '$completionRate%'),
            _buildStatRow('Отменено', '$cancelledRides'),
            _buildStatRow(
              'Средняя оценка',
              (_analytics['avgRating'] ?? 0.0).toStringAsFixed(1),
            ),
            _buildStatRow(
              'Средняя дистанция',
              '${(_analytics['avgDistance'] ?? 0.0).toStringAsFixed(1)} км',
            ),
            _buildStatRow(
              'Среднее время',
              '${(_analytics['avgDuration'] ?? 0) ~/ 60} мин',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialOverview() {
    final totalSpent = _analytics['totalSpent'] ?? 0.0;
    final avgFare = _analytics['avgFare'] ?? 0.0;
    final formatter = NumberFormat.currency(symbol: '₸', decimalDigits: 0);

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Финансовый обзор',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Всего потрачено', formatter.format(totalSpent)),
            _buildStatRow('Средняя стоимость', formatter.format(avgFare)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDrivers() {
    final topDrivers = _analytics['topDrivers'] as List<Map<String, dynamic>>? ?? [];

    if (topDrivers.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'Нет данных о водителях',
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
              'Топ водителей',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...topDrivers.map((driver) => _buildDriverTile(driver)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverTile(Map<String, dynamic> driver) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: driver['photoUrl'] != null
                ? NetworkImage(driver['photoUrl'] as String)
                : null,
            child: driver['photoUrl'] == null
                ? const Icon(Icons.person)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${driver['rideCount']} поездок',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 4),
              Text(
                (driver['rating'] as double).toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
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
}
