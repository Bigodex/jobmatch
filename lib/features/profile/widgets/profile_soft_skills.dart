// =======================================================
// PROFILE SOFT SKILLS
// -------------------------------------------------------
// Card de habilidades comportamentais
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/constants/app_icons.dart';

class ProfileSoftSkills extends StatelessWidget {
  const ProfileSoftSkills({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: colors.cardTertiary,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===================================================
            // HEADER
            // ===================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // -------------------------------------------------
                // TITLE + ICON
                // -------------------------------------------------
                Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.softskills,
                      width: 18,
                      height: 18,
                    ),

                    const SizedBox(width: 8),

                    const Text(
                      'Habilidades Comportamentais',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 18),
                ),
              ],
            ),

            const Divider(),

            const SizedBox(height: 8),

            // ===================================================
            // LISTA
            // ===================================================
            const _SkillItem(
              title: 'Comunicação Eficaz',
              description:
                  'Capacidade de transmitir ideias de forma clara e objetiva, seja em reuniões com o time, apresentações de projetos ou documentações técnicas.',
            ),

            const Divider(height: 24),

            const _SkillItem(
              title: 'Trabalho em Equipe',
              description:
                  'Habilidade para colaborar com outros desenvolvedores, designers e gerentes de projeto, promovendo um ambiente produtivo e alinhado com os objetivos do time.',
            ),

            const Divider(height: 24),

            const _SkillItem(
              title: 'Aprendizado Contínuo',
              description:
                  'Habilidade para colaborar com outros desenvolvedores, designers e gerentes de projeto, promovendo um ambiente produtivo e alinhado com os objetivos do time.',
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// SKILL ITEM
// =======================================================

class _SkillItem extends StatelessWidget {
  final String title;
  final String description;

  const _SkillItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // -------------------------------------------------
        // ICON
        // -------------------------------------------------
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SvgPicture.asset(
            AppIcons.softskillsitem,
            width: 16,
            height: 16,
          ),
        ),

        const SizedBox(width: 10),

        // -------------------------------------------------
        // TEXT
        // -------------------------------------------------
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}