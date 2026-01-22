/// Email value object with validation
class Email {
  final String value;

  Email._(this.value);

  /// Factory constructor with validation
  factory Email(String input) {
    if (input.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(input)) {
      throw ArgumentError('Invalid email format');
    }
    
    return Email._(input);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Email && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
