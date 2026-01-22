import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

/// New delivery request screen with step-by-step flow
class DeliveryRequestScreen extends ConsumerStatefulWidget {
  const DeliveryRequestScreen({super.key});

  @override
  ConsumerState<DeliveryRequestScreen> createState() => _DeliveryRequestScreenState();
}

class _DeliveryRequestScreenState extends ConsumerState<DeliveryRequestScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Form controllers
  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _itemController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  // Form data
  GeoPoint? _pickupLocation;
  GeoPoint? _deliveryLocation;
  String _pickupAddress = '';
  String _deliveryAddress = '';
  String _itemDescription = '';
  String _recipientName = '';
  String _recipientPhone = '';
  String _notes = '';

  final List<String> _steps = [
    'Откуда забрать',
    'Куда доставить',
    'Что доставить',
    'Получатель',
    'Подтверждение'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _pickupController.dispose();
    _deliveryController.dispose();
    _itemController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _pickupAddress.isNotEmpty;
      case 1:
        return _deliveryAddress.isNotEmpty;
      case 2:
        return _itemDescription.isNotEmpty;
      case 3:
        return _recipientName.isNotEmpty && _recipientPhone.isNotEmpty;
      case 4:
        return true;
      default:
        return false;
    }
  }

  Future<void> _submitDeliveryRequest() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      _showError('Пользователь не авторизован');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create delivery request
      final deliveryDoc = await FirebaseFirestore.instance.collection('deliveries').add({
        'companyUserId': user.id,
        'companyName': user.fullName,
        'driverId': null,
        'driverName': null,
        'status': 'pending',
        'pickupLocation': _pickupLocation,
        'pickupAddress': _pickupAddress,
        'deliveryLocation': _deliveryLocation,
        'deliveryAddress': _deliveryAddress,
        'itemDescription': _itemDescription,
        'recipientName': _recipientName,
        'recipientPhone': _recipientPhone,
        'notes': _notes,
        'requestedAt': FieldValue.serverTimestamp(),
        'acceptedAt': null,
        'pickedUpAt': null,
        'deliveredAt': null,
        'cancelledAt': null,
        'fare': null,
      });

      // Find nearby drivers
      final driversSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'driver')
          .where('isActive', isEqualTo: true)
          .where('availabilityStatus', isEqualTo: 'available')
          .get();

      if (driversSnapshot.docs.isEmpty) {
        throw Exception('Нет доступных курьеров поблизости');
      }

      // Send notifications to drivers
      final notificationService = ref.read(notificationServiceProvider);
      int successfulNotifications = 0;

      for (var driverDoc in driversSnapshot.docs) {
        final driverId = driverDoc.id;
        
        try {
          await notificationService.sendNotificationToUser(
            userId: driverId,
            title: 'Новый заказ на доставку',
            body: 'Доставка: $_itemDescription\nОт: $_pickupAddress\nДо: $_deliveryAddress',
            data: {
              'type': 'delivery_request',
              'deliveryId': deliveryDoc.id,
              'pickupAddress': _pickupAddress,
              'deliveryAddress': _deliveryAddress,
              'itemDescription': _itemDescription,
              'recipientName': _recipientName,
              'recipientPhone': _recipientPhone,
              'companyName': user.fullName,
            },
          );
          
          successfulNotifications++;
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          // Continue with other drivers
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successfulNotifications > 0
                  ? 'Заказ отправлен $successfulNotifications курьерам!'
                  : 'Заказ создан, но не удалось отправить уведомления',
            ),
            backgroundColor: successfulNotifications > 0 ? Colors.green : Colors.orange,
          ),
        );
        
        // Navigate to tracking screen
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.push('${AppRoutes.tracking}?deliveryId=${deliveryDoc.id}');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Не удалось создать заказ: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая доставка'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Step content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPickupStep(),
                _buildDeliveryStep(),
                _buildItemStep(),
                _buildRecipientStep(),
                _buildConfirmationStep(),
              ],
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(_steps.length, (index) {
          final isActive = index <= _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.blue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < _steps.length - 1) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPickupStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Откуда забрать?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Укажите адрес, откуда нужно забрать посылку',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _pickupController,
                    decoration: const InputDecoration(
                      labelText: 'Адрес отправления',
                      hintText: 'Например: ул. Навои, 15',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _pickupAddress = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Open map picker
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('Выбрать на карте'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Куда доставить?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Укажите адрес доставки',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _deliveryController,
                    decoration: const InputDecoration(
                      labelText: 'Адрес доставки',
                      hintText: 'Например: ул. Амира Темура, 108',
                      prefixIcon: Icon(Icons.flag),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _deliveryAddress = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Open map picker
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('Выбрать на карте'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Что доставить?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Опишите что нужно доставить',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _itemController,
                    decoration: const InputDecoration(
                      labelText: 'Описание товара',
                      hintText: 'Например: Документы, Еда, Подарок',
                      prefixIcon: Icon(Icons.inventory_2),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _itemDescription = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Дополнительные заметки (необязательно)',
                      hintText: 'Особые инструкции для курьера',
                      prefixIcon: Icon(Icons.note),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _notes = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Кто получатель?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Укажите данные получателя',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _recipientNameController,
                    decoration: const InputDecoration(
                      labelText: 'Имя получателя',
                      hintText: 'Например: Иван Петров',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _recipientName = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _recipientPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Телефон получателя',
                      hintText: '+998 90 123 45 67',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _recipientPhone = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Подтверждение заказа',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Проверьте данные перед отправкой',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSummaryCard('Откуда', _pickupAddress, Icons.location_on, Colors.green),
                  const SizedBox(height: 12),
                  _buildSummaryCard('Куда', _deliveryAddress, Icons.flag, Colors.red),
                  const SizedBox(height: 12),
                  _buildSummaryCard('Что', _itemDescription, Icons.inventory_2, Colors.blue),
                  const SizedBox(height: 12),
                  _buildSummaryCard('Получатель', '$_recipientName\n$_recipientPhone', Icons.person, Colors.purple),
                  if (_notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildSummaryCard('Заметки', _notes, Icons.note, Colors.orange),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String content, IconData icon, Color color) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Назад'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: AppButton(
              text: _currentStep == _steps.length - 1 ? 'Заказать доставку' : 'Далее',
              onPressed: _canProceed() 
                  ? (_currentStep == _steps.length - 1 ? _submitDeliveryRequest : _nextStep)
                  : null,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}