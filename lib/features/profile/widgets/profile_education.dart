// =======================================================
// PROFILE EDUCATION
// -------------------------------------------------------
// Card de formações acadêmicas
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/features/profile/models/education_model.dart';

class ProfileEducation extends StatelessWidget {
  final List<EducationModel> educations;

  const ProfileEducation({
    super.key,
    required this.educations,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

    // =======================================================
    // SAFE GUARD (evita tela vazia silenciosa)
    // =======================================================

    if (educations.isEmpty) {
      return const SizedBox(); // ou coloca um placeholder se quiser
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
                      AppIcons.cap,
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Formações',
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
            // LISTA
            // ===================================================
            Column(
              children: educations
                  .asMap()
                  .entries
                  .map((entry) {
                    final index = entry.key;
                    final edu = entry.value;
                    final isLast = index == educations.length - 1;

                    return Column(
                      children: [
                        _EducationItem(
                          institution: edu.institution,
                          course: edu.course,
                          period: _formatPeriod(
                            edu.startDate,
                            edu.endDate,
                          ),
                          showLine: !isLast,
                        ),
                        if (!isLast)
                          const SizedBox(height: 20),
                      ],
                    );
                  })
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // =======================================================
  // FORMATADOR DE PERÍODO
  // =======================================================

  String _formatPeriod(DateTime start, DateTime? end) {
    final formatter = DateFormat('MMM yyyy', 'pt_BR');

    final startFormatted = formatter.format(start);

    if (end == null) {
      return '$startFormatted - Atual';
    }

    final endFormatted = formatter.format(end);

    return '$startFormatted - $endFormatted';
  }
}

// =======================================================
// EDUCATION ITEM
// =======================================================

class _EducationItem extends StatelessWidget {
  final String institution;
  final String course;
  final String period;
  final bool showLine;

  const _EducationItem({
    required this.institution,
    required this.course,
    required this.period,
    required this.showLine,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ===================================================
        // TIMELINE
        // ===================================================
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, size: 18),
            ),

            const SizedBox(height: 8),

            if (showLine)
              Container(
                width: 2,
                height: 70,
                color: Colors.white.withOpacity(0.2),
              ),
          ],
        ),

        const SizedBox(width: 12),

        // ===================================================
        // CONTEÚDO
        // ===================================================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                institution,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                course,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                period,
                style: TextStyle(
                  fontSize: 12,
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