/// Phone number value object with validation
class PhoneNumber {
  final String value;

  PhoneNumber._(this.value);

  /// Factory constructor with validation
  factory PhoneNumber(String input) {
    if (input.isEmpty) {
      throw ArgumentError('Phone number cannot be empty');
    }
    
    // Remove common formatting characters
    final cleaned = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check if it contains only digits and optional + prefix
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    
    if (!phoneRegex.hasMatch(cleaned)) {
      throw ArgumentError('Invalid phone number format');
    }
    
    return PhoneNumber._(cleaned);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneNumber &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
