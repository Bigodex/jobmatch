// =======================================================
// STEP COMPANY TEAM
// -------------------------------------------------------
// Etapa de colaboradores da empresa
// - quantidade de funcionários
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
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Colaboradores',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Informe quantas pessoas trabalham na empresa hoje. O porte será definido automaticamente pelo JobMatch.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _FieldLabel(
                      label: 'Quantidade de funcionários',
                      icon: AppIcons.hashtag,
                    ),
                    const SizedBox(height: 8),
                    AppValidatedInputField(
                      controller: _employeesController,
                      hint: 'Ex: 42',
                      hasError: _employeesHasError,
                      isValid: _isEmployeesValid,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: _handleEmployeesChanged,
                    ),
                    const SizedBox(height: 18),
                    _CompanySizePreview(
                      companySize: currentSize,
                      employeesCount: _employeesCount,
                    ),
                    const SizedBox(height: 18),
                    _SizeRuleList(currentSize: currentSize),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasValue
              ? theme.colorScheme.primary.withOpacity(0.85)
              : Colors.white.withOpacity(0.16),
          width: hasValue ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: hasValue
                  ? theme.colorScheme.primary.withOpacity(0.16)
                  : Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                AppIcons.buildingfull,
                width: 19,
                height: 19,
                colorFilter: ColorFilter.mode(
                  hasValue
                      ? theme.colorScheme.primary
                      : Colors.white.withOpacity(0.58),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Classificação automática',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withOpacity(0.62),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasValue ? companySize! : 'Aguardando quantidade',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: hasValue
                        ? theme.colorScheme.primary
                        : Colors.white.withOpacity(0.72),
                  ),
                ),
                if (employeesCount != null && employeesCount! > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$employeesCount colaborador(es)',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeRuleList extends StatelessWidget {
  final String? currentSize;

  const _SizeRuleList({required this.currentSize});

  static const _rules = [
    ('Pequena empresa', '1 até 49 funcionários'),
    ('Média empresa', '50 até 249 funcionários'),
    ('Grande empresa', '250 até 999 funcionários'),
    ('Multinacional', '1000+ funcionários'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _rules.map((rule) {
        final selected = rule.$1 == currentSize;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                  : Colors.white.withOpacity(0.035),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                    : Colors.white.withOpacity(0.08),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: 17,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white.withOpacity(0.36),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    rule.$1,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? Colors.white
                          : Colors.white.withOpacity(0.78),
                    ),
                  ),
                ),
                Text(
                  rule.$2,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
          width: 15,
          height: 15,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
