import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import 'repository_providers.dart';

/// Current user provider
final currentUserProvider = StreamProvider.family<User?, String>((ref, userId) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.watchUser(userId);
});

/// Driver provider - Get driver details by ID
final driverProvider = FutureProvider.family<Driver?, String>((ref, driverId) async {
  final repository = ref.watch(userRepositoryProvider);
  final user = await repository.getUserById(driverId);
  return user is Driver ? user : null;
});

/// Driver availability provider - Get drivers by availability status
final driverAvailabilityProvider =
    FutureProvider.family<List<Driver>, AvailabilityStatus>((ref, status) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getDriversByAvailability(status);
});

/// Available drivers provider - Get only available drivers
final availableDriversProvider = FutureProvider<List<Driver>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getDriversByAvailability(AvailabilityStatus.available);
});

/// Busy drivers provider - Get only busy drivers
final busyDriversProvider = FutureProvider<List<Driver>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getDriversByAvailability(AvailabilityStatus.busy);
});

/// Offline drivers provider - Get only offline drivers
final offlineDriversProvider = FutureProvider<List<Driver>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getDriversByAvailability(AvailabilityStatus.offline);
});
