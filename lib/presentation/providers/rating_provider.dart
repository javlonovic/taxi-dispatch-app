import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/rating_repository.dart';
import 'repository_providers.dart';

/// Submit rating state provider
final submitRatingProvider = StateNotifierProvider.autoDispose
    .family<SubmitRatingNotifier, AsyncValue<void>, String>(
  (ref, rideId) => SubmitRatingNotifier(
    ref.watch(ratingRepositoryProvider),
    rideId,
  ),
);

/// Submit rating notifier
class SubmitRatingNotifier extends StateNotifier<AsyncValue<void>> {
  final RatingRepository _repository;
  final String _rideId;

  SubmitRatingNotifier(this._repository, this._rideId)
      : super(const AsyncValue.data(null));

  Future<void> submitRating(double rating, String? feedback) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await _repository.submitRating(
        _rideId,
        Rating(rating: rating, feedback: feedback),
      );
    });
  }
}

/// Get reviews provider
final reviewsProvider = FutureProvider.autoDispose.family<List<Review>, String>(
  (ref, userId) async {
    final repository = ref.watch(ratingRepositoryProvider);
    return repository.getReviews(userId);
  },
);

/// Get average rating provider
final averageRatingProvider = FutureProvider.autoDispose.family<double, String>(
  (ref, userId) async {
    final repository = ref.watch(ratingRepositoryProvider);
    return repository.calculateAverageRating(userId);
  },
);
