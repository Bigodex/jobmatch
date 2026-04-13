// =======================================================
// PROFILE EDUCATION
// -------------------------------------------------------
// - Title branco
// - Textos dos itens mais opacos
// - Sem justify
// - Badge de pendência quando faltar dado
// - Badge de OK em primary com check preto quando estiver completo
// - Mantém timeline e logos
// - Aceita imagem local e remota no logo
// =======================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

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
            // HEADER
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
                      'Formação',
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
                    context.push(
                      '/edit-education',
                      extra: educations,
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                ),
              ],
            ),

            Divider(color: theme.dividerColor.withOpacity(0.2)),
            const SizedBox(height: 8),

            if (educations.isEmpty)
              const _PendingEducationItem(
                fieldName: 'Formação',
              )
            else
              Column(
                children: educations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final education = entry.value;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == educations.length - 1 ? 0 : 24,
                    ),
                    child: _EducationItem(
                      institution: _safe(education.institution),
                      period: _formatPeriod(
                        education.startDate,
                        education.endDate,
                      ),
                      course: _safe(education.course),
                      description: _safe(education.description),
                      logoUrl: _safe(education.logoUrl),
                      logoColor: _getLogoColor(education.institution),
                      logoText: _getLogoText(education.institution),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  static String? _safe(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  static String? _formatPeriod(DateTime startDate, DateTime? endDate) {
    if (startDate.year == 1900) return null;

    final startFormatted = DateFormat('dd/MM/yyyy').format(startDate);

    if (endDate == null) {
      final months = _monthDifference(startDate, DateTime.now());
      final periodText = months >= 12
          ? '${(months / 12).floor()} ano${(months / 12).floor() > 1 ? 's' : ''}'
          : '$months mes${months > 1 ? 'es' : ''}';

      return '$startFormatted - Até o momento • $periodText';
    }

    final endFormatted = DateFormat('dd/MM/yyyy').format(endDate);
    final months = _monthDifference(startDate, endDate);

    return '$startFormatted - $endFormatted • $months mes${months > 1 ? 'es' : ''}';
  }

  static int _monthDifference(DateTime start, DateTime end) {
    int months = (end.year - start.year) * 12 + (end.month - start.month);
    if (end.day < start.day) {
      months--;
    }
    return months <= 0 ? 1 : months;
  }

  static Color _getLogoColor(String institution) {
    final normalized = institution.toLowerCase();

    if (normalized.contains('utfpr')) return const Color(0xFF1E8E3E);
    if (normalized.contains('unidep')) return const Color(0xFF7A1FA2);
    if (normalized.contains('unioeste')) return const Color(0xFF0D5BD7);

    return const Color(0xFF3A3A3A);
  }

  static String _getLogoText(String institution) {
    if (institution.trim().isEmpty) return '?';
    return institution.trim()[0].toUpperCase();
  }
}

// =======================================================
// EDUCATION ITEM
// =======================================================

class _EducationItem extends StatelessWidget {
  final String? institution;
  final String? period;
  final String? course;
  final String? description;
  final String? logoUrl;
  final Color logoColor;
  final String logoText;

  const _EducationItem({
    required this.institution,
    required this.period,
    required this.course,
    required this.description,
    required this.logoUrl,
    required this.logoColor,
    required this.logoText,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = institution == null ||
        period == null ||
        course == null ||
        description == null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                _StatusLogo(
                  logoUrl: logoUrl,
                  logoColor: logoColor,
                  logoText: logoText,
                  isPending: isPending,
                ),
                const SizedBox(height: 8),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (institution != null)
                  Text(
                    institution!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  )
                else
                  _pendingText(
                    context: context,
                    fieldName: 'instituição',
                  ),
                const SizedBox(height: 4),
                if (period != null)
                  Text(
                    period!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.62),
                    ),
                  )
                else
                  _pendingText(
                    context: context,
                    fieldName: 'período',
                  ),
                const SizedBox(height: 14),
                if (course != null)
                  Text(
                    course!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.74),
                    ),
                  )
                else
                  _pendingText(
                    context: context,
                    fieldName: 'curso',
                  ),
                const SizedBox(height: 6),
                if (description != null)
                  Text(
                    description!,
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
      ),
    );
  }
}

// =======================================================
// ITEM PENDENTE (LISTA VAZIA)
// =======================================================

class _PendingEducationItem extends StatelessWidget {
  final String fieldName;

  const _PendingEducationItem({
    required this.fieldName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PendingIcon(icon: AppIcons.cap),
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
// LOGO COM BADGE DE STATUS
// =======================================================

class _StatusLogo extends StatelessWidget {
  final String? logoUrl;
  final Color logoColor;
  final String logoText;
  final bool isPending;

  const _StatusLogo({
    required this.logoUrl,
    required this.logoColor,
    required this.logoText,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final theme = Theme.of(context);
    final pendingColor = Colors.amber.shade300;

    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildLogoImage(),
            ),
          ),
          Positioned(
            right: -3,
            bottom: -3,
            child: Container(
              width: 12,
              height: 12,
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
                size: 9,
                color: Colors.black.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoImage() {
    if (logoUrl == null || logoUrl!.trim().isEmpty) {
      return _fallbackLogo();
    }

    final normalized = logoUrl!.trim().toLowerCase();

    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return Image.network(
        logoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _fallbackLogo();
        },
      );
    }

    final file = File(logoUrl!);

    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _fallbackLogo();
        },
      );
    }

    return _fallbackLogo();
  }

  Widget _fallbackLogo() {
    return Container(
      width: 36,
      height: 36,
      color: logoColor,
      alignment: Alignment.center,
      child: Text(
        logoText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// =======================================================
// ÍCONE SIMPLES COM BADGE DE PENDÊNCIA
// =======================================================

class _PendingIcon extends StatelessWidget {
  final String icon;

  const _PendingIcon({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
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
                color: pendingColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.cardTertiary,
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.priority_high_rounded,
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