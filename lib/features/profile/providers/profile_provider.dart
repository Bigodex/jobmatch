// =======================================================
// PROFILE PROVIDER
// -------------------------------------------------------
// Gerencia estado + edição do perfil
// =======================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/profile_model.dart';
import '../models/resume_model.dart';
import '../models/language_model.dart';
import '../models/soft_skill_model.dart';
import '../models/tech_skill_model.dart';
import '../models/experience_model.dart';
import '../models/education_model.dart';
import '../models/social_link_model.dart'; // 🔥 ADD

import '../services/profile_service.dart';

// =======================================================
// NOTIFIER
// =======================================================
class ProfileNotifier extends StateNotifier<AsyncValue<ProfileModel>> {
  final ProfileService _service;

  ProfileNotifier(this._service) : super(const AsyncLoading()) {
    loadProfile();
  }

  // ===================================================
  // LOAD INICIAL
  // ===================================================
  Future<void> loadProfile() async {
    try {
      final profile = await _service.getProfile();
      state = AsyncData(profile);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ===================================================
  // UPDATE COVER
  // ===================================================
  Future<void> updateCover(String url) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      user: current.user.copyWith(
        coverUrl: url,
      ),
    );

    state = AsyncData(updated);
    await _persist(updated);
  }

  // ===================================================
  // UPDATE AVATAR
  // ===================================================
  Future<void> updateAvatar(String url) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      user: current.user.copyWith(
        avatarUrl: url,
      ),
    );

    state = AsyncData(updated);
    await _persist(updated);
  }

  // ===================================================
  // UPDATE USER INFO
  // ===================================================
  Future<void> updateUserInfo({
    required String name,
    required String role,
  }) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      user: current.user.copyWith(
        name: name,
        role: role,
      ),
    );

    state = AsyncData(updated);
    await _persist(updated);
  }

  // ===================================================
  // UPDATE RESUME
  // ===================================================
  Future<void> updateResume(ResumeModel updatedResume) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      resume: updatedResume,
    );

    state = AsyncData(updated);
    await _persist(updated);
  }

  // ===================================================
  // UPDATE LANGUAGES
  // ===================================================
  Future<void> updateLanguages(List<LanguageModel> languages) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      languages: languages,
    );

    state = AsyncData(updated);
    await _persist(updated);
  }

  // ===================================================
  // UPDATE SOFT SKILLS
  // ===================================================
  Future<void> updateSoftSkills(List<SoftSkillModel> skills) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      softSkills: skills,
    );

    state = AsyncData(updated);
    await _persist(updated);
  }

  // ===================================================
  // UPDATE HARD SKILLS
  // ===================================================
  Future<void> updateHardSkills(List<TechSkillModel> skills) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      techSkills: skills,
    );

    state = AsyncData(updated);
    await _persist(updated);
  }

  // ===================================================
  // UPDATE EXPERIENCES
  // ===================================================
  Future<void> updateExperiences(List<ExperienceModel> experiences) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      experiences: experiences,
    );

    state = AsyncData(updated);
    await _persist(updated);
  }

  // ===================================================
  // UPDATE EDUCATIONS
  // ===================================================
  Future<void> updateEducations(List<EducationModel> educations) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      education: educations,
    );

    state = AsyncData(updated);
    await _persist(updated);
  }

  // ===================================================
  // 🔥 UPDATE LINKS (NOVO)
  // ===================================================
  Future<void> updateLinks(List<SocialLinkModel> links) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      links: links, // 👈 importante: nome do campo no model
    );

    state = AsyncData(updated);
    await _persist(updated);
  }

  // ===================================================
  // PERSISTÊNCIA
  // ===================================================
  Future<void> _persist(ProfileModel profile) async {
    try {
      await _service.updateProfile(profile);
    } catch (e) {
      // TODO: tratamento futuro
    }
  }
}

// =======================================================
// SERVICE PROVIDER
// =======================================================
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

// =======================================================
// PROFILE PROVIDER
// =======================================================
final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileModel>>((ref) {
  final service = ref.read(profileServiceProvider);
  return ProfileNotifier(service);
});