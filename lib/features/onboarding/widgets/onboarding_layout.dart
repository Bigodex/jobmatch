// =======================================================
// ONBOARDING LAYOUT (COM JOBU DINÂMICO)
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/features/onboarding/widgets/onboarding_header.dart';
import 'package:jobmatch/features/onboarding/widgets/onboarding_jobu_tuto.dart';

class OnboardingLayout extends StatelessWidget {
  final Widget child;

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  // 🔥 NOVO: mensagem dinâmica do Jobu
  final String? jobuMessage;

  const OnboardingLayout({
    super.key,
    required this.child,
    required this.currentStep,
    required this.totalSteps,
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
              currentStep: currentStep,
              totalSteps: totalSteps,
              onBack: onBack,
            ),

            // 🔥 JOBU DINÂMICO
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

  String _getTextByStep(int step) {
    switch (step) {
      case 0:
        return 'Bora lá! Qual o seu nome?';
      case 1:
        return 'E quando você nasceu?';
      case 2:
        return 'Qual sua especialidade?';
      case 3:
        return 'E por último, quais idiomas \nvocê fala?';
      default:
        return '';
    }
  }
}