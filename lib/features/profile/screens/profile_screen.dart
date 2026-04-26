// =======================================================
// PROFILE SCREEN
// -------------------------------------------------------
// Tela de perfil do usuário.
// Orquestra Header + Resumo + seções.
// Conectada com provider (dados reais).
//
// Ajuste:
// - permite atualizar o currículo ao arrastar a tela para baixo
// - usa RefreshIndicator igual comportamento da Network
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jobmatch/features/profile/providers/profile_provider.dart';

import 'package:jobmatch/features/profile/widgets/profile_education.dart';
import 'package:jobmatch/features/profile/widgets/profile_experience.dart';
import 'package:jobmatch/features/profile/widgets/profile_hard_skills.dart';
import 'package:jobmatch/features/profile/widgets/profile_languages.dart';
import 'package:jobmatch/features/profile/widgets/profile_links.dart';
import 'package:jobmatch/features/profile/widgets/profile_soft_skills.dart';
import 'package:jobmatch/features/profile/widgets/profile_screen_skeleton.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

import '../../../shared/widgets/app_header.dart';

import '../widgets/profile_header.dart';
import '../widgets/profile_resume.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // ===================================================
  // REFRESH PROFILE
  // ---------------------------------------------------
  // Recarrega os dados do perfil ao arrastar a tela
  // para baixo.
  // ===================================================
  Future<void> _refreshProfile(WidgetRef ref) async {
    await ref.read(profileProvider.notifier).loadProfile();
  }

  // ===================================================
  // BUILD
  // ---------------------------------------------------
  // Monta a tela principal do currículo.
  // ===================================================
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final profileAsync = ref.watch(profileProvider);

    // ===================================================
    // TROQUE PARA false QUANDO TERMINAR DE VALIDAR O VISUAL
    // ===================================================
    const bool previewSkeleton = false;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ===================================================
            // HEADER FIXO
            // ===================================================
            const AppHeader(title: 'Meu currículo'),

            // ===================================================
            // CONTEÚDO
            // ===================================================
            Expanded(
              child: previewSkeleton
                  ? const ProfileScreenSkeleton()
                  : profileAsync.when(
                      data: (profile) {
                        return RefreshIndicator(
                          color: theme.colorScheme.primary,
                          backgroundColor: theme.cardColor,
                          onRefresh: () => _refreshProfile(ref),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                // ---------------------------------------------
                                // HEADER DO PERFIL
                                // ---------------------------------------------
                                ProfileHeader(
                                  user: profile.user,
                                  onConnectionsTap: () {
                                    context.push('/network/connections');
                                  },
                                ),

                                const SizedBox(height: 16),

                                // ---------------------------------------------
                                // RESUMO PROFISSIONAL
                                // ---------------------------------------------
                                AppSectionCard(
                                  child: ProfileResume(
                                    resume: profile.resume,
                                    email: profile.user.email,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // ---------------------------------------------
                                // IDIOMAS
                                // ---------------------------------------------
                                AppSectionCard(
                                  child: ProfileLanguages(
                                    languages: profile.languages,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // ---------------------------------------------
                                // SOFT SKILLS
                                // ---------------------------------------------
                                AppSectionCard(
                                  child: ProfileSoftSkills(
                                    skills: profile.softSkills,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // ---------------------------------------------
                                // HARD SKILLS
                                // ---------------------------------------------
                                AppSectionCard(
                                  child: ProfileHardSkills(
                                    skills: profile.techSkills,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // ---------------------------------------------
                                // EXPERIÊNCIA
                                // ---------------------------------------------
                                AppSectionCard(
                                  child: ProfileExperience(
                                    experiences: profile.experiences,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // ---------------------------------------------
                                // FORMAÇÃO
                                // ---------------------------------------------
                                AppSectionCard(
                                  child: ProfileEducation(
                                    educations: profile.education,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // ---------------------------------------------
                                // LINKS
                                // ---------------------------------------------
                                AppSectionCard(
                                  child: ProfileLinks(
                                    links: profile.links,
                                  ),
                                ),

                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        );
                      },

                      // ===================================================
                      // LOADING
                      // ===================================================
                      loading: () => const ProfileScreenSkeleton(),

                      // ===================================================
                      // ERROR
                      // ===================================================
                      error: (e, _) {
                        return RefreshIndicator(
                          color: theme.colorScheme.primary,
                          backgroundColor: theme.cardColor,
                          onRefresh: () => _refreshProfile(ref),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.65,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    'Erro ao carregar perfil: $e',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}