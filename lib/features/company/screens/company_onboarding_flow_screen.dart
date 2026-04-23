// =======================================================
// COMPANY ONBOARDING FLOW SCREEN
// -------------------------------------------------------
// Fluxo de cadastro da página empresarial
// - reaproveita header de progresso
// - reaproveita Jobu
// - step de vagas é condicional
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jobmatch/features/company/providers/company_onboarding_provider.dart';
import 'package:jobmatch/features/company/widgets/company_onboarding_step.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_header.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_identity.dart';
import 'package:jobmatch/features/onboarding/widgets/onboarding_header.dart';
import 'package:jobmatch/features/onboarding/widgets/onboarding_jobu_tuto.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class CompanyOnboardingFlowScreen extends ConsumerStatefulWidget {
  const CompanyOnboardingFlowScreen({super.key});

  @override
  ConsumerState<CompanyOnboardingFlowScreen> createState() =>
      _CompanyOnboardingFlowScreenState();
}

class _CompanyOnboardingFlowScreenState
    extends ConsumerState<CompanyOnboardingFlowScreen> {
  // ===================================================
  // STEP ATUAL
  // ===================================================
  CompanyOnboardingStep _currentStep = CompanyOnboardingStep.header;

  // ===================================================
  // JOBU MESSAGE
  // ===================================================
  String? _jobuMessage;

  // ===================================================
  // DEFINE STEP
  // ===================================================
  void _setStep(CompanyOnboardingStep step) {
    setState(() {
      _currentStep = step;
      _jobuMessage = null;
    });
  }

  // ===================================================
  // LISTA DE STEPS ATIVOS
  // ---------------------------------------------------
  // Remove o step de vagas quando a empresa não está
  // contratando
  // ===================================================
  List<CompanyOnboardingStep> _getActiveSteps(CompanyOnboardingState company) {
    final steps = <CompanyOnboardingStep>[
      CompanyOnboardingStep.header,
      CompanyOnboardingStep.identity,
      CompanyOnboardingStep.about,
      CompanyOnboardingStep.hiring,
      if (company.isHiring) CompanyOnboardingStep.jobs,
      CompanyOnboardingStep.team,
      CompanyOnboardingStep.checklist,
    ];

    return steps;
  }

  // ===================================================
  // ÍNDICE DA BARRA
  // ===================================================
  int _getProgressCurrentStep(CompanyOnboardingState company) {
    final steps = _getActiveSteps(company);
    final index = steps.indexOf(_currentStep);

    if (index == -1) return 0;
    return index;
  }

  // ===================================================
  // TOTAL DA BARRA
  // ===================================================
  int _getProgressTotalSteps(CompanyOnboardingState company) {
    return _getActiveSteps(company).length;
  }

  // ===================================================
  // PRÓXIMO STEP
  // ===================================================
  void _nextStep() {
    final company = ref.read(companyOnboardingProvider);
    final steps = _getActiveSteps(company);
    final currentIndex = steps.indexOf(_currentStep);

    if (currentIndex == -1) {
      _setStep(steps.first);
      return;
    }

    final nextIndex = currentIndex + 1;

    if (nextIndex >= steps.length) {
      return;
    }

    _setStep(steps[nextIndex]);
  }

  // ===================================================
  // STEP ANTERIOR
  // ===================================================
  void _prevStep() {
    final company = ref.read(companyOnboardingProvider);
    final steps = _getActiveSteps(company);
    final currentIndex = steps.indexOf(_currentStep);

    if (currentIndex <= 0) {
      context.pop();
      return;
    }

    _setStep(steps[currentIndex - 1]);
  }

  // ===================================================
  // CONTINUE DOS STEPS
  // ===================================================
  void _handleStepComplete() {
    _nextStep();
  }

  // ===================================================
  // TEXTO PADRÃO DO JOBU
  // ===================================================
  String _getJobuText() {
    if (_jobuMessage != null && _jobuMessage!.trim().isNotEmpty) {
      return _jobuMessage!;
    }

    switch (_currentStep) {
      case CompanyOnboardingStep.header:
        return 'Vamos montar a página da sua empresa?';

      case CompanyOnboardingStep.identity:
        return 'Agora preciso do Q nome, categoria e CNPJ da empresa.';

      case CompanyOnboardingStep.about:
        return 'Boa! Agora quero entender melhor o perfil da empresa e o que ela faz.';

      case CompanyOnboardingStep.hiring:
        return 'Sua empresa está contratando agora ou quer apenas montar a página primeiro?';

      case CompanyOnboardingStep.jobs:
        return 'Perfeito. Então bora cadastrar pelo menos uma vaga para a empresa já entrar em cena.';

      case CompanyOnboardingStep.team:
        return 'Quantas pessoas trabalham aí hoje? Com isso eu já ajusto o porte empresarial de forma coerente.';

      case CompanyOnboardingStep.checklist:
        return 'Confere tudo direitinho antes de finalizar a página empresarial.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(companyOnboardingProvider);

    final progressCurrentStep = _getProgressCurrentStep(company);
    final progressTotalSteps = _getProgressTotalSteps(company);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            OnboardingHeader(
              currentStep: progressCurrentStep,
              totalSteps: progressTotalSteps,
              onBack: _prevStep,
            ),
            JobuTuto(
              text: _getJobuText(),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: SingleChildScrollView(
                  key: ValueKey(_currentStep.name),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================
  // BUILD STEP
  // ===================================================
  Widget _buildStep() {
    switch (_currentStep) {
      case CompanyOnboardingStep.header:
        return StepCompanyHeader(
          onNext: _handleStepComplete,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case CompanyOnboardingStep.identity:
        return StepCompanyIdentity(
          onNext: _handleStepComplete,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case CompanyOnboardingStep.about:
        return _CompanyPlaceholderStep(
          title: 'Sobre a empresa',
          subtitle: 'Setor, tipo, site e descrição',
          description:
              'Essa etapa será separada para apresentar melhor o perfil da empresa.',
          primaryLabel: 'Continuar',
          onPrimaryTap: _handleStepComplete,
        );

      case CompanyOnboardingStep.hiring:
        return _CompanyHiringPlaceholderStep(
          onYes: () {
            ref.read(companyOnboardingProvider.notifier).setHiring(true);
            _handleStepComplete();
          },
          onNo: () {
            ref.read(companyOnboardingProvider.notifier).setHiring(false);
            _handleStepComplete();
          },
        );

      case CompanyOnboardingStep.jobs:
        return _CompanyPlaceholderStep(
          title: 'Vagas',
          subtitle: 'Cadastro inicial de vagas',
          description:
              'Esse step só aparece quando a empresa informa que está contratando.',
          primaryLabel: 'Continuar',
          onPrimaryTap: _handleStepComplete,
        );

      case CompanyOnboardingStep.team:
        return _CompanyPlaceholderStep(
          title: 'Colaboradores',
          subtitle: 'Quantidade e porte empresarial',
          description:
              'Aqui vamos calcular automaticamente o porte da empresa com base na quantidade de colaboradores.',
          primaryLabel: 'Continuar',
          onPrimaryTap: _handleStepComplete,
        );

      case CompanyOnboardingStep.checklist:
        return _CompanyChecklistPlaceholderStep(
          onFinish: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Fluxo empresarial estruturado. Agora seguimos para os steps reais.',
                ),
              ),
            );
          },
        );
    }
  }
}

// =======================================================
// PLACEHOLDER STEP BASE
// -------------------------------------------------------
// Temporário para o fluxo já existir sem quebrar enquanto
// os steps reais ainda não foram criados
// =======================================================
class _CompanyPlaceholderStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;

  const _CompanyPlaceholderStep({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.primaryLabel,
    required this.onPrimaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSectionCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPrimaryTap,
                child: Text(primaryLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// PLACEHOLDER HIRING STEP
// =======================================================
class _CompanyHiringPlaceholderStep extends StatelessWidget {
  final VoidCallback onYes;
  final VoidCallback onNo;

  const _CompanyHiringPlaceholderStep({
    required this.onYes,
    required this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSectionCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sua empresa está contratando?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Se tiver vagas para publicar, o fluxo leva você direto para o cadastro delas.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onYes,
                child: const Text('Sim, tenho vagas para publicar'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onNo,
                child: const Text('Não, quero continuar sem vagas'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// PLACEHOLDER CHECKLIST STEP
// =======================================================
class _CompanyChecklistPlaceholderStep extends ConsumerWidget {
  final VoidCallback onFinish;

  const _CompanyChecklistPlaceholderStep({
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final company = ref.watch(companyOnboardingProvider);

    return AppSectionCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Checklist',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _ChecklistLine(
              label: 'Header',
              value: company.hasHeaderContent
                  ? 'Preenchido'
                  : 'Opcional / vazio',
            ),
            _ChecklistLine(
              label: 'Identidade',
              value: company.hasIdentityData ? 'Preenchido' : 'Pendente',
            ),
            _ChecklistLine(
              label: 'Sobre',
              value: company.hasAboutData ? 'Preenchido' : 'Pendente',
            ),
            _ChecklistLine(
              label: 'Contratação',
              value: company.isHiring
                  ? 'Empresa informou que está contratando'
                  : 'Empresa não informou vagas no momento',
            ),
            _ChecklistLine(
              label: 'Vagas',
              value: company.isHiring
                  ? '${company.jobs.length} cadastrada(s)'
                  : 'Step ignorado',
            ),
            _ChecklistLine(
              label: 'Colaboradores',
              value: company.hasTeamData ? 'Preenchido' : 'Pendente',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onFinish,
                child: const Text('Finalizar depois'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// CHECKLIST LINE
// =======================================================
class _ChecklistLine extends StatelessWidget {
  final String label;
  final String value;

  const _ChecklistLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}