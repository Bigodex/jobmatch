// =======================================================
// PROFILE RESUME (SOMENTE VISUAL)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/features/profile/models/resume_model.dart';
import 'package:jobmatch/features/profile/screens/edit_resume_screen.dart';

class ProfileResume extends StatelessWidget {
  final ResumeModel? resume;

  const ProfileResume({
    super.key,
    required this.resume,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    if (resume == null) return const SizedBox();

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
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(AppIcons.cv, width: 18, height: 18),
                    const SizedBox(width: 8),
                    Text(
                      resume!.labels.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditResumeScreen(resume: resume!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                ),
              ],
            ),

            Divider(color: theme.dividerColor.withOpacity(0.2)),
            const SizedBox(height: 12),

            _info(
              icon: AppIcons.cake,
              title: resume!.labels.birthDateLabel,
              value: _formatBirth(resume!.birthDate),
            ),

            const SizedBox(height: 12),

            _info(
              icon: AppIcons.building,
              title: resume!.labels.cityLabel,
              value: _safe(resume!.city),
            ),

            const SizedBox(height: 12),

            // 🔥 DESCRIPTION COM LINHA + JUSTIFY
            _infoWithLine(
              icon: AppIcons.info,
              title: resume!.labels.descriptionLabel,
              value: _safe(resume!.description),
            ),
          ],
        ),
      ),
    );
  }

  // =======================================================
  // ITEM NORMAL (SEM LINHA)
  // =======================================================
  Widget _info({
    required String icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(icon, width: 16, height: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }

  // =======================================================
  // ITEM COM LINHA + JUSTIFY (DESCRIPTION)
  // =======================================================
  Widget _infoWithLine({
    required String icon,
    required String title,
    required String value,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ÍCONE + LINHA
          SizedBox(
            width: 16,
            child: Column(
              children: [
                SvgPicture.asset(icon, width: 16, height: 16),

                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.only(top: 8),
                    color: Colors.white24,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // TEXTO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),

                // 🔥 JUSTIFY AQUI
                Text(
                  value,
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _safe(String? v) =>
      v == null || v.trim().isEmpty ? 'Não informado' : v;

  String _formatBirth(DateTime? d) {
    if (d == null) return 'Não informado';

    final now = DateTime.now();
    int age = now.year - d.year;

    if (now.month < d.month ||
        (now.month == d.month && now.day < d.day)) {
      age--;
    }

    return '${d.day}/${d.month}/${d.year} | $age anos';
  }
}