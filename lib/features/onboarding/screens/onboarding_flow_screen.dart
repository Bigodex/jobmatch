// =======================================================
// ONBOARDING FLOW SCREEN
// =======================================================

// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =======================================================
// AUTH
// =======================================================
import 'package:jobmatch/features/auth/providers/auth_provider.dart';

// =======================================================
// PROFILE
// =======================================================
import 'package:jobmatch/features/profile/models/profile_model.dart';
import 'package:jobmatch/features/profile/models/user_model.dart';
import 'package:jobmatch/features/profile/models/resume_model.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';

// =======================================================
// CORE
// =======================================================
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/features/onboarding/widgets/onboarding_step.dart';
import 'package:jobmatch/features/onboarding/widgets/steps/step_checklist.dart';
import 'package:jobmatch/features/onboarding/widgets/steps/step_education.dart';
import 'package:jobmatch/features/onboarding/widgets/steps/step_experience.dart';
import 'package:jobmatch/features/onboarding/widgets/steps/step_hard_skills.dart';
import 'package:jobmatch/features/onboarding/widgets/steps/step_links.dart';
import 'package:jobmatch/features/onboarding/widgets/steps/step_profile_intro.dart';
import 'package:jobmatch/features/onboarding/widgets/steps/step_resume.dart';
import 'package:jobmatch/features/onboarding/widgets/steps/step_soft_skills.dart';

// =======================================================
// LAYOUT
// =======================================================
import '../widgets/onboarding_layout.dart';

// =======================================================
// STEPS
// =======================================================
import '../widgets/steps/step_indetification.dart';
import '../widgets/steps/step_specialty.dart';
import '../widgets/steps/step_languages.dart';
import '../widgets/steps/step_password.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  // ===================================================
  // STEP ATUAL
  // ===================================================
  OnboardingStep _currentStep = OnboardingStep.name;

  // ===================================================
  // JOBU MESSAGE
  // ===================================================
  String? _jobuMessage;

  // ===================================================
  // LOADING CREATE ACCOUNT
  // ===================================================
  bool _isCreatingAccount = false;

  // ===================================================
  // MODO EDIÇÃO VINDO DO CHECKLIST
  // ===================================================
  bool _isEditingFromChecklist = false;

  // ===================================================
  // ÚLTIMO STEP ANTES DO CHECKLIST
  // ===================================================
  OnboardingStep? _lastStepBeforeChecklist;

  // ===================================================
  // STEPS DA BARRA - OBRIGATÓRIOS
  // ===================================================
  static const List<OnboardingStep> _requiredProgressSteps = [
    OnboardingStep.name,
    OnboardingStep.specialty,
    OnboardingStep.languages,
    OnboardingStep.account,
  ];

  // ===================================================
  // STEPS DA BARRA - OPCIONAIS
  // ===================================================
  static const List<OnboardingStep> _optionalProgressSteps = [
    OnboardingStep.resume,
    OnboardingStep.softSkills,
    OnboardingStep.hardSkills,
    OnboardingStep.experience,
    OnboardingStep.education,
    OnboardingStep.links,
  ];

  // ===================================================
  // MAPEIA STEP OPCIONAL -> CHAVE DO CHECKLIST
  // ===================================================
  String? _getOptionalStepKey(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.resume:
        return 'resume';
      case OnboardingStep.softSkills:
        return 'softSkills';
      case OnboardingStep.hardSkills:
        return 'hardSkills';
      case OnboardingStep.experience:
        return 'experience';
      case OnboardingStep.education:
        return 'education';
      case OnboardingStep.links:
        return 'links';
      default:
        return null;
    }
  }

  // ===================================================
  // DEFINE STEP E MARCA VISITA OPCIONAL
  // ===================================================
  void _setStep(OnboardingStep step, {bool editingFromChecklist = false}) {
    setState(() {
      _currentStep = step;
      _isEditingFromChecklist = editingFromChecklist;
      _jobuMessage = null;
    });

    final optionalStepKey = _getOptionalStepKey(step);

    if (optionalStepKey != null) {
      ref
          .read(onboardingProvider.notifier)
          .markOptionalStepVisited(optionalStepKey);
    }
  }

  // ===================================================
  // DEFINE SE A BARRA EXPANDE
  // ===================================================
  bool _shouldUseExpandedProgress(OnboardingState onboarding) {
    if (onboarding.completeProfileNow) {
      return true;
    }

    return _optionalProgressSteps.contains(_currentStep);
  }

  // ===================================================
  // LISTA ATIVA DE PROGRESSO
  // ===================================================
  List<OnboardingStep> _getActiveProgressSteps(OnboardingState onboarding) {
    if (_shouldUseExpandedProgress(onboarding)) {
      return [..._requiredProgressSteps, ..._optionalProgressSteps];
    }

    return _requiredProgressSteps;
  }

  // ===================================================
  // ÍNDICE DA BARRA
  // ===================================================
  int _getProgressCurrentStep(OnboardingState onboarding) {
    final activeSteps = _getActiveProgressSteps(onboarding);
    final currentIndex = activeSteps.indexOf(_currentStep);

    if (currentIndex != -1) {
      return currentIndex;
    }

    if (_currentStep == OnboardingStep.profileIntro) {
      return _requiredProgressSteps.length - 1;
    }

    if (_currentStep == OnboardingStep.checklist) {
      return activeSteps.length - 1;
    }

    return 0;
  }

  // ===================================================
  // TOTAL DE STEPS DA BARRA
  // ===================================================
  int _getProgressTotalSteps(OnboardingState onboarding) {
    return _getActiveProgressSteps(onboarding).length;
  }

  // ===================================================
  // NAVEGAÇÃO NORMAL
  // ===================================================
  void _nextStep() {
    final current = _currentStep;

    if (current == OnboardingStep.profileIntro) {
      final onboarding = ref.read(onboardingProvider);

      if (!onboarding.completeProfileNow) {
        _lastStepBeforeChecklist = OnboardingStep.profileIntro;
        _setStep(OnboardingStep.checklist);
        return;
      }
    }

    final nextStep = _currentStep.next();

    if (nextStep == OnboardingStep.checklist) {
      _lastStepBeforeChecklist = _currentStep;
    }

    _setStep(nextStep);
  }

  // ===================================================
  // FINALIZAR EDIÇÃO E VOLTAR AO CHECKLIST
  // ===================================================
  void _finishChecklistEdit() {
    setState(() {
      _isEditingFromChecklist = false;
      _currentStep = OnboardingStep.checklist;
      _jobuMessage = null;
    });
  }

  // ===================================================
  // CONTINUE DOS STEPS
  // ===================================================
  void _handleStepComplete() {
    if (_isEditingFromChecklist) {
      _finishChecklistEdit();
      return;
    }

    _nextStep();
  }

  // ===================================================
  // SKIP DOS STEPS OPCIONAIS
  // ===================================================
  void _handleStepSkip() {
    if (_isEditingFromChecklist) {
      _finishChecklistEdit();
      return;
    }

    _nextStep();
  }

  // ===================================================
  // VOLTAR
  // ===================================================
  void _prevStep() {
    if (_isEditingFromChecklist) {
      _finishChecklistEdit();
      return;
    }

    if (_currentStep == OnboardingStep.name) {
      context.go('/welcome');
      return;
    }

    if (_currentStep == OnboardingStep.checklist &&
        _lastStepBeforeChecklist != null) {
      _setStep(_lastStepBeforeChecklist!);
      return;
    }

    setState(() {
      _currentStep = _currentStep.previous();
      _jobuMessage = null;
    });
  }

  // ===================================================
  // ABRIR STEP PELO CHECKLIST
  // ===================================================
  void _goToChecklistStep(String stepKey) {
    if (_isCreatingAccount) return;

    late final OnboardingStep targetStep;

    switch (stepKey) {
      case 'name':
      case 'birthDate':
        targetStep = OnboardingStep.name;
        break;

      case 'specialty':
        targetStep = OnboardingStep.specialty;
        break;

      case 'languages':
        targetStep = OnboardingStep.languages;
        break;

      case 'account':
        targetStep = OnboardingStep.account;
        break;

      case 'resume':
        targetStep = OnboardingStep.resume;
        break;

      case 'softSkills':
        targetStep = OnboardingStep.softSkills;
        break;

      case 'hardSkills':
        targetStep = OnboardingStep.hardSkills;
        break;

      case 'experience':
        targetStep = OnboardingStep.experience;
        break;

      case 'education':
        targetStep = OnboardingStep.education;
        break;

      case 'links':
        targetStep = OnboardingStep.links;
        break;

      default:
        targetStep = OnboardingStep.name;
        break;
    }

    _setStep(targetStep, editingFromChecklist: true);
  }

  // ===================================================
  // CREATE ACCOUNT
  // ===================================================
  Future<void> _createAccount() async {
    if (_isCreatingAccount) return;

    final onboarding = ref.read(onboardingProvider);

    final hasRequiredData =
        (onboarding.name?.trim().isNotEmpty ?? false) &&
        (onboarding.lastName?.trim().isNotEmpty ?? false) &&
        onboarding.birthDate != null &&
        onboarding.specialties.isNotEmpty &&
        onboarding.languages.isNotEmpty &&
        (onboarding.email?.trim().isNotEmpty ?? false) &&
        (onboarding.password?.trim().isNotEmpty ?? false);

    if (!hasRequiredData) {
      setState(() {
        _jobuMessage =
            'Ainda falta um ou mais campos obrigatórios para criar sua conta.';
      });
      return;
    }

    setState(() {
      _isCreatingAccount = true;
      _jobuMessage = 'Criando sua conta...';
    });

    try {
      final authController = ref.read(authControllerProvider.notifier);
      final profileService = ref.read(profileServiceProvider);

      await authController.register(
        onboarding.email!.trim(),
        onboarding.password!.trim(),
      );

      final profile = ProfileModel(
        user: UserModel(
          name: onboarding.fullName,
          email: onboarding.email!.trim(),
          role: onboarding.role,
          avatarUrl: '',
          coverUrl: '',
          connections: 0,
          views: 0,
        ),
        resume: ResumeModel(
          birthDate: onboarding.birthDate,
          state: onboarding.selectedUf,
          city: onboarding.city,
          description: onboarding.resumeDescription,
          labels: ResumeLabels.defaultLabels(),
        ),
        experiences: onboarding.experiences,
        education: onboarding.education,
        languages: onboarding.languages,
        softSkills: onboarding.softSkills,
        techSkills: onboarding.techSkills,
        links: onboarding.links,
      );

      await profileService.updateProfile(profile);

      ref.invalidate(profileProvider);
      ref.read(onboardingProvider.notifier).reset();

      if (!mounted) return;

      setState(() {
        _isCreatingAccount = false;
        _isEditingFromChecklist = false;
        _jobuMessage = null;
        _lastStepBeforeChecklist = null;
      });

      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCreatingAccount = false;
        _jobuMessage = 'Não consegui criar sua conta. ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onboarding = ref.watch(onboardingProvider);

    final progressCurrentStep = _getProgressCurrentStep(onboarding);
    final progressTotalSteps = _getProgressTotalSteps(onboarding);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: OnboardingLayout(
                  key: ValueKey(
                    '${_currentStep.name}-${_isEditingFromChecklist ? 'edit' : 'flow'}',
                  ),
                  progressCurrentStep: progressCurrentStep,
                  totalSteps: progressTotalSteps,
                  currentStep: _currentStep,
                  onBack: _isCreatingAccount ? null : _prevStep,
                  jobuMessage: _jobuMessage,
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
  // STEPS
  // ===================================================
  Widget _buildStep() {
    switch (_currentStep) {
      case OnboardingStep.name:
        return StepIdentification(
          onNext: _handleStepComplete,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.specialty:
        return StepSpecialty(
          onNext: _handleStepComplete,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.languages:
        return StepLanguages(
          onNext: _handleStepComplete,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.account:
        return StepPassword(
          onNext: _handleStepComplete,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.profileIntro:
        return StepProfileIntro(onNext: _handleStepComplete);

      case OnboardingStep.resume:
        return StepResume(
          onNext: _handleStepComplete,
          onSkip: _handleStepSkip,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.softSkills:
        return StepSoftSkills(
          onNext: _handleStepComplete,
          onSkip: _handleStepSkip,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.hardSkills:
        return StepHardSkills(
          onNext: _handleStepComplete,
          onSkip: _handleStepSkip,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.experience:
        return StepExperience(
          onNext: _handleStepComplete,
          onSkip: _handleStepSkip,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.education:
        return StepEducation(
          onNext: _handleStepComplete,
          onSkip: _handleStepSkip,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.links:
        return StepLinks(
          onNext: _handleStepComplete,
          onSkip: _handleStepSkip,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.checklist:
        return StepChecklist(
          onCreateAccount: _createAccount,
          onEditStep: _goToChecklistStep,
        );
    }
  }
}
