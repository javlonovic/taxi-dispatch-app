/// Rating repository interface
abstract class RatingRepository {
  /// Submit a rating for a ride
  Future<void> submitRating(String rideId, Rating rating);

  /// Calculate average rating for a user
  Future<double> calculateAverageRating(String userId);

  /// Get reviews for a user
  Future<List<Review>> getReviews(String userId);
}

/// Rating
class Rating {
  final double rating;
  final String? feedback;

  Rating({
    required this.rating,
    this.feedback,
  });
}

/// Review
class Review {
  final String id;
  final double rating;
  final String? feedback;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.rating,
    this.feedback,
    required this.timestamp,
  });
}
