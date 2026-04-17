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
  final bool isPublic;

  const ProfileLanguages({
    super.key,
    required this.languages,
    this.isPublic = false,
  });

  static bool hasPublicContent({
    required List<LanguageModel> languages,
  }) {
    return languages.isNotEmpty;
  }

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

    if (isPublic && languages.isEmpty) {
      return const SizedBox.shrink();
    }

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
                if (!isPublic)
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
            const SizedBox(height: 4),

            // ===================================================
            // LISTA
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
                      showBadge: !isPublic,
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
// ITEM DE IDIOMA
// =======================================================

class _LanguageItem extends StatelessWidget {
  final String flag;
  final String name;
  final int percent;
  final String levelLabel;
  final bool showBadge;

  const _LanguageItem({
    required this.flag,
    required this.name,
    required this.percent,
    required this.levelLabel,
    required this.showBadge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // ===================================================
        // FLAG + BADGE OK
        // ===================================================
        SizedBox(
          width: 34,
          height: 30,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: 2,
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              if (showBadge)
                Positioned(
                  right: -2,
                  bottom: -1,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 9,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // ===================================================
        // NAME + LEVEL
        // ===================================================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
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