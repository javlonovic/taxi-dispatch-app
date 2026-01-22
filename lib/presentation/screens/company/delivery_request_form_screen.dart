import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/delivery/ready_time_selector.dart';
import '../../widgets/delivery/delivery_address_map_picker.dart';
import '../../../core/utils/form_validators.dart';
import '../../../domain/repositories/ride_repository.dart';
import '../../../domain/entities/user.dart';
import '../../providers/ride_provider.dart';
import '../../providers/auth_provider.dart';

/// Enhanced delivery request form with recipient details and scheduled pickup
class DeliveryRequestFormScreen extends ConsumerStatefulWidget {
  final String? branchId;
  final GeoPoint? pickupLocation;
  final String? pickupAddress;

  const DeliveryRequestFormScreen({
    super.key,
    this.branchId,
    this.pickupLocation,
    this.pickupAddress,
  });

  @override
  ConsumerState<DeliveryRequestFormScreen> createState() =>
      _DeliveryRequestFormScreenState();
}

class _DeliveryRequestFormScreenState
    extends ConsumerState<DeliveryRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _deliveryAddressController = TextEditingController();

  GeoPoint? _deliveryLocation;
  int _selectedReadyMinutes = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _deliveryAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заказать доставку'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Pickup location info (read-only)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Откуда',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.pickupAddress ?? 'Не указано',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Delivery address
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.flag,
                          color: Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Куда',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _deliveryAddressController,
                      decoration: InputDecoration(
                        labelText: 'Адрес доставки *',
                        hintText: 'Введите адрес',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.map),
                          onPressed: _selectDeliveryLocationOnMap,
                          tooltip: 'Выбрать на карте',
                        ),
                      ),
                      validator: FormValidators.address,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Recipient details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.blue,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Получатель',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _recipientNameController,
                      decoration: InputDecoration(
                        labelText: 'Имя получателя *',
                        hintText: 'Иван Петров',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: FormValidators.recipientName,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _recipientPhoneController,
                      decoration: InputDecoration(
                        labelText: 'Телефон получателя *',
                        hintText: '+7 (999) 123-45-67',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      validator: FormValidators.phone,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Ready time selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ReadyTimeSelector(
                  selectedMinutes: _selectedReadyMinutes,
                  onSelected: (minutes) {
                    setState(() {
                      _selectedReadyMinutes = minutes;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitDeliveryRequest,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Найти такси',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Required fields note
            Text(
              '* Обязательные поля',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDeliveryLocationOnMap() async {
    final result = await DeliveryAddressMapPicker.show(
      context,
      initialLocation: _deliveryLocation,
      initialAddress: _deliveryAddressController.text,
    );

    if (result != null) {
      setState(() {
        _deliveryLocation = result.location;
        _deliveryAddressController.text = result.address;
      });
    }
  }

  Future<void> _submitDeliveryRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_deliveryLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, выберите адрес доставки на карте'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get current user
      final currentUserAsync = ref.read(currentUserProvider);
      final currentUser = currentUserAsync.value;
      
      if (currentUser == null) {
        throw Exception('Пользователь не авторизован');
      }

      // Get company name if user is a company
      String? companyName;
      if (currentUser is Company) {
        companyName = currentUser.companyName;
      }

      // Create ride request with enhanced delivery fields
      final rideRequest = RideRequest(
        companyUserId: currentUser.id,
        pickupLocation: widget.pickupLocation!,
        pickupAddress: widget.pickupAddress!,
        destination: _deliveryLocation,
        destinationAddress: _deliveryAddressController.text.trim(),
        branchId: widget.branchId,
        companyName: companyName,
        companyPhone: currentUser.phoneNumber,
        recipientName: _recipientNameController.text.trim(),
        recipientPhone: _recipientPhoneController.text.trim(),
        readyInMinutes: _selectedReadyMinutes,
      );

      // Create the ride
      await ref.read(rideNotifierProvider.notifier).createRideRequest(rideRequest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedReadyMinutes > 0
                  ? 'Заказ создан! Водитель будет уведомлен через $_selectedReadyMinutes мин'
                  : 'Заказ создан! Ищем водителя...',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
