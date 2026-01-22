/// License plate value object with validation
class LicensePlate {
  final String value;

  LicensePlate._(this.value);

  /// Factory constructor with validation
  factory LicensePlate(String input) {
    if (input.isEmpty) {
      throw ArgumentError('License plate cannot be empty');
    }
    
    final trimmed = input.trim().toUpperCase();
    
    if (trimmed.length < 2 || trimmed.length > 15) {
      throw ArgumentError('License plate must be between 2 and 15 characters');
    }
    
    // Allow alphanumeric characters, spaces, and hyphens
    final plateRegex = RegExp(r'^[A-Z0-9\s\-]+$');
    
    if (!plateRegex.hasMatch(trimmed)) {
      throw ArgumentError('License plate contains invalid characters');
    }
    
    return LicensePlate._(trimmed);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LicensePlate &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
