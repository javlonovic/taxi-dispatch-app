/// Form validation utilities for Russian localized app
class FormValidators {
  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName обязательно для заполнения'
          : 'Это поле обязательно';
    }
    return null;
  }

  /// Validate phone number (Russian format)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Укажите номер телефона';
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    // Check if it's a valid Russian phone number (10-11 digits)
    if (digitsOnly.length < 10) {
      return 'Номер телефона слишком короткий';
    }

    if (digitsOnly.length > 11) {
      return 'Номер телефона слишком длинный';
    }

    // If 11 digits, first digit should be 7 or 8
    if (digitsOnly.length == 11) {
      if (!digitsOnly.startsWith('7') && !digitsOnly.startsWith('8')) {
        return 'Номер должен начинаться с 7 или 8';
      }
    }

    return null;
  }

  /// Validate recipient name
  static String? recipientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Укажите имя получателя';
    }

    if (value.trim().length < 2) {
      return 'Имя слишком короткое';
    }

    // Check if contains at least some letters
    if (!RegExp(r'[а-яА-ЯёЁa-zA-Z]').hasMatch(value)) {
      return 'Имя должно содержать буквы';
    }

    return null;
  }

  /// Validate delivery address
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Укажите адрес доставки';
    }

    if (value.trim().length < 5) {
      return 'Адрес слишком короткий';
    }

    return null;
  }

  /// Format phone number for display
  static String formatPhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length == 10) {
      // Format: +7 (XXX) XXX-XX-XX
      return '+7 (${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6, 8)}-${digitsOnly.substring(8)}';
    } else if (digitsOnly.length == 11) {
      // Format: +7 (XXX) XXX-XX-XX (remove leading 7 or 8)
      final withoutCountryCode = digitsOnly.substring(1);
      return '+7 (${withoutCountryCode.substring(0, 3)}) ${withoutCountryCode.substring(3, 6)}-${withoutCountryCode.substring(6, 8)}-${withoutCountryCode.substring(8)}';
    }

    return phone;
  }

  /// Validate that location is selected
  static String? validateLocationSelected(
    dynamic location,
    String fieldName,
  ) {
    if (location == null) {
      return 'Пожалуйста, выберите $fieldName на карте';
    }
    return null;
  }
}
