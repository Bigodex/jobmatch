// =======================================================
// PROFILE SCREEN
// -------------------------------------------------------
// Tela de perfil do usuário.
// Orquestra Header + Resumo + seções.
// Agora conectada com provider (dados reais)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jobmatch/features/profile/providers/profile_provider.dart';

import 'package:jobmatch/features/profile/widgets/profile_education.dart';
import 'package:jobmatch/features/profile/widgets/profile_experience.dart';
import 'package:jobmatch/features/profile/widgets/profile_hard_skills.dart';
import 'package:jobmatch/features/profile/widgets/profile_languages.dart';
import 'package:jobmatch/features/profile/widgets/profile_links.dart';
import 'package:jobmatch/features/profile/widgets/profile_soft_skills.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

import '../../../shared/widgets/app_header.dart';

import '../widgets/profile_header.dart';
import '../widgets/profile_resume.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final profileAsync = ref.watch(profileProvider);

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
              child: profileAsync.when(
                data: (profile) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // ---------------------------------------------
                        // HEADER DO PERFIL
                        // ---------------------------------------------
                        ProfileHeader(user: profile.user),

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
                          child: ProfileLanguages(languages: profile.languages),
                        ),

                        const SizedBox(height: 16),

                        // ---------------------------------------------
                        // SOFT SKILLS
                        // ---------------------------------------------
                        AppSectionCard(
                          child: ProfileSoftSkills(skills: profile.softSkills),
                        ),

                        const SizedBox(height: 16),

                        // ---------------------------------------------
                        // HARD SKILLS
                        // ---------------------------------------------
                        AppSectionCard(
                          child: ProfileHardSkills(skills: profile.techSkills),
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
                          child: ProfileLinks(links: profile.links),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },

                // ===================================================
                // LOADING
                // ===================================================
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),

                // ===================================================
                // ERROR
                // ===================================================
                error: (e, _) =>
                    Center(child: Text('Erro ao carregar perfil: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}