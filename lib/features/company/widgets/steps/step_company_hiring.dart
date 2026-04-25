// =======================================================
// STEP COMPANY HIRING
// -------------------------------------------------------
// Pergunta se a empresa está contratando no momento
// - define se o fluxo passa pelo step de vagas
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/company/providers/company_onboarding_provider.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class StepCompanyHiring extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final Function(String?) onJobuMessageChange;

  const StepCompanyHiring({
    super.key,
    required this.onNext,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepCompanyHiring> createState() => _StepCompanyHiringState();
}

class _StepCompanyHiringState extends ConsumerState<StepCompanyHiring> {
  bool? _isHiring;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    final company = ref.read(companyOnboardingProvider);

    _isHiring = company.isHiring ? true : null;
  }

  Future<void> _showJobuMessageAndWait(
    String message, {
    int minMilliseconds = 1400,
  }) async {
    widget.onJobuMessageChange(message);

    final estimated =
        (message.replaceAll('\n', ' ').trim().length * 42).clamp(1100, 2200);

    await Future.delayed(
      Duration(
        milliseconds: estimated > minMilliseconds ? estimated : minMilliseconds,
      ),
    );
  }

  void _handleSelect(bool value) {
    setState(() {
      _isHiring = value;
    });

    ref.read(companyOnboardingProvider.notifier).setHiring(value);
    widget.onJobuMessageChange(null);
  }

  Future<void> _handleContinue() async {
    if (_isNavigating || _isHiring == null) return;

    setState(() {
      _isNavigating = true;
    });

    if (_isHiring == true) {
      await _showJobuMessageAndWait(
        'Perfeito. Vamos cadastrar suas vagas.',
        minMilliseconds: 1200,
      );
    } else {
      await _showJobuMessageAndWait(
        'Beleza. Vamos seguir sem vagas por agora.',
        minMilliseconds: 1200,
      );
    }

    if (!mounted) return;

    setState(() {
      _isNavigating = false;
    });

    widget.onJobuMessageChange(null);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

    return Transform.translate(
      offset: const Offset(0, -6),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                            AppIcons.briefcase,
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Sua Empresa Está Contratando?',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(
                        color: Colors.white.withOpacity(0.08),
                        height: 1,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Se a empresa tiver vagas abertas, o próximo passo leva você para o cadastro delas.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.80),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Se ainda não estiver contratando, tudo bem. A página empresarial continua normalmente e você pode publicar vagas depois.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _optionCard(
                        title: 'Sim, estamos contratando',
                        subtitle:
                            'Quero seguir para o cadastro de vagas da empresa.',
                        selected: _isHiring == true,
                        onTap: () => _handleSelect(true),
                      ),
                      const SizedBox(height: 12),
                      _optionCard(
                        title: 'Não, por enquanto não',
                        subtitle:
                            'Quero continuar o cadastro da página sem publicar vagas agora.',
                        selected: _isHiring == false,
                        onTap: () => _handleSelect(false),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isHiring != null ? _handleContinue : null,
                          child: _isNavigating
                              ? const _LoadingDots(
                                  color: Colors.black,
                                )
                              : const Text('Continuar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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

// =======================================================
// LOADING DOTS
// =======================================================
class _LoadingDots extends StatefulWidget {
  final Color color;

  const _LoadingDots({
    this.color = Colors.white,
  });

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const double _dotSize = 5;
  static const double _spacing = 4;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _opacityForDot(int index) {
    final value = _controller.value;
    final phase = value * 3;

    if (phase >= index && phase < index + 1) {
      return 1.0;
    }

    return 0.28;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index == 2 ? 0 : _spacing,
              ),
              child: Opacity(
                opacity: _opacityForDot(index),
                child: Container(
                  width: _dotSize,
                  height: _dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}