import 'package:flutter/foundation.dart';
import '../../domain/repositories/rating_repository.dart';
import '../../core/exceptions/app_exception.dart';
import '../datasources/firestore_rating_datasource.dart';
import '../datasources/firestore_user_datasource.dart';
import '../models/rating_dto.dart';

/// Rating repository implementation
class RatingRepositoryImpl implements RatingRepository {
  final FirestoreRatingDataSource _ratingDataSource;
  final FirestoreUserDataSource _userDataSource;

  RatingRepositoryImpl({
    required FirestoreRatingDataSource ratingDataSource,
    required FirestoreUserDataSource userDataSource,
  })  : _ratingDataSource = ratingDataSource,
        _userDataSource = userDataSource;

  @override
  Future<void> submitRating(String rideId, Rating rating) async {
    try {
      // Get the ride to determine who is rating whom
      final rideData = await _ratingDataSource.getRideById(rideId);
      
      if (rideData == null) {
        throw GeneralException('Ride not found');
      }

      final driverUserId = rideData['driverUserId'] as String?;
      final companyUserId = rideData['companyUserId'] as String;
      
      if (driverUserId == null) {
        throw GeneralException('Ride has no assigned driver');
      }

      // Get existing rating if any
      final existingRating = rideData['rating'] as Map<String, dynamic>?;
      final ratingDto = existingRating != null 
          ? RatingDTO.fromJson(existingRating)
          : RatingDTO();

      // Update the appropriate rating field based on feedback
      final updatedRating = RatingDTO(
        driverRating: rating.feedback != null && rating.feedback!.isNotEmpty
            ? (ratingDto.driverRating ?? rating.rating)
            : ratingDto.driverRating,
        companyRating: rating.feedback == null || rating.feedback!.isEmpty
            ? (ratingDto.companyRating ?? rating.rating)
            : ratingDto.companyRating,
        driverFeedback: rating.feedback != null && rating.feedback!.isNotEmpty
            ? rating.feedback
            : ratingDto.driverFeedback,
        companyFeedback: rating.feedback == null || rating.feedback!.isEmpty
            ? rating.feedback
            : ratingDto.companyFeedback,
      );

      // Submit the rating
      await _ratingDataSource.submitRating(rideId, updatedRating);

      // Update user profiles with new average ratings
      if (updatedRating.driverRating != null) {
        await _updateUserAverageRating(driverUserId, true);
      }
      if (updatedRating.companyRating != null) {
        await _updateUserAverageRating(companyUserId, false);
      }
    } catch (e) {
      if (e is GeneralException) rethrow;
      throw GeneralException('Failed to submit rating: $e');
    }
  }

  @override
  Future<double> calculateAverageRating(String userId) async {
    try {
      // Determine if user is a driver by checking their profile
      final userDto = await _userDataSource.getUserById(userId);
      
      if (userDto == null) {
        throw GeneralException('User not found');
      }

      final isDriver = userDto.type == 'driver';
      
      // Get all rides with ratings for this user
      final ridesWithRatings = await _ratingDataSource.getRidesWithRatings(userId, isDriver);

      if (ridesWithRatings.isEmpty) {
        return 0.0;
      }

      // Calculate average
      double totalRating = 0.0;
      int count = 0;

      for (final rideData in ridesWithRatings) {
        final rating = rideData['rating'] as Map<String, dynamic>?;
        if (rating != null) {
          final ratingDto = RatingDTO.fromJson(rating);
          final userRating = isDriver ? ratingDto.driverRating : ratingDto.companyRating;
          
          if (userRating != null) {
            totalRating += userRating;
            count++;
          }
        }
      }

      return count > 0 ? totalRating / count : 0.0;
    } catch (e) {
      if (e is GeneralException) rethrow;
      throw GeneralException('Failed to calculate average rating: $e');
    }
  }

  @override
  Future<List<Review>> getReviews(String userId) async {
    try {
      // Determine if user is a driver
      final userDto = await _userDataSource.getUserById(userId);
      
      if (userDto == null) {
        throw GeneralException('User not found');
      }

      final isDriver = userDto.type == 'driver';
      
      // Get all rides with ratings
      final ridesWithRatings = await _ratingDataSource.getRidesWithRatings(userId, isDriver);

      // Convert to Review objects
      final reviews = <Review>[];
      
      for (final rideData in ridesWithRatings) {
        final rating = rideData['rating'] as Map<String, dynamic>?;
        if (rating != null) {
          final ratingDto = RatingDTO.fromJson(rating);
          final userRating = isDriver ? ratingDto.driverRating : ratingDto.companyRating;
          final userFeedback = isDriver ? ratingDto.driverFeedback : ratingDto.companyFeedback;
          
          if (userRating != null) {
            reviews.add(Review(
              id: rideData['id'] as String,
              rating: userRating,
              feedback: userFeedback,
              timestamp: (rideData['completedAt'] as dynamic).toDate(),
            ));
          }
        }
      }

      return reviews;
    } catch (e) {
      if (e is GeneralException) rethrow;
      throw GeneralException('Failed to get reviews: $e');
    }
  }

  /// Update user's average rating in their profile
  Future<void> _updateUserAverageRating(String userId, bool isDriver) async {
    try {
      final averageRating = await calculateAverageRating(userId);
      
      await _userDataSource.updateUser(userId, {
        'averageRating': averageRating,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Log error but don't throw - rating submission should succeed even if profile update fails
      debugPrint('Warning: Failed to update user average rating: $e');
    }
  }
}
