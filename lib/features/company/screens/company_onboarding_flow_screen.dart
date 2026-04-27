// =======================================================
// COMPANY ONBOARDING FLOW SCREEN
// -------------------------------------------------------
// Fluxo de cadastro da página empresarial
// - reaproveita header de progresso
// - reaproveita Jobu
// - mantém posicionamento igual ao onboarding de usuário
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jobmatch/features/company/providers/company_onboarding_provider.dart';
import 'package:jobmatch/features/company/widgets/company_onboarding_step.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_about.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_checklist.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_header.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_hiring.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_identity.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_jobs.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_team.dart';
import 'package:jobmatch/features/onboarding/widgets/onboarding_header.dart';
import 'package:jobmatch/features/onboarding/widgets/onboarding_jobu_tuto.dart';

class CompanyOnboardingFlowScreen extends ConsumerStatefulWidget {
  const CompanyOnboardingFlowScreen({super.key});

  @override
  ConsumerState<CompanyOnboardingFlowScreen> createState() =>
      _CompanyOnboardingFlowScreenState();
}

class _CompanyOnboardingFlowScreenState
    extends ConsumerState<CompanyOnboardingFlowScreen> {
  CompanyOnboardingStep _currentStep = CompanyOnboardingStep.header;
  String? _jobuMessage;

  void _setStep(CompanyOnboardingStep step) {
    setState(() {
      _currentStep = step;
      _jobuMessage = null;
    });
  }

  List<CompanyOnboardingStep> _getActiveSteps(CompanyOnboardingState company) {
    return <CompanyOnboardingStep>[
      CompanyOnboardingStep.header,
      CompanyOnboardingStep.identity,
      CompanyOnboardingStep.about,
      CompanyOnboardingStep.hiring,
      if (company.isHiring) CompanyOnboardingStep.jobs,
      CompanyOnboardingStep.team,
      CompanyOnboardingStep.checklist,
    ];
  }

  int _getProgressCurrentStep(CompanyOnboardingState company) {
    final steps = _getActiveSteps(company);
    final index = steps.indexOf(_currentStep);
    if (index == -1) return 0;
    return index;
  }

  int _getProgressTotalSteps(CompanyOnboardingState company) {
    return _getActiveSteps(company).length;
  }

  void _nextStep() {
    final company = ref.read(companyOnboardingProvider);
    final steps = _getActiveSteps(company);
    final currentIndex = steps.indexOf(_currentStep);

    if (currentIndex == -1) {
      _setStep(steps.first);
      return;
    }

    final nextIndex = currentIndex + 1;
    if (nextIndex >= steps.length) return;

    _setStep(steps[nextIndex]);
  }

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

  void _handleStepComplete() {
    _nextStep();
  }

  void _handleChecklistEdit(String stepKey) {
    switch (stepKey) {
      case 'header':
        _setStep(CompanyOnboardingStep.header);
        return;
      case 'identity':
        _setStep(CompanyOnboardingStep.identity);
        return;
      case 'about':
        _setStep(CompanyOnboardingStep.about);
        return;
      case 'hiring':
        _setStep(CompanyOnboardingStep.hiring);
        return;
      case 'jobs':
        _setStep(CompanyOnboardingStep.jobs);
        return;
      case 'team':
        _setStep(CompanyOnboardingStep.team);
        return;
    }
  }

  String _getJobuText() {
    if (_jobuMessage != null && _jobuMessage!.trim().isNotEmpty) {
      return _jobuMessage!;
    }

    switch (_currentStep) {
      case CompanyOnboardingStep.header:
        return 'Vamos montar a página da sua empresa?';
      case CompanyOnboardingStep.identity:
        return 'Agora preciso dos dados da empresa.';
      case CompanyOnboardingStep.about:
        return 'Agora quero conhecer melhor a empresa.';
      case CompanyOnboardingStep.hiring:
        return 'Sua empresa está contratando agora?';
      case CompanyOnboardingStep.jobs:
        return 'Show! Bora cadastrar pelo menos uma vaga.';
      case CompanyOnboardingStep.team:
        return 'Quantas pessoas trabalham aí hoje?';
      case CompanyOnboardingStep.checklist:
        return 'Confere tudo antes de finalizar a página.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(companyOnboardingProvider);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            OnboardingHeader(
              currentStep: _getProgressCurrentStep(company),
              totalSteps: _getProgressTotalSteps(company),
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
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_currentStep.name),
                  child: _buildStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case CompanyOnboardingStep.header:
        return StepCompanyHeader(
          onNext: _handleStepComplete,
          onJobuMessageChange: (msg) => setState(() => _jobuMessage = msg),
        );
      case CompanyOnboardingStep.identity:
        return StepCompanyIdentity(
          onNext: _handleStepComplete,
          onJobuMessageChange: (msg) => setState(() => _jobuMessage = msg),
        );
      case CompanyOnboardingStep.about:
        return StepCompanyAbout(
          onNext: _handleStepComplete,
          onJobuMessageChange: (msg) => setState(() => _jobuMessage = msg),
        );
      case CompanyOnboardingStep.hiring:
        return StepCompanyHiring(
          onNext: _handleStepComplete,
          onJobuMessageChange: (msg) => setState(() => _jobuMessage = msg),
        );
      case CompanyOnboardingStep.jobs:
        return StepCompanyJobs(
          onNext: _handleStepComplete,
          onJobuMessageChange: (msg) => setState(() => _jobuMessage = msg),
        );
      case CompanyOnboardingStep.team:
        return StepCompanyTeam(
          onNext: _handleStepComplete,
          onJobuMessageChange: (msg) => setState(() => _jobuMessage = msg),
        );
      case CompanyOnboardingStep.checklist:
        return StepCompanyChecklist(
          onEditStep: _handleChecklistEdit,
          onFinish: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Página empresarial finalizada.'),
              ),
            );
          },
        );
    }
  }
}
