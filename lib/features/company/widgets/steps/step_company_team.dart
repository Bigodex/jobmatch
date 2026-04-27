// =======================================================
// STEP COMPANY TEAM
// -------------------------------------------------------
// Etapa de colaboradores da página empresarial
// - quantidade de colaboradores
// - porte calculado automaticamente
// - validação visual no mesmo padrão do onboarding
// =======================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/company/providers/company_onboarding_provider.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';
import 'package:jobmatch/shared/widgets/app_validated_input_field.dart';

class StepCompanyTeam extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final Function(String?) onJobuMessageChange;

  const StepCompanyTeam({
    super.key,
    required this.onNext,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepCompanyTeam> createState() => _StepCompanyTeamState();
}

class _StepCompanyTeamState extends ConsumerState<StepCompanyTeam> {
  late final TextEditingController employeesController;

  bool _employeesHasError = false;
  bool _isNavigating = false;

  int get _employeesCount => int.tryParse(employeesController.text.trim()) ?? 0;
  bool get _isEmployeesValid => _employeesCount > 0;

  String get _companySize {
    if (!_isEmployeesValid) return '';
    return ref
        .read(companyOnboardingProvider.notifier)
        .getAutomaticCompanySize(_employeesCount);
  }

  @override
  void initState() {
    super.initState();

    final company = ref.read(companyOnboardingProvider);
    employeesController = TextEditingController(
      text: company.employeesCount == null ? '' : '${company.employeesCount}',
    );
  }

  @override
  void dispose() {
    employeesController.dispose();
    super.dispose();
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

  void _setEmployees(int value) {
    final safeValue = value < 0 ? 0 : value;

    setState(() {
      employeesController.text = safeValue == 0 ? '' : '$safeValue';
      employeesController.selection = TextSelection.collapsed(
        offset: employeesController.text.length,
      );
      _employeesHasError = false;
    });

    widget.onJobuMessageChange(null);
  }

  void _increment() {
    _setEmployees(_employeesCount + 1);
  }

  void _decrement() {
    if (_employeesCount <= 1) {
      _setEmployees(0);
      return;
    }

    _setEmployees(_employeesCount - 1);
  }

  Future<void> _handleContinue() async {
    if (_isNavigating) return;

    setState(() {
      _employeesHasError = !_isEmployeesValid;
    });

    if (_employeesHasError) {
      widget.onJobuMessageChange('Informe a quantidade de colaboradores.');
      return;
    }

    ref.read(companyOnboardingProvider.notifier).setTeamData(
          employeesCount: _employeesCount,
        );

    setState(() {
      _isNavigating = true;
    });

    await _showJobuMessageAndWait(
      'Boa. Porte empresarial calculado automaticamente.',
      minMilliseconds: 1200,
    );

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
    final size = _companySize;

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
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  bottom: 16,
                  top: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.cardTertiary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.group,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Colaboradores',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      color: Colors.white.withOpacity(0.08),
                      height: 1,
                    ),
                    const SizedBox(height: 16),
                    _fieldTitle(
                      icon: AppIcons.group,
                      title: 'Quantidade de colaboradores',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _counterButton(
                          icon: Icons.remove_rounded,
                          onTap: _decrement,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppValidatedInputField(
                            controller: employeesController,
                            hint: 'Ex: 25',
                            maxLength: 6,
                            hasError: _employeesHasError,
                            isValid: _isEmployeesValid,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              setState(() {
                                if (_employeesHasError) {
                                  _employeesHasError =
                                      (int.tryParse(value.trim()) ?? 0) <= 0;
                                }
                              });
                              widget.onJobuMessageChange(null);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        _counterButton(
                          icon: Icons.add_rounded,
                          onTap: _increment,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _companySizeBox(size),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleContinue,
                        child: _isNavigating
                            ? const _LoadingDots(color: Colors.black)
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
    );
  }

  Widget _fieldTitle({
    required String icon,
    required String title,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _counterButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _companySizeBox(String size) {
    final theme = Theme.of(context);
    final isValid = size.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isValid
              ? theme.colorScheme.primary
              : Colors.white.withOpacity(0.16),
          width: isValid ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppIcons.buildingfull,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(
              isValid ? theme.colorScheme.primary : Colors.white54,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Porte empresarial',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.64),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isValid ? size : 'Será calculado automaticamente',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isValid ? Colors.white : Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          if (isValid)
            Icon(
              Icons.check_circle_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final phase = (_controller.value * 3).floor() % 3;
        return Text(
          '.' * (phase + 1),
          style: TextStyle(
            color: widget.color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        );
      },
    );
  }
}
