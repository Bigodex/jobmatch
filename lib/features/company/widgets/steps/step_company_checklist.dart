// =======================================================
// STEP COMPANY CHECKLIST
// -------------------------------------------------------
// Revisão do cadastro empresarial no mesmo estilo visual
// do checklist do onboarding de usuários.
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/company/providers/company_onboarding_provider.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class StepCompanyChecklist extends ConsumerWidget {
  final void Function(String stepKey) onEditStep;
  final VoidCallback onFinish;

  const StepCompanyChecklist({
    super.key,
    required this.onEditStep,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final company = ref.watch(companyOnboardingProvider);

    final sections = [
      _ChecklistSectionData(
        title: 'Identidade',
        icon: AppIcons.id,
        stepKey: 'identity',
        completed: company.hasIdentityData,
        items: [
          _ChecklistLineData(
            title: 'Nome da empresa',
            subtitle: _filledOrPending(company.companyName),
            completed: _hasText(company.companyName),
            icon: AppIcons.buildingfull,
          ),
          _ChecklistLineData(
            title: 'Categoria',
            subtitle: _filledOrPending(company.companyCategory),
            completed: _hasText(company.companyCategory),
            icon: AppIcons.nodes,
          ),
          _ChecklistLineData(
            title: 'CNPJ',
            subtitle: _filledOrPending(company.cnpj),
            completed: _hasText(company.cnpj),
            icon: AppIcons.id2,
          ),
        ],
      ),
      _ChecklistSectionData(
        title: 'Sobre a empresa',
        icon: AppIcons.infofull,
        stepKey: 'about',
        completed: company.hasAboutData,
        items: [
          _ChecklistLineData(
            title: 'Tipo da empresa',
            subtitle: _filledOrPending(company.companyType),
            completed: _hasText(company.companyType),
            icon: AppIcons.buildingbriefcase,
          ),
          _ChecklistLineData(
            title: 'Descrição',
            subtitle: _hasText(company.description)
                ? _truncate(company.description!, 90)
                : 'Não preenchido',
            completed: _hasText(company.description),
            icon: AppIcons.resume,
          ),
          if (_hasText(company.website))
            _ChecklistLineData(
              title: 'Site',
              subtitle: company.website,
              completed: true,
              icon: AppIcons.links,
            ),
        ],
      ),
      _ChecklistSectionData(
        title: 'Contratação',
        icon: AppIcons.briefcase,
        stepKey: 'hiring',
        completed: true,
        items: [
          _ChecklistLineData(
            title: 'Status de contratação',
            subtitle: company.isHiring
                ? 'Empresa está contratando agora'
                : 'Empresa não está contratando agora',
            completed: true,
            icon: company.isHiring ? AppIcons.verify : AppIcons.info,
          ),
        ],
      ),
      if (company.isHiring)
        _ChecklistSectionData(
          title: 'Vagas',
          icon: AppIcons.bagmoney,
          stepKey: 'jobs',
          completed: company.jobs.isNotEmpty,
          items: company.jobs.isNotEmpty
              ? company.jobs.take(3).map((job) {
                  final subtitleParts = <String>[
                    if (job.seniority.trim().isNotEmpty) job.seniority,
                    if (job.workModel.trim().isNotEmpty) job.workModel,
                    if (job.location.trim().isNotEmpty) job.location,
                  ];

                  return _ChecklistLineData(
                    title: job.title.trim().isNotEmpty ? job.title : 'Vaga',
                    subtitle: subtitleParts.isNotEmpty
                        ? subtitleParts.join(' • ')
                        : null,
                    completed: true,
                    icon: AppIcons.briefcase,
                  );
                }).toList()
              : [
                  _ChecklistLineData(
                    title: 'Nenhuma vaga cadastrada',
                    completed: false,
                    icon: AppIcons.briefcase,
                  ),
                ],
          footerText: company.jobs.length > 3
              ? '+${company.jobs.length - 3} vaga(s) cadastrada(s)'
              : null,
        ),
      _ChecklistSectionData(
        title: 'Colaboradores',
        icon: AppIcons.group,
        stepKey: 'team',
        completed: company.hasTeamData,
        items: [
          _ChecklistLineData(
            title: 'Quantidade',
            subtitle: company.employeesCount != null
                ? '${company.employeesCount} colaborador(es)'
                : 'Não preenchido',
            completed: company.employeesCount != null && company.employeesCount! > 0,
            icon: AppIcons.hashtag,
          ),
          _ChecklistLineData(
            title: 'Porte empresarial',
            subtitle: _filledOrPending(company.companySize),
            completed: _hasText(company.companySize),
            icon: AppIcons.skyscraper,
          ),
        ],
      ),
      _ChecklistSectionData(
        title: 'Visual da página',
        icon: AppIcons.image,
        stepKey: 'header',
        completed: company.hasHeaderContent,
        items: [
          _ChecklistLineData(
            title: 'Capa ou logo',
            subtitle: company.hasHeaderContent
                ? 'Visual configurado'
                : 'Opcional / não preenchido',
            completed: company.hasHeaderContent,
            icon: AppIcons.image,
          ),
        ],
      ),
    ];

    final requiredSections = sections.where((section) {
      return section.stepKey != 'header';
    }).toList();

    final optionalSections = sections.where((section) {
      return section.stepKey == 'header';
    }).toList();

    final allRequiredCompleted = requiredSections.every((section) {
      if (section.stepKey == 'jobs' && !company.isHiring) return true;
      return section.completed;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
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
                      'Revisão da Página Empresarial',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      allRequiredCompleted
                          ? 'Os dados principais da página empresarial estão prontos. Confira antes de finalizar.'
                          : 'Revise os dados abaixo. Os itens pendentes precisam ser ajustados antes de finalizar.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Dados da Empresa'),
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
                    const SizedBox(height: 12),
                    _sectionTitle(context, 'Opcionais'),
                    const SizedBox(height: 12),
                    ...optionalSections.map(
                      (section) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ChecklistSectionTile(
                          section: section,
                          onEdit: () => onEditStep(section.stepKey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: allRequiredCompleted ? onFinish : null,
                        child: const Text('Finalizar página'),
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

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static String _filledOrPending(String? value) {
    return _hasText(value) ? value!.trim() : 'Não preenchido';
  }

  static String _truncate(String value, int max) {
    final text = value.trim();
    if (text.length <= max) return text;
    return '${text.substring(0, max).trim()}...';
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
  final bool completed;

  const _ChecklistLineData({
    required this.title,
    required this.icon,
    this.subtitle,
    required this.completed,
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
    final pendingColor = Colors.amber.shade300;
    final borderColor = section.completed
        ? Theme.of(context).colorScheme.primary.withOpacity(1.0)
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
                          ? Theme.of(context).colorScheme.primary
                          : pendingColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: Colors.white.withOpacity(0.12)),
          const SizedBox(height: 10),
          ...List.generate(section.items.length, (index) {
            final item = section.items[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == section.items.length - 1 ? 0 : 10,
              ),
              child: _ChecklistLineItem(item: item),
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
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.9)
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

  const _ChecklistLineItem({required this.item});

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
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final pendingColor = Colors.amber.shade300;
    final iconColor = iconColorOverride ??
        (completed ? Theme.of(context).colorScheme.primary : pendingColor);
    final badgeColor = badgeColorOverride ??
        (completed ? Theme.of(context).colorScheme.primary : pendingColor);
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
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
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
