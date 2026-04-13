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
  final String? email;

  const ProfileResume({
    super.key,
    required this.resume,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    if (resume == null) return const SizedBox();

    final emailValue = _safe(email);
    final birthValue = _formatBirth(resume!.birthDate);
    final stateValue = _safe(resume!.state);
    final cityValue = _safe(resume!.city);
    final descriptionValue = _safe(resume!.description);

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
                    SvgPicture.asset(AppIcons.cv, width: 20, height: 20),
                    const SizedBox(width: 12),
                    Text(
                      resume!.labels.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
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
            const SizedBox(height: 8),

            _info(
              context: context,
              icon: AppIcons.mail,
              title: 'Email',
              value: emailValue,
              placeholderHighlight: 'Email',
            ),

            const SizedBox(height: 12),

            _info(
              context: context,
              icon: AppIcons.cake,
              title: resume!.labels.birthDateLabel,
              value: birthValue,
              placeholderHighlight: resume!.labels.birthDateLabel,
            ),

            const SizedBox(height: 12),

            _info(
              context: context,
              icon: AppIcons.state,
              title: resume!.labels.stateLabel,
              value: stateValue,
              placeholderHighlight: 'Estado',
            ),

            const SizedBox(height: 12),

            _info(
              context: context,
              icon: AppIcons.buildingfull,
              title: resume!.labels.cityLabel,
              value: cityValue,
              placeholderHighlight: 'Cidade',
            ),

            const SizedBox(height: 12),

            _infoWithLine(
              context: context,
              icon: AppIcons.infofull,
              title: resume!.labels.descriptionLabel,
              value: descriptionValue,
              placeholderHighlight: 'Descrição',
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
    required BuildContext context,
    required String icon,
    required String title,
    required String? value,
    required String placeholderHighlight,
  }) {
    final isPending = value == null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusIcon(
          icon: icon,
          isPending: isPending,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              if (isPending)
                _pendingText(
                  context: context,
                  fieldName: placeholderHighlight,
                )
              else
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.62),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // =======================================================
  // ITEM COM LINHA (DESCRIPTION)
  // =======================================================
  Widget _infoWithLine({
    required BuildContext context,
    required String icon,
    required String title,
    required String? value,
    required String placeholderHighlight,
  }) {
    final isPending = value == null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                _StatusIcon(
                  icon: icon,
                  isPending: isPending,
                ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                if (isPending)
                  _pendingText(
                    context: context,
                    fieldName: placeholderHighlight,
                  )
                else
                  Text(
                    value,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.62),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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
          fontSize: 14,
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

  String? _safe(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return v.trim();
  }

  String? _formatBirth(DateTime? d) {
    if (d == null) return null;

    final now = DateTime.now();
    int age = now.year - d.year;

    if (now.month < d.month ||
        (now.month == d.month && now.day < d.day)) {
      age--;
    }

    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');

    return '$day/$month/${d.year} | $age anos';
  }
}

// =======================================================
// ÍCONE COM BADGE DE STATUS
// -------------------------------------------------------
// - Pendente -> badge amarela com exclamação preta
// - Preenchido -> badge azul com check preto
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
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    final pendingColor = Colors.amber.shade300;
    final successColor = theme.colorScheme.primary;

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
                color: isPending ? pendingColor : successColor,
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