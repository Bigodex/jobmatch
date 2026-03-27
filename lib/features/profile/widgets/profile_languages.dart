// =======================================================
// PROFILE LANGUAGES
// -------------------------------------------------------
// Agora conectado ao LanguageModel (dados dinâmicos)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/features/profile/models/language_model.dart';

class ProfileLanguages extends StatelessWidget {
  final List<LanguageModel> languages;

  const ProfileLanguages({super.key, required this.languages});

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
                Row(
                  children: [
                    SvgPicture.asset(AppIcons.language, width: 18, height: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Idiomas',
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

            Divider(color: Theme.of(context).dividerColor.withOpacity(0.2)),
            const SizedBox(height: 12),

            // ===================================================
            // LISTA DINÂMICA
            // ===================================================
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: languages
                  .map(
                    (lang) => _LanguageChip(
                      flag: lang.flag,
                      label: lang.name,
                      level: '${lang.level}%',
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// LANGUAGE CHIP
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.cardSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // BANDEIRA
          Text(flag, style: const TextStyle(fontSize: 18)),

          const SizedBox(width: 8),

          // TEXTO
          Text('$label | $level', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
