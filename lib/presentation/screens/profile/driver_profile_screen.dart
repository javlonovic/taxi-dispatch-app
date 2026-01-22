import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/user.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart' hide currentUserProvider;
import '../../providers/repository_providers.dart';
import '../../widgets/star_rating_widget.dart';
import '../../widgets/driver_bottom_nav.dart';
import '../../widgets/driver_status_toggle.dart';
import '../../widgets/driver_status_confirmation_dialog.dart';

class DriverProfileScreen extends ConsumerStatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  ConsumerState<DriverProfileScreen> createState() =>
      _DriverProfileScreenState();
}

class _DriverProfileScreenState extends ConsumerState<DriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _colorController = TextEditingController();
  final _yearController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _licensePlateController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, bool isProfilePhoto) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      
      try {
        final authState = ref.read(authStateProvider).value;
        if (authState == null) return;

        final repository = ref.read(userRepositoryProvider);
        
        if (isProfilePhoto) {
          await repository.uploadProfilePhoto(authState.id, pickedFile.path);
        } else {
          await repository.uploadDriverLicensePhoto(
              authState.id, pickedFile.path);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Фото успешно загружено')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось загрузить фото: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _saveProfile(Driver driver) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(userRepositoryProvider);
      
      final updates = <String, dynamic>{};
      
      if (_fullNameController.text != driver.fullName) {
        updates['fullName'] = _fullNameController.text;
      }
      if (_phoneController.text != driver.phoneNumber) {
        updates['phoneNumber'] = _phoneController.text;
      }
      
      final vehicleUpdates = <String, dynamic>{};
      if (_makeController.text != driver.vehicleInfo.make) {
        vehicleUpdates['make'] = _makeController.text;
      }
      if (_modelController.text != driver.vehicleInfo.model) {
        vehicleUpdates['model'] = _modelController.text;
      }
      if (_licensePlateController.text != driver.vehicleInfo.licensePlate) {
        vehicleUpdates['licensePlate'] = _licensePlateController.text;
      }
      if (_colorController.text != driver.vehicleInfo.color) {
        vehicleUpdates['color'] = _colorController.text;
      }
      if (_yearController.text != driver.vehicleInfo.year.toString()) {
        vehicleUpdates['year'] = int.parse(_yearController.text);
      }
      
      if (vehicleUpdates.isNotEmpty) {
        updates['vehicleInfo'] = {
          ...driver.vehicleInfo.toMap(),
          ...vehicleUpdates,
        };
      }
      
      if (_licenseNumberController.text != driver.driverLicenseNumber) {
        updates['driverLicenseNumber'] = _licenseNumberController.text;
      }

      if (updates.isNotEmpty) {
        await repository.updateUserProfile(driver.id, updates);
      }

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль успешно обновлен')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось обновить профиль: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleStatusChange(Driver driver, bool newStatus) async {
    await DriverStatusConfirmationDialog.show(
      context,
      newStatus,
      () async {
        setState(() => _isLoading = true);
        try {
          final repository = ref.read(userRepositoryProvider);
          await repository.updateDriverActiveStatus(driver.id, newStatus);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  newStatus
                      ? 'Статус изменен на Активен'
                      : 'Статус изменен на Неактивен',
                ),
                backgroundColor: newStatus ? Colors.green : Colors.grey,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Не удалось изменить статус: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Not logged in')),
          );
        }

        final userStream = ref.watch(currentUserProvider(user.id));
        
        return userStream.when(
          data: (currentUser) {
            if (currentUser == null || currentUser is! Driver) {
              return const Scaffold(
                body: Center(child: Text('User not found')),
              );
            }

            final driver = currentUser;
            
            // Initialize controllers with current values
            if (!_isEditing) {
              _fullNameController.text = driver.fullName;
              _phoneController.text = driver.phoneNumber;
              _makeController.text = driver.vehicleInfo.make;
              _modelController.text = driver.vehicleInfo.model;
              _licensePlateController.text = driver.vehicleInfo.licensePlate;
              _colorController.text = driver.vehicleInfo.color;
              _yearController.text = driver.vehicleInfo.year.toString();
              _licenseNumberController.text = driver.driverLicenseNumber;
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Профиль водителя'),
                actions: [
                  if (!_isEditing)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => setState(() => _isEditing = true),
                    ),
                ],
              ),
              body: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Photo
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundImage: driver.profilePhotoUrl != null
                                        ? NetworkImage(driver.profilePhotoUrl!)
                                        : null,
                                    child: driver.profilePhotoUrl == null
                                        ? const Icon(Icons.person, size: 60)
                                        : null,
                                  ),
                                  if (_isEditing)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        child: IconButton(
                                          icon: const Icon(Icons.camera_alt,
                                              color: Colors.white),
                                          onPressed: () => _pickImage(
                                              ImageSource.gallery, true),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Rating Display
                            Center(
                              child: Column(
                                children: [
                                  RatingDisplay(
                                    rating: driver.averageRating,
                                    totalRatings: driver.totalRides,
                                    starSize: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${driver.totalRides} rides completed',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Driver Status Toggle
                            DriverStatusToggle(
                              driver: driver,
                              onStatusChanged: (newStatus) =>
                                  _handleStatusChange(driver, newStatus),
                            ),
                            const SizedBox(height: 24),

                            // Personal Information
                            Text(
                              'Личная информация',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _fullNameController,
                              decoration: const InputDecoration(
                                labelText: 'Полное имя',
                                border: OutlineInputBorder(),
                              ),
                              enabled: _isEditing,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите полное имя';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Номер телефона',
                                border: OutlineInputBorder(),
                              ),
                              enabled: _isEditing,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите номер телефона';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: driver.email,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              enabled: false,
                            ),
                            const SizedBox(height: 24),

                            // Vehicle Information
                            Text(
                              'Информация об автомобиле',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _makeController,
                              decoration: const InputDecoration(
                                labelText: 'Марка',
                                border: OutlineInputBorder(),
                              ),
                              enabled: _isEditing,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _modelController,
                              decoration: const InputDecoration(
                                labelText: 'Модель',
                                border: OutlineInputBorder(),
                              ),
                              enabled: _isEditing,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _licensePlateController,
                              decoration: const InputDecoration(
                                labelText: 'Номер автомобиля',
                                border: OutlineInputBorder(),
                              ),
                              enabled: _isEditing,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _colorController,
                              decoration: const InputDecoration(
                                labelText: 'Цвет',
                                border: OutlineInputBorder(),
                              ),
                              enabled: _isEditing,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _yearController,
                              decoration: const InputDecoration(
                                labelText: 'Год',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              enabled: _isEditing,
                            ),
                            const SizedBox(height: 24),

                            // Driver License
                            Text(
                              'Водительское удостоверение',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _licenseNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Номер удостоверения',
                                border: OutlineInputBorder(),
                              ),
                              enabled: _isEditing,
                            ),
                            const SizedBox(height: 16),
                            if (driver.driverLicensePhotoUrl != null)
                              Image.network(
                                driver.driverLicensePhotoUrl!,
                                height: 200,
                              ),
                            if (_isEditing)
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _pickImage(ImageSource.gallery, false),
                                icon: const Icon(Icons.upload),
                                label: const Text('Загрузить фото удостоверения'),
                              ),
                            const SizedBox(height: 24),

                            // Statistics
                            Text(
                              'Статистика',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatCard(
                                  'Total Rides',
                                  driver.totalRides.toString(),
                                ),
                                _buildStatCard(
                                  'Rating',
                                  driver.averageRating.toStringAsFixed(1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Action Buttons
                            if (_isEditing)
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _saveProfile(driver),
                                      child: const Text('Сохранить'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          setState(() => _isEditing = false),
                                      child: const Text('Отмена'),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
              bottomNavigationBar: const DriverBottomNav(currentIndex: 1),
            );
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            body: Center(child: Text('Error: $error')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

extension on VehicleInfo {
  Map<String, dynamic> toMap() {
    return {
      'make': make,
      'model': model,
      'licensePlate': licensePlate,
      'color': color,
      'year': year,
    };
  }
}
