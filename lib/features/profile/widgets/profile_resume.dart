// =======================================================
// PROFILE RESUME
// -------------------------------------------------------
// Card de resumo profissional
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

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
          color: colors.cardTertiary, // 🔥 AGORA FUNCIONA
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
                const Text(
                  'Resumo Profissional',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
              title: 'Data de Nascimento',
              value: '15/12/2005 | 18 Anos',
            ),

            const SizedBox(height: 12),

            const _InfoItem(
              title: 'Cidade',
              value: 'Brasil - Pato Branco PR',
            ),

            const SizedBox(height: 12),

            const _InfoItem(
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
  final String title;
  final String value;

  const _InfoItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
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
    );
  }
}