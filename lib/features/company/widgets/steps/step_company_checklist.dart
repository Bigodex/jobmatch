// =======================================================
// STEP COMPANY CHECKLIST
// -------------------------------------------------------
// Checklist final do onboarding empresarial
// - mesmo padrão visual do checklist do onboarding usuário
// - seções com status, itens internos e botão de edição
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/company/providers/company_onboarding_provider.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class StepCompanyChecklist extends ConsumerWidget {
  final VoidCallback onFinish;
  final void Function(String stepKey) onEditStep;

  const StepCompanyChecklist({
    super.key,
    required this.onFinish,
    required this.onEditStep,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final company = ref.watch(companyOnboardingProvider);

    final hasCover = (company.coverUrl ?? '').trim().isNotEmpty;
    final hasLogo = (company.logoUrl ?? '').trim().isNotEmpty;
    final hasSlogan = (company.slogan ?? '').trim().isNotEmpty;
    final hasWebsite = (company.website ?? '').trim().isNotEmpty;
    final hasJobs = !company.isHiring || company.jobs.isNotEmpty;

    final sections = [
      _ChecklistSectionData(
        title: 'Header',
        icon: AppIcons.image,
        stepKey: 'header',
        completed: true,
        items: [
          _ChecklistLineData(
            title: 'Capa',
            subtitle: hasCover ? 'Adicionada' : 'Opcional / vazia',
            completed: true,
            icon: AppIcons.image,
          ),
          _ChecklistLineData(
            title: 'Logo',
            subtitle: hasLogo ? 'Adicionada' : 'Opcional / vazia',
            completed: true,
            icon: AppIcons.buildingfull,
          ),
        ],
      ),
      _ChecklistSectionData(
        title: 'Identificação da Empresa',
        icon: AppIcons.buildingfull,
        stepKey: 'identity',
        completed: company.hasIdentityData,
        items: [
          _ChecklistLineData(
            title: 'Nome da Empresa',
            subtitle: _valueOrPending(company.companyName),
            completed: (company.companyName ?? '').trim().isNotEmpty,
            icon: AppIcons.skyscraper,
          ),
          _ChecklistLineData(
            title: 'Setor da Empresa',
            subtitle: _valueOrPending(company.companyCategory),
            completed: (company.companyCategory ?? '').trim().isNotEmpty,
            icon: AppIcons.nodes,
          ),
          _ChecklistLineData(
            title: 'CNPJ',
            subtitle: _valueOrPending(company.cnpj),
            completed: (company.cnpj ?? '').trim().isNotEmpty,
            icon: AppIcons.government,
          ),
        ],
      ),
      _ChecklistSectionData(
        title: 'Sobre',
        icon: AppIcons.info,
        stepKey: 'about',
        completed: company.hasAboutData,
        items: [
          _ChecklistLineData(
            title: 'Tipo da Empresa',
            subtitle: _valueOrPending(company.companyType),
            completed: (company.companyType ?? '').trim().isNotEmpty,
            icon: AppIcons.buildingfull,
          ),
          _ChecklistLineData(
            title: 'Descrição',
            subtitle: (company.description ?? '').trim().isNotEmpty
                ? _truncate(company.description!, 90)
                : 'Não preenchido',
            completed: (company.description ?? '').trim().isNotEmpty,
            icon: AppIcons.info,
          ),
          _ChecklistLineData(
            title: 'Slogan',
            subtitle: hasSlogan ? company.slogan!.trim() : 'Opcional / vazio',
            completed: true,
            icon: AppIcons.ray,
          ),
          _ChecklistLineData(
            title: 'Site',
            subtitle: hasWebsite ? company.website!.trim() : 'Opcional / vazio',
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
            title: 'Status',
            subtitle: company.isHiring
                ? 'Empresa está contratando'
                : 'Sem vagas no momento',
            completed: true,
            icon: AppIcons.briefcase,
          ),
        ],
      ),
      _ChecklistSectionData(
        title: 'Vagas',
        icon: AppIcons.briefcase,
        stepKey: 'jobs',
        completed: hasJobs,
        items: company.isHiring
            ? company.jobs.isNotEmpty
                ? company.jobs.take(3).map((job) {
                    final subtitleParts = <String>[];
                    if (job.seniority.trim().isNotEmpty) {
                      subtitleParts.add(job.seniority.trim());
                    }
                    if (job.workModel.trim().isNotEmpty) {
                      subtitleParts.add(job.workModel.trim());
                    }
                    if (job.location.trim().isNotEmpty) {
                      subtitleParts.add(job.location.trim());
                    }

                    return _ChecklistLineData(
                      title: job.title.trim().isNotEmpty
                          ? job.title.trim()
                          : 'Vaga',
                      subtitle: subtitleParts.isNotEmpty
                          ? subtitleParts.join(' • ')
                          : null,
                      completed: true,
                      icon: AppIcons.briefcase,
                    );
                  }).toList()
                : [
                    _ChecklistLineData(
                      title: 'Nenhuma vaga adicionada',
                      subtitle: 'Adicione pelo menos uma vaga.',
                      completed: false,
                      icon: AppIcons.briefcase,
                    ),
                  ]
            : [
                _ChecklistLineData(
                  title: 'Step ignorado',
                  subtitle: 'A empresa não está contratando agora.',
                  completed: true,
                  icon: AppIcons.briefcase,
                ),
              ],
        footerText: company.jobs.length > 3
            ? '+${company.jobs.length - 3} vaga(s)'
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
            subtitle: company.employeesCount == null
                ? 'Não preenchido'
                : '${company.employeesCount} colaborador(es)',
            completed: company.employeesCount != null && company.employeesCount! > 0,
            icon: AppIcons.group,
          ),
          _ChecklistLineData(
            title: 'Porte empresarial',
            subtitle: _valueOrPending(company.companySize),
            completed: (company.companySize ?? '').trim().isNotEmpty,
            icon: AppIcons.buildingfull,
          ),
        ],
      ),
    ];

    final allRequiredCompleted = sections.every((section) => section.completed);

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
                      'Revisão da Página Empresarial',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      allRequiredCompleted
                          ? 'Tudo pronto. Revise os dados e finalize a página empresarial.'
                          : 'Revise os dados abaixo. Os itens pendentes precisam ser ajustados antes de finalizar.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle(context, 'Dados da Empresa'),
                    const SizedBox(height: 12),
                    ...sections.map(
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

  static String _valueOrPending(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? 'Não preenchido' : text;
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
