// =======================================================
// STEP COMPANY IDENTITY
// -------------------------------------------------------
// Etapa de identificação da empresa
// - nome da empresa
// - categoria da empresa
// - CNPJ
// - mesmo padrão visual do onboarding
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
// CNPJ FORMATTER
// =======================================================
class CnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 14) {
      digits = digits.substring(0, 14);
    }

    final formatted = _formatCnpj(digits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  static String _formatCnpj(String digits) {
    if (digits.isEmpty) return '';

    if (digits.length <= 2) {
      return digits;
    } else if (digits.length <= 5) {
      return '${digits.substring(0, 2)}.${digits.substring(2)}';
    } else if (digits.length <= 8) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5)}';
    } else if (digits.length <= 12) {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8)}';
    } else {
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12)}';
    }
  }
}

// =======================================================
// TITLE CASE FORMATTER
// =======================================================
class CompanyTitleInputFormatter extends TextInputFormatter {
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
// COMPANY CATEGORY OPTION
// =======================================================
class CompanyCategoryOption {
  final String label;
  final String icon;

  const CompanyCategoryOption({
    required this.label,
    required this.icon,
  });
}

class StepCompanyIdentity extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final Function(String?) onJobuMessageChange;

  const StepCompanyIdentity({
    super.key,
    required this.onNext,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepCompanyIdentity> createState() =>
      _StepCompanyIdentityState();
}

class _StepCompanyIdentityState extends ConsumerState<StepCompanyIdentity> {
  late final TextEditingController companyNameController;
  late final TextEditingController cnpjController;

  String? selectedCategory;

  bool _companyNameHasError = false;
  bool _companyCategoryHasError = false;
  bool _cnpjHasError = false;
  bool _isNavigating = false;

  static const List<CompanyCategoryOption> _companyCategories = [
    CompanyCategoryOption(label: 'Agronegócio', icon: AppIcons.plant),
    CompanyCategoryOption(label: 'Alimentação', icon: AppIcons.feed),
    CompanyCategoryOption(label: 'Automotivo', icon: AppIcons.wheel),
    CompanyCategoryOption(label: 'Beleza e Estética', icon: AppIcons.lipstick),
    CompanyCategoryOption(label: 'Consultoria', icon: AppIcons.laptop),
    CompanyCategoryOption(label: 'Construção Civil', icon: AppIcons.helmet),
    CompanyCategoryOption(label: 'E-commerce', icon: AppIcons.store),
    CompanyCategoryOption(label: 'Educação', icon: AppIcons.cap),
    CompanyCategoryOption(label: 'Energia', icon: AppIcons.ray),
    CompanyCategoryOption(label: 'Entretenimento', icon: AppIcons.popcorn),
    CompanyCategoryOption(label: 'Financeiro', icon: AppIcons.bagmoney),
    CompanyCategoryOption(label: 'Hotelaria', icon: AppIcons.hotel),
    CompanyCategoryOption(label: 'Imobiliário', icon: AppIcons.key),
    CompanyCategoryOption(label: 'Indústria', icon: AppIcons.industry),
    CompanyCategoryOption(label: 'Jurídico', icon: AppIcons.law),
    CompanyCategoryOption(label: 'Logística', icon: AppIcons.boxes),
    CompanyCategoryOption(label: 'Marketing', icon: AppIcons.speaker),
    CompanyCategoryOption(label: 'Moda', icon: AppIcons.hanger),
    CompanyCategoryOption(label: 'Recursos Humanos', icon: AppIcons.rh),
    CompanyCategoryOption(label: 'Saúde', icon: AppIcons.healthy),
    CompanyCategoryOption(label: 'Serviços', icon: AppIcons.service),
    CompanyCategoryOption(label: 'Tecnologia', icon: AppIcons.code),
    CompanyCategoryOption(
      label: 'Telecomunicações',
      icon: AppIcons.antenna,
    ),
    CompanyCategoryOption(label: 'Turismo', icon: AppIcons.planet),
    CompanyCategoryOption(label: 'Varejo', icon: AppIcons.fastcar),
  ];

  bool get _isCompanyNameValid => companyNameController.text.trim().length >= 2;

  bool get _isCompanyCategoryValid =>
      selectedCategory != null && selectedCategory!.trim().isNotEmpty;

  bool get _isCnpjValid => _hasCompleteCnpj(cnpjController.text);

  CompanyCategoryOption? get _selectedCategoryOption {
    if (selectedCategory == null) return null;

    for (final category in _companyCategories) {
      if (category.label == selectedCategory) {
        return category;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();

    final company = ref.read(companyOnboardingProvider);

    companyNameController = TextEditingController(
      text: company.companyName ?? '',
    );

    selectedCategory = (company.companyCategory ?? '').trim().isEmpty
        ? null
        : company.companyCategory;

    cnpjController = TextEditingController(
      text: _formatCnpj(company.cnpj ?? ''),
    );
  }

  @override
  void dispose() {
    companyNameController.dispose();
    cnpjController.dispose();
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

  bool _hasCompleteCnpj(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length == 14;
  }

  String _formatCnpj(String value) {
    String digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 14) {
      digits = digits.substring(0, 14);
    }

    return CnpjInputFormatter._formatCnpj(digits);
  }

  void _persistIdentity() {
    ref.read(companyOnboardingProvider.notifier).setIdentity(
          companyName: companyNameController.text.trim(),
          companyCategory: selectedCategory?.trim() ?? '',
          cnpj: cnpjController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        );
  }

  Future<void> _openCategorySelector() async {
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
                  'Categoria da Empresa',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _companyCategories.length,
                    separatorBuilder: (_, __) => Divider(
                      color: Colors.white.withOpacity(0.06),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final item = _companyCategories[index];
                      final isSelected = item.label == selectedCategory;

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
      selectedCategory = result;

      if (_companyCategoryHasError) {
        _companyCategoryHasError = false;
      }
    });

    widget.onJobuMessageChange(null);
  }

  Future<void> _handleContinue() async {
    if (_isNavigating) return;

    setState(() {
      _companyNameHasError = companyNameController.text.trim().length < 2;
      _companyCategoryHasError =
          selectedCategory == null || selectedCategory!.trim().isEmpty;
      _cnpjHasError = !_hasCompleteCnpj(cnpjController.text);
    });

    if (_companyNameHasError) {
      widget.onJobuMessageChange('Preciso do nome da empresa.');
      return;
    }

    if (_companyCategoryHasError) {
      widget.onJobuMessageChange('Escolha a categoria da empresa.');
      return;
    }

    if (_cnpjHasError) {
      widget.onJobuMessageChange('Preciso do CNPJ completo.');
      return;
    }

    _persistIdentity();

    setState(() {
      _isNavigating = true;
    });

    await _showJobuMessageAndWait(
      'Boa. Dados principais salvos.',
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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
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

                      // ===================================================
                      // HEADER
                      // ===================================================
                      Row(
                        children: [
                          SvgPicture.asset(
                            AppIcons.buildingfull,
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Identificação da Empresa',
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

                      // ===================================================
                      // NOME DA EMPRESA
                      // ===================================================
                      _editItem(
                        icon: AppIcons.skyscraper,
                        title: 'Nome da Empresa',
                        child: AppValidatedInputField(
                          controller: companyNameController,
                          hint: 'Digite o nome da empresa',
                          maxLength: 80,
                          hasError: _companyNameHasError,
                          isValid: _isCompanyNameValid,
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: [
                            CompanyTitleInputFormatter(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              if (_companyNameHasError) {
                                _companyNameHasError = value.trim().length < 2;
                              }
                            });

                            widget.onJobuMessageChange(null);
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ===================================================
                      // CATEGORIA
                      // ===================================================
                      _editItem(
                        icon: AppIcons.nodes,
                        title: 'Setor da Empresa',
                        child: AppValidatedSelectorField(
                          hint: 'Selecione o setor da empresa',
                          value: selectedCategory,
                          selectedIcon: _selectedCategoryOption?.icon,
                          onTap: _openCategorySelector,
                          hasError: _companyCategoryHasError,
                          isValid: _isCompanyCategoryValid,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ===================================================
                      // CNPJ
                      // ===================================================
                      _editItem(
                        icon: AppIcons.government,
                        title: 'CNPJ',
                        child: AppValidatedInputField(
                          controller: cnpjController,
                          hint: 'Digite o CNPJ da empresa',
                          maxLength: 18,
                          hasError: _cnpjHasError,
                          isValid: _isCnpjValid,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            CnpjInputFormatter(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              if (_cnpjHasError) {
                                _cnpjHasError = !_hasCompleteCnpj(value);
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