// =======================================================
// COMPANY PAGES SCREEN
// -------------------------------------------------------
// Tela intermediária para listar páginas empresariais já
// criadas e iniciar o cadastro de uma nova página.
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/company/providers/company_onboarding_provider.dart';
import 'package:jobmatch/features/profile_company/models/company_profile_model.dart';
import 'package:jobmatch/features/profile_company/providers/company_profile_provider.dart';
import 'package:jobmatch/shared/widgets/app_header.dart';

class CompanyPagesScreen extends ConsumerWidget {
  const CompanyPagesScreen({super.key});

  void _createNewCompanyPage(BuildContext context, WidgetRef ref) {
    ref.read(companyOnboardingProvider.notifier).reset();
    context.push('/company/onboarding?from=company-pages');
  }

  void _openCompanyPage(BuildContext context, CompanyProfileModel company) {
    final companyId = company.id.trim();

    if (companyId.isEmpty) {
      context.go('/company/profile');
      return;
    }

    context.go('/company/profile/$companyId');
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(companyProfilesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    final pagesState = ref.watch(companyProfilesProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Páginas Empresariais',
              showBackButton: true,
              onBackTap: () => context.go('/menu'),
            ),
            Expanded(
              child: pagesState.when(
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
                        'Erro ao carregar páginas empresariais: $error',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                data: (pages) {
                  return RefreshIndicator(
                    color: theme.colorScheme.primary,
                    backgroundColor: theme.cardColor,
                    onRefresh: () => _refresh(ref),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                      children: [
                        _IntroCard(colors: colors),
                        const SizedBox(height: 14),
                        ...pages.map(
                          (company) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CompanyPageCard(
                              company: company,
                              onAccess: () => _openCompanyPage(context, company),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _CreateCompanyPageCard(
                          onTap: () => _createNewCompanyPage(context, ref),
                        ),
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
}

class _IntroCard extends StatelessWidget {
  final AppColorsExtension colors;

  const _IntroCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardTertiary.withOpacity(0.90),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: SvgPicture.asset(
                AppIcons.buildingfull,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gerencie suas páginas',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Acesse uma página empresarial criada ou cadastre uma nova empresa.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.58),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyPageCard extends StatelessWidget {
  final CompanyProfileModel company;
  final VoidCallback onAccess;

  const _CompanyPageCard({
    required this.company,
    required this.onAccess,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    final logoUrl = company.logoUrl.trim();
    final name = company.companyName.trim().isEmpty
        ? 'Página empresarial'
        : company.companyName.trim();
    final details = [
      company.companyCategory.trim(),
      company.companySize.trim(),
      if (company.isHiring || company.jobs.isNotEmpty) 'Contratando',
    ].where((item) => item.isNotEmpty).join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardTertiary.withOpacity(0.86),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.055)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _CompanyLogo(logoUrl: logoUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      details.isEmpty
                          ? 'Página empresarial cadastrada'
                          : details,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.55),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onAccess,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Acessar Página da Empresa',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  final String logoUrl;

  const _CompanyLogo({required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (logoUrl.isNotEmpty) {
      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.25),
          ),
          image: DecorationImage(
            image: NetworkImage(logoUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.18),
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          AppIcons.buildingfull,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.72),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _CreateCompanyPageCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateCompanyPageCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.30),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppIcons.adduser,
                    width: 21,
                    height: 21,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Criar nova página empresarial',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Iniciar cadastro de outra empresa.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.primary.withOpacity(0.85),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
