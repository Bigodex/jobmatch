// =======================================================
// PROFILE SCREEN
// -------------------------------------------------------
// Tela de perfil do usuário.
// Orquestra Header + Resumo + futuras seções.
// =======================================================

import 'package:flutter/material.dart';
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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              child: SingleChildScrollView(
                child: Column(
                  children: const [
                    // ---------------------------------------------
                    // HEADER DO PERFIL
                    // ---------------------------------------------
                    ProfileHeader(),

                    SizedBox(height: 16),

                    // ---------------------------------------------
                    // RESUMO PROFISSIONAL
                    // ---------------------------------------------
                    AppSectionCard(child: ProfileResume()),

                    SizedBox(height: 16),

                    // ---------------------------------------------
                    // IDIOMAS
                    // ---------------------------------------------
                    AppSectionCard(child: ProfileLanguages()),

                    SizedBox(height: 16),

                    // ---------------------------------------------
                    // SOFT SKILLS
                    // ---------------------------------------------
                    AppSectionCard(child: ProfileSoftSkills()),

                    SizedBox(height: 16),

                    // ---------------------------------------------
                    // HARD SKILLS
                    // ---------------------------------------------

                    AppSectionCard(child: ProfileHardSkills()),

                    SizedBox(height: 16),
                    
                    // ---------------------------------------------
                    // EXPERIENCIA
                    // ---------------------------------------------

                    AppSectionCard(child: ProfileExperience()),

                    SizedBox(height: 16),

                    // ---------------------------------------------
                    // FORMAÇÃO
                    // ---------------------------------------------

                    AppSectionCard(child: ProfileEducation()),

                    SizedBox(height: 16),

                    // ---------------------------------------------
                    // FORMAÇÃO
                    // ---------------------------------------------
                    
                    AppSectionCard(child: ProfileLinks()),

                    SizedBox(height: 32),


                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
