// =======================================================
// ONBOARDING HEADER
// -------------------------------------------------------
// Header com botão voltar + progress bar
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

class OnboardingHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  const OnboardingHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    final progress = (currentStep + 1) / totalSteps;

    return Container(
      color: appColors.header,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [

          // ===================================================
          // BOTÃO VOLTAR (SEMPRE ATIVO)
          // ===================================================
          GestureDetector(
            onTap: onBack, // 🔥 sempre ativo

            behavior: HitTestBehavior.opaque,

            child: Container(
              padding: const EdgeInsets.all(8),

              child: SvgPicture.asset(
                AppIcons.arrowleft,
                height: 26,
                width: 26,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ===================================================
          // PROGRESS BAR
          // ===================================================
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
                valueColor: AlwaysStoppedAnimation(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}