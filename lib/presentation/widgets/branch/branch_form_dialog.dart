import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/branch.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/branch_provider.dart';
import 'osm_branch_map_picker.dart';

/// Dialog for adding or editing a branch
class BranchFormDialog extends ConsumerStatefulWidget {
  final String companyId;
  final Branch? branch; // null for add, non-null for edit
  final VoidCallback? onSaved;

  const BranchFormDialog({
    Key? key,
    required this.companyId,
    this.branch,
    this.onSaved,
  }) : super(key: key);

  @override
  ConsumerState<BranchFormDialog> createState() => _BranchFormDialogState();
}

class _BranchFormDialogState extends ConsumerState<BranchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  GeoPoint? _selectedLocation;
  bool _isHeadquarters = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.branch?.name ?? '');
    _addressController = TextEditingController(text: widget.branch?.address ?? '');
    _selectedLocation = widget.branch?.location;
    _isHeadquarters = widget.branch?.isHeadquarters ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.branch != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  _isEditMode ? l10n.editBranch : l10n.addBranch,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Branch name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.branchName,
                    hintText: l10n.branchNameHint,
                    prefixIcon: const Icon(Icons.business),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.branchNameRequired;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Address field
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: l10n.address,
                    hintText: l10n.branchAddress,
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.fieldRequired;
                    }
                    return null;
                  },
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),

                // Location picker button
                OutlinedButton.icon(
                  onPressed: _pickLocation,
                  icon: Icon(
                    _selectedLocation != null
                        ? Icons.check_circle
                        : Icons.map,
                    color: _selectedLocation != null
                        ? Colors.green
                        : null,
                  ),
                  label: Text(
                    _selectedLocation != null
                        ? l10n.branchLocation
                        : l10n.selectLocationOnMap,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    side: BorderSide(
                      color: _selectedLocation != null
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                ),
                if (_selectedLocation != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 16),

                // Headquarters checkbox
                CheckboxListTile(
                  value: _isHeadquarters,
                  onChanged: (value) {
                    setState(() {
                      _isHeadquarters = value ?? false;
                    });
                  },
                  title: Text(l10n.isHeadquarters),
                  subtitle: Text(
                    'Отметьте, если это главный офис',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveBranch,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(l10n.save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickLocation() async {
    final location = await showDialog<GeoPoint>(
      context: context,
      builder: (context) => OSMBranchMapPicker(
        initialLocation: _selectedLocation,
        initialAddress: _addressController.text,
      ),
    );

    if (location != null) {
      setState(() {
        _selectedLocation = location;
      });
    }
  }

  Future<void> _saveBranch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectLocationOnMap),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final branch = Branch(
        id: widget.branch?.id ?? '',
        companyId: widget.companyId,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        location: _selectedLocation!,
        isHeadquarters: _isHeadquarters,
        createdAt: widget.branch?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditMode) {
        await ref.read(branchNotifierProvider.notifier).updateBranch(branch);
      } else {
        await ref.read(branchNotifierProvider.notifier).createBranch(branch);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? AppLocalizations.of(context)!.updatedSuccessfully
                  : AppLocalizations.of(context)!.savedSuccessfully,
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSaved?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_isEditMode ? AppLocalizations.of(context)!.failedToUpdate : AppLocalizations.of(context)!.failedToSave}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
