// =======================================================
// STEP COMPANY TEAM
// -------------------------------------------------------
// Etapa de colaboradores da empresa
// - quantidade de colaboradores
// - classificação automática do porte empresarial
// =======================================================

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
  late final TextEditingController _employeesController;

  bool _employeesHasError = false;
  bool _isNavigating = false;

  int? get _employeesCount {
    final value = _employeesController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.isEmpty) return null;
    return int.tryParse(value);
  }

  bool get _isEmployeesValid {
    final count = _employeesCount;
    return count != null && count > 0;
  }

  @override
  void initState() {
    super.initState();

    final company = ref.read(companyOnboardingProvider);

    _employeesController = TextEditingController(
      text: company.employeesCount?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _employeesController.dispose();
    super.dispose();
  }

  Future<void> _showJobuMessageAndWait(
    String message, {
    int minMilliseconds = 1300,
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

  void _persistTeam() {
    final count = _employeesCount;
    if (count == null || count < 1) return;

    ref.read(companyOnboardingProvider.notifier).setEmployeesCount(count);
  }

  void _setEmployeesValue(int value) {
    final safeValue = value < 1 ? 1 : value;

    _employeesController.text = safeValue.toString();
    _employeesController.selection = TextSelection.fromPosition(
      TextPosition(offset: _employeesController.text.length),
    );

    setState(() => _employeesHasError = false);

    ref.read(companyOnboardingProvider.notifier).setEmployeesCount(safeValue);
    widget.onJobuMessageChange(null);
  }

  void _incrementEmployees() {
    _setEmployeesValue((_employeesCount ?? 0) + 1);
  }

  void _decrementEmployees() {
    final count = _employeesCount;

    if (count == null || count <= 1) {
      _setEmployeesValue(1);
      return;
    }

    _setEmployeesValue(count - 1);
  }

  void _handleEmployeesChanged(String value) {
    final count = _employeesCount;

    setState(() {
      _employeesHasError = value.trim().isNotEmpty && !_isEmployeesValid;
    });

    if (count != null && count > 0) {
      ref.read(companyOnboardingProvider.notifier).setEmployeesCount(count);
      widget.onJobuMessageChange(null);
    }
  }

  Future<void> _handleContinue() async {
    if (_isNavigating) return;

    setState(() {
      _employeesHasError = !_isEmployeesValid;
    });

    if (!_isEmployeesValid) {
      await _showJobuMessageAndWait(
        'Me informa a quantidade de colaboradores para eu classificar a empresa automaticamente.',
      );
      return;
    }

    _persistTeam();

    setState(() => _isNavigating = true);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    final company = ref.watch(companyOnboardingProvider);
    final currentSize = company.companySize ??
        (_employeesCount != null
            ? ref
                .read(companyOnboardingProvider.notifier)
                .getAutomaticCompanySize(_employeesCount!)
            : null);

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          AppSectionCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
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
                          AppIcons.group,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Colaboradores',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(height: 1, color: Colors.white.withOpacity(0.12)),
                    const SizedBox(height: 20),
                    const _FieldLabel(
                      label: 'Quantidade de colaboradores',
                      icon: AppIcons.group,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _CounterButton(
                          icon: Icons.remove_rounded,
                          onTap: _decrementEmployees,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppValidatedInputField(
                            controller: _employeesController,
                            hint: 'Ex: 42',
                            hasError: _employeesHasError,
                            isValid: _isEmployeesValid,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: _handleEmployeesChanged,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _CounterButton(
                          icon: Icons.add_rounded,
                          onTap: _incrementEmployees,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _CompanySizePreview(
                      companySize: currentSize,
                      employeesCount: _employeesCount,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isNavigating ? null : _handleContinue,
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
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.4),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

class _CompanySizePreview extends StatelessWidget {
  final String? companySize;
  final int? employeesCount;

  const _CompanySizePreview({
    required this.companySize,
    required this.employeesCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = companySize != null && companySize!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasValue
              ? theme.colorScheme.primary.withOpacity(0.95)
              : Colors.white.withOpacity(0.16),
          width: hasValue ? 1.8 : 1,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppIcons.buildingfull,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              hasValue
                  ? theme.colorScheme.primary
                  : Colors.white.withOpacity(0.58),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Porte empresarial',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withOpacity(0.56),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasValue ? companySize! : 'Aguardando quantidade',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: hasValue ? Colors.white : Colors.white.withOpacity(0.72),
                  ),
                ),
                if (employeesCount != null && employeesCount! > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$employeesCount colaborador(es)',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.white.withOpacity(0.58),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (hasValue)
            Icon(
              Icons.check_circle_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final String icon;

  const _FieldLabel({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 18,
          height: 18,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
