import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/user.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart' as user_provider;
import '../../providers/driver_availability_provider.dart';
import '../../widgets/earnings_summary_widget.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/driver_bottom_nav.dart';

/// Driver dashboard screen
class DriverDashboardScreen extends ConsumerWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Не авторизован')),
          );
        }

        final currentUserAsync = ref.watch(user_provider.currentUserProvider(user.id));

        return currentUserAsync.when(
          data: (currentUser) {
            if (currentUser == null || currentUser is! Driver) {
              return const Scaffold(
                body: Center(child: Text('Водитель не найден')),
              );
            }

            return _DriverDashboardContent(driver: currentUser);
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            body: Center(child: Text('Ошибка: $error')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Ошибка: $error')),
      ),
    );
  }
}

/// Driver dashboard content widget
class _DriverDashboardContent extends ConsumerStatefulWidget {
  final Driver driver;

  const _DriverDashboardContent({required this.driver});

  @override
  ConsumerState<_DriverDashboardContent> createState() =>
      _DriverDashboardContentState();
}

class _DriverDashboardContentState
    extends ConsumerState<_DriverDashboardContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: AppLogoSmall(),
        ),
        title: const Text('Панель водителя'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: widget.driver.profilePhotoUrl != null
                          ? NetworkImage(widget.driver.profilePhotoUrl!)
                          : null,
                      child: widget.driver.profilePhotoUrl == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.driver.fullName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.driver.vehicleInfo.make} ${widget.driver.vehicleInfo.model}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            widget.driver.vehicleInfo.licensePlate,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Active Status Toggle
            Card(
              color: widget.driver.isActive ? Colors.green.shade50 : Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      widget.driver.isActive ? Icons.check_circle : Icons.cancel,
                      color: widget.driver.isActive ? Colors.green : Colors.grey,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.driver.isActive ? 'Вы активны' : 'Вы неактивны',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: widget.driver.isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.driver.isActive
                                ? 'Вы получаете заказы'
                                : 'Включите, чтобы получать заказы',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: widget.driver.isActive,
                      onChanged: (value) async {
                        final notifier = ref.read(
                          driverAvailabilityNotifierProvider(widget.driver.id).notifier,
                        );
                        await notifier.setActive(value);
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          'Total Rides',
                          widget.driver.totalRides.toString(),
                          Icons.local_taxi,
                        ),
                        _buildStatItem(
                          context,
                          'Rating',
                          widget.driver.averageRating.toStringAsFixed(1),
                          Icons.star,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Earnings summary
            EarningsSummaryWidget(driverId: widget.driver.id),
          ],
        ),
      ),
      bottomNavigationBar: const DriverBottomNav(currentIndex: 0),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

}
