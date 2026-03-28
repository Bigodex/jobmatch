// =======================================================
// PROFILE HARD SKILLS
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/features/profile/models/tech_skill_model.dart';

class ProfileHardSkills extends StatelessWidget {
  final List<TechSkillModel> skills;

  const ProfileHardSkills({super.key, required this.skills});

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
                    SvgPicture.asset(AppIcons.laptop, width: 16, height: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Habilidades Técnicas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // 🔥 BOTÃO EDITAR CORRIGIDO
                IconButton(
                  onPressed: () {
                    context.push(
                      '/edit-hard-skills',
                      extra: skills, // ✅ CORRETO
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                ),
              ],
            ),

            Divider(color: theme.dividerColor.withOpacity(0.2)),
            const SizedBox(height: 8),

            // ===================================================
            // LISTA DINÂMICA
            // ===================================================
            Column(
              children: skills.asMap().entries.map((entry) {
                final index = entry.key;
                final skill = entry.value;

                return Column(
                  children: [
                    _HardSkillItem(
                      title: skill.title,
                      level: _levelLabel(skill.level),
                      progress: skill.level / 100,
                      tags: skill.tools,
                    ),
                    if (index != skills.length - 1)
                      const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // =======================================================
  // LABEL DE NÍVEL
  // =======================================================
  String _levelLabel(int level) {
    if (level >= 85) return 'Avançado';
    if (level >= 60) return 'Intermediário';
    return 'Básico';
  }
}

// =======================================================
// HARD SKILL ITEM
// =======================================================

class _HardSkillItem extends StatelessWidget {
  final String title;
  final String level;
  final double progress;
  final List<String> tags;

  const _HardSkillItem({
    required this.title,
    required this.level,
    required this.progress,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SvgPicture.asset(AppIcons.code, width: 16, height: 16),
        ),

        const SizedBox(width: 10),

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

              const SizedBox(height: 4),

              Text(
                level,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor:
                      AlwaysStoppedAnimation(theme.colorScheme.primary),
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    tags.map((tag) => _TagChip(label: tag)).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =======================================================
// TAG CHIP
// =======================================================

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.cardTertiary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}