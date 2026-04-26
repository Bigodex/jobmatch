// =======================================================
// PROFILE PROVIDER
// -------------------------------------------------------
// Gerencia o estado do perfil do usuário e centraliza as
// ações de atualização usadas pelas telas de edição.
//
// Responsabilidades:
// - carregar o perfil inicial
// - aplicar atualizações otimistas na UI
// - persistir alterações no ProfileService
// - desfazer alteração local caso a persistência falhe
// =======================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/education_model.dart';
import '../models/experience_model.dart';
import '../models/language_model.dart';
import '../models/profile_model.dart';
import '../models/resume_model.dart';
import '../models/social_link_model.dart';
import '../models/soft_skill_model.dart';
import '../models/tech_skill_model.dart';
import '../services/profile_service.dart';

// =======================================================
// PROFILE PERSISTENCE EXCEPTION
// -------------------------------------------------------
// Erro específico para falhas ao salvar o perfil.
//
// Antes o provider engolia o erro silenciosamente no _persist,
// fazendo a tela parecer salva mesmo quando o Firebase falhava.
// Agora o erro é propagado para quem chamou a ação, permitindo
// exibir feedback real para o usuário.
// =======================================================
class ProfilePersistenceException implements Exception {
  final String message;
  final Object cause;

  const ProfilePersistenceException({
    required this.message,
    required this.cause,
  });

  @override
  String toString() {
    return '$message\nCausa: $cause';
  }
}

// =======================================================
// PROFILE NOTIFIER
// -------------------------------------------------------
// Controla o AsyncValue<ProfileModel> usado pelas telas.
//
// A atualização segue o padrão:
// - pega o estado atual
// - cria uma versão atualizada
// - atualiza a UI imediatamente
// - tenta salvar no banco
// - se falhar, volta para o estado anterior e propaga erro
// =======================================================
class ProfileNotifier extends StateNotifier<AsyncValue<ProfileModel>> {
  final ProfileService _service;

  ProfileNotifier(this._service) : super(const AsyncLoading()) {
    loadProfile();
  }

  // ===================================================
  // LOAD PROFILE
  // ---------------------------------------------------
  // Carrega o perfil inicial a partir do service.
  // Caso falhe, o erro fica exposto no AsyncValue para a UI.
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
  // ---------------------------------------------------
  // Atualiza a URL da capa do usuário.
  // ===================================================
  Future<void> updateCover(String url) async {
    await _updateProfile(
      (current) => current.copyWith(
        user: current.user.copyWith(
          coverUrl: url,
        ),
      ),
    );
  }

  // ===================================================
  // UPDATE AVATAR
  // ---------------------------------------------------
  // Atualiza a URL do avatar do usuário.
  // ===================================================
  Future<void> updateAvatar(String url) async {
    await _updateProfile(
      (current) => current.copyWith(
        user: current.user.copyWith(
          avatarUrl: url,
        ),
      ),
    );
  }

  // ===================================================
  // UPDATE USER INFO
  // ---------------------------------------------------
  // Atualiza informações principais do usuário.
  // ===================================================
  Future<void> updateUserInfo({
    required String name,
    required String role,
  }) async {
    await _updateProfile(
      (current) => current.copyWith(
        user: current.user.copyWith(
          name: name,
          role: role,
        ),
      ),
    );
  }

  // ===================================================
  // UPDATE RESUME
  // ---------------------------------------------------
  // Atualiza os dados pessoais/profissionais do currículo.
  // ===================================================
  Future<void> updateResume(ResumeModel updatedResume) async {
    await _updateProfile(
      (current) => current.copyWith(
        resume: updatedResume,
      ),
    );
  }

  // ===================================================
  // UPDATE LANGUAGES
  // ---------------------------------------------------
  // Atualiza a lista de idiomas do perfil.
  // ===================================================
  Future<void> updateLanguages(List<LanguageModel> languages) async {
    await _updateProfile(
      (current) => current.copyWith(
        languages: languages,
      ),
    );
  }

  // ===================================================
  // UPDATE SOFT SKILLS
  // ---------------------------------------------------
  // Atualiza a lista de habilidades comportamentais.
  // ===================================================
  Future<void> updateSoftSkills(List<SoftSkillModel> skills) async {
    await _updateProfile(
      (current) => current.copyWith(
        softSkills: skills,
      ),
    );
  }

  // ===================================================
  // UPDATE HARD SKILLS
  // ---------------------------------------------------
  // Atualiza a lista de habilidades técnicas.
  // ===================================================
  Future<void> updateHardSkills(List<TechSkillModel> skills) async {
    await _updateProfile(
      (current) => current.copyWith(
        techSkills: skills,
      ),
    );
  }

  // ===================================================
  // UPDATE EXPERIENCES
  // ---------------------------------------------------
  // Atualiza a lista de experiências profissionais.
  // ===================================================
  Future<void> updateExperiences(List<ExperienceModel> experiences) async {
    await _updateProfile(
      (current) => current.copyWith(
        experiences: experiences,
      ),
    );
  }

  // ===================================================
  // UPDATE EDUCATIONS
  // ---------------------------------------------------
  // Atualiza a lista de formações acadêmicas.
  // ===================================================
  Future<void> updateEducations(List<EducationModel> educations) async {
    await _updateProfile(
      (current) => current.copyWith(
        education: educations,
      ),
    );
  }

  // ===================================================
  // UPDATE LINKS
  // ---------------------------------------------------
  // Atualiza a lista de links sociais/profissionais.
  // ===================================================
  Future<void> updateLinks(List<SocialLinkModel> links) async {
    await _updateProfile(
      (current) => current.copyWith(
        links: links,
      ),
    );
  }

  // ===================================================
  // UPDATE PROFILE
  // ---------------------------------------------------
  // Helper central para evitar repetição nos métodos de update.
  //
  // Ele garante que toda alteração passe pelo mesmo fluxo:
  // - valida estado atual
  // - monta estado atualizado
  // - aplica atualização otimista
  // - persiste no service
  // ===================================================
  Future<void> _updateProfile(
    ProfileModel Function(ProfileModel current) update,
  ) async {
    final current = state.value;

    if (current == null) {
      return;
    }

    final updated = update(current);

    state = AsyncData(updated);

    await _persist(
      previous: current,
      updated: updated,
    );
  }

  // ===================================================
  // PERSIST PROFILE
  // ---------------------------------------------------
  // Salva o perfil atualizado no banco.
  //
  // Caso o save falhe:
  // - restaura o estado anterior para não deixar a UI mentir
  // - propaga um erro específico para a tela poder tratar
  // ===================================================
  Future<void> _persist({
    required ProfileModel previous,
    required ProfileModel updated,
  }) async {
    try {
      await _service.updateProfile(updated);
    } catch (e, st) {
      state = AsyncData(previous);

      Error.throwWithStackTrace(
        ProfilePersistenceException(
          message: 'Não foi possível salvar as alterações do perfil.',
          cause: e,
        ),
        st,
      );
    }
  }
}

// =======================================================
// PROFILE SERVICE PROVIDER
// -------------------------------------------------------
// Disponibiliza a instância do ProfileService para o notifier.
// =======================================================
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

// =======================================================
// PROFILE PROVIDER
// -------------------------------------------------------
// Provider principal consumido pelas telas de perfil.
// =======================================================
final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileModel>>((ref) {
  final service = ref.read(profileServiceProvider);
  return ProfileNotifier(service);
});
