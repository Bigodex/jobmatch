// =======================================================
// PROFILE HARD SKILLS
// -------------------------------------------------------
// Card de habilidades técnicas
//
// Estrutura:
// - Header (título + editar)
// - Lista de habilidades
// - Barra de progresso
// - Tags (tecnologias)
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

class ProfileHardSkills extends StatelessWidget {
  const ProfileHardSkills({super.key});

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
                const Text(
                  'Habilidades Técnicas',
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
            // LISTA
            // ===================================================
            const _HardSkillItem(
              title: 'Design de Interfaces',
              level: 'Avançado',
              progress: 0.8,
              tags: ['Figma', 'Adobe XD', 'Photoshop'],
            ),

            const SizedBox(height: 16),

            const _HardSkillItem(
              title: 'Design Responsivo',
              level: 'Avançado',
              progress: 0.75,
              tags: ['Figma', 'Adobe XD', 'VS Code', '#CSS', '#HTML'],
            ),

            const SizedBox(height: 16),

            const _HardSkillItem(
              title: 'Desenvolvimento Web',
              level: 'Avançado',
              progress: 0.8,
              tags: [
                'VS Code',
                'Git/GitHub',
                'Postman',
                '#CSS',
                '#HTML',
                'Node.js',
              ],
            ),
          ],
        ),
      ),
    );
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ===================================================
        // TÍTULO
        // ===================================================
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 4),

        // ===================================================
        // NÍVEL
        // ===================================================
        Text(
          level,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),

        const SizedBox(height: 8),

        // ===================================================
        // PROGRESS BAR
        // ===================================================
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(
              theme.colorScheme.primary,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ===================================================
        // TAGS
        // ===================================================
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) => _TagChip(label: tag)).toList(),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: colors.cardSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),

      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
    );
  }
}