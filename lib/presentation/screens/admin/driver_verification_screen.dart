import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/user.dart';
import '../../providers/repository_providers.dart';

/// Admin screen for reviewing and verifying driver documents
class DriverVerificationScreen extends ConsumerStatefulWidget {
  const DriverVerificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DriverVerificationScreen> createState() =>
      _DriverVerificationScreenState();
}

class _DriverVerificationScreenState
    extends ConsumerState<DriverVerificationScreen> {
  bool _isLoading = true;
  List<Driver> _pendingDrivers = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPendingDrivers();
  }

  Future<void> _loadPendingDrivers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final drivers = await ref
          .read(userRepositoryProvider)
          .getPendingDriverVerifications();

      if (mounted) {
        setState(() {
          _pendingDrivers = drivers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateVerificationStatus(
    Driver driver,
    VerificationStatus status,
    String? notes,
  ) async {
    try {
      await ref
          .read(userRepositoryProvider)
          .updateDriverVerificationStatus(driver.id, status, notes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == VerificationStatus.approved
                  ? 'Driver approved successfully'
                  : 'Driver verification rejected',
            ),
            backgroundColor:
                status == VerificationStatus.approved ? Colors.green : Colors.red,
          ),
        );

        // Reload the list
        _loadPendingDrivers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update verification: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showVerificationDialog(Driver driver, VerificationStatus status) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          status == VerificationStatus.approved
              ? 'Approve Driver'
              : 'Reject Driver',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Driver: ${driver.fullName}'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: status == VerificationStatus.approved
                    ? 'Notes (optional)'
                    : 'Rejection reason',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateVerificationStatus(
                driver,
                status,
                notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: status == VerificationStatus.approved
                  ? Colors.green
                  : Colors.red,
            ),
            child: Text(
              status == VerificationStatus.approved ? 'Approve' : 'Reject',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Verification'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPendingDrivers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _pendingDrivers.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 64, color: Colors.green),
                          SizedBox(height: 16),
                          Text('No pending verifications'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPendingDrivers,
                      child: ListView.builder(
                        itemCount: _pendingDrivers.length,
                        itemBuilder: (context, index) {
                          final driver = _pendingDrivers[index];
                          return _DriverVerificationCard(
                            driver: driver,
                            onApprove: () => _showVerificationDialog(
                              driver,
                              VerificationStatus.approved,
                            ),
                            onReject: () => _showVerificationDialog(
                              driver,
                              VerificationStatus.rejected,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _DriverVerificationCard extends StatelessWidget {
  final Driver driver;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _DriverVerificationCard({
    required this.driver,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: driver.profilePhotoUrl != null
                      ? NetworkImage(driver.profilePhotoUrl!)
                      : null,
                  child: driver.profilePhotoUrl == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.fullName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        driver.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        driver.phoneNumber,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Vehicle Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Make & Model',
              value:
                  '${driver.vehicleInfo.make} ${driver.vehicleInfo.model}',
            ),
            _InfoRow(
              label: 'License Plate',
              value: driver.vehicleInfo.licensePlate,
            ),
            _InfoRow(
              label: 'Color',
              value: driver.vehicleInfo.color,
            ),
            _InfoRow(
              label: 'Year',
              value: driver.vehicleInfo.year.toString(),
            ),
            const Divider(height: 24),
            Text(
              'Driver License',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'License Number',
              value: driver.driverLicenseNumber,
            ),
            if (driver.driverLicensePhotoUrl != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  driver.driverLicensePhotoUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
