// =======================================================
// COMPANY ONBOARDING FLOW SCREEN
// -------------------------------------------------------
// Fluxo de cadastro da página empresarial
// - reaproveita header de progresso
// - reaproveita Jobu
// - step de vagas é condicional
// - edição pelo checklist volta para o checklist
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jobmatch/features/company/providers/company_onboarding_provider.dart';
import 'package:jobmatch/features/company/widgets/company_onboarding_layout.dart';
import 'package:jobmatch/features/company/widgets/company_onboarding_step.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_about.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_checklist.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_header.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_hiring.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_identity.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_jobs.dart';
import 'package:jobmatch/features/company/widgets/steps/step_company_team.dart';

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
  bool _isEditingFromChecklist = false;

  void _setStep(
    CompanyOnboardingStep step, {
    bool editingFromChecklist = false,
  }) {
    setState(() {
      _currentStep = step;
      _isEditingFromChecklist = editingFromChecklist;
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
    if (_isEditingFromChecklist) {
      _setStep(CompanyOnboardingStep.checklist);
      return;
    }

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
    if (_isEditingFromChecklist) {
      _setStep(CompanyOnboardingStep.checklist);
      return;
    }

    _nextStep();
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
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: CompanyOnboardingLayout(
                  key: ValueKey(
                    '${_currentStep.name}-${_isEditingFromChecklist ? "edit" : "flow"}',
                  ),
                  progressCurrentStep: _getProgressCurrentStep(company),
                  totalSteps: _getProgressTotalSteps(company),
                  onBack: _prevStep,
                  jobuMessage: _getJobuText(),
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
          onJobuMessageChange: _setJobuMessage,
        );
      case CompanyOnboardingStep.identity:
        return StepCompanyIdentity(
          onNext: _handleStepComplete,
          onJobuMessageChange: _setJobuMessage,
        );
      case CompanyOnboardingStep.about:
        return StepCompanyAbout(
          onNext: _handleStepComplete,
          onJobuMessageChange: _setJobuMessage,
        );
      case CompanyOnboardingStep.hiring:
        return StepCompanyHiring(
          onNext: _handleStepComplete,
          onJobuMessageChange: _setJobuMessage,
        );
      case CompanyOnboardingStep.jobs:
        return StepCompanyJobs(
          onNext: _handleStepComplete,
          onJobuMessageChange: _setJobuMessage,
        );
      case CompanyOnboardingStep.team:
        return StepCompanyTeam(
          onNext: _handleStepComplete,
          onJobuMessageChange: _setJobuMessage,
        );
      case CompanyOnboardingStep.checklist:
        return StepCompanyChecklist(
          onEditStep: _handleChecklistEdit,
          onFinish: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Página empresarial revisada com sucesso.'),
              ),
            );
          },
        );
    }
  }

  void _setJobuMessage(String? message) {
    setState(() {
      _jobuMessage = message;
    });
  }

  void _handleChecklistEdit(String stepKey) {
    CompanyOnboardingStep? targetStep;

    switch (stepKey) {
      case 'header':
        targetStep = CompanyOnboardingStep.header;
        break;
      case 'identity':
        targetStep = CompanyOnboardingStep.identity;
        break;
      case 'about':
        targetStep = CompanyOnboardingStep.about;
        break;
      case 'hiring':
        targetStep = CompanyOnboardingStep.hiring;
        break;
      case 'jobs':
        targetStep = CompanyOnboardingStep.jobs;
        break;
      case 'team':
        targetStep = CompanyOnboardingStep.team;
        break;
    }

    if (targetStep == null) return;

    _setStep(targetStep, editingFromChecklist: true);
  }
}
