// =======================================================
// STEP EXPERIENCE
// -------------------------------------------------------
// Experiências no onboarding
// - Mesmo modelo de soft/hard skills
// - Labels + ícones acima dos campos
// - Primeiro item fixo, não removível
// - Validações faladas pelo Jobu
// - Validação visual com shared input
// - Logo como picker de imagem da galeria
// - Datas digitáveis em MM/AAAA
// - Checkbox de emprego atual
// - Cálculo visual do período
// - Contadores ocultos
// =======================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/features/profile/models/experience_model.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';
import 'package:jobmatch/shared/widgets/app_validated_input_field.dart';

// =======================================================
// TEXT FORMATTERS
// =======================================================
class ExperienceTitleInputFormatter extends TextInputFormatter {
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

      if (capitalizeNext && RegExp(r'[a-zà-ÿA-ZÀ-Ÿ]').hasMatch(char)) {
        buffer.write(char.toUpperCase());
        capitalizeNext = false;
      } else {
        buffer.write(char);
        capitalizeNext = char == ' ' || char == '-' || char == '\'';
      }
    }

    return buffer.toString();
  }
}

class ExperienceDescriptionInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = _capitalizeFirst(newValue.text);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  static String _capitalizeFirst(String value) {
    if (value.isEmpty) return value;

    final firstIndex = value.indexOf(RegExp(r'[a-zà-ÿA-ZÀ-Ÿ]'));

    if (firstIndex == -1) return value;

    final firstChar = value[firstIndex];
    final upperFirst = firstChar.toUpperCase();

    return value.substring(0, firstIndex) +
        upperFirst +
        value.substring(firstIndex + 1);
  }
}

// =======================================================
// MONTH / YEAR FORMATTER
// =======================================================
class MonthYearInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 6) {
      digits = digits.substring(0, 6);
    }

    final formatted = _formatMonthYear(digits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  static String _formatMonthYear(String digits) {
    if (digits.isEmpty) return '';

    if (digits.length <= 2) {
      return digits;
    }

    return '${digits.substring(0, 2)}/${digits.substring(2)}';
  }
}

class StepExperience extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Function(String?) onJobuMessageChange;

  const StepExperience({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepExperience> createState() => _StepExperienceState();
}

class _StepExperienceState extends ConsumerState<StepExperience> {
  static final DateTime _storageEmptyDate = DateTime(1900, 1, 1);

  late List<TextEditingController> companies;
  late List<TextEditingController> roles;
  late List<TextEditingController> descriptions;
  late List<TextEditingController> startDateControllers;
  late List<TextEditingController> endDateControllers;

  late List<String?> logoImages;
  late List<DateTime?> startDates;
  late List<DateTime?> endDates;
  late List<bool> isCurrentJobs;

  final ImagePicker _imagePicker = ImagePicker();

  bool _validationTriggered = false;

  @override
  void initState() {
    super.initState();

    final onboarding = ref.read(onboardingProvider);
    final experiences = onboarding.experiences;

    if (experiences.isNotEmpty) {
      companies = experiences
          .map(
            (e) => TextEditingController(
              text: ExperienceTitleInputFormatter._toTitleCase(e.company),
            ),
          )
          .toList();

      roles = experiences
          .map(
            (e) => TextEditingController(
              text: ExperienceTitleInputFormatter._toTitleCase(e.role),
            ),
          )
          .toList();

      descriptions = experiences
          .map(
            (e) => TextEditingController(
              text: ExperienceDescriptionInputFormatter._capitalizeFirst(
                e.description,
              ),
            ),
          )
          .toList();

      logoImages = experiences
          .map((e) => (e.logoUrl?.trim().isEmpty ?? true) ? null : e.logoUrl)
          .toList();

      startDates = experiences
          .map((e) => _isStorageEmptyDate(e.startDate) ? null : e.startDate)
          .toList();

      endDates = experiences.map((e) => e.endDate).toList();

      isCurrentJobs = experiences.map((e) {
        final hasContent = e.company.trim().isNotEmpty ||
            e.role.trim().isNotEmpty ||
            e.description.trim().isNotEmpty ||
            (e.logoUrl?.trim().isNotEmpty ?? false) ||
            !_isStorageEmptyDate(e.startDate);

        return hasContent && e.endDate == null;
      }).toList();

      startDateControllers = startDates
          .map(
            (date) => TextEditingController(
              text: date != null ? _formatMonthYear(date) : '',
            ),
          )
          .toList();

      endDateControllers = List.generate(
        endDates.length,
        (index) => TextEditingController(
          text: isCurrentJobs[index]
              ? ''
              : (endDates[index] != null ? _formatMonthYear(endDates[index]!) : ''),
        ),
      );
    } else {
      companies = [TextEditingController()];
      roles = [TextEditingController()];
      descriptions = [TextEditingController()];
      startDateControllers = [TextEditingController()];
      endDateControllers = [TextEditingController()];
      logoImages = [null];
      startDates = [null];
      endDates = [null];
      isCurrentJobs = [false];
    }

    for (final controller in companies) {
      controller.addListener(_handleFieldChanged);
    }

    for (final controller in roles) {
      controller.addListener(_handleFieldChanged);
    }

    for (final controller in descriptions) {
      controller.addListener(_handleFieldChanged);
    }
  }

  bool _isStorageEmptyDate(DateTime? date) {
    if (date == null) return false;

    return date.year == _storageEmptyDate.year &&
        date.month == _storageEmptyDate.month &&
        date.day == _storageEmptyDate.day;
  }

  @override
  void dispose() {
    for (final controller in companies) {
      controller.dispose();
    }

    for (final controller in roles) {
      controller.dispose();
    }

    for (final controller in descriptions) {
      controller.dispose();
    }

    for (final controller in startDateControllers) {
      controller.dispose();
    }

    for (final controller in endDateControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _handleFieldChanged() {
    widget.onJobuMessageChange(null);
    setState(() {});
    _sync();
  }

  void _showJobuMessage(String message) {
    widget.onJobuMessageChange(message);

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        widget.onJobuMessageChange(null);
      }
    });
  }

  DateTime? _parseMonthYear(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length != 6) return null;

    final month = int.tryParse(digits.substring(0, 2));
    final year = int.tryParse(digits.substring(2, 6));

    if (month == null || year == null) return null;
    if (month < 1 || month > 12) return null;
    if (year < 1970) return null;

    return DateTime(year, month, 1);
  }

  String _formatMonthYear(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '$month/${date.year}';
  }

  void _onStartDateChanged(int index, String value) {
    final parsed = _parseMonthYear(value);

    setState(() {
      startDates[index] = parsed;

      if (parsed != null &&
          endDates[index] != null &&
          endDates[index]!.isBefore(parsed)) {
        endDates[index] = null;
        endDateControllers[index].clear();
      }
    });

    widget.onJobuMessageChange(null);
    _sync();
  }

  void _onEndDateChanged(int index, String value) {
    final parsed = _parseMonthYear(value);

    setState(() {
      endDates[index] = parsed;
    });

    widget.onJobuMessageChange(null);
    _sync();
  }

  bool _isExperienceTouched(int index) {
    return companies[index].text.trim().isNotEmpty ||
        roles[index].text.trim().isNotEmpty ||
        descriptions[index].text.trim().isNotEmpty ||
        startDateControllers[index].text.trim().isNotEmpty ||
        endDateControllers[index].text.trim().isNotEmpty ||
        (logoImages[index]?.trim().isNotEmpty ?? false) ||
        startDates[index] != null ||
        endDates[index] != null ||
        isCurrentJobs[index];
  }

  bool get _allExperiencesEmpty {
    return !List.generate(companies.length, (index) => _isExperienceTouched(index))
        .contains(true);
  }

  bool _shouldValidateItem(int index) {
    if (!_validationTriggered) return false;

    if (_allExperiencesEmpty) {
      return index == 0;
    }

    return _isExperienceTouched(index);
  }

  bool _isCompanyValid(int index) {
    return companies[index].text.trim().length >= 2;
  }

  bool _isRoleValid(int index) {
    return roles[index].text.trim().length >= 2;
  }

  bool _isDescriptionValid(int index) {
    return descriptions[index].text.trim().length >= 10;
  }

  bool _isStartDateValid(int index) {
    final text = startDateControllers[index].text.trim();
    if (text.isEmpty) return false;
    return _parseMonthYear(text) != null;
  }

  bool _isEndDateValid(int index) {
    if (isCurrentJobs[index]) return true;

    final text = endDateControllers[index].text.trim();
    if (text.isEmpty) return false;

    final parsedEnd = _parseMonthYear(text);
    final parsedStart = _parseMonthYear(startDateControllers[index].text.trim());

    if (parsedEnd == null) return false;
    if (parsedStart != null && parsedEnd.isBefore(parsedStart)) return false;

    return true;
  }

  bool _companyHasError(int index) {
    if (!_shouldValidateItem(index)) return false;
    return !_isCompanyValid(index);
  }

  bool _roleHasError(int index) {
    if (!_shouldValidateItem(index)) return false;
    return !_isRoleValid(index);
  }

  bool _descriptionHasError(int index) {
    if (!_shouldValidateItem(index)) return false;
    return !_isDescriptionValid(index);
  }

  bool _startDateHasError(int index) {
    if (!_shouldValidateItem(index)) return false;
    return !_isStartDateValid(index);
  }

  bool _endDateHasError(int index) {
    if (!_shouldValidateItem(index)) return false;
    return !_isEndDateValid(index);
  }

  bool _companyIsValidState(int index) {
    if (!_isExperienceTouched(index)) return false;
    return _isCompanyValid(index);
  }

  bool _roleIsValidState(int index) {
    if (!_isExperienceTouched(index)) return false;
    return _isRoleValid(index);
  }

  bool _descriptionIsValidState(int index) {
    if (!_isExperienceTouched(index)) return false;
    return _isDescriptionValid(index);
  }

  bool _startDateIsValidState(int index) {
    if (!_isExperienceTouched(index)) return false;
    return _isStartDateValid(index);
  }

  bool _endDateIsValidState(int index) {
    if (!_isExperienceTouched(index)) return false;
    return _isEndDateValid(index);
  }

  List<ExperienceModel> _buildExperiencesForStorage() {
    return List.generate(
      companies.length,
      (index) => ExperienceModel(
        company: companies[index].text.trim(),
        role: roles[index].text.trim(),
        description: descriptions[index].text.trim(),
        startDate: startDates[index] ?? _storageEmptyDate,
        endDate: isCurrentJobs[index] ? null : endDates[index],
        logoUrl: logoImages[index],
      ),
    );
  }

  void _sync() {
    ref.read(onboardingProvider.notifier).setExperiences(
          _buildExperiencesForStorage(),
        );
  }

  void _addExperience() {
    final companyController = TextEditingController();
    final roleController = TextEditingController();
    final descriptionController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();

    companyController.addListener(_handleFieldChanged);
    roleController.addListener(_handleFieldChanged);
    descriptionController.addListener(_handleFieldChanged);

    setState(() {
      companies.add(companyController);
      roles.add(roleController);
      descriptions.add(descriptionController);
      startDateControllers.add(startController);
      endDateControllers.add(endController);
      logoImages.add(null);
      startDates.add(null);
      endDates.add(null);
      isCurrentJobs.add(false);
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  void _removeExperience(int index) {
    if (index == 0) {
      _showJobuMessage(
        'O primeiro item é fixo para \nte orientar.',
      );
      return;
    }

    companies[index].dispose();
    roles[index].dispose();
    descriptions[index].dispose();
    startDateControllers[index].dispose();
    endDateControllers[index].dispose();

    setState(() {
      companies.removeAt(index);
      roles.removeAt(index);
      descriptions.removeAt(index);
      startDateControllers.removeAt(index);
      endDateControllers.removeAt(index);
      logoImages.removeAt(index);
      startDates.removeAt(index);
      endDates.removeAt(index);
      isCurrentJobs.removeAt(index);
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  Future<void> _pickLogoImage(int index) async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() {
      logoImages[index] = pickedFile.path;
    });

    widget.onJobuMessageChange(null);
    _sync();
  }

  void _removeLogoImage(int index) {
    setState(() {
      logoImages[index] = null;
    });

    widget.onJobuMessageChange(null);
    _sync();
  }

  void _toggleCurrentJob(int index, bool? value) {
    final isCurrent = value ?? false;

    setState(() {
      isCurrentJobs[index] = isCurrent;

      if (isCurrent) {
        endDates[index] = null;
        endDateControllers[index].clear();
      }
    });

    widget.onJobuMessageChange(null);
    _sync();
  }

  String _calculatePeriod(DateTime start, DateTime end) {
    final totalMonths = ((end.year - start.year) * 12) + (end.month - start.month);

    if (totalMonths < 0) {
      return 'Período inválido';
    }

    if (totalMonths == 0) {
      return 'Menos de 1 mês';
    }

    final years = totalMonths ~/ 12;
    final months = totalMonths % 12;

    if (years > 0 && months > 0) {
      return '$years ${years == 1 ? 'ano' : 'anos'} e $months ${months == 1 ? 'mês' : 'meses'}';
    }

    if (years > 0) {
      return '$years ${years == 1 ? 'ano' : 'anos'}';
    }

    return '$months ${months == 1 ? 'mês' : 'meses'}';
  }

  String? _periodLabelFor(int index) {
    final start = startDates[index];

    if (start == null) return null;

    final end = isCurrentJobs[index] ? DateTime.now() : endDates[index];

    if (end == null) return null;

    if (end.isBefore(start)) {
      return 'Período inválido';
    }

    final endLabel = isCurrentJobs[index] ? 'Atual' : _formatMonthYear(end);

    return '${_formatMonthYear(start)} - $endLabel • ${_calculatePeriod(start, end)}';
  }

  void _handleContinue() {
    setState(() {
      _validationTriggered = true;
    });

    final touchedIndexes = List.generate(companies.length, (index) => index)
        .where(_isExperienceTouched)
        .toList();

    if (touchedIndexes.isEmpty) {
      _showJobuMessage(
        'Preencha pelo menos uma experiência ou clique em pular.',
      );
      return;
    }

    for (final index in touchedIndexes) {
      final company = companies[index].text.trim();
      final role = roles[index].text.trim();
      final description = descriptions[index].text.trim();
      final startDateText = startDateControllers[index].text.trim();
      final endDateText = endDateControllers[index].text.trim();
      final startDate = _parseMonthYear(startDateText);
      final endDate = _parseMonthYear(endDateText);
      final isCurrent = isCurrentJobs[index];

      if (company.isEmpty) {
        _showJobuMessage('Preencha a empresa ou remova o item vazio.');
        return;
      }

      if (company.length < 2) {
        _showJobuMessage('O nome da empresa está curto demais.');
        return;
      }

      if (role.isEmpty) {
        _showJobuMessage('Preencha o cargo da experiência "$company".');
        return;
      }

      if (role.length < 2) {
        _showJobuMessage(
          'O cargo da experiência "$company" está curto demais.',
        );
        return;
      }

      if (startDateText.isEmpty || startDate == null) {
        _showJobuMessage(
          'Digite a data de início em MM/AAAA para "$company".',
        );
        return;
      }

      if (!isCurrent && (endDateText.isEmpty || endDate == null)) {
        _showJobuMessage(
          'Digite a data de fim em MM/AAAA ou marque "Emprego atual" em "$company".',
        );
        return;
      }

      if (!isCurrent && endDate != null && endDate.isBefore(startDate)) {
        _showJobuMessage(
          'A data de fim não pode ser antes da data de início em "$company".',
        );
        return;
      }

      if (description.isEmpty) {
        _showJobuMessage('Descreva sua atuação em "$company".');
        return;
      }

      if (description.length < 10) {
        _showJobuMessage(
          'A descrição de \n"$company" está curta demais.',
        );
        return;
      }
    }

    final validExperiences = touchedIndexes.map((index) {
      return ExperienceModel(
        company: companies[index].text.trim(),
        role: roles[index].text.trim(),
        description: descriptions[index].text.trim(),
        startDate: _parseMonthYear(startDateControllers[index].text.trim())!,
        endDate: isCurrentJobs[index]
            ? null
            : _parseMonthYear(endDateControllers[index].text.trim()),
        logoUrl: logoImages[index],
      );
    }).toList();

    ref.read(onboardingProvider.notifier).setExperiences(validExperiences);
    widget.onJobuMessageChange(null);
    widget.onNext();
  }

  void _handleSkip() {
    ref.read(onboardingProvider.notifier).setExperiences([]);
    widget.onJobuMessageChange(null);
    widget.onSkip();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return SingleChildScrollView(
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
                          AppIcons.briefcase,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Experiências',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      color: theme.dividerColor.withOpacity(0.2),
                    ),
                    if (companies.isNotEmpty)
                      Column(
                        children: List.generate(companies.length, (index) {
                          return Column(
                            children: [
                              _experienceItem(index),
                              if (index != companies.length - 1)
                                Divider(
                                  height: 24,
                                  color: theme.dividerColor.withOpacity(0.2),
                                ),
                            ],
                          );
                        }),
                      ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _addExperience,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar experiência'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _handleSkip,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: theme.colorScheme.primary,
                              ),
                              foregroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Pular'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handleContinue,
                            child: const Text('Continuar'),
                          ),
                        ),
                      ],
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

  Widget _experienceItem(int index) {
    final isFixedItem = index == 0;
    final periodLabel = _periodLabelFor(index);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _fieldLabel(
                  svgIcon: AppIcons.image,
                  label: 'Logo da empresa',
                ),
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: isFixedItem ? 0.35 : 1,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: IconButton(
                    tooltip: isFixedItem ? 'Item fixo' : 'Remover experiência',
                    onPressed: () => _removeExperience(index),
                    icon: SvgPicture.asset(
                      AppIcons.trash,
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        theme.iconTheme.color ?? Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _logoPicker(index),
          const SizedBox(height: 12),
          _fieldLabel(
            svgIcon: AppIcons.buildingfull,
            label: 'Empresa',
          ),
          const SizedBox(height: 8),
          AppValidatedInputField(
            controller: companies[index],
            hint: 'Empresa (ex: Google)',
            maxLength: 60,
            hasError: _companyHasError(index),
            isValid: _companyIsValidState(index),
            inputFormatters: [
              ExperienceTitleInputFormatter(),
            ],
          ),
          const SizedBox(height: 12),
          _fieldLabel(
            svgIcon: AppIcons.role,
            label: 'Cargo',
          ),
          const SizedBox(height: 8),
          AppValidatedInputField(
            controller: roles[index],
            hint: 'Cargo (ex: Desenvolvedor)',
            maxLength: 60,
            hasError: _roleHasError(index),
            isValid: _roleIsValidState(index),
            inputFormatters: [
              ExperienceTitleInputFormatter(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(
                      svgIcon: AppIcons.calendar,
                      label: 'Data de início',
                    ),
                    const SizedBox(height: 8),
                    AppValidatedInputField(
                      controller: startDateControllers[index],
                      hint: 'MM/AAAA',
                      maxLength: 7,
                      keyboardType: TextInputType.number,
                      hasError: _startDateHasError(index),
                      isValid: _startDateIsValidState(index),
                      inputFormatters: [
                        MonthYearInputFormatter(),
                      ],
                      onChanged: (value) => _onStartDateChanged(index, value),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel(
                      svgIcon: AppIcons.calendarcheck,
                      label: 'Data de fim',
                    ),
                    const SizedBox(height: 8),
                    AppValidatedInputField(
                      controller: endDateControllers[index],
                      hint: isCurrentJobs[index] ? 'Atual' : 'MM/AAAA',
                      maxLength: 7,
                      enabled: !isCurrentJobs[index],
                      keyboardType: TextInputType.number,
                      hasError: _endDateHasError(index),
                      isValid: _endDateIsValidState(index),
                      inputFormatters: [
                        MonthYearInputFormatter(),
                      ],
                      onChanged: (value) => _onEndDateChanged(index, value),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _toggleCurrentJob(index, !isCurrentJobs[index]),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Theme(
                  data: theme.copyWith(
                    checkboxTheme: CheckboxThemeData(
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  child: Checkbox(
                    value: isCurrentJobs[index],
                    onChanged: (value) => _toggleCurrentJob(index, value),
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Emprego atual',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (periodLabel != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      periodLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          _fieldLabel(
            svgIcon: AppIcons.info,
            label: 'Descrição',
          ),
          const SizedBox(height: 8),
          AppValidatedInputField(
            controller: descriptions[index],
            hint: 'Descreva sua atuação...',
            minLines: 3,
            maxLines: null,
            maxLength: 300,
            keyboardType: TextInputType.multiline,
            hasError: _descriptionHasError(index),
            isValid: _descriptionIsValidState(index),
            inputFormatters: [
              ExperienceDescriptionInputFormatter(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _logoPicker(int index) {
    final theme = Theme.of(context);
    final imagePath = logoImages[index];
    final hasImage = imagePath != null && imagePath.trim().isNotEmpty;

    return GestureDetector(
      onTap: () => _pickLogoImage(index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.35),
                    ),
                    color: Colors.white.withOpacity(0.05),
                    image: hasImage
                        ? DecorationImage(
                            image: _buildImageProvider(imagePath),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: hasImage
                      ? null
                      : Icon(
                          Icons.camera_alt_rounded,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                ),
                if (hasImage)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: GestureDetector(
                      onTap: () => _removeLogoImage(index),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Adicione a imagem de LOGO da empresa.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: Colors.white.withOpacity(0.88),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _buildImageProvider(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }

    return FileImage(File(path));
  }

  Widget _fieldLabel({
    String? svgIcon,
    IconData? iconData,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (svgIcon != null)
          SvgPicture.asset(
            svgIcon,
            width: 16,
            height: 16,
          )
        else
          Icon(
            iconData,
            size: 16,
            color: theme.colorScheme.primary,
          ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}