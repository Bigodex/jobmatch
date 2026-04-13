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
        return 'Bora lá! Pode me passar alguns dados pessoais?';
      case 1:
        return 'Qual a sua especialidade?';
      case 2:
        return 'Você fala só um idioma ou mais de um?';
      case 3:
        return 'Agora por fim seu e-mail e senha!';
      case 4:
        return 'E ai, quer finalizar as infos do perfil?';
      case 5:
        return 'Show! Fala onde você mora e conta mais sobre você!';
      case 6:
        return 'As habilidades comportamentais são muito importantes.';
      case 7:
        return 'Agora suas habilidades técnicas linguagens, tecnologias e afins.';
      case 8:
        return 'Coloque suas melhores experiências.';
      case 9:
        return 'Já é formado? Está cursando algo?.';
      case 10:
        return 'Coloque links para facilitar contatos se desejar.';
      case 11:
        return 'Confere tudo e vem pro JobMatch!.';
      default:
        return '';
    }
  }
}