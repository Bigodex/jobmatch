// =======================================================
// AUTH PROVIDER
// =======================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/auth_user_model.dart';
import '../services/auth_service.dart';

// 🔥 IMPORT DO PROFILE
import '../../profile/services/profile_service.dart';
import '../../profile/providers/profile_provider.dart';

// =======================================================
// SERVICE PROVIDER
// =======================================================
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// =======================================================
// AUTH STATE (STREAM)
// =======================================================
final authStateProvider = StreamProvider<AuthUserModel?>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.authStateChanges;
});

// =======================================================
// CONTROLLER
// =======================================================
class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final AuthService _service;
  final ProfileService _profileService;

  AuthController(this.ref, this._service, this._profileService)
      : super(const AsyncData(null));

  // ===================================================
  // LOGIN
  // ===================================================
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    try {
      await _service.login(email: email, password: password);

      // 🔥 força recarregar o perfil da conta logada
      ref.invalidate(profileProvider);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ===================================================
  // REGISTER
  // ===================================================
  Future<void> register(String email, String password) async {
    state = const AsyncLoading();

    try {
      await _service.register(email: email, password: password);

      // 🔥 CRIA PROFILE AUTOMATICAMENTE
      await _profileService.createProfile();

      // 🔥 força recarregar o profile recém-criado
      ref.invalidate(profileProvider);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ===================================================
  // UPDATE CURRENT USER EMAIL
  // ===================================================
  Future<void> updateCurrentUserEmail(String newEmail) async {
    state = const AsyncLoading();

    try {
      await _service.updateCurrentUserEmail(newEmail);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ===================================================
  // LOGOUT
  // ===================================================
  Future<void> logout() async {
    try {
      await _service.logout();

      // 🔥 limpa o profile em memória ao sair
      ref.invalidate(profileProvider);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// =======================================================
// CONTROLLER PROVIDER
// =======================================================
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final service = ref.watch(authServiceProvider);

  // 🔥 INJEÇÃO CORRETA
  final profileService = ref.watch(profileServiceProvider);

  return AuthController(ref, service, profileService);
});