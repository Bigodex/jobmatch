// =======================================================
// COMPANY PROFILE SCREEN
// -------------------------------------------------------
// Página empresarial criada após finalizar o cadastro da
// empresa. Estrutura inspirada no ProfileScreen do usuário.
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/profile_company/models/company_profile_model.dart';
import 'package:jobmatch/features/profile_company/providers/company_profile_provider.dart';
import 'package:jobmatch/features/profile_company/widgets/company_profile_header.dart';
import 'package:jobmatch/features/profile_company/widgets/company_profile_info_card.dart';
import 'package:jobmatch/features/profile_company/widgets/company_category_icon.dart';
import 'package:jobmatch/shared/widgets/app_header.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class CompanyProfileScreen extends ConsumerWidget {
  final String? companyId;

  const CompanyProfileScreen({
    super.key,
    this.companyId,
  });

  Future<void> _refresh(WidgetRef ref) async {
    final safeCompanyId = companyId?.trim() ?? '';

    if (safeCompanyId.isNotEmpty) {
      ref.invalidate(companyProfileByIdProvider(safeCompanyId));
      return;
    }

    await ref.read(companyProfileProvider.notifier).loadCompanyProfile();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final safeCompanyId = companyId?.trim() ?? '';
    final companyAsync = safeCompanyId.isNotEmpty
        ? ref.watch(companyProfileByIdProvider(safeCompanyId))
        : ref.watch(companyProfileProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Perfil Empresarial'),
            Expanded(
              child: companyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => RefreshIndicator(
                  color: theme.colorScheme.primary,
                  backgroundColor: theme.cardColor,
                  onRefresh: () => _refresh(ref),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                      Text(
                        'Erro ao carregar perfil empresarial: $error',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                data: (company) {
                  if (company == null) {
                    return RefreshIndicator(
                      color: theme.colorScheme.primary,
                      backgroundColor: theme.cardColor,
                      onRefresh: () => _refresh(ref),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        children: const [
                          _EmptyCompanyProfile(),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: theme.colorScheme.primary,
                    backgroundColor: theme.cardColor,
                    onRefresh: () => _refresh(ref),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        CompanyProfileHeader(company: company),
                        const SizedBox(height: 10),
                        _buildIdentityCard(context, company),
                        const SizedBox(height: 10),
                        _buildAboutCard(context, company),
                        const SizedBox(height: 10),
                        _buildJobsCard(context, company),
                        const SizedBox(height: 10),
                        _buildTeamCard(context, company),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildIdentityCard(BuildContext context, CompanyProfileModel company) {
    return CompanyProfileInfoCard(
      title: 'Identidade',
      icon: AppIcons.id,
      children: [
        CompanyProfileInfoLine(
          title: 'Nome da empresa',
          value: company.companyName,
          icon: AppIcons.buildingfull,
          hideWhenEmpty: false,
        ),
        CompanyProfileInfoLine(
          title: 'Categoria',
          value: company.companyCategory,
          icon: getCompanyCategoryIcon(company.companyCategory),
          hideWhenEmpty: false,
        ),
        CompanyProfileInfoLine(
          title: 'CNPJ',
          value: _maskCnpj(company.cnpj),
          icon: AppIcons.id2,
          hideWhenEmpty: false,
        ),
      ],
    );
  }

  Widget _buildAboutCard(BuildContext context, CompanyProfileModel company) {
    return CompanyProfileInfoCard(
      title: 'Sobre a empresa',
      icon: AppIcons.infofull,
      children: [
        CompanyProfileInfoLine(
          title: 'Tipo da empresa',
          value: company.companyType,
          icon: AppIcons.buildingbriefcase,
          hideWhenEmpty: false,
        ),
        CompanyProfileInfoLine(
          title: 'Setor',
          value: company.sector,
          icon: AppIcons.industry,
        ),
        CompanyProfileInfoLine(
          title: 'Slogan',
          value: company.slogan,
          icon: AppIcons.chat,
        ),
        CompanyProfileInfoLine(
          title: 'Site oficial',
          value: company.website,
          icon: AppIcons.links,
        ),
        CompanyProfileInfoLine(
          title: 'Descrição',
          value: company.description,
          icon: AppIcons.resume,
          hideWhenEmpty: false,
        ),
      ],
    );
  }

  Widget _buildJobsCard(BuildContext context, CompanyProfileModel company) {
    final hasJobs = company.jobs.isNotEmpty;

    return CompanyProfileInfoCard(
      title: 'Vagas',
      icon: AppIcons.briefcase,
      children: [
        if (hasJobs)
          ...company.jobs.map((job) => _CompanyJobCard(job: job))
        else
          const _EmptyCompanyJobs(),
      ],
    );
  }


  Widget _buildTeamCard(BuildContext context, CompanyProfileModel company) {
    return CompanyProfileInfoCard(
      title: 'Colaboradores',
      icon: AppIcons.group,
      children: [
        CompanyProfileInfoLine(
          title: 'Quantidade',
          value: company.employeesCount > 0
              ? '${company.employeesCount} colaborador(es)'
              : '',
          icon: AppIcons.hashtag,
          hideWhenEmpty: false,
        ),
        CompanyProfileInfoLine(
          title: 'Porte empresarial',
          value: company.companySize,
          icon: AppIcons.skyscraper,
          hideWhenEmpty: false,
        ),
      ],
    );
  }


  String _maskCnpj(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length != 14) {
      return value.trim();
    }

    return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12, 14)}';
  }
}


class _CompanyJobCard extends StatelessWidget {
  final CompanyProfileJobModel job;

  const _CompanyJobCard({
    required this.job,
  });

  String get _title {
    final value = job.title.trim();
    return value.isNotEmpty ? value : 'Vaga';
  }

  String get _seniority {
    final value = job.seniority.trim();
    return value.isNotEmpty ? value.toUpperCase() : 'NÍVEL';
  }

  String get _salary {
    final value = job.salary.trim();
    return value.isNotEmpty ? value : 'Salário não informado';
  }

  String get _location {
    final value = job.location.trim();
    return value.isNotEmpty ? value : 'Localização não informada';
  }

  String get _workModel {
    final value = job.workModel.trim();
    return value.isNotEmpty ? value : 'Modelo não informado';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final description = job.description.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: colors.cardTertiary,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _workModel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _seniority,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withOpacity(0.06),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sobre a vaga',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                _CompanyJobInfoLine(
                  icon: AppIcons.bagmoney,
                  text: _salary,
                ),
                _CompanyJobInfoLine(
                  icon: AppIcons.pin,
                  text: _location,
                ),
                _CompanyJobInfoLine(
                  icon: AppIcons.model,
                  text: _workModel,
                ),
                const _CompanyJobInfoLine(
                  icon: AppIcons.schedule,
                  text: 'Vaga cadastrada recentemente',
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.66),
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyJobInfoLine extends StatelessWidget {
  final String icon;
  final String text;

  const _CompanyJobInfoLine({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: 13,
            height: 13,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.72),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.68),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCompanyJobs extends StatelessWidget {
  const _EmptyCompanyJobs();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 12,
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            AppIcons.jobuCompany,
            width: 94,
            height: 94,
          ),
          const SizedBox(height: 12),
          const Text(
            'Adicione suas vagas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Gere oportunidades, e amplie seus colaboradores',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.58),
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCompanyProfile extends StatelessWidget {
  const _EmptyCompanyProfile();

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 10),
        child: Column(
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            const Text(
              'Nenhuma página empresarial criada ainda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Finalize o cadastro da empresa para gerar automaticamente esse perfil.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.64),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
