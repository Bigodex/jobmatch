// =======================================================
// PROFILE LANGUAGES
// -------------------------------------------------------
// Card de idiomas do usuário
//
// Segue o mesmo padrão do ProfileResume,
// mas com exibição em formato de chips.
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

class ProfileLanguages extends StatelessWidget {
  const ProfileLanguages({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: colors.cardTertiary, // 🔥 mesmo padrão que você definiu
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
                  'Idiomas',
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

            const SizedBox(height: 12),

            // ===================================================
            // LISTA DE IDIOMAS
            // ===================================================
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [

                _LanguageChip(
                  flag: '🇧🇷',
                  label: 'Português',
                  level: '100%',
                ),

                _LanguageChip(
                  flag: '🇩🇪',
                  label: 'Alemão',
                  level: '10%',
                ),

                _LanguageChip(
                  flag: '🇺🇸',
                  label: 'Inglês',
                  level: '30%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// LANGUAGE CHIP
// -------------------------------------------------------
// Item individual de idioma
// =======================================================

class _LanguageChip extends StatelessWidget {
  final String flag;
  final String label;
  final String level;

  const _LanguageChip({
    required this.flag,
    required this.label,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: colors.cardSecondary, // 🔥 leve contraste
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ===================================================
          // BANDEIRA
          // ===================================================
          Text(
            flag,
            style: const TextStyle(fontSize: 18),
          ),

          const SizedBox(width: 8),

          // ===================================================
          // TEXTO
          // ===================================================
          Text(
            '$label | $level',
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}