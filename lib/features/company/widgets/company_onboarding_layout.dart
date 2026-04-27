// =======================================================
// COMPANY ONBOARDING LAYOUT
// -------------------------------------------------------
// Layout base do fluxo de cadastro empresarial.
// Mantém header, Jobu e SafeArea padronizados para todos
// os steps da feature company.
// =======================================================

import 'package:flutter/material.dart';

import 'package:jobmatch/features/onboarding/widgets/onboarding_header.dart';
import 'package:jobmatch/features/onboarding/widgets/onboarding_jobu_tuto.dart';

class CompanyOnboardingLayout extends StatelessWidget {
  final Widget child;
  final int progressCurrentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final String jobuMessage;

  const CompanyOnboardingLayout({
    super.key,
    required this.child,
    required this.progressCurrentStep,
    required this.totalSteps,
    required this.jobuMessage,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        bottom: true,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            const SizedBox(height: 8),
            OnboardingHeader(
              currentStep: progressCurrentStep,
              totalSteps: totalSteps,
              onBack: onBack,
            ),
            JobuTuto(
              text: jobuMessage,
            ),
            Expanded(
              child: ClipRect(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
