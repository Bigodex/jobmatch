// =======================================================
// STEP COMPANY ABOUT
// -------------------------------------------------------
// Etapa sobre da empresa
// - slogan (opcional)
// - tipo
// - site oficial (opcional)
// - descrição
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
import 'package:jobmatch/shared/widgets/app_validated_selector_field.dart';

// =======================================================
// TITLE CASE FORMATTER
// =======================================================
class CompanyAboutTitleInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = _toTitleCase(newValue.text);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  static String _toTitleCase(String value) {
    if (value.isEmpty) return value;

    final buffer = StringBuffer();
    bool capitalizeNext = true;

    for (int i = 0; i < value.length; i++) {
      final char = value[i];

      if (capitalizeNext && RegExp(r'[a-zà-ÿA-ZÀ-Ÿ0-9]').hasMatch(char)) {
        buffer.write(char.toUpperCase());
        capitalizeNext = false;
      } else {
        buffer.write(char);
        capitalizeNext =
            char == ' ' || char == '-' || char == '/' || char == '\'';
      }
    }

    return buffer.toString();
  }
}

// =======================================================
// OPTION MODEL
// =======================================================
class CompanyAboutOption {
  final String label;
  final String icon;

  const CompanyAboutOption({
    required this.label,
    required this.icon,
  });
}

class StepCompanyAbout extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final Function(String?) onJobuMessageChange;

  const StepCompanyAbout({
    super.key,
    required this.onNext,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepCompanyAbout> createState() => _StepCompanyAboutState();
}

class _StepCompanyAboutState extends ConsumerState<StepCompanyAbout> {
  late final TextEditingController sloganController;
  late final TextEditingController websiteController;
  late final TextEditingController descriptionController;

  String? selectedCompanyType;

  bool _typeHasError = false;
  bool _descriptionHasError = false;
  bool _isNavigating = false;

  static const List<CompanyAboutOption> _companyTypes = [
    CompanyAboutOption(label: 'Empresa Privada', icon: AppIcons.buildingfull),
    CompanyAboutOption(label: 'Empresa Pública', icon: AppIcons.government),
    CompanyAboutOption(label: 'Startup', icon: AppIcons.ray),
    CompanyAboutOption(label: 'ONG', icon: AppIcons.planet),
    CompanyAboutOption(label: 'Cooperativa', icon: AppIcons.group),
    CompanyAboutOption(label: 'MEI', icon: AppIcons.id2),
  ];

  bool get _isCompanyTypeValid =>
      selectedCompanyType != null && selectedCompanyType!.trim().isNotEmpty;

  bool get _isDescriptionValid => descriptionController.text.trim().length >= 20;

  CompanyAboutOption? get _selectedCompanyTypeOption {
    if (selectedCompanyType == null) return null;

    for (final item in _companyTypes) {
      if (item.label == selectedCompanyType) {
        return item;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();

    final company = ref.read(companyOnboardingProvider);

    sloganController = TextEditingController(
      text: company.slogan ?? '',
    );

    websiteController = TextEditingController(
      text: company.website ?? '',
    );

    descriptionController = TextEditingController(
      text: company.description ?? '',
    );

    selectedCompanyType = (company.companyType ?? '').trim().isEmpty
        ? null
        : company.companyType;
  }

  @override
  void dispose() {
    sloganController.dispose();
    websiteController.dispose();
    descriptionController.dispose();
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

  void _persistAbout() {
    ref.read(companyOnboardingProvider.notifier).setAbout(
          slogan: sloganController.text.trim(),
          sector: '',
          companyType: selectedCompanyType?.trim() ?? '',
          website: websiteController.text.trim(),
          description: descriptionController.text.trim(),
        );
  }

  Future<void> _openTypeSelector() async {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.cardTertiary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tipo da Empresa',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _companyTypes.length,
                    separatorBuilder: (_, __) => Divider(
                      color: Colors.white.withOpacity(0.06),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final item = _companyTypes[index];
                      final isSelected = item.label == selectedCompanyType;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        leading: SvgPicture.asset(
                          item.icon,
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(isSelected ? 1 : 0.84),
                            BlendMode.srcIn,
                          ),
                        ),
                        title: Text(
                          item.label,
                          style: TextStyle(
                            color: Colors.white.withOpacity(
                              isSelected ? 1 : 0.84,
                            ),
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          Navigator.of(context).pop(item.label);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null) return;

    setState(() {
      selectedCompanyType = result;
      if (_typeHasError) _typeHasError = false;
    });

    widget.onJobuMessageChange(null);
  }

  Future<void> _handleContinue() async {
    if (_isNavigating) return;

    setState(() {
      _typeHasError =
          selectedCompanyType == null || selectedCompanyType!.trim().isEmpty;
      _descriptionHasError = descriptionController.text.trim().length < 20;
    });

    if (_typeHasError) {
      widget.onJobuMessageChange('Escolha o tipo da empresa.');
      return;
    }

    if (_descriptionHasError) {
      widget.onJobuMessageChange('Descreva melhor a empresa.');
      return;
    }

    _persistAbout();

    setState(() {
      _isNavigating = true;
    });

    await _showJobuMessageAndWait(
      'Ótimo. Perfil da empresa salvo.',
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

    return Transform.translate(
      offset: const Offset(0, -6),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            AppSectionCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
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
                            AppIcons.info,
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Sobre da Empresa',
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

                      _editItem(
                        icon: AppIcons.lamp,
                        title: 'Slogan',
                        child: AppValidatedInputField(
                          controller: sloganController,
                          hint: 'Ex: Conectando talentos ao futuro',
                          maxLength: 80,
                          hasError: false,
                          isValid: sloganController.text.trim().isNotEmpty,
                          textCapitalization: TextCapitalization.sentences,
                          inputFormatters: [
                            CompanyAboutTitleInputFormatter(),
                          ],
                          onChanged: (_) {
                            setState(() {});
                            widget.onJobuMessageChange(null);
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      _editItem(
                        icon: AppIcons.building,
                        title: 'Tipo',
                        child: AppValidatedSelectorField(
                          hint: 'Selecione o tipo da empresa',
                          value: selectedCompanyType,
                          selectedIcon: _selectedCompanyTypeOption?.icon,
                          onTap: _openTypeSelector,
                          hasError: _typeHasError,
                          isValid: _isCompanyTypeValid,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _editItem(
                        icon: AppIcons.links,
                        title: 'Site Oficial',
                        child: AppValidatedInputField(
                          controller: websiteController,
                          hint: 'https://www.suaempresa.com.br',
                          maxLength: 120,
                          hasError: false,
                          isValid: websiteController.text.trim().isNotEmpty,
                          keyboardType: TextInputType.url,
                          textCapitalization: TextCapitalization.none,
                          onChanged: (_) {
                            setState(() {});
                            widget.onJobuMessageChange(null);
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      _editItem(
                        icon: AppIcons.info,
                        title: 'Descrição da Empresa',
                        child: AppValidatedInputField(
                          controller: descriptionController,
                          hint:
                              'Descreva a empresa, propósito, atuação e diferenciais.',
                          maxLength: 500,
                          maxLines: 6,
                          hasError: _descriptionHasError,
                          isValid: _isDescriptionValid,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (value) {
                            setState(() {
                              if (_descriptionHasError) {
                                _descriptionHasError = value.trim().length < 20;
                              }
                            });

                            widget.onJobuMessageChange(null);
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleContinue,
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

  Widget _editItem({
    required String icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        ),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: child),
      ],
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