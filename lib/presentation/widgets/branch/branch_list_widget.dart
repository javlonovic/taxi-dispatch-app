import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/branch.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/branch_provider.dart';
import '../../providers/auth_provider.dart';
import '../loading_widget.dart';
import '../error_widget.dart';
import 'branch_form_dialog.dart';

/// Widget to display list of all branches for a company
class BranchListWidget extends ConsumerWidget {
  final VoidCallback? onBranchAdded;
  final VoidCallback? onBranchUpdated;
  final VoidCallback? onBranchDeleted;

  const BranchListWidget({
    Key? key,
    this.onBranchAdded,
    this.onBranchUpdated,
    this.onBranchDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final branchesAsync = ref.watch(branchesStreamProvider);

    return branchesAsync.when(
      data: (branches) => _buildBranchList(context, ref, branches, l10n),
      loading: () => const LoadingWidget(),
      error: (error, stack) => ErrorDisplayWidget(
        message: error.toString(),
        onRetry: () => ref.refresh(branchesStreamProvider),
      ),
    );
  }

  Widget _buildBranchList(
    BuildContext context,
    WidgetRef ref,
    List<Branch> branches,
    AppLocalizations l10n,
  ) {
    if (branches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.branches,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Нет филиалов',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddBranchDialog(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.addBranch),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with add button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.branches,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddBranchDialog(context, ref),
                icon: const Icon(Icons.add, size: 20),
                label: Text(l10n.addBranch),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Branch list - use SizedBox with fixed height instead of Expanded
        SizedBox(
          height: 300, // Fixed height to prevent overflow
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];
              return _BranchCard(
                branch: branch,
                onEdit: () => _showEditBranchDialog(context, ref, branch),
                onDelete: () => _showDeleteConfirmation(context, ref, branch),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddBranchDialog(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authStateProvider);
    authState.whenData((user) {
      if (user == null) return;

      showDialog(
        context: context,
        builder: (context) => BranchFormDialog(
          companyId: user.id,
          onSaved: () {
            onBranchAdded?.call();
          },
        ),
      );
    });
  }

  void _showEditBranchDialog(
    BuildContext context,
    WidgetRef ref,
    Branch branch,
  ) {
    showDialog(
      context: context,
      builder: (context) => BranchFormDialog(
        companyId: branch.companyId,
        branch: branch,
        onSaved: () {
          onBranchUpdated?.call();
        },
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Branch branch,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    // Check if this is the last branch
    final canDelete = await ref.read(
      canDeleteBranchProvider(
        BranchParams(
          companyId: branch.companyId,
          branchId: branch.id,
        ),
      ).future,
    );

    if (!canDelete) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cannotDeleteLastBranch),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.deleteBranch),
          content: Text(l10n.confirmDeleteBranch),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(l10n.delete),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        try {
          await ref.read(branchNotifierProvider.notifier).deleteBranch(
                branch.companyId,
                branch.id,
              );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.deletedSuccessfully),
                backgroundColor: Colors.green,
              ),
            );
            onBranchDeleted?.call();
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.failedToDelete}: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }
}

/// Card widget for displaying a single branch
class _BranchCard extends StatelessWidget {
  final Branch branch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BranchCard({
    Key? key,
    required this.branch,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Branch name with headquarters badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      branch.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (branch.isHeadquarters) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                l10n.headquarters,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      branch.address,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text(l10n.edit),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    label: Text(l10n.delete),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
