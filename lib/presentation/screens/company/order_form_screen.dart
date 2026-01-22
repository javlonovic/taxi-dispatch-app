import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/repository_providers.dart' as repo;
import '../../widgets/company_bottom_nav.dart';
import '../../widgets/common/app_button.dart';

/// Form-based order screen replacing the map
class OrderFormScreen extends ConsumerStatefulWidget {
  const OrderFormScreen({super.key});

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();

  bool _isLoadingLocation = false;
  bool _isGeocoding = false;
  bool _isSubmitting = false;
  GeoPoint? _pickupLocation;
  String _pickupAddress = '';
  GeoPoint? _destinationLocation;
  String _destinationAddress = '';
  int _tutorialStep = 0;
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _checkTutorial();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    super.dispose();
  }

  Future<void> _checkTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool('has_seen_order_tutorial') ?? false;
      if (!hasSeen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _showTutorial = true;
              _tutorialStep = 0;
            });
          }
        });
      }
    } catch (e) {
      // If SharedPreferences fails, just skip tutorial
      debugPrint('Failed to check tutorial status: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final locationService = ref.read(repo.locationServiceProvider);
      
      final hasPermission = await locationService.requestLocationPermission();
      if (!hasPermission) {
        if (mounted) {
          _showError('Разрешение на местоположение необходимо');
        }
        return;
      }

      final position = await locationService.getCurrentLocation();
      final geoPoint = GeoPoint(position.latitude, position.longitude);
      
      setState(() {
        _pickupLocation = geoPoint;
      });

      await _geocodeLocation(geoPoint, true);
      
    } catch (e) {
      if (mounted) {
        _showError('Не удалось получить местоположение: $e');
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _geocodeLocation(GeoPoint location, bool isPickup) async {
    setState(() => _isGeocoding = true);

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = _formatAddress(place);
        
        setState(() {
          if (isPickup) {
            _pickupAddress = address;
          } else {
            _destinationAddress = address;
            _destinationController.text = address;
          }
        });
      }
    } catch (e) {
      final fallbackAddress = '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
      setState(() {
        if (isPickup) {
          _pickupAddress = fallbackAddress;
        } else {
          _destinationAddress = fallbackAddress;
          _destinationController.text = fallbackAddress;
        }
      });
    } finally {
      setState(() => _isGeocoding = false);
    }
  }

  Future<void> _geocodeDestination() async {
    final address = _destinationController.text.trim();
    if (address.isEmpty) return;

    setState(() => _isGeocoding = true);

    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final geoPoint = GeoPoint(location.latitude, location.longitude);
        
        setState(() {
          _destinationLocation = geoPoint;
        });

        await _geocodeLocation(geoPoint, false);
      } else {
        _showError('Адрес не найден. Пожалуйста, уточните адрес.');
      }
    } catch (e) {
      _showError('Не удалось найти адрес: $e');
    } finally {
      setState(() => _isGeocoding = false);
    }
  }

  String _formatAddress(Placemark place) {
    final parts = <String>[];
    if (place.street != null && place.street!.isNotEmpty) {
      parts.add(place.street!);
    }
    if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
      parts.add(place.subThoroughfare!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Адрес не определен';
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pickupLocation == null) {
      _showError('Не удалось определить ваше местоположение');
      return;
    }

    // Geocode destination if not already done
    if (_destinationLocation == null && _destinationController.text.isNotEmpty) {
      await _geocodeDestination();
      if (_destinationLocation == null) {
        _showError('Не удалось определить адрес доставки');
        return;
      }
    }

    if (_destinationController.text.isEmpty) {
      _showError('Пожалуйста, укажите адрес доставки');
      return;
    }

    final user = ref.read(currentUserProvider).value;
    if (user == null || user is! Company) {
      _showError('Пользователь не авторизован');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dispatchService = ref.read(repo.rideDispatchServiceProvider);
      
      // Create ride request with recipient info
      final rideId = await dispatchService.createRideRequestAndNotify(
        companyUserId: user.id,
        pickupLocation: _pickupLocation!,
        pickupAddress: _pickupAddress,
        destination: _destinationLocation,
        destinationAddress: _destinationAddress,
        recipientName: _recipientNameController.text.trim(),
        recipientPhone: _recipientPhoneController.text.trim(),
        searchRadiusKm: 100.0, // Large radius to notify all active drivers
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заказ отправлен водителям!'),
            backgroundColor: Colors.green,
          ),
        );
        context.push('${AppRoutes.tracking}?rideId=$rideId');
      }
    } catch (e) {
      if (mounted) {
        _showError('Не удалось отправить заказ: $e');
      }
    } finally {
      setState(() => _isSubmitting = false);
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

  void _nextTutorialStep() {
    if (_tutorialStep < 3) {
      setState(() => _tutorialStep++);
    } else {
      _completeTutorial();
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_order_tutorial', true);
    setState(() {
      _showTutorial = false;
      _tutorialStep = 0;
    });
  }

  String? _validateDestination(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Пожалуйста, укажите адрес доставки';
    }
    return null;
  }

  String? _validateRecipientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Пожалуйста, укажите имя получателя';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Пожалуйста, укажите номер телефона';
    }
    // Basic phone validation
    final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]+$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Пожалуйста, введите корректный номер телефона';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать заказ'),
        actions: [
          if (_showTutorial)
            TextButton(
              onPressed: _skipTutorial,
              child: const Text('Пропустить'),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pickup location info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.green),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Место отправления',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (_isLoadingLocation || _isGeocoding)
                            const LinearProgressIndicator()
                          else
                            Text(
                              _pickupAddress.isEmpty ? 'Определение адреса...' : _pickupAddress,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),

                  // Destination field
                  Text(
                    'Куда доставить? *',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      hintText: 'Введите адрес доставки',
                      prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                      suffixIcon: _isGeocoding
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: _geocodeDestination,
                              tooltip: 'Найти адрес',
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: _validateDestination,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _geocodeDestination(),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Recipient name field
                  Text(
                    'Имя получателя *',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _recipientNameController,
                    decoration: InputDecoration(
                      hintText: 'Введите имя получателя',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: _validateRecipientName,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Recipient phone field
                  Text(
                    'Телефон получателя *',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _recipientPhoneController,
                    decoration: InputDecoration(
                      hintText: '+998 90 123 45 67',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: _validatePhone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submitOrder(),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Submit button
                  AppButton(
                    text: 'Отправить заказ',
                    onPressed: (_isSubmitting || _isLoadingLocation || _isGeocoding)
                        ? null
                        : _submitOrder,
                    isLoading: _isSubmitting,
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),

          // Tutorial overlay
          if (_showTutorial) _buildTutorialOverlay(),
        ],
      ),
      bottomNavigationBar: const CompanyBottomNav(currentIndex: 0),
    );
  }

  Widget _buildTutorialOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _nextTutorialStep,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            _buildTutorialCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialCard() {
    final steps = [
      {
        'title': 'Добро пожаловать!',
        'description': 'Это форма для создания заказа. Заполните все поля, чтобы отправить заказ водителям.',
        'icon': Icons.info_outline,
      },
      {
        'title': 'Адрес доставки',
        'description': 'Введите адрес, куда нужно доставить заказ. Система автоматически определит ваше текущее местоположение как место отправления.',
        'icon': Icons.location_on,
      },
      {
        'title': 'Информация о получателе',
        'description': 'Укажите имя и телефон человека, который будет получать заказ. Это поможет водителю связаться с получателем.',
        'icon': Icons.person,
      },
      {
        'title': 'Отправка заказа',
        'description': 'После заполнения всех полей нажмите "Отправить заказ". Все активные водители поблизости получат уведомление о вашем заказе.',
        'icon': Icons.send,
      },
    ];

    final step = steps[_tutorialStep];

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_tutorialStep + 1} / ${steps.length}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _skipTutorial,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Icon(
            step['icon'] as IconData,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            step['title'] as String,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            step['description'] as String,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              if (_tutorialStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _tutorialStep--);
                    },
                    child: const Text('Назад'),
                  ),
                ),
              if (_tutorialStep > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextTutorialStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_tutorialStep < steps.length - 1 ? 'Далее' : 'Начать'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

