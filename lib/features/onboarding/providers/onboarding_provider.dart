// =======================================================
// ONBOARDING PROVIDER (FINAL E CORRETO)
// =======================================================

import 'package:flutter_riverpod/legacy.dart';

// =======================================================
// PROFILE MODELS
// =======================================================
import 'package:jobmatch/features/profile/models/language_model.dart';

// =======================================================
// STATE
// =======================================================
class OnboardingState {
  final String? name;
  final String? lastName;
  final DateTime? birthDate;
  final List<String> specialties;
  final List<LanguageModel> languages;

  const OnboardingState({
    this.name,
    this.lastName,
    this.birthDate,
    this.specialties = const [],
    this.languages = const [],
  });

  // ===================================================
  // COPY WITH
  // ===================================================
  OnboardingState copyWith({
    String? name,
    String? lastName,
    DateTime? birthDate,
    List<String>? specialties,
    List<LanguageModel>? languages,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      specialties: specialties ?? this.specialties,
      languages: languages ?? this.languages,
    );
  }

  // ===================================================
  // 🔥 DERIVADOS
  // ===================================================
  String get fullName {
    return '${name ?? ''} ${lastName ?? ''}'.trim();
  }

  String get role {
    if (specialties.isEmpty) return '';
    return specialties.join(' • ');
  }
}

// =======================================================
// CONTROLLER
// =======================================================
class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController() : super(const OnboardingState());

  // ===================================================
  // NAME
  // ===================================================
  void setName(String name, String lastName) {
    state = state.copyWith(
      name: name,
      lastName: lastName,
    );
  }

  // ===================================================
  // BIRTHDATE
  // ===================================================
  void setBirthDate(DateTime date) {
    state = state.copyWith(
      birthDate: date,
    );
  }

  // ===================================================
  // SPECIALTIES
  // ===================================================
  void setSpecialties(List<String> specialties) {
    state = state.copyWith(
      specialties: specialties,
    );
  }

  // ===================================================
  // LANGUAGES
  // ===================================================
  void setLanguages(List<LanguageModel> languages) {
    state = state.copyWith(
      languages: languages,
    );
  }

  // ===================================================
  // RESET
  // ===================================================
  void reset() {
    state = const OnboardingState();
  }
}

// =======================================================
// PROVIDER
// =======================================================
final onboardingProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController();
});