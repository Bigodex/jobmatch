// =======================================================
// ONBOARDING FLOW SCREEN (BACK CORRETO COM GO ROUTER)
// =======================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 🔥 IMPORTANTE

// =======================================================
// CORE
// =======================================================
import 'package:jobmatch/features/onboarding/widgets/onboarding_step.dart';

// =======================================================
// LAYOUT
// =======================================================
import '../widgets/onboarding_layout.dart';

// =======================================================
// STEPS
// =======================================================
import '../widgets/steps/step_name.dart';
import '../widgets/steps/step_birthdate.dart';
import '../widgets/steps/step_specialty.dart';
import '../widgets/steps/step_languages.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {

  // ===================================================
  // STEP ATUAL
  // ===================================================
  OnboardingStep _currentStep = OnboardingStep.name;

  // ===================================================
  // JOBU MESSAGE
  // ===================================================
  String? _jobuMessage;

  // ===================================================
  // NAVEGAÇÃO
  // ===================================================
  void _nextStep() {
    setState(() {
      _currentStep = _currentStep.next();
      _jobuMessage = null;
    });
  }

  void _prevStep() {
    // 🔥 SE FOR O PRIMEIRO STEP → VOLTA PRA WELCOME
    if (_currentStep == OnboardingStep.name) {
      context.go('/welcome'); // 🔥 CORRETO COM GO ROUTER
      return;
    }

    // 🔥 SENÃO → VOLTA STEP NORMAL
    setState(() {
      _currentStep = _currentStep.previous();
      _jobuMessage = null;
    });
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

                  // 🔥 SEMPRE ATIVO
                  onBack: _prevStep,

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
        return StepName(onNext: _nextStep);

      case OnboardingStep.birthDate:
        return StepBirthDate(onNext: _nextStep);

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
        return StepLanguages(onNext: _nextStep);
    }
  }
}