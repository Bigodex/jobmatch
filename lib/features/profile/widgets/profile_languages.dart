// =======================================================
// PROFILE LANGUAGES (LISTA PREMIUM)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/features/profile/models/language_model.dart';
import 'package:jobmatch/features/profile/screens/edit_language_screen.dart';

class ProfileLanguages extends StatelessWidget {
  final List<LanguageModel> languages;

  const ProfileLanguages({super.key, required this.languages});

  // ===================================================
  // LABEL (MESMA REGRA DO EDIT)
  // ===================================================
  String _getLevelLabel(int value) {
    if (value == 100) return 'Nativo';
    if (value >= 90) return 'Expert';
    if (value >= 61) return 'Avançado';
    if (value >= 40) return 'Intermediário';
    if (value >= 21) return 'Iniciante';
    if (value >= 10) return 'Básico';
    return 'Muito baixo';
  }

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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditLanguageScreen(languages: languages),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                ),
              ],
            ),

            Divider(color: theme.dividerColor.withOpacity(0.2)),
            const SizedBox(height: 12),

            // ===================================================
            // LISTA (🔥 NOVO DESIGN)
            // ===================================================
            Column(
              children: List.generate(languages.length, (index) {
                final lang = languages[index];

                return Column(
                  children: [
                    _LanguageItem(
                      flag: lang.flag,
                      name: lang.name,
                      percent: lang.level,
                      levelLabel: _getLevelLabel(lang.level),
                    ),

                    if (index != languages.length - 1)
                      Divider(
                        height: 20,
                        color: theme.dividerColor.withOpacity(0.2),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// ITEM DE IDIOMA (🔥 NOVO)
// =======================================================

class _LanguageItem extends StatelessWidget {
  final String flag;
  final String name;
  final int percent;
  final String levelLabel;

  const _LanguageItem({
    required this.flag,
    required this.name,
    required this.percent,
    required this.levelLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [

        // ===================================================
        // FLAG
        // ===================================================
        Text(
          flag,
          style: const TextStyle(fontSize: 22),
        ),

        const SizedBox(width: 12),

        // ===================================================
        // NAME + LEVEL
        // ===================================================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Nome
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 2),

              // Nível
              Text(
                levelLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // ===================================================
        // PORCENTAGEM
        // ===================================================
        Text(
          '$percent%',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}