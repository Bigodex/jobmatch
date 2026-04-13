// =======================================================
// STEP CHECKLIST
// -------------------------------------------------------
// Tela final do onboarding com resumo do que foi concluído
// e do que ainda está pendente antes de criar a conta
// - Organizado por seções
// - Pendentes com contorno amarelo + exclamação
// - Opcionais só aparecem se foram visitados ou preenchidos
// - Ícones internos dos itens brancos
// - Badges internos azul primary nos itens concluídos
// - Ícone dentro do badge concluído preto
// - Ícones do título do card mantidos com cor de status
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class StepChecklist extends ConsumerWidget {
  final VoidCallback onCreateAccount;
  final void Function(String stepKey) onEditStep;

  const StepChecklist({
    super.key,
    required this.onCreateAccount,
    required this.onEditStep,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    final onboarding = ref.watch(onboardingProvider);
    final visitedOptionalStepKeys = onboarding.visitedOptionalSteps.toSet();

    final cpf = onboarding.userDocument?.cpf.trim() ?? '';
    final hasFullName =
        (onboarding.name?.trim().isNotEmpty ?? false) &&
        (onboarding.lastName?.trim().isNotEmpty ?? false);
    final hasBirthDate = onboarding.birthDate != null;
    final hasCpf = cpf.isNotEmpty;
    final hasAccount =
        (onboarding.email?.trim().isNotEmpty ?? false) &&
        (onboarding.password?.trim().isNotEmpty ?? false);

    final requiredSections = [
      _ChecklistSectionData(
        title: 'Identificação',
        icon: AppIcons.id,
        stepKey: 'name',
        completed: hasFullName && hasBirthDate && hasCpf,
        items: [
          _ChecklistLineData(
            title: 'Nome Completo',
            subtitle: hasFullName ? onboarding.fullName : 'Não preenchido',
            completed: hasFullName,
            icon: AppIcons.user,
          ),
          _ChecklistLineData(
            title: 'Data de Nascimento',
            subtitle: hasBirthDate
                ? _formatDate(onboarding.birthDate!)
                : 'Não preenchido',
            completed: hasBirthDate,
            icon: AppIcons.cake,
          ),
          _ChecklistLineData(
            title: 'CPF',
            subtitle: hasCpf ? _maskCpf(cpf) : 'Não preenchido',
            completed: hasCpf,
            icon: AppIcons.id2,
          ),
        ],
      ),
      _ChecklistSectionData(
        title: 'Especialidade',
        icon: AppIcons.nodes,
        stepKey: 'specialty',
        completed: onboarding.specialties.isNotEmpty,
        items: onboarding.specialties.isNotEmpty
            ? onboarding.specialties
                .map(
                  (specialty) => _ChecklistLineData(
                    title: specialty,
                    completed: true,
                    icon: _getSpecialtyIcon(specialty),
                  ),
                )
                .toList()
            : [
                _ChecklistLineData(
                  title: 'Não preenchido',
                  completed: false,
                  icon: AppIcons.nodes,
                ),
              ],
      ),
      _ChecklistSectionData(
        title: 'Idiomas',
        icon: AppIcons.language,
        stepKey: 'languages',
        completed: onboarding.languages.isNotEmpty,
        items: onboarding.languages.isNotEmpty
            ? onboarding.languages
                .map(
                  (language) => _ChecklistLineData(
                    title: language.name,
                    subtitle: _getLanguageLevelLabel(language.level),
                    trailingValue: '${language.level}%',
                    completed: true,
                    icon: AppIcons.language,
                    flag: language.flag,
                    isLanguageLayout: true,
                  ),
                )
                .toList()
            : [
                _ChecklistLineData(
                  title: 'Não preenchido',
                  completed: false,
                  icon: AppIcons.language,
                ),
              ],
      ),
      _ChecklistSectionData(
        title: 'Login',
        icon: AppIcons.puzzle,
        stepKey: 'account',
        completed: hasAccount,
        items: [
          _ChecklistLineData(
            title: 'E-mail',
            subtitle: onboarding.email?.trim().isNotEmpty == true
                ? onboarding.email!
                : 'Não preenchido',
            completed: onboarding.email?.trim().isNotEmpty == true,
            icon: AppIcons.mail,
          ),
          _ChecklistLineData(
            title: 'Senha',
            subtitle: hasAccount ? 'Configurada' : 'Não preenchido',
            completed: onboarding.password?.trim().isNotEmpty == true,
            icon: AppIcons.lock,
          ),
        ],
      ),
    ];

    final optionalSections = [
      _ChecklistSectionData(
        title: 'Resumo',
        icon: AppIcons.resume,
        stepKey: 'resume',
        completed: onboarding.resumeDescription?.trim().isNotEmpty == true,
        items: onboarding.resumeDescription?.trim().isNotEmpty == true
            ? [
                if ((onboarding.city?.trim().isNotEmpty ?? false))
                  _ChecklistLineData(
                    title: 'Localização',
                    subtitle: onboarding.city!,
                    completed: true,
                    icon: AppIcons.state,
                  ),
                _ChecklistLineData(
                  title: 'Resumo profissional',
                  subtitle: _truncate(
                    onboarding.resumeDescription!,
                    90,
                  ),
                  completed: true,
                  icon: AppIcons.resume,
                ),
              ]
            : [
                _ChecklistLineData(
                  title: 'Pendente',
                  completed: false,
                  icon: AppIcons.resume,
                ),
              ],
      ),
      _ChecklistSectionData(
        title: 'Habilidades Comportamentais',
        icon: AppIcons.softskills,
        stepKey: 'softSkills',
        completed: onboarding.softSkills.isNotEmpty,
        items: onboarding.softSkills.isNotEmpty
            ? onboarding.softSkills.take(3).map((skill) {
                return _ChecklistLineData(
                  title: skill.title.trim().isNotEmpty
                      ? skill.title
                      : 'Habilidade',
                  subtitle: skill.description.trim().isNotEmpty
                      ? _truncate(skill.description, 70)
                      : null,
                  completed: true,
                  icon: AppIcons.softskillsitem,
                );
              }).toList()
            : [
                _ChecklistLineData(
                  title: 'Pendente',
                  completed: false,
                  icon: AppIcons.softskills,
                ),
              ],
        footerText: onboarding.softSkills.length > 3
            ? '+${onboarding.softSkills.length - 3} habilidade(s)'
            : null,
      ),
      _ChecklistSectionData(
        title: 'Habilidades Técnicas',
        icon: AppIcons.code,
        stepKey: 'hardSkills',
        completed: onboarding.techSkills.isNotEmpty,
        items: onboarding.techSkills.isNotEmpty
            ? onboarding.techSkills.take(3).map((skill) {
                final tags = skill.tools.take(3).join(', ');
                return _ChecklistLineData(
                  title: skill.title.trim().isNotEmpty
                      ? skill.title
                      : 'Habilidade',
                  subtitle: tags.isNotEmpty
                      ? '${skill.level}% • $tags'
                      : '${skill.level}%',
                  completed: true,
                  icon: AppIcons.hardskillsitem,
                );
              }).toList()
            : [
                _ChecklistLineData(
                  title: 'Pendente',
                  completed: false,
                  icon: AppIcons.code,
                ),
              ],
        footerText: onboarding.techSkills.length > 3
            ? '+${onboarding.techSkills.length - 3} habilidade(s)'
            : null,
      ),
      _ChecklistSectionData(
        title: 'Experiência',
        icon: AppIcons.briefcase,
        stepKey: 'experience',
        completed: onboarding.experiences.isNotEmpty,
        items: onboarding.experiences.isNotEmpty
            ? onboarding.experiences.take(3).map((exp) {
                final subtitleParts = <String>[];

                if (exp.role.trim().isNotEmpty) {
                  subtitleParts.add(exp.role);
                }

                if (exp.startDate.year != 1900) {
                  final start = _formatMonthYear(exp.startDate);
                  final end = exp.endDate != null
                      ? _formatMonthYear(exp.endDate!)
                      : 'Atual';
                  subtitleParts.add('$start - $end');
                }

                return _ChecklistLineData(
                  title: exp.company.trim().isNotEmpty
                      ? exp.company
                      : 'Experiência',
                  subtitle:
                      subtitleParts.isNotEmpty ? subtitleParts.join(' • ') : null,
                  completed: true,
                  icon: AppIcons.briefcase,
                );
              }).toList()
            : [
                _ChecklistLineData(
                  title: 'Pendente',
                  completed: false,
                  icon: AppIcons.briefcase,
                ),
              ],
        footerText: onboarding.experiences.length > 3
            ? '+${onboarding.experiences.length - 3} experiência(s)'
            : null,
      ),
      _ChecklistSectionData(
        title: 'Formação',
        icon: AppIcons.cap,
        stepKey: 'education',
        completed: onboarding.education.isNotEmpty,
        items: onboarding.education.isNotEmpty
            ? onboarding.education.take(3).map((edu) {
                final subtitleParts = <String>[];

                if (edu.course.trim().isNotEmpty) {
                  subtitleParts.add(edu.course);
                }

                if (edu.startDate.year != 1900) {
                  final start = _formatMonthYear(edu.startDate);
                  final end = edu.endDate != null
                      ? _formatMonthYear(edu.endDate!)
                      : 'Atual';
                  subtitleParts.add('$start - $end');
                }

                return _ChecklistLineData(
                  title: edu.institution.trim().isNotEmpty
                      ? edu.institution
                      : 'Formação',
                  subtitle:
                      subtitleParts.isNotEmpty ? subtitleParts.join(' • ') : null,
                  completed: true,
                  icon: AppIcons.cap,
                );
              }).toList()
            : [
                _ChecklistLineData(
                  title: 'Pendente',
                  completed: false,
                  icon: AppIcons.cap,
                ),
              ],
        footerText: onboarding.education.length > 3
            ? '+${onboarding.education.length - 3} formação(ões)'
            : null,
      ),
      _ChecklistSectionData(
        title: 'Links',
        icon: AppIcons.links,
        stepKey: 'links',
        completed: onboarding.links.isNotEmpty,
        items: onboarding.links.isNotEmpty
            ? onboarding.links.take(3).map((link) {
                return _ChecklistLineData(
                  title: link.label.trim().isNotEmpty ? link.label : 'Link',
                  subtitle: link.url.trim().isNotEmpty
                      ? _truncate(link.url, 55)
                      : null,
                  completed: true,
                  icon: AppIcons.links,
                );
              }).toList()
            : [
                _ChecklistLineData(
                  title: 'Pendente',
                  completed: false,
                  icon: AppIcons.links,
                ),
              ],
        footerText: onboarding.links.length > 3
            ? '+${onboarding.links.length - 3} link(s)'
            : null,
      ),
    ];

    final visibleOptionalSections = optionalSections.where((section) {
      if (section.completed) return true;
      return visitedOptionalStepKeys.contains(section.stepKey);
    }).toList();

    final completedOptionalSections =
        visibleOptionalSections.where((item) => item.completed).toList();

    final pendingOptionalSections =
        visibleOptionalSections.where((item) => !item.completed).toList();

    final allRequiredCompleted =
        requiredSections.every((section) => section.completed);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          AppSectionCard(
            child: Padding(
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
                    const Text(
                      'Revisão do Cadastro',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      allRequiredCompleted
                          ? 'Seus dados obrigatórios já estão prontos. Você pode criar sua conta agora e completar o restante depois.'
                          : 'Revise os dados abaixo. Os obrigatórios precisam estar completos para criar sua conta.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _sectionTitle(context, 'Dados do Usuário'),
                    const SizedBox(height: 12),
                    ...requiredSections.map(
                      (section) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ChecklistSectionTile(
                          section: section,
                          onEdit: () => onEditStep(section.stepKey),
                        ),
                      ),
                    ),

                    if (completedOptionalSections.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _sectionTitle(context, 'Opcionais concluídos'),
                      const SizedBox(height: 12),
                      ...completedOptionalSections.map(
                        (section) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ChecklistSectionTile(
                            section: section,
                            onEdit: () => onEditStep(section.stepKey),
                          ),
                        ),
                      ),
                    ],

                    if (pendingOptionalSections.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _sectionTitle(
                        context,
                        'Pendentes',
                        isPending: true,
                      ),
                      const SizedBox(height: 12),
                      ...pendingOptionalSections.map(
                        (section) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ChecklistSectionTile(
                            section: section,
                            onEdit: () => onEditStep(section.stepKey),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: allRequiredCompleted ? onCreateAccount : null,
                        child: const Text('Criar conta'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String title, {
    bool isPending = false,
  }) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: isPending
            ? Colors.amber.shade300
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }

  static String _getSpecialtyIcon(String specialty) {
    final normalized = specialty
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');

    if (normalized.contains('desenvolv') ||
        normalized.contains('program') ||
        normalized.contains('software') ||
        normalized.contains('frontend') ||
        normalized.contains('backend') ||
        normalized.contains('fullstack') ||
        normalized.contains('mobile')) {
      return AppIcons.code;
    }

    if (normalized.contains('designer') ||
        normalized.contains('design') ||
        normalized.contains('ux') ||
        normalized.contains('ui')) {
      return AppIcons.resume;
    }

    if (normalized.contains('qa') ||
        normalized.contains('qualidade') ||
        normalized.contains('teste') ||
        normalized.contains('tester')) {
      return AppIcons.puzzle;
    }

    if (normalized.contains('dados') ||
        normalized.contains('data') ||
        normalized.contains('analyst') ||
        normalized.contains('analista')) {
      return AppIcons.nodes;
    }

    if (normalized.contains('produto') ||
        normalized.contains('product') ||
        normalized.contains('manager') ||
        normalized.contains('gerente')) {
      return AppIcons.briefcase;
    }

    return AppIcons.nodes;
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  static String _formatMonthYear(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _maskCpf(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length != 11) return value;

    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.'
        '${digits.substring(6, 9)}-${digits.substring(9)}';
  }

  static String _truncate(String value, int max) {
    final text = value.trim();

    if (text.length <= max) return text;

    return '${text.substring(0, max).trim()}...';
  }

  static String _getLanguageLevelLabel(int value) {
    if (value == 100) return 'Nativo';
    if (value >= 90) return 'Expert';
    if (value >= 61) return 'Avançado';
    if (value >= 40) return 'Intermediário';
    if (value >= 21) return 'Iniciante';
    if (value >= 10) return 'Básico';
    return 'Muito baixo';
  }
}

class _ChecklistSectionData {
  final String title;
  final String icon;
  final List<_ChecklistLineData> items;
  final bool completed;
  final String stepKey;
  final String? footerText;

  const _ChecklistSectionData({
    required this.title,
    required this.icon,
    required this.items,
    required this.completed,
    required this.stepKey,
    this.footerText,
  });
}

class _ChecklistLineData {
  final String title;
  final String icon;
  final String? subtitle;
  final String? trailingValue;
  final String? flag;
  final bool completed;
  final bool isLanguageLayout;

  const _ChecklistLineData({
    required this.title,
    required this.icon,
    this.subtitle,
    this.trailingValue,
    this.flag,
    required this.completed,
    this.isLanguageLayout = false,
  });
}

class _ChecklistSectionTile extends StatelessWidget {
  final _ChecklistSectionData section;
  final VoidCallback onEdit;

  const _ChecklistSectionTile({
    required this.section,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendingColor = Colors.amber.shade300;

    final borderColor = section.completed
        ? theme.colorScheme.primary.withOpacity(1.0)
        : pendingColor.withOpacity(0.85);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ChecklistStatusIcon(
                icon: section.icon,
                completed: section.completed,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: section.completed
                        ? Colors.white
                        : Colors.white.withOpacity(0.95),
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: SvgPicture.asset(
                    AppIcons.pencil,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      section.completed
                          ? theme.colorScheme.primary
                          : pendingColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.12),
          ),
          const SizedBox(height: 10),
          ...List.generate(section.items.length, (index) {
            final item = section.items[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == section.items.length - 1 ? 0 : 10,
              ),
              child: item.isLanguageLayout
                  ? _ChecklistLanguageLineItem(item: item)
                  : _ChecklistLineItem(item: item),
            );
          }),
          if (section.footerText != null) ...[
            const SizedBox(height: 10),
            Text(
              section.footerText!,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: section.completed
                    ? theme.colorScheme.primary.withOpacity(0.9)
                    : pendingColor.withOpacity(0.95),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChecklistLineItem extends StatelessWidget {
  final _ChecklistLineData item;

  const _ChecklistLineItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChecklistStatusIcon(
          icon: item.icon,
          completed: item.completed,
          size: 18,
          iconColorOverride: Colors.white,
          badgeColorOverride: item.completed
              ? Theme.of(context).colorScheme.primary
              : Colors.amber.shade300,
          badgeIconColorOverride: Colors.black.withOpacity(0.85),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: item.subtitle != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: item.completed
                            ? Colors.white
                            : Colors.white.withOpacity(0.92),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: Colors.white.withOpacity(0.68),
                      ),
                    ),
                  ],
                )
              : Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: item.completed
                        ? Colors.white
                        : Colors.white.withOpacity(0.92),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ChecklistLanguageLineItem extends StatelessWidget {
  final _ChecklistLineData item;

  const _ChecklistLanguageLineItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChecklistFlagStatusIcon(
          flag: item.flag ?? '🌐',
          completed: item.completed,
          size: 20,
          badgeColorOverride: item.completed
              ? Theme.of(context).colorScheme.primary
              : Colors.amber.shade300,
          badgeIconColorOverride: Colors.black.withOpacity(0.85),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: item.completed
                      ? Colors.white
                      : Colors.white.withOpacity(0.92),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.subtitle ?? '',
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: Colors.white.withOpacity(0.68),
                      ),
                    ),
                  ),
                  if (item.trailingValue != null &&
                      item.trailingValue!.trim().isNotEmpty)
                    Text(
                      item.trailingValue!,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChecklistStatusIcon extends StatelessWidget {
  final String icon;
  final bool completed;
  final double size;
  final Color? iconColorOverride;
  final Color? badgeColorOverride;
  final Color? badgeIconColorOverride;

  const _ChecklistStatusIcon({
    required this.icon,
    required this.completed,
    required this.size,
    this.iconColorOverride,
    this.badgeColorOverride,
    this.badgeIconColorOverride,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    final pendingColor = Colors.amber.shade300;

    final iconColor = iconColorOverride ??
        (completed ? theme.colorScheme.primary : pendingColor);

    final badgeColor = badgeColorOverride ??
        (completed ? theme.colorScheme.primary : pendingColor);

    final badgeIconColor =
        badgeIconColorOverride ?? Colors.black.withOpacity(0.85);

    return SizedBox(
      width: size + 8,
      height: size + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: size,
                height: size,
                colorFilter: ColorFilter.mode(
                  iconColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: size * 0.56,
              height: size * 0.56,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.cardTertiary,
                  width: 1.4,
                ),
              ),
              child: Icon(
                completed ? Icons.check_rounded : Icons.priority_high_rounded,
                size: size * 0.34,
                color: badgeIconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistFlagStatusIcon extends StatelessWidget {
  final String flag;
  final bool completed;
  final double size;
  final Color? badgeColorOverride;
  final Color? badgeIconColorOverride;

  const _ChecklistFlagStatusIcon({
    required this.flag,
    required this.completed,
    required this.size,
    this.badgeColorOverride,
    this.badgeIconColorOverride,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final pendingColor = Colors.amber.shade300;

    final badgeColor = badgeColorOverride ??
        (completed ? Theme.of(context).colorScheme.primary : pendingColor);

    final badgeIconColor =
        badgeIconColorOverride ?? Colors.black.withOpacity(0.85);

    return SizedBox(
      width: size + 10,
      height: size + 10,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Center(
              child: Text(
                flag,
                style: TextStyle(fontSize: size),
              ),
            ),
          ),
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: size * 0.54,
              height: size * 0.54,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.cardTertiary,
                  width: 1.4,
                ),
              ),
              child: Icon(
                completed ? Icons.check_rounded : Icons.priority_high_rounded,
                size: size * 0.32,
                color: badgeIconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}