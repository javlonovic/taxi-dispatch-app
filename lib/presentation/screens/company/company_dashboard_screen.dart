import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taxi_dispatch_app/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/company_bottom_nav.dart';
import '../../widgets/company/first_time_user_banner.dart';
import '../../widgets/company/recent_deliveries_widget.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/notification_badge.dart';

/// Company dashboard screen with enhanced UI
/// Displays first-time user banner, prominent search button, and recent deliveries
class CompanyDashboardScreen extends ConsumerWidget {
  const CompanyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null || user is! Company) {
          return _buildErrorState(context, l10n);
        }
        
        return _buildDashboard(context, ref, l10n, user);
      },
      loading: () => _buildLoadingState(context, l10n),
      error: (error, stack) => _buildErrorState(context, l10n),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Company company,
  ) {
    final recentRidesAsync = ref.watch(rideHistoryProvider(company.id));
    
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: AppLogoSmall(),
        ),
        title: Text(l10n.companyDashboard),
        actions: [
          const NotificationBadge(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
            tooltip: 'Settings',
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(rideHistoryProvider(company.id));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // First-time user banner
              if (!company.hasCompletedFirstOrder)
                FirstTimeUserBanner(
                  onDismiss: () => _dismissBanner(ref, company.id),
                  onLearnMore: () => _showHelpDialog(context, l10n),
                ),
              
              if (!company.hasCompletedFirstOrder)
                const SizedBox(height: AppSpacing.xl),
              
              // Welcome message
              Text(
                'Добро пожаловать, ${company.companyName}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Создайте заказ или просмотрите историю',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Primary action button - large and prominent
              ElevatedButton.icon(
                icon: const Icon(Icons.local_taxi, size: 32),
                label: Text(
                  l10n.searchForTaxi,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xl,
                    horizontal: AppSpacing.lg,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                onPressed: () => _initiateDeliveryRequest(context, ref, company),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Quick stats
              _buildQuickStats(context, l10n, company),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Recent deliveries section
              recentRidesAsync.when(
                data: (rides) {
                  final recentRides = rides.take(5).toList();
                  return RecentDeliveriesWidget(
                    deliveries: recentRides,
                    onViewAll: () => context.go(AppRoutes.rideHistory),
                  );
                },
                loading: () => const ShimmerList(itemCount: 3),
                error: (error, stack) => Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Не удалось загрузить историю',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () {
                          ref.invalidate(rideHistoryProvider(company.id));
                        },
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CompanyBottomNav(currentIndex: 0),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    AppLocalizations l10n,
    Company company,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.history,
            label: 'Всего заказов',
            value: company.totalRides.toString(),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.star,
            label: l10n.rating,
            value: company.averageRating.toStringAsFixed(1),
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.companyDashboard),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
      bottomNavigationBar: const CompanyBottomNav(currentIndex: 0),
    );
  }

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.companyDashboard),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.somethingWentWrong,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Пожалуйста, войдите снова',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CompanyBottomNav(currentIndex: 0),
    );
  }

  Future<void> _initiateDeliveryRequest(
    BuildContext context,
    WidgetRef ref,
    Company company,
  ) async {
    // Navigate to ride request screen
    if (context.mounted) {
      context.go(AppRoutes.rideRequest);
    }
  }

  Future<void> _dismissBanner(WidgetRef ref, String companyId) async {
    // Mark first order as completed to dismiss banner
    final userRepository = ref.read(userRepositoryProvider);
    try {
      await userRepository.markFirstOrderCompleted(companyId);
      // Refresh auth state to update UI
      ref.invalidate(authStateProvider);
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  void _showHelpDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.howToOrder),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpStep(
                context,
                '1',
                'Нажмите кнопку "Найти такси"',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildHelpStep(
                context,
                '2',
                'Выберите филиал (если у вас несколько)',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildHelpStep(
                context,
                '3',
                'Заполните детали доставки',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildHelpStep(
                context,
                '4',
                'Подтвердите заказ и ждите водителя',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpStep(BuildContext context, String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
