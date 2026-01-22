/// Rating value object with validation
class Rating {
  final double value;

  Rating._(this.value);

  /// Factory constructor with validation
  factory Rating(double input) {
    if (input < 0.0 || input > 5.0) {
      throw ArgumentError('Rating must be between 0.0 and 5.0');
    }
    
    return Rating._(input);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rating && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toStringAsFixed(1);
}
