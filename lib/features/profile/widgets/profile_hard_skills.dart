// =======================================================
// PROFILE HARD SKILLS
// -------------------------------------------------------
// - Title branco
// - Textos dos itens mais opacos
// - Sem justify
// - Badge de pendência quando faltar dado
// - Badge de OK em primary com check preto quando estiver completo
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/features/profile/models/tech_skill_model.dart';

class ProfileHardSkills extends StatelessWidget {
  final List<TechSkillModel> skills;
  final bool isPublic;

  const ProfileHardSkills({
    super.key,
    required this.skills,
    this.isPublic = false,
  });

  static bool hasPublicContent({
    required List<TechSkillModel> skills,
  }) {
    return skills.any(_skillHasAnyContent);
  }

  static bool _skillHasAnyContent(TechSkillModel skill) {
    final hasTitle = skill.title.trim().isNotEmpty;
    final hasLevel = skill.level > 0;
    final hasTags = skill.tools
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .isNotEmpty;

    return hasTitle || hasLevel || hasTags;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    final visibleSkills = isPublic
        ? skills.where(_skillHasAnyContent).toList()
        : skills;

    if (isPublic && visibleSkills.isEmpty) {
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
                    SvgPicture.asset(
                      AppIcons.laptop,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Habilidades Técnicas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (!isPublic)
                  IconButton(
                    onPressed: () {
                      context.push(
                        '/edit-hard-skills',
                        extra: skills,
                      );
                    },
                    icon: const Icon(Icons.edit, size: 18),
                  ),
              ],
            ),

            Divider(color: theme.dividerColor.withOpacity(0.2)),
            const SizedBox(height: 8),

            // ===================================================
            // LISTA DINÂMICA / PLACEHOLDER
            // ===================================================
            if (!isPublic && skills.isEmpty)
              _PendingHardSkillItem(
                fieldName: 'Habilidades Técnicas',
              )
            else
              Column(
                children: visibleSkills.asMap().entries.map((entry) {
                  final index = entry.key;
                  final skill = entry.value;

                  return Column(
                    children: [
                      _HardSkillItem(
                        title: skill.title,
                        levelValue: skill.level,
                        levelLabel: _levelLabel(skill.level),
                        progress: skill.level / 100,
                        tags: skill.tools,
                        isPublic: isPublic,
                      ),
                      if (index != visibleSkills.length - 1)
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
  static String _levelLabel(int level) {
    if (level >= 85) return 'Avançado';
    if (level >= 60) return 'Intermediário';
    if (level > 0) return 'Básico';
    return '';
  }
}

// =======================================================
// HARD SKILL ITEM
// =======================================================

class _HardSkillItem extends StatelessWidget {
  final String title;
  final int levelValue;
  final String levelLabel;
  final double progress;
  final List<String> tags;
  final bool isPublic;

  const _HardSkillItem({
    required this.title,
    required this.levelValue,
    required this.levelLabel,
    required this.progress,
    required this.tags,
    required this.isPublic,
  });

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    final safeTitle = title.trim();
    final cleanTags = tags.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final hasTitle = safeTitle.isNotEmpty;
    final hasLevel = levelValue > 0;
    final hasTags = cleanTags.isNotEmpty;
    final isPending = !hasTitle || !hasLevel || !hasTags;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusIcon(
          icon: AppIcons.code,
          isPending: isPending,
          showBadge: !isPublic,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: isPublic
              ? _PublicHardSkillContent(
                  hasTitle: hasTitle,
                  safeTitle: safeTitle,
                  hasLevel: hasLevel,
                  levelLabel: levelLabel,
                  progress: progress,
                  hasTags: hasTags,
                  cleanTags: cleanTags,
                )
              : _PrivateHardSkillContent(
                  context: context,
                  hasTitle: hasTitle,
                  safeTitle: safeTitle,
                  hasLevel: hasLevel,
                  levelLabel: levelLabel,
                  progress: progress,
                  hasTags: hasTags,
                  cleanTags: cleanTags,
                ),
        ),
      ],
    );
  }
}

class _PublicHardSkillContent extends StatelessWidget {
  final bool hasTitle;
  final String safeTitle;
  final bool hasLevel;
  final String levelLabel;
  final double progress;
  final bool hasTags;
  final List<String> cleanTags;

  const _PublicHardSkillContent({
    required this.hasTitle,
    required this.safeTitle,
    required this.hasLevel,
    required this.levelLabel,
    required this.progress,
    required this.hasTags,
    required this.cleanTags,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = <Widget>[];

    if (hasTitle) {
      children.add(
        Text(
          safeTitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
    }

    if (hasLevel) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 4));
      }

      children.add(
        Text(
          levelLabel,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.62),
          ),
        ),
      );

      children.add(const SizedBox(height: 8));

      children.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 4,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(
              theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (hasTags) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 12));
      }

      children.add(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cleanTags
              .map((tag) => _TagChip(label: tag))
              .toList(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _PrivateHardSkillContent extends StatelessWidget {
  final BuildContext context;
  final bool hasTitle;
  final String safeTitle;
  final bool hasLevel;
  final String levelLabel;
  final double progress;
  final bool hasTags;
  final List<String> cleanTags;

  const _PrivateHardSkillContent({
    required this.context,
    required this.hasTitle,
    required this.safeTitle,
    required this.hasLevel,
    required this.levelLabel,
    required this.progress,
    required this.hasTags,
    required this.cleanTags,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTitle)
          Text(
            safeTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          )
        else
          _pendingText(
            context: this.context,
            fieldName: 'nome da habilidade',
          ),

        const SizedBox(height: 4),

        if (hasLevel)
          Text(
            levelLabel,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.62),
            ),
          )
        else
          _pendingText(
            context: this.context,
            fieldName: 'nível',
          ),

        const SizedBox(height: 8),

        if (hasLevel)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(
                theme.colorScheme.primary,
              ),
            ),
          ),

        SizedBox(height: hasLevel ? 12 : 10),

        if (hasTags)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cleanTags
                .map((tag) => _TagChip(label: tag))
                .toList(),
          )
        else
          _pendingText(
            context: this.context,
            fieldName: 'tecnologias',
          ),
      ],
    );
  }
}

// =======================================================
// ITEM PENDENTE (LISTA VAZIA)
// =======================================================

class _PendingHardSkillItem extends StatelessWidget {
  final String fieldName;

  const _PendingHardSkillItem({
    required this.fieldName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusIcon(
          icon: AppIcons.code,
          isPending: true,
          showBadge: true,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _pendingText(
            context: context,
            fieldName: fieldName,
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

  const _TagChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.cardTertiary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.68),
        ),
      ),
    );
  }
}

// =======================================================
// TEXTO DE PENDÊNCIA
// =======================================================

Widget _pendingText({
  required BuildContext context,
  required String fieldName,
}) {
  final pendingColor = Colors.amber.shade300;

  return RichText(
    textAlign: TextAlign.start,
    text: TextSpan(
      style: TextStyle(
        fontSize: 13,
        height: 1.4,
        color: Colors.white.withOpacity(0.78),
      ),
      children: [
        const TextSpan(
          text: 'Preencha os dados de ',
        ),
        TextSpan(
          text: fieldName,
          style: TextStyle(
            color: pendingColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const TextSpan(
          text: ', que no momento se encontra pendente.',
        ),
      ],
    ),
  );
}

// =======================================================
// ÍCONE COM BADGE DE STATUS
// =======================================================

class _StatusIcon extends StatelessWidget {
  final String icon;
  final bool isPending;
  final bool showBadge;

  const _StatusIcon({
    required this.icon,
    required this.isPending,
    required this.showBadge,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final theme = Theme.of(context);
    final pendingColor = Colors.amber.shade300;

    if (!showBadge) {
      return SizedBox(
        width: 18,
        height: 18,
        child: SvgPicture.asset(
          icon,
          width: 16,
          height: 16,
        ),
      );
    }

    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              icon,
              width: 16,
              height: 16,
            ),
          ),
          Positioned(
            right: -3,
            bottom: -3,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: isPending ? pendingColor : theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.cardTertiary,
                  width: 1.2,
                ),
              ),
              child: Icon(
                isPending ? Icons.priority_high_rounded : Icons.check_rounded,
                size: 8,
                color: Colors.black.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}