import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taxi_dispatch_app/l10n/app_localizations.dart';
import '../../core/router/app_router.dart';

/// Bottom navigation bar for company users
class CompanyBottomNav extends StatelessWidget {
  final int currentIndex;

  const CompanyBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.companyDashboard);
        break;
      case 1:
        context.go(AppRoutes.companyProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: l10n.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: l10n.profile,
        ),
      ],
    );
  }
}
