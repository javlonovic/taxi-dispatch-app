import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../providers/onboarding_provider.dart';

enum OnboardingPageType {
  welcome,
  forCompanies,
  forDrivers,
  getStarted,
}

class OnboardingPage extends ConsumerWidget {
  final OnboardingPageType type;

  const OnboardingPage({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (type) {
      case OnboardingPageType.welcome:
        return _WelcomePage();
      case OnboardingPageType.forCompanies:
        return _ForCompaniesPage();
      case OnboardingPageType.forDrivers:
        return _ForDriversPage();
      case OnboardingPageType.getStarted:
        return _GetStartedPage();
    }
  }
}

// Welcome Screen
class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // App logo - use actual logo if available, fallback to icon
            const _AppLogo(size: 120),
            
            const SizedBox(height: 40),
            
            // Title
            Text(
              'Добро пожаловать!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                height: 1.3,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // App name
            const Text(
              'Vezunchik',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Subtitle
            Text(
              'Быстрая и надежная доставка\nдля вашего бизнеса',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// For Companies Screen
class _ForCompaniesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Illustration
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withValues(alpha: 0.2),
                    Colors.blue.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.business_center,
                size: 90,
                color: Colors.blue[700],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              'Для компаний',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              'Заказывайте доставку из любого\nфилиала вашей компании',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Features
            const _FeatureItem(
              icon: Icons.account_tree,
              text: 'Управление филиалами',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            const _FeatureItem(
              icon: Icons.location_on,
              text: 'Отслеживание в реальном времени',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            const _FeatureItem(
              icon: Icons.history,
              text: 'История доставок',
              color: Colors.blue,
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// For Drivers Screen
class _ForDriversPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Illustration
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withValues(alpha: 0.2),
                    Colors.green.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_shipping,
                size: 90,
                color: Colors.green[700],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              'Для водителей',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              'Принимайте заказы и\nзарабатывайте больше',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Features
            const _FeatureItem(
              icon: Icons.schedule,
              text: 'Гибкий график',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            const _FeatureItem(
              icon: Icons.notifications_active,
              text: 'Мгновенные уведомления',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            const _FeatureItem(
              icon: Icons.account_balance_wallet,
              text: 'Отслеживание заработка',
              color: Colors.green,
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Get Started Screen
class _GetStartedPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // Icon
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rocket_launch,
                size: 75,
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Title
            Text(
              'Готовы начать?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              'Выберите свою роль для регистрации',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Company button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(onboardingProvider.notifier).completeOnboarding();
                  if (context.mounted) {
                    context.go(AppRoutes.companyRegistration);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.blue.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.business_center, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Я компания',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Driver button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(onboardingProvider.notifier).completeOnboarding();
                  if (context.mounted) {
                    context.go(AppRoutes.driverRegistration);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.green.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_shipping, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Я водитель',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// Feature item widget
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final MaterialColor? color;

  const _FeatureItem({
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final featureColor = color ?? Colors.blue;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: featureColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: featureColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: featureColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: featureColor[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// App Logo widget - displays actual logo or fallback icon
class _AppLogo extends StatelessWidget {
  final double size;

  const _AppLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    // Try to load the logo image, with fallback to icon
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(16),
      child: Image.asset(
        'assets/icon/app_icon.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to icon if image doesn't exist or fails to load
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_taxi,
              size: size * 0.53, // 80/150 ratio
              color: Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }
}
