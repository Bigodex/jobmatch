// =======================================================
// PROFILE SOFT SKILLS
// -------------------------------------------------------
// Agora conectado ao SoftSkillModel (dados dinâmicos)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/features/profile/models/soft_skill_model.dart';

class ProfileSoftSkills extends StatelessWidget {
  final List<SoftSkillModel> skills;

  const ProfileSoftSkills({super.key, required this.skills});

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
                  onPressed: () {
                    context.push('/edit-soft-skills', extra: skills);
                  },
                  icon: const Icon(Icons.edit, size: 18),
                ),
              ],
            ),

            Divider(color: Theme.of(context).dividerColor.withOpacity(0.2)),
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
                    _SkillItem(
                      title: skill.title,
                      description: skill.description,
                    ),

                    // Divider entre itens (menos no último)
                    if (index != skills.length - 1)
                      Divider(
                        height: 24,
                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                      ),
                  ],
                );
              }).toList(),
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

  const _SkillItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SvgPicture.asset(
            AppIcons.softskillsitem,
            width: 16,
            height: 16,
          ),
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

              const SizedBox(height: 6),

              Text(
                description,
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
