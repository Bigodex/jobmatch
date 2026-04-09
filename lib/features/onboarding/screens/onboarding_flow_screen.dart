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
  // NAVEGAÇÃO
  // ===================================================
  void _nextStep() {
    setState(() {
      final current = _currentStep;

      if (current == OnboardingStep.profileIntro) {
        final onboarding = ref.read(onboardingProvider);

        if (!onboarding.completeProfileNow) {
          _currentStep = OnboardingStep.checklist;
          _jobuMessage = null;
          return;
        }
      }

      _currentStep = _currentStep.next();
      _jobuMessage = null;
    });
  }

  void _prevStep() {
    if (_currentStep == OnboardingStep.name) {
      context.go('/welcome');
      return;
    }

    setState(() {
      _currentStep = _currentStep.previous();
      _jobuMessage = null;
    });
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
          role: onboarding.role,
          avatarUrl: '',
          coverUrl: '',
          connections: 0,
          views: 0,
        ),
        resume: ResumeModel(
          birthDate: onboarding.birthDate,
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
        _jobuMessage = null;
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

  // ===================================================
  // BUILD
  // ===================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  key: ValueKey(_currentStep),
                  currentStep: _currentStep.index,
                  totalSteps: OnboardingStep.values.length,
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
          onNext: _nextStep,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.specialty:
        return StepSpecialty(
          onNext: _nextStep,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.languages:
        return StepLanguages(
          onNext: _nextStep,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.account:
        return StepPassword(
          onNext: _nextStep,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.profileIntro:
        return StepProfileIntro(
          onNext: _nextStep,
        );

      case OnboardingStep.resume:
        return StepResume(
          onNext: _nextStep,
          onSkip: _nextStep,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.softSkills:
        return StepSoftSkills(
          onNext: _nextStep,
          onSkip: _nextStep,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.hardSkills:
        return StepHardSkills(
          onNext: _nextStep,
          onSkip: _nextStep,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.experience:
        return StepExperience(
          onNext: _nextStep,
          onSkip: _nextStep,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.education:
        return StepEducation(
          onNext: _nextStep,
          onSkip: _nextStep,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.links:
        return StepLinks(
          onNext: _nextStep,
          onSkip: _nextStep,
          onJobuMessageChange: (msg) {
            setState(() {
              _jobuMessage = msg;
            });
          },
        );

      case OnboardingStep.checklist:
        return StepChecklist(
          onCreateAccount: _createAccount,
        );
    }
  }
}