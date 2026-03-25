// =======================================================
// PROFILE EDUCATION
// -------------------------------------------------------
// Card de formações acadêmicas
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/constants/app_icons.dart';

class ProfileEducation extends StatelessWidget {
  const ProfileEducation({super.key});

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
                      AppIcons.cap,
                      width: 18,
                      height: 18,
                    ),

                    const SizedBox(width: 8),

                    const Text(
                      'Formações',
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
            // ITEM
            // ===================================================
            const _EducationItem(
              institution: 'Centro Universitário de Pato Branco - UNIDEP',
              level: 'Ensino Superior',
              course: 'ADS (análise e desenvolvimento de sistemas)',
              period: '1 ano - Até o momento',
              logoColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// EDUCATION ITEM
// =======================================================

class _EducationItem extends StatelessWidget {
  final String institution;
  final String level;
  final String course;
  final String period;
  final Color logoColor;

  const _EducationItem({
    required this.institution,
    required this.level,
    required this.course,
    required this.period,
    required this.logoColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ===================================================
        // COLUNA ESQUERDA (LOGO + LINHA)
        // ===================================================
        Column(
          children: [

            // LOGO
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: logoColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            const SizedBox(height: 8),

            // LINHA
            Container(
              width: 2,
              height: 70,
              color: Colors.white
            ),
          ],
        ),

        const SizedBox(width: 12),

        // ===================================================
        // CONTEÚDO
        // ===================================================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // INSTITUIÇÃO
              Text(
                institution,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              // NÍVEL
              Text(
                level,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 8),

              // CURSO
              Text(
                course,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              // PERÍODO
              Text(
                period,
                style: TextStyle(
                  fontSize: 12,
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