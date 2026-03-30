// =======================================================
// PROFILE EDUCATION
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart'; // 🔥 ADD

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

    if (educations.isEmpty) return const SizedBox();

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

            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(AppIcons.cap, width: 18, height: 18),
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
                  onPressed: () {
                    context.push(
                      '/edit-education',
                      extra: educations,
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                ),
              ],
            ),

            Divider(color: Theme.of(context).dividerColor.withOpacity(0.2)),
            const SizedBox(height: 8),

            // LISTA
            Column(
              children: educations.map((edu) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _EducationItem(
                    institution: edu.institution,
                    course: edu.course,
                    description: edu.description,
                    period: _formatPeriod(edu.startDate, edu.endDate),
                    logoUrl: edu.logoUrl,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPeriod(DateTime start, DateTime? end) {
    final formatter = DateFormat('MMM yyyy', 'pt_BR');
    final startFormatted = formatter.format(start);

    if (end == null) return '$startFormatted - Atual';

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
  final String description;
  final String period;
  final String? logoUrl;

  const _EducationItem({
    required this.institution,
    required this.course,
    required this.description,
    required this.period,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // COLUNA ESQUERDA
          SizedBox(
            width: 44,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: logoUrl != null && logoUrl!.isNotEmpty
                      ? Image.network(
                          logoUrl!,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return _fallback();
                          },
                        )
                      : _fallback(),
                ),

                const SizedBox(height: 8),

                // LINHA DINÂMICA
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // CONTEÚDO
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

                const SizedBox(height: 4),

                Text(
                  period,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  course,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Colors.white
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: 36,
      height: 36,
      color: Colors.white.withOpacity(0.1),
      child: const Icon(Icons.school, size: 18),
    );
  }
}