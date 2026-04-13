// =======================================================
// ONBOARDING LAYOUT
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/features/onboarding/widgets/onboarding_header.dart';
import 'package:jobmatch/features/onboarding/widgets/onboarding_jobu_tuto.dart';
import 'package:jobmatch/features/onboarding/widgets/onboarding_step.dart';

class OnboardingLayout extends StatelessWidget {
  final Widget child;

  // ===================================================
  // PROGRESSO DA BARRA
  // ===================================================
  final int progressCurrentStep;
  final int totalSteps;

  // ===================================================
  // STEP REAL DO FLUXO
  // ===================================================
  final OnboardingStep currentStep;

  final VoidCallback? onBack;
  final String? jobuMessage;

  const OnboardingLayout({
    super.key,
    required this.child,
    required this.progressCurrentStep,
    required this.totalSteps,
    required this.currentStep,
    this.onBack,
    this.jobuMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 8),

            OnboardingHeader(
              currentStep: progressCurrentStep,
              totalSteps: totalSteps,
              onBack: onBack,
            ),

            JobuTuto(
              text: jobuMessage ?? _getTextByStep(currentStep),
            ),

            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  String _getTextByStep(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.name:
        return 'Bora lá! Pode me passar alguns dados pessoais?';

      case OnboardingStep.specialty:
        return 'Qual a sua especialidade?';

      case OnboardingStep.languages:
        return 'Você fala só um idioma ou mais de um?';

      case OnboardingStep.account:
        return 'Agora por fim seu e-mail e senha!';

      case OnboardingStep.profileIntro:
        return 'E aí, quer finalizar as infos do perfil?';

      case OnboardingStep.resume:
        return 'Show! Fala onde você mora e conta mais sobre você!';

      case OnboardingStep.softSkills:
        return 'As habilidades comportamentais são muito importantes.';

      case OnboardingStep.hardSkills:
        return 'Agora suas habilidades técnicas, linguagens, tecnologias e afins.';

      case OnboardingStep.experience:
        return 'Coloque suas melhores experiências.';

      case OnboardingStep.education:
        return 'Já é formado? Está cursando algo?';

      case OnboardingStep.links:
        return 'Coloque links para facilitar contatos, se desejar.';

      case OnboardingStep.checklist:
        return 'Confere se preencheu todos os dados direitinho.';

      }
  }
}