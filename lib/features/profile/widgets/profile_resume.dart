// =======================================================
// PROFILE RESUME
// -------------------------------------------------------
// Card de resumo profissional
//
// Ajustes:
// - Uso de labels do model
// - Mantida estrutura original
// - Sem invenção de propriedades
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/features/profile/models/resume_model.dart';

class ProfileResume extends StatelessWidget {
  final ResumeModel? resume;
  final VoidCallback? onEdit;

  const ProfileResume({super.key, required this.resume, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    // ===================================================
    // ESTADO VAZIO
    // ===================================================
    if (resume == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.cardTertiary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(AppIcons.cv, width: 18, height: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Resumo Profissional',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Divider(height: 24),

              Text(
                'Informações ainda não disponíveis.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: double.infinity,
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
                Expanded(
                  child: Row(
                    children: [
                      SvgPicture.asset(AppIcons.cv, width: 18, height: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          resume!.labels.title, // 🔥 AGORA DINÂMICO
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit,
                      size: 18,
                      color: theme.iconTheme.color,
                    ),
                    tooltip: 'Editar resumo',
                  ),
              ],
            ),

            const SizedBox(height: 8),

            Divider(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
            ),

            const SizedBox(height: 8),

            // ===================================================
            // INFOS
            // ===================================================
            _InfoItem(
              icon: AppIcons.cake,
              title: resume!.labels.birthDateLabel, // 🔥 DINÂMICO
              value: _formatBirth(resume!.birthDate),
            ),

            const SizedBox(height: 12),

            _InfoItem(
              icon: AppIcons.building,
              title: resume!.labels.cityLabel, // 🔥 DINÂMICO
              value: _safeText(resume!.city, fallback: 'Não informado'),
            ),

            const SizedBox(height: 12),

            _InfoItem(
              icon: AppIcons.info,
              title: resume!.labels.descriptionLabel, // 🔥 DINÂMICO
              value: _safeText(
                resume!.description,
                fallback: 'Sem descrição cadastrada',
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  // =======================================================
  // SAFE TEXT
  // =======================================================
  String _safeText(String? value, {String fallback = 'Não informado'}) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }
    return value.trim();
  }

  // =======================================================
  // FORMATADOR DATA
  // =======================================================
  String _formatBirth(DateTime? date) {
    if (date == null) return 'Não informado';

    final now = DateTime.now();

    int age = now.year - date.year;

    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      age--;
    }

    final safeAge = age < 0 ? 0 : age;

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} | $safeAge anos';
  }
}

// =======================================================
// INFO ITEM
// =======================================================

class _InfoItem extends StatelessWidget {
  final String icon;
  final String title;
  final String value;
  final int maxLines;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SvgPicture.asset(icon, width: 16, height: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}