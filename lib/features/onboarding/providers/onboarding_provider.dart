// =======================================================
// ONBOARDING PROVIDER (COM USER DOCUMENT + IBGE LOCATION)
// =======================================================

import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

// =======================================================
// PROFILE MODELS
// =======================================================
import 'package:jobmatch/features/profile/models/language_model.dart';
import 'package:jobmatch/features/profile/models/experience_model.dart';
import 'package:jobmatch/features/profile/models/education_model.dart';
import 'package:jobmatch/features/profile/models/soft_skill_model.dart';
import 'package:jobmatch/features/profile/models/tech_skill_model.dart';
import 'package:jobmatch/features/profile/models/social_link_model.dart';
import 'package:jobmatch/features/profile/models/user_document_model.dart';

// =======================================================
// SERVICES
// =======================================================
import 'package:jobmatch/features/onboarding/services/ibge_localidades_service.dart';

// =======================================================
// SENTINELA PARA COPYWITH
// =======================================================
const Object _unset = Object();

// =======================================================
// STATE
// =======================================================
class OnboardingState {
  final String? name;
  final String? lastName;
  final DateTime? birthDate;

  final UserDocumentModel? userDocument;

  final List<String> specialties;
  final List<LanguageModel> languages;

  final String? email;
  final String? password;

  final bool completeProfileNow;

  final String? resumeDescription;
  final String? city;
  final String? selectedUf;

  final List<Map<String, dynamic>> states;
  final List<Map<String, dynamic>> cities;

  final bool isLoadingStates;
  final bool isLoadingCities;
  final String? locationError;

  final List<ExperienceModel> experiences;
  final List<EducationModel> education;
  final List<SoftSkillModel> softSkills;
  final List<TechSkillModel> techSkills;
  final List<SocialLinkModel> links;

  const OnboardingState({
    this.name,
    this.lastName,
    this.birthDate,
    this.userDocument,
    this.specialties = const [],
    this.languages = const [],
    this.email,
    this.password,
    this.completeProfileNow = false,
    this.resumeDescription,
    this.city,
    this.selectedUf,
    this.states = const [],
    this.cities = const [],
    this.isLoadingStates = false,
    this.isLoadingCities = false,
    this.locationError,
    this.experiences = const [],
    this.education = const [],
    this.softSkills = const [],
    this.techSkills = const [],
    this.links = const [],
  });

  // ===================================================
  // COPY WITH
  // ===================================================
  OnboardingState copyWith({
    Object? name = _unset,
    Object? lastName = _unset,
    Object? birthDate = _unset,
    Object? userDocument = _unset,
    List<String>? specialties,
    List<LanguageModel>? languages,
    Object? email = _unset,
    Object? password = _unset,
    bool? completeProfileNow,
    Object? resumeDescription = _unset,
    Object? city = _unset,
    Object? selectedUf = _unset,
    List<Map<String, dynamic>>? states,
    List<Map<String, dynamic>>? cities,
    bool? isLoadingStates,
    bool? isLoadingCities,
    Object? locationError = _unset,
    List<ExperienceModel>? experiences,
    List<EducationModel>? education,
    List<SoftSkillModel>? softSkills,
    List<TechSkillModel>? techSkills,
    List<SocialLinkModel>? links,
  }) {
    return OnboardingState(
      name: identical(name, _unset) ? this.name : name as String?,
      lastName: identical(lastName, _unset)
          ? this.lastName
          : lastName as String?,
      birthDate: identical(birthDate, _unset)
          ? this.birthDate
          : birthDate as DateTime?,
      userDocument: identical(userDocument, _unset)
          ? this.userDocument
          : userDocument as UserDocumentModel?,
      specialties: specialties ?? this.specialties,
      languages: languages ?? this.languages,
      email: identical(email, _unset) ? this.email : email as String?,
      password:
          identical(password, _unset) ? this.password : password as String?,
      completeProfileNow: completeProfileNow ?? this.completeProfileNow,
      resumeDescription: identical(resumeDescription, _unset)
          ? this.resumeDescription
          : resumeDescription as String?,
      city: identical(city, _unset) ? this.city : city as String?,
      selectedUf: identical(selectedUf, _unset)
          ? this.selectedUf
          : selectedUf as String?,
      states: states ?? this.states,
      cities: cities ?? this.cities,
      isLoadingStates: isLoadingStates ?? this.isLoadingStates,
      isLoadingCities: isLoadingCities ?? this.isLoadingCities,
      locationError: identical(locationError, _unset)
          ? this.locationError
          : locationError as String?,
      experiences: experiences ?? this.experiences,
      education: education ?? this.education,
      softSkills: softSkills ?? this.softSkills,
      techSkills: techSkills ?? this.techSkills,
      links: links ?? this.links,
    );
  }

  // ===================================================
  // DERIVADOS
  // ===================================================
  String get fullName {
    return '${name ?? ''} ${lastName ?? ''}'.trim();
  }

  String get role {
    if (specialties.isEmpty) return '';
    return specialties.join(' • ');
  }

  String? get username => null;

  String? get formattedLocation {
    final cityValue = city?.trim();
    final ufValue = selectedUf?.trim();

    if (cityValue == null || cityValue.isEmpty) return null;
    if (ufValue == null || ufValue.isEmpty) return cityValue;

    return '$cityValue - $ufValue';
  }
}

// =======================================================
// CONTROLLER
// =======================================================
class OnboardingController extends StateNotifier<OnboardingState> {
  final IbgeLocalidadesService _ibgeService;

  OnboardingController(this._ibgeService) : super(const OnboardingState());

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
  // USER DOCUMENT
  // ===================================================
  void setUserDocument(UserDocumentModel doc) {
    state = state.copyWith(
      userDocument: doc,
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
  // ACCOUNT
  // ===================================================
  void setAccount({
    required String email,
    required String password,
  }) {
    state = state.copyWith(
      email: email,
      password: password,
    );
  }

  // ===================================================
  // PROFILE INTRO
  // ===================================================
  void setCompleteProfileNow(bool value) {
    state = state.copyWith(
      completeProfileNow: value,
    );
  }

  // ===================================================
  // IBGE - ESTADOS
  // ===================================================
  Future<void> loadStates() async {
    if (state.isLoadingStates) return;
    if (state.states.isNotEmpty) return;

    state = state.copyWith(
      isLoadingStates: true,
      locationError: null,
    );

    try {
      final result = await _ibgeService.fetchStates();

      state = state.copyWith(
        states: result,
        isLoadingStates: false,
        locationError: null,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingStates: false,
        locationError: 'Erro ao carregar estados.',
      );
    }
  }

  // ===================================================
  // IBGE - CIDADES POR UF
  // ===================================================
  Future<void> loadCitiesByUf(String uf) async {
    state = state.copyWith(
      selectedUf: uf,
      city: null,
      cities: const [],
      isLoadingCities: true,
      locationError: null,
    );

    try {
      final result = await _ibgeService.fetchCitiesByUf(uf);

      state = state.copyWith(
        cities: result,
        isLoadingCities: false,
        locationError: null,
      );
    } catch (_) {
      state = state.copyWith(
        cities: const [],
        isLoadingCities: false,
        locationError: 'Erro ao carregar cidades.',
      );
    }
  }

  // ===================================================
  // LOCATION
  // ===================================================
  void setLocation({
    String? uf,
    String? city,
  }) {
    state = state.copyWith(
      selectedUf: uf ?? state.selectedUf,
      city: city,
    );
  }

  void clearLocation() {
    state = state.copyWith(
      selectedUf: null,
      city: null,
      cities: const [],
      locationError: null,
    );
  }

  // ===================================================
  // RESUME
  // ===================================================
  void setResume({
    String? description,
    String? city,
    String? uf,
  }) {
    state = state.copyWith(
      resumeDescription: description,
      city: city,
      selectedUf: uf ?? state.selectedUf,
    );
  }

  // ===================================================
  // OUTROS
  // ===================================================
  void setSoftSkills(List<SoftSkillModel> skills) {
    state = state.copyWith(softSkills: skills);
  }

  void setTechSkills(List<TechSkillModel> skills) {
    state = state.copyWith(techSkills: skills);
  }

  void setExperiences(List<ExperienceModel> experiences) {
    state = state.copyWith(experiences: experiences);
  }

  void setEducation(List<EducationModel> education) {
    state = state.copyWith(education: education);
  }

  void setLinks(List<SocialLinkModel> links) {
    state = state.copyWith(links: links);
  }

  void reset() {
    state = const OnboardingState();
  }

  void setUsername(String usernameValue) {}
}

// =======================================================
// PROVIDER
// =======================================================
final onboardingProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  final client = http.Client();
  final service = IbgeLocalidadesService(client);

  return OnboardingController(service);
});