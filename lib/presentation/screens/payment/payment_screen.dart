import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_provider.dart';
import '../../providers/auth_provider.dart';

/// Payment screen for managing payment methods
/// Requirements: 11.2
class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Please log in')),
          );
        }

        final paymentMethodsAsync = ref.watch(paymentMethodsProvider(user.id));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Payment Methods'),
          ),
          body: paymentMethodsAsync.when(
            data: (methods) {
              if (methods.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.credit_card_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No payment methods added',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _addPaymentMethod(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Payment Method'),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: methods.length,
                      itemBuilder: (context, index) {
                        final method = methods[index];
                        return _PaymentMethodCard(
                          method: method,
                          onDelete: () => _deletePaymentMethod(context, ref, user.id, method.id),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _addPaymentMethod(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Payment Method'),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${error.toString()}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(paymentMethodsProvider(user.id)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: ${error.toString()}')),
      ),
    );
  }

  void _addPaymentMethod(BuildContext context, WidgetRef ref) {
    // In a real implementation, this would:
    // 1. Present Stripe card input form
    // 2. Create payment method
    // 3. Save to Firestore
    // 4. Refresh the list
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add payment method functionality - integrate with Stripe SDK'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deletePaymentMethod(BuildContext context, WidgetRef ref, String userId, String methodId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: const Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete payment method
              // In real implementation, call repository method
              ref.invalidate(paymentMethodsProvider(userId));
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment method deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final dynamic method;
  final VoidCallback onDelete;

  const _PaymentMethodCard({
    required this.method,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          _getCardIcon(method.type),
          size: 32,
        ),
        title: Text('${_getCardBrand(method.type)} •••• ${method.last4}'),
        subtitle: Text(method.type),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }

  IconData _getCardIcon(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  String _getCardBrand(String type) {
    return type.substring(0, 1).toUpperCase() + type.substring(1);
  }
}
