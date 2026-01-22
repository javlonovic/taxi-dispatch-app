import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/entities/user.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart' hide currentUserProvider;
import '../../providers/repository_providers.dart';
import '../../widgets/company_bottom_nav.dart';
import '../../widgets/star_rating_widget.dart';
import '../../widgets/branch/branch_list_widget.dart';

class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() =>
      _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _businessAddressController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _registrationNumberController.dispose();
    _businessAddressController.dispose();
    super.dispose();
  }



  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      
      try {
        final authState = ref.read(authStateProvider).value;
        if (authState == null) return;

        final repository = ref.read(userRepositoryProvider);
        await repository.uploadProfilePhoto(authState.id, pickedFile.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo uploaded successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload photo: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _saveProfile(Company company) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(userRepositoryProvider);
      
      final updates = <String, dynamic>{};
      
      if (_fullNameController.text != company.fullName) {
        updates['fullName'] = _fullNameController.text;
      }
      if (_phoneController.text != company.phoneNumber) {
        updates['phoneNumber'] = _phoneController.text;
      }
      if (_companyNameController.text != company.companyName) {
        updates['companyName'] = _companyNameController.text;
      }
      if (_registrationNumberController.text !=
          company.companyRegistrationNumber) {
        updates['companyRegistrationNumber'] =
            _registrationNumberController.text;
      }
      if (_businessAddressController.text != company.businessAddress) {
        updates['businessAddress'] = _businessAddressController.text;
      }

      if (updates.isNotEmpty) {
        await repository.updateUserProfile(company.id, updates);
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Не авторизован')),
          );
        }

        final userStream = ref.watch(currentUserProvider(user.id));
        
        return userStream.when(
          data: (currentUser) {
            if (currentUser == null || currentUser is! Company) {
              return const Scaffold(
                body: Center(child: Text('Пользователь не найден')),
              );
            }

            final company = currentUser;
            
            // Initialize controllers with current values
            if (!_isEditing) {
              _fullNameController.text = company.fullName;
              _phoneController.text = company.phoneNumber;
              _companyNameController.text = company.companyName;
              _registrationNumberController.text =
                  company.companyRegistrationNumber;
              _businessAddressController.text = company.businessAddress;
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Профиль компании'),
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
                                    backgroundImage:
                                        company.profilePhotoUrl != null
                                            ? NetworkImage(
                                                company.profilePhotoUrl!)
                                            : null,
                                    child: company.profilePhotoUrl == null
                                        ? const Icon(Icons.business, size: 60)
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
                                          onPressed: () =>
                                              _pickImage(ImageSource.gallery),
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
                                    rating: company.averageRating,
                                    totalRatings: company.totalRides,
                                    starSize: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${company.totalRides} заказов запрошено',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
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
                              initialValue: company.email,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              enabled: false,
                            ),
                            const SizedBox(height: 24),

                            // Company Information
                            Text(
                              'Информация о компании',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _companyNameController,
                              decoration: const InputDecoration(
                                labelText: 'Название компании',
                                border: OutlineInputBorder(),
                              ),
                              enabled: _isEditing,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите название компании';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _registrationNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Регистрационный номер',
                                border: OutlineInputBorder(),
                              ),
                              enabled: _isEditing,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите регистрационный номер';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _businessAddressController,
                              decoration: const InputDecoration(
                                labelText: 'Адрес компании',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              enabled: _isEditing,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Пожалуйста, введите адрес компании';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Branch Management Section
                            if (!_isEditing) ...[
                              Text(
                                'Управление филиалами',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 400,
                                child: BranchListWidget(
                                  onBranchAdded: () {
                                    // Refresh if needed
                                  },
                                  onBranchUpdated: () {
                                    // Refresh if needed
                                  },
                                  onBranchDeleted: () {
                                    // Refresh if needed
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Action Buttons
                            if (_isEditing)
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _saveProfile(company),
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
                            
                            // Add bottom padding to account for bottom navigation
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
              bottomNavigationBar: const CompanyBottomNav(currentIndex: 1),
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
}
