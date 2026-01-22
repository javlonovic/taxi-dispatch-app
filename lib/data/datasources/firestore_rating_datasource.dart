import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/rating_dto.dart';

/// Firestore data source for rating operations
class FirestoreRatingDataSource {
  final FirebaseFirestore _firestore;

  FirestoreRatingDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Submit a rating for a ride
  Future<void> submitRating(String rideId, RatingDTO rating) async {
    try {
      final rideRef = _firestore.collection('rides').doc(rideId);
      
      await rideRef.update({
        'rating': rating.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw GeneralException('Failed to submit rating: ${e.message}', e.code);
    } catch (e) {
      throw GeneralException('Failed to submit rating: $e');
    }
  }

  /// Get all rides with ratings for a user
  Future<List<Map<String, dynamic>>> getRidesWithRatings(String userId, bool isDriver) async {
    try {
      final field = isDriver ? 'driverUserId' : 'companyUserId';
      
      final snapshot = await _firestore
          .collection('rides')
          .where(field, isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .where('rating', isNull: false)
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } on FirebaseException catch (e) {
      throw GeneralException('Failed to fetch ratings: ${e.message}', e.code);
    } catch (e) {
      throw GeneralException('Failed to fetch ratings: $e');
    }
  }

  /// Get ride by ID
  Future<Map<String, dynamic>?> getRideById(String rideId) async {
    try {
      final doc = await _firestore.collection('rides').doc(rideId).get();
      
      if (!doc.exists) {
        return null;
      }

      return {
        'id': doc.id,
        ...doc.data()!,
      };
    } on FirebaseException catch (e) {
      throw GeneralException('Failed to fetch ride: ${e.message}', e.code);
    } catch (e) {
      throw GeneralException('Failed to fetch ride: $e');
    }
  }
}
