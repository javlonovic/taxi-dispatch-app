import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/branch.dart';
import '../../providers/branch_provider.dart';
import '../../widgets/branch/branch_selector_bottom_sheet.dart';
import 'delivery_request_form_screen.dart';

/// Coordinator for initiating delivery requests
/// Handles branch selection if company has multiple branches
class DeliveryRequestCoordinator {
  /// Start the delivery request flow
  /// Shows branch selector if company has multiple branches, then shows the form
  static Future<void> startDeliveryRequest(
    BuildContext context,
    WidgetRef ref,
    String companyId,
  ) async {
    try {
      // Get company branches
      final branchesAsync = ref.read(
        companyBranchesStreamProvider(companyId),
      );

      final branches = await branchesAsync.when(
        data: (branches) => Future.value(branches),
        loading: () => Future<List<Branch>>.value([]),
        error: (error, stack) => throw error,
      );

      Branch? selectedBranch;

      if (branches.isEmpty) {
        // No branches - show error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'У вас нет филиалов. Пожалуйста, добавьте филиал в профиле.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      } else if (branches.length == 1) {
        // Single branch - use it automatically
        selectedBranch = branches.first;
      } else {
        // Multiple branches - show selector
        if (context.mounted) {
          selectedBranch = await BranchSelectorBottomSheet.show(
            context,
            companyId,
          );
        }

        // User cancelled branch selection
        if (selectedBranch == null) {
          return;
        }
      }

      // Navigate to delivery request form with selected branch
      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DeliveryRequestFormScreen(
              branchId: selectedBranch!.id,
              pickupLocation: selectedBranch.location,
              pickupAddress: selectedBranch.address,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
