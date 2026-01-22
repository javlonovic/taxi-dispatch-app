import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/user.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/onboarding_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Не авторизован'));
          }

          return ListView(
            children: [
              // Account Section
              _buildSectionHeader(context, 'Аккаунт'),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Профиль'),
                subtitle: Text(user.email),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to profile screen based on user type
                  if (user.type == UserType.driver) {
                    context.go(AppRoutes.driverProfile);
                  } else {
                    context.go(AppRoutes.companyProfile);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Подтверждение Email'),
                subtitle: const Text('Подтвердите адрес электронной почты'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push(AppRoutes.emailVerification);
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Подтверждение телефона'),
                subtitle: const Text('Подтвердите номер телефона'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push(AppRoutes.phoneVerification);
                },
              ),
              const Divider(),

              // Notifications Section
              _buildSectionHeader(context, 'Уведомления'),
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Push-уведомления'),
                subtitle: const Text('Получать обновления о поездках'),
                value: true,
                onChanged: (value) {
                  // Toggle push notifications
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.email_outlined),
                title: const Text('Email-уведомления'),
                subtitle: const Text('Получать обновления по email'),
                value: false,
                onChanged: (value) {
                  // Toggle email notifications
                },
              ),
              const Divider(),

              // Privacy Section
              _buildSectionHeader(context, 'Конфиденциальность и безопасность'),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Изменить пароль'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to change password
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Политика конфиденциальности'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Условия использования'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to terms of service
                },
              ),
              const Divider(),

              // App Section
              _buildSectionHeader(context, 'Приложение'),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Язык'),
                subtitle: const Text('Русский'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to language selection
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Помощь и поддержка'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.push(AppRoutes.helpCenter);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('О приложении'),
                subtitle: const Text('Версия 1.0.0'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Show about dialog with logo
                  _showAboutDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Показать обучение'),
                subtitle: const Text('Повторить вводный тур'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await ref.read(onboardingProvider.notifier).resetOnboarding();
                  if (context.mounted) {
                    context.go(AppRoutes.onboarding);
                  }
                },
              ),
              const Divider(),

              // Logout Section
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Выйти',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Выход'),
                      content: const Text('Вы уверены, что хотите выйти?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Выйти'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await ref.read(authRepositoryProvider).logout();
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App logo
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/icon/app_icon.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if logo doesn't exist
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_taxi,
                      size: 50,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // App name
            const Text(
              'Taxi Dispatch App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Version
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              'Connecting drivers with companies for fast and reliable delivery services.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Copyright
            Text(
              '© 2024 Taxi Dispatch App',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
