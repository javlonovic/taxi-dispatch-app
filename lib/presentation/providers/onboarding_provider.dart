import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/localization_provider.dart';

/// State class for onboarding
class OnboardingState {
  final bool hasSeenOnboarding;
  final bool isLoading;

  const OnboardingState({
    required this.hasSeenOnboarding,
    this.isLoading = false,
  });

  OnboardingState copyWith({
    bool? hasSeenOnboarding,
    bool? isLoading,
  }) {
    return OnboardingState(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier for managing onboarding state
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  static const String _onboardingKey = 'has_seen_onboarding';
  final SharedPreferences _prefs;

  OnboardingNotifier(this._prefs)
      : super(OnboardingState(
          hasSeenOnboarding: _prefs.getBool(_onboardingKey) ?? false,
        ));

  /// Check if user has completed onboarding
  bool get hasSeenOnboarding => state.hasSeenOnboarding;

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _prefs.setBool(_onboardingKey, true);
      state = state.copyWith(
        hasSeenOnboarding: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Skip onboarding (same as complete)
  Future<void> skipOnboarding() async {
    await completeOnboarding();
  }

  /// Reset onboarding (for testing purposes)
  Future<void> resetOnboarding() async {
    await _prefs.setBool(_onboardingKey, false);
    state = state.copyWith(hasSeenOnboarding: false);
  }
}

/// Provider for onboarding state management
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingNotifier(prefs);
});

/// Convenience provider to check if onboarding is complete
final hasSeenOnboardingProvider = Provider<bool>((ref) {
  return ref.watch(onboardingProvider).hasSeenOnboarding;
});
