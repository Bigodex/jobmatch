// =======================================================
// STEP PROFILE INTRO
// -------------------------------------------------------
// Convite para completar o perfil agora ou depois
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jobmatch/core/constants/app_icons.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class StepProfileIntro extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const StepProfileIntro({super.key, required this.onNext});

  @override
  ConsumerState<StepProfileIntro> createState() => _StepProfileIntroState();
}

class _StepProfileIntroState extends ConsumerState<StepProfileIntro> {
  bool? _completeNow;

  @override
  void initState() {
    super.initState();

    final onboarding = ref.read(onboardingProvider);
    _completeNow = onboarding.completeProfileNow;
  }

  void _handleSelect(bool value) {
    setState(() {
      _completeNow = value;
    });

    ref.read(onboardingProvider.notifier).setCompleteProfileNow(value);
  }

  void _handleContinue() {
    if (_completeNow == null) return;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          AppSectionCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.cardTertiary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.incomplete,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Complete seu Perfil',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withOpacity(0.08), height: 1),
                    const SizedBox(height: 16),

                    Text(
                      'Você pode aproveitar agora para preencher mais informações do seu perfil e deixar tudo mais completo.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.80),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Mas fica tranquila(o): isso não é obrigatório. Você pode continuar agora e completar depois quando quiser.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _optionCard(
                      title: 'Quero completar agora',
                      subtitle:
                          'Vou preencher mais dados do perfil já no cadastro.',
                      selected: _completeNow == true,
                      onTap: () => _handleSelect(true),
                    ),

                    const SizedBox(height: 12),

                    _optionCard(
                      title: 'Prefiro fazer depois',
                      subtitle:
                          'Quero terminar meu cadastro agora e completar o perfil mais tarde.',
                      selected: _completeNow == false,
                      onTap: () => _handleSelect(false),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _completeNow != null
                            ? _handleContinue
                            : null,
                        child: const Text('Continuar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionCard({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Colors.white24,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? theme.colorScheme.primary : Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.70),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
