import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State class for managing locale
class LocaleState {
  final Locale locale;

  const LocaleState({required this.locale});

  LocaleState copyWith({Locale? locale}) {
    return LocaleState(
      locale: locale ?? this.locale,
    );
  }
}

/// Provider for managing app locale
class LocaleNotifier extends StateNotifier<LocaleState> {
  static const String _localeKey = 'app_locale';
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs)
      : super(LocaleState(
          locale: Locale(_prefs.getString(_localeKey) ?? 'ru', ''),
        ));

  /// Change the app locale
  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  /// Get current locale
  Locale get currentLocale => state.locale;

  /// Check if current locale is Russian
  bool get isRussian => state.locale.languageCode == 'ru';

  /// Check if current locale is English
  bool get isEnglish => state.locale.languageCode == 'en';

  /// Toggle between Russian and English
  Future<void> toggleLocale() async {
    final newLocale = isRussian ? const Locale('en', '') : const Locale('ru', '');
    await setLocale(newLocale);
  }
}

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

/// Provider for locale management
final localeProvider = StateNotifierProvider<LocaleNotifier, LocaleState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

/// Provider for current locale (convenience)
final currentLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(localeProvider).locale;
});
