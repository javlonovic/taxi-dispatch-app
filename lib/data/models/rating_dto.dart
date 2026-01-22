import '../../domain/entities/ride.dart';

/// Data Transfer Object for rating
class RatingDTO {
  final double? driverRating;
  final double? companyRating;
  final String? driverFeedback;
  final String? companyFeedback;

  RatingDTO({
    this.driverRating,
    this.companyRating,
    this.driverFeedback,
    this.companyFeedback,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'driverRating': driverRating,
      'companyRating': companyRating,
      'driverFeedback': driverFeedback,
      'companyFeedback': companyFeedback,
    };
  }

  /// Create from JSON
  factory RatingDTO.fromJson(Map<String, dynamic> json) {
    return RatingDTO(
      driverRating: json['driverRating']?.toDouble(),
      companyRating: json['companyRating']?.toDouble(),
      driverFeedback: json['driverFeedback'] as String?,
      companyFeedback: json['companyFeedback'] as String?,
    );
  }

  /// Convert to domain entity
  RideRating toEntity() {
    return RideRating(
      driverRating: driverRating,
      companyRating: companyRating,
      driverFeedback: driverFeedback,
      companyFeedback: companyFeedback,
    );
  }

  /// Create from domain entity
  factory RatingDTO.fromEntity(RideRating rating) {
    return RatingDTO(
      driverRating: rating.driverRating,
      companyRating: rating.companyRating,
      driverFeedback: rating.driverFeedback,
      companyFeedback: rating.companyFeedback,
    );
  }
}
