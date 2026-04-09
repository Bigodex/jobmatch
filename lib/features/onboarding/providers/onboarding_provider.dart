// =======================================================
// ONBOARDING PROVIDER (COM USER DOCUMENT)
// =======================================================

import 'package:flutter_riverpod/legacy.dart';

// =======================================================
// PROFILE MODELS
// =======================================================
import 'package:jobmatch/features/profile/models/language_model.dart';
import 'package:jobmatch/features/profile/models/experience_model.dart';
import 'package:jobmatch/features/profile/models/education_model.dart';
import 'package:jobmatch/features/profile/models/soft_skill_model.dart';
import 'package:jobmatch/features/profile/models/tech_skill_model.dart';
import 'package:jobmatch/features/profile/models/social_link_model.dart';

// 🔥 NOVO MODEL
import 'package:jobmatch/features/profile/models/user_document_model.dart';

// =======================================================
// STATE
// =======================================================
class OnboardingState {
  final String? name;
  final String? lastName;
  final DateTime? birthDate;

  // 🔥 NOVO
  final UserDocumentModel? userDocument;

  final List<String> specialties;
  final List<LanguageModel> languages;

  final String? email;
  final String? password;

  final bool completeProfileNow;

  final String? resumeDescription;
  final String? city;

  final List<ExperienceModel> experiences;
  final List<EducationModel> education;
  final List<SoftSkillModel> softSkills;
  final List<TechSkillModel> techSkills;
  final List<SocialLinkModel> links;

  const OnboardingState({
    this.name,
    this.lastName,
    this.birthDate,
    this.userDocument, // 👈 novo
    this.specialties = const [],
    this.languages = const [],
    this.email,
    this.password,
    this.completeProfileNow = false,
    this.resumeDescription,
    this.city,
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
    String? name,
    String? lastName,
    DateTime? birthDate,
    UserDocumentModel? userDocument, // 👈 novo
    List<String>? specialties,
    List<LanguageModel>? languages,
    String? email,
    String? password,
    bool? completeProfileNow,
    String? resumeDescription,
    String? city,
    List<ExperienceModel>? experiences,
    List<EducationModel>? education,
    List<SoftSkillModel>? softSkills,
    List<TechSkillModel>? techSkills,
    List<SocialLinkModel>? links,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      userDocument: userDocument ?? this.userDocument,
      specialties: specialties ?? this.specialties,
      languages: languages ?? this.languages,
      email: email ?? this.email,
      password: password ?? this.password,
      completeProfileNow:
          completeProfileNow ?? this.completeProfileNow,
      resumeDescription:
          resumeDescription ?? this.resumeDescription,
      city: city ?? this.city,
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
}

// =======================================================
// CONTROLLER
// =======================================================
class OnboardingController
    extends StateNotifier<OnboardingState> {
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
  // 🔥 USER DOCUMENT (NOVO)
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
  // RESUME
  // ===================================================
  void setResume({
    String? description,
    String? city,
  }) {
    state = state.copyWith(
      resumeDescription: description,
      city: city,
    );
  }

  // ===================================================
  // OUTROS (mantidos)
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
    StateNotifierProvider<OnboardingController,
        OnboardingState>((ref) {
  return OnboardingController();
});