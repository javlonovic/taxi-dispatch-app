import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/branch.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/branch_provider.dart';
import '../loading_widget.dart';
import '../error_widget.dart';

/// Bottom sheet for selecting a branch for delivery requests
class BranchSelectorBottomSheet extends ConsumerStatefulWidget {
  final String companyId;
  final String? selectedBranchId;

  const BranchSelectorBottomSheet({
    Key? key,
    required this.companyId,
    this.selectedBranchId,
  }) : super(key: key);

  @override
  ConsumerState<BranchSelectorBottomSheet> createState() =>
      _BranchSelectorBottomSheetState();

  /// Show the branch selector bottom sheet
  static Future<Branch?> show(
    BuildContext context,
    String companyId, {
    String? selectedBranchId,
  }) {
    return showModalBottomSheet<Branch>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => BranchSelectorBottomSheet(
        companyId: companyId,
        selectedBranchId: selectedBranchId,
      ),
    );
  }
}

class _BranchSelectorBottomSheetState
    extends ConsumerState<BranchSelectorBottomSheet> {
  String? _selectedBranchId;

  @override
  void initState() {
    super.initState();
    _selectedBranchId = widget.selectedBranchId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final branchesAsync = ref.watch(
      companyBranchesStreamProvider(widget.companyId),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.selectBranchForDelivery,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Branch list
            Expanded(
              child: branchesAsync.when(
                data: (branches) => _buildBranchList(
                  context,
                  branches,
                  scrollController,
                  l10n,
                ),
                loading: () => const LoadingWidget(),
                error: (error, stack) => ErrorDisplayWidget(
                  message: error.toString(),
                  onRetry: () => ref.refresh(
                    companyBranchesStreamProvider(widget.companyId),
                  ),
                ),
              ),
            ),

            // Confirm button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedBranchId != null
                      ? () => _confirmSelection(context, branchesAsync.value)
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.confirm,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBranchList(
    BuildContext context,
    List<Branch> branches,
    ScrollController scrollController,
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
              'Нет филиалов',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: branches.length,
      itemBuilder: (context, index) {
        final branch = branches[index];
        final isSelected = _selectedBranchId == branch.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedBranchId = branch.id;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Radio button
                  Radio<String>(
                    value: branch.id,
                    groupValue: _selectedBranchId,
                    onChanged: (value) {
                      setState(() {
                        _selectedBranchId = value;
                      });
                    },
                  ),
                  const SizedBox(width: 12),

                  // Branch info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Branch name with headquarters badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                branch.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            if (branch.isHeadquarters)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 12,
                                      color: Colors.blue[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.headquarters,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Address
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                branch.address,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[700],
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Selected indicator
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmSelection(BuildContext context, List<Branch>? branches) {
    if (_selectedBranchId == null || branches == null) return;

    final selectedBranch = branches.firstWhere(
      (branch) => branch.id == _selectedBranchId,
    );

    Navigator.of(context).pop(selectedBranch);
  }
}
