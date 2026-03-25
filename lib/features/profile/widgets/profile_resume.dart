// =======================================================
// PROFILE RESUME
// -------------------------------------------------------
// Card de resumo profissional
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/constants/app_icons.dart';

class ProfileResume extends StatelessWidget {
  const ProfileResume({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ===================================================
    // EXTENSION (PEGA cardSecondary)
    // ===================================================
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
                      AppIcons.cv,
                      width: 18,
                      height: 18,
                    ),

                    const SizedBox(width: 8),

                    const Text(
                      'Resumo Profissional',
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
            // INFO
            // ===================================================
            const _InfoItem(
              icon: AppIcons.cake,
              title: 'Data de Nascimento',
              value: '23/10/1996 | 29 Anos',
            ),

            const SizedBox(height: 12),

            const _InfoItem(
              icon: AppIcons.building,
              title: 'Cidade',
              value: 'Brasil - Pato Branco PR',
            ),

            const SizedBox(height: 12),

            const _InfoItem(
              icon: AppIcons.info,
              title: 'Descrição',
              value:
                  'Profissional de UI/UX com 5 anos de experiência em design centrado no usuário, com atuação em startups e grandes empresas.',
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// INFO ITEM
// =======================================================

class _InfoItem extends StatelessWidget {
  final String icon;
  final String title;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
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
            icon,
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
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}