// =======================================================
// PROFILE SOFT SKILLS
// -------------------------------------------------------
// - Agora conectado ao SoftSkillModel (dados dinâmicos)
// - Com placeholder de pendência no padrão do resumo
// - Badge de exclamação no ícone quando faltar dado
// - Badge de OK em primary com check preto quando estiver completo
// - Title branco
// - Textos dos itens mais opacos
// - Sem justify
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/features/profile/models/soft_skill_model.dart';

class ProfileSoftSkills extends StatelessWidget {
  final List<SoftSkillModel> skills;

  const ProfileSoftSkills({
    super.key,
    required this.skills,
  });

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
                        color: Colors.white,
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

            Divider(color: theme.dividerColor.withOpacity(0.2)),
            const SizedBox(height: 8),

            // ===================================================
            // LISTA DINÂMICA / PLACEHOLDER
            // ===================================================
            if (skills.isEmpty)
              _PendingSoftSkillItem(
                fieldName: 'Habilidades Comportamentais',
              )
            else
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
                      if (index != skills.length - 1)
                        Divider(
                          height: 24,
                          color: theme.dividerColor.withOpacity(0.2),
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

  const _SkillItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final safeTitle = title.trim();
    final safeDescription = description.trim();

    final hasTitle = safeTitle.isNotEmpty;
    final hasDescription = safeDescription.isNotEmpty;
    final isPending = !hasTitle || !hasDescription;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusIcon(
          icon: AppIcons.softskillsitem,
          isPending: isPending,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasTitle)
                const SizedBox.shrink()
              else
                const SizedBox.shrink(),
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
                  context: context,
                  fieldName: 'nome da habilidade',
                ),
              const SizedBox(height: 6),
              if (hasDescription)
                Text(
                  safeDescription,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Colors.white.withOpacity(0.62),
                  ),
                )
              else
                _pendingText(
                  context: context,
                  fieldName: 'descrição',
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// =======================================================
// ITEM PENDENTE (LISTA VAZIA)
// =======================================================

class _PendingSoftSkillItem extends StatelessWidget {
  final String fieldName;

  const _PendingSoftSkillItem({
    required this.fieldName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusIcon(
          icon: AppIcons.softskillsitem,
          isPending: true,
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

  const _StatusIcon({
    required this.icon,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final theme = Theme.of(context);
    final pendingColor = Colors.amber.shade300;

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