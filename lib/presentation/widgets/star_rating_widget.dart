import 'package:flutter/material.dart';

/// Star rating widget for displaying and selecting ratings
class StarRatingWidget extends StatelessWidget {
  final double rating;
  final Function(double)? onRatingChanged;
  final double size;
  final bool interactive;
  final Color? activeColor;
  final Color? inactiveColor;

  const StarRatingWidget({
    Key? key,
    required this.rating,
    this.onRatingChanged,
    this.size = 24,
    this.interactive = false,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeStarColor = activeColor ?? Colors.amber;
    final inactiveStarColor = inactiveColor ?? Colors.grey[300]!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        final isFilled = rating >= starValue;
        final isHalfFilled = rating >= starValue - 0.5 && rating < starValue;

        return GestureDetector(
          onTap: interactive && onRatingChanged != null
              ? () => onRatingChanged!(starValue)
              : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size * 0.1),
            child: Icon(
              isFilled
                  ? Icons.star
                  : isHalfFilled
                      ? Icons.star_half
                      : Icons.star_border,
              size: size,
              color: isFilled || isHalfFilled
                  ? activeStarColor
                  : inactiveStarColor,
            ),
          ),
        );
      }),
    );
  }
}

/// Display rating with number
class RatingDisplay extends StatelessWidget {
  final double rating;
  final int? totalRatings;
  final double starSize;

  const RatingDisplay({
    Key? key,
    required this.rating,
    this.totalRatings,
    this.starSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StarRatingWidget(
          rating: rating,
          size: starSize,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: starSize * 0.9,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (totalRatings != null) ...[
          const SizedBox(width: 4),
          Text(
            '($totalRatings)',
            style: TextStyle(
              fontSize: starSize * 0.8,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}
