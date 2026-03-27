// =======================================================
// PROFILE PROVIDER
// -------------------------------------------------------
// Gerencia estado + edição do perfil
// - cover
// - avatar
// - user info
// - resume
// =======================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/profile_model.dart';
import '../models/resume_model.dart';
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
  // PERSISTÊNCIA CENTRALIZADA
  // ===================================================
  Future<void> _persist(ProfileModel profile) async {
    try {
      await _service.updateProfile(profile);
    } catch (e) {
      // 🔥 Aqui você pode evoluir:
      // - rollback de state
      // - snackbar global
      // - retry automático
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