// =======================================================
// PROFILE EXPERIENCE
// -------------------------------------------------------
// Card de experiências profissionais
// Ajustado para manter:
// - empresa
// - período
// - cargo
// - descrição
// - timeline visual mais próxima do layout original
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/features/profile/models/experience_model.dart';

class ProfileExperience extends StatelessWidget {
  final List<ExperienceModel> experiences;

  const ProfileExperience({
    super.key,
    required this.experiences,
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
                      AppIcons.briefcase,
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Experiência',
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

            const Divider(),
            const SizedBox(height: 8),

            // ===================================================
            // LISTA DINÂMICA
            // ===================================================
            Column(
              children: experiences.asMap().entries.map((entry) {
                final index = entry.key;
                final experience = entry.value;
                final isLast = index == experiences.length - 1;

                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                  child: _ExperienceItem(
                    company: experience.company,
                    period: _formatPeriod(
                      experience.startDate,
                      experience.endDate,
                    ),
                    role: experience.role,
                    description: experience.description,
                    logoColor: _getLogoColor(experience.company),
                    logoText: _getLogoText(experience.company),
                    showLine: !isLast,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // =======================================================
  // FORMATA PERÍODO
  // =======================================================

  String _formatPeriod(DateTime startDate, DateTime? endDate) {
    final startFormatted = DateFormat('dd/MM/yyyy').format(startDate);

    if (endDate == null) {
      final months = _monthDifference(startDate, DateTime.now());
      final periodText = months >= 12
          ? '${(months / 12).floor()} ano${(months / 12).floor() > 1 ? 's' : ''}'
          : '$months mes${months > 1 ? 'es' : ''}';

      return '$periodText - Até o momento';
    }

    final endFormatted = DateFormat('dd/MM/yyyy').format(endDate);
    final months = _monthDifference(startDate, endDate);

    return '$startFormatted - $endFormatted - $months Meses';
  }

  int _monthDifference(DateTime start, DateTime end) {
    int months = (end.year - start.year) * 12 + (end.month - start.month);
    if (end.day < start.day) {
      months--;
    }
    return months <= 0 ? 1 : months;
  }

  // =======================================================
  // MOCK VISUAL DE LOGO/COR
  // -------------------------------------------------------
  // Enquanto seu model não tiver logoUrl / brandColor
  // =======================================================

  Color _getLogoColor(String company) {
    final normalized = company.toLowerCase();

    if (normalized.contains('ids')) {
      return const Color(0xFF0D5BD7);
    }

    if (normalized.contains('agende')) {
      return const Color(0xFF5C5C5C);
    }

    return const Color(0xFF3A3A3A);
  }

  String _getLogoText(String company) {
    final normalized = company.toLowerCase();

    if (normalized.contains('ids')) {
      return 'ids';
    }

    if (normalized.contains('agende')) {
      return 'a';
    }

    return company.isNotEmpty ? company[0].toUpperCase() : '?';
  }
}

// =======================================================
// EXPERIENCE ITEM
// =======================================================

class _ExperienceItem extends StatelessWidget {
  final String company;
  final String period;
  final String role;
  final String description;
  final Color logoColor;
  final String logoText;
  final bool showLine;

  const _ExperienceItem({
    required this.company,
    required this.period,
    required this.role,
    required this.description,
    required this.logoColor,
    required this.logoText,
    required this.showLine,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===================================================
        // COLUNA ESQUERDA (LOGO + TIMELINE)
        // ===================================================
        SizedBox(
          width: 44,
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: logoColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  logoText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              if (showLine)
                Container(
                  width: 2,
                  height: 126,
                  color: Colors.white.withOpacity(0.18),
                ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // ===================================================
        // CONTEÚDO
        // ===================================================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EMPRESA
              Text(
                company,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              // PERÍODO
              Text(
                period,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 14),

              // CARGO
              Text(
                role,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              // DESCRIÇÃO
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}