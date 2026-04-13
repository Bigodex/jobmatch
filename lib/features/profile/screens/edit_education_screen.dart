// =======================================================
// EDIT EDUCATION SCREEN
// -------------------------------------------------------
// Mesmo padrão do StepEducation, adaptado para edição:
// - Labels + ícones acima dos campos
// - Primeiro item fixo
// - Validação visual com shared input
// - Logo como picker de imagem da galeria
// - Datas digitáveis em MM/AAAA
// - Checkbox de curso atual
// - Cálculo visual do período
// - Salva apenas itens válidos
// =======================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

import 'package:jobmatch/features/profile/models/education_model.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';
import 'package:jobmatch/features/profile/screens/success_screen.dart';

import 'package:jobmatch/shared/widgets/app_header.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';
import 'package:jobmatch/shared/widgets/app_validated_input_field.dart';

// =======================================================
// TEXT FORMATTERS
// =======================================================
class EducationTitleInputFormatter extends TextInputFormatter {
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

class EducationDescriptionInputFormatter extends TextInputFormatter {
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

class EditEducationScreen extends ConsumerStatefulWidget {
  final List<EducationModel> educations;

  const EditEducationScreen({
    super.key,
    required this.educations,
  });

  @override
  ConsumerState<EditEducationScreen> createState() =>
      _EditEducationScreenState();
}

class _EditEducationScreenState
    extends ConsumerState<EditEducationScreen> {
  static final DateTime _storageEmptyDate = DateTime(1900, 1, 1);

  late List<TextEditingController> institutions;
  late List<TextEditingController> courses;
  late List<TextEditingController> descriptions;
  late List<TextEditingController> startDateControllers;
  late List<TextEditingController> endDateControllers;

  late List<String?> logoImages;
  late List<DateTime?> startDates;
  late List<DateTime?> endDates;
  late List<bool> isCurrentStudies;

  final ImagePicker _imagePicker = ImagePicker();

  bool _validationTriggered = false;
  bool _hasChanged = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    if (widget.educations.isNotEmpty) {
      institutions = widget.educations
          .map(
            (e) => TextEditingController(
              text: EducationTitleInputFormatter._toTitleCase(e.institution),
            ),
          )
          .toList();

      courses = widget.educations
          .map(
            (e) => TextEditingController(
              text: EducationTitleInputFormatter._toTitleCase(e.course),
            ),
          )
          .toList();

      descriptions = widget.educations
          .map(
            (e) => TextEditingController(
              text: EducationDescriptionInputFormatter._capitalizeFirst(
                e.description,
              ),
            ),
          )
          .toList();

      logoImages = widget.educations
          .map((e) => (e.logoUrl?.trim().isEmpty ?? true) ? null : e.logoUrl)
          .toList();

      startDates = widget.educations
          .map((e) => _isStorageEmptyDate(e.startDate) ? null : e.startDate)
          .toList();

      endDates = widget.educations.map((e) => e.endDate).toList();

      isCurrentStudies = widget.educations.map((e) {
        final hasContent = e.institution.trim().isNotEmpty ||
            e.course.trim().isNotEmpty ||
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
          text: isCurrentStudies[index]
              ? ''
              : (endDates[index] != null
                  ? _formatMonthYear(endDates[index]!)
                  : ''),
        ),
      );
    } else {
      institutions = [TextEditingController()];
      courses = [TextEditingController()];
      descriptions = [TextEditingController()];
      startDateControllers = [TextEditingController()];
      endDateControllers = [TextEditingController()];
      logoImages = [null];
      startDates = [null];
      endDates = [null];
      isCurrentStudies = [false];
    }

    for (final controller in institutions) {
      controller.addListener(_handleFieldChanged);
    }

    for (final controller in courses) {
      controller.addListener(_handleFieldChanged);
    }

    for (final controller in descriptions) {
      controller.addListener(_handleFieldChanged);
    }

    _recalculateState();
  }

  bool _isStorageEmptyDate(DateTime? date) {
    if (date == null) return false;

    return date.year == _storageEmptyDate.year &&
        date.month == _storageEmptyDate.month &&
        date.day == _storageEmptyDate.day;
  }

  @override
  void dispose() {
    for (final controller in institutions) {
      controller.dispose();
    }

    for (final controller in courses) {
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
    _errorMessage = null;
    _recalculateState();
  }

  void _recalculateState() {
    _hasChanged = _hasEducationsChanged();

    if (mounted) {
      setState(() {});
    }
  }

  bool _hasEducationsChanged() {
    final current = _buildComparableSnapshot();
    final original = _buildOriginalComparableSnapshot();

    if (current.length != original.length) return true;

    for (int i = 0; i < current.length; i++) {
      final currentItem = current[i];
      final originalItem = original[i];

      if (currentItem['institution'] != originalItem['institution']) return true;
      if (currentItem['course'] != originalItem['course']) return true;
      if (currentItem['description'] != originalItem['description']) return true;
      if (currentItem['start'] != originalItem['start']) return true;
      if (currentItem['end'] != originalItem['end']) return true;
      if (currentItem['logo'] != originalItem['logo']) return true;
      if (currentItem['isCurrent'] != originalItem['isCurrent']) return true;
    }

    return false;
  }

  List<Map<String, dynamic>> _buildComparableSnapshot() {
    final items = <Map<String, dynamic>>[];

    for (int index = 0; index < institutions.length; index++) {
      if (!_isEducationTouched(index)) continue;

      items.add({
        'institution': institutions[index].text.trim(),
        'course': courses[index].text.trim(),
        'description': descriptions[index].text.trim(),
        'start': startDateControllers[index].text.trim(),
        'end': isCurrentStudies[index] ? '' : endDateControllers[index].text.trim(),
        'logo': (logoImages[index] ?? '').trim(),
        'isCurrent': isCurrentStudies[index],
      });
    }

    return items;
  }

  List<Map<String, dynamic>> _buildOriginalComparableSnapshot() {
    final items = <Map<String, dynamic>>[];

    for (final education in widget.educations) {
      final originalIsCurrent = education.endDate == null;

      items.add({
        'institution': education.institution.trim(),
        'course': education.course.trim(),
        'description': education.description.trim(),
        'start': _isStorageEmptyDate(education.startDate)
            ? ''
            : _formatMonthYear(education.startDate),
        'end': originalIsCurrent || education.endDate == null
            ? ''
            : _formatMonthYear(education.endDate!),
        'logo': (education.logoUrl ?? '').trim(),
        'isCurrent': originalIsCurrent,
      });
    }

    return items;
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
      _errorMessage = null;

      if (parsed != null &&
          endDates[index] != null &&
          endDates[index]!.isBefore(parsed)) {
        endDates[index] = null;
        endDateControllers[index].clear();
      }
    });

    _recalculateState();
  }

  void _onEndDateChanged(int index, String value) {
    final parsed = _parseMonthYear(value);

    setState(() {
      endDates[index] = parsed;
      _errorMessage = null;
    });

    _recalculateState();
  }

  bool _isEducationTouched(int index) {
    return institutions[index].text.trim().isNotEmpty ||
        courses[index].text.trim().isNotEmpty ||
        descriptions[index].text.trim().isNotEmpty ||
        startDateControllers[index].text.trim().isNotEmpty ||
        endDateControllers[index].text.trim().isNotEmpty ||
        (logoImages[index]?.trim().isNotEmpty ?? false) ||
        startDates[index] != null ||
        endDates[index] != null ||
        isCurrentStudies[index];
  }

  bool get _allEducationsEmpty {
    return !List.generate(institutions.length, (index) => _isEducationTouched(index))
        .contains(true);
  }

  bool _shouldValidateItem(int index) {
    if (!_validationTriggered) return false;

    if (_allEducationsEmpty) {
      return index == 0;
    }

    return _isEducationTouched(index);
  }

  bool _isInstitutionValid(int index) {
    return institutions[index].text.trim().length >= 2;
  }

  bool _isCourseValid(int index) {
    return courses[index].text.trim().length >= 2;
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
    if (isCurrentStudies[index]) return true;

    final text = endDateControllers[index].text.trim();
    if (text.isEmpty) return false;

    final parsedEnd = _parseMonthYear(text);
    final parsedStart = _parseMonthYear(startDateControllers[index].text.trim());

    if (parsedEnd == null) return false;
    if (parsedStart != null && parsedEnd.isBefore(parsedStart)) return false;

    return true;
  }

  bool _institutionHasError(int index) {
    if (!_shouldValidateItem(index)) return false;
    return !_isInstitutionValid(index);
  }

  bool _courseHasError(int index) {
    if (!_shouldValidateItem(index)) return false;
    return !_isCourseValid(index);
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

  bool _institutionIsValidState(int index) {
    if (!_isEducationTouched(index)) return false;
    return _isInstitutionValid(index);
  }

  bool _courseIsValidState(int index) {
    if (!_isEducationTouched(index)) return false;
    return _isCourseValid(index);
  }

  bool _descriptionIsValidState(int index) {
    if (!_isEducationTouched(index)) return false;
    return _isDescriptionValid(index);
  }

  bool _startDateIsValidState(int index) {
    if (!_isEducationTouched(index)) return false;
    return _isStartDateValid(index);
  }

  bool _endDateIsValidState(int index) {
    if (!_isEducationTouched(index)) return false;
    return _isEndDateValid(index);
  }

  void _addEducation() {
    final institutionController = TextEditingController();
    final courseController = TextEditingController();
    final descriptionController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();

    institutionController.addListener(_handleFieldChanged);
    courseController.addListener(_handleFieldChanged);
    descriptionController.addListener(_handleFieldChanged);

    setState(() {
      institutions.add(institutionController);
      courses.add(courseController);
      descriptions.add(descriptionController);
      startDateControllers.add(startController);
      endDateControllers.add(endController);
      logoImages.add(null);
      startDates.add(null);
      endDates.add(null);
      isCurrentStudies.add(false);
      _errorMessage = null;
    });

    _recalculateState();
  }

  void _removeEducation(int index) {
    if (index == 0) {
      setState(() {
        _validationTriggered = true;
        _errorMessage = 'O primeiro item é fixo para te orientar.';
      });
      return;
    }

    institutions[index].dispose();
    courses[index].dispose();
    descriptions[index].dispose();
    startDateControllers[index].dispose();
    endDateControllers[index].dispose();

    setState(() {
      institutions.removeAt(index);
      courses.removeAt(index);
      descriptions.removeAt(index);
      startDateControllers.removeAt(index);
      endDateControllers.removeAt(index);
      logoImages.removeAt(index);
      startDates.removeAt(index);
      endDates.removeAt(index);
      isCurrentStudies.removeAt(index);
      _errorMessage = null;
    });

    _recalculateState();
  }

  Future<void> _pickLogoImage(int index) async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() {
      logoImages[index] = pickedFile.path;
      _errorMessage = null;
    });

    _recalculateState();
  }

  void _removeLogoImage(int index) {
    setState(() {
      logoImages[index] = null;
      _errorMessage = null;
    });

    _recalculateState();
  }

  void _toggleCurrentStudy(int index, bool? value) {
    final isCurrent = value ?? false;

    setState(() {
      isCurrentStudies[index] = isCurrent;
      _errorMessage = null;

      if (isCurrent) {
        endDates[index] = null;
        endDateControllers[index].clear();
      }
    });

    _recalculateState();
  }

  String _calculatePeriod(DateTime start, DateTime end) {
    final totalMonths =
        ((end.year - start.year) * 12) + (end.month - start.month);

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

    final end = isCurrentStudies[index] ? DateTime.now() : endDates[index];

    if (end == null) return null;

    if (end.isBefore(start)) {
      return 'Período inválido';
    }

    final endLabel = isCurrentStudies[index] ? 'Atual' : _formatMonthYear(end);

    return '${_formatMonthYear(start)} - $endLabel • ${_calculatePeriod(start, end)}';
  }

  Future<void> _save() async {
    setState(() {
      _validationTriggered = true;
      _errorMessage = null;
    });

    final touchedIndexes = List.generate(institutions.length, (index) => index)
        .where(_isEducationTouched)
        .toList();

    if (touchedIndexes.isEmpty) {
      setState(() {
        _errorMessage = 'Preencha pelo menos uma formação.';
      });
      return;
    }

    for (final index in touchedIndexes) {
      final institution = institutions[index].text.trim();
      final course = courses[index].text.trim();
      final description = descriptions[index].text.trim();
      final startDateText = startDateControllers[index].text.trim();
      final endDateText = endDateControllers[index].text.trim();
      final startDate = _parseMonthYear(startDateText);
      final endDate = _parseMonthYear(endDateText);
      final isCurrent = isCurrentStudies[index];

      if (institution.isEmpty) {
        setState(() {
          _errorMessage = 'Preencha a instituição ou remova o item vazio.';
        });
        return;
      }

      if (institution.length < 2) {
        setState(() {
          _errorMessage = 'O nome da instituição está curto demais.';
        });
        return;
      }

      if (course.isEmpty) {
        setState(() {
          _errorMessage = 'Preencha o curso da formação "$institution".';
        });
        return;
      }

      if (course.length < 2) {
        setState(() {
          _errorMessage = 'O curso da formação "$institution" está curto demais.';
        });
        return;
      }

      if (startDateText.isEmpty || startDate == null) {
        setState(() {
          _errorMessage = 'Digite a data de início em MM/AAAA para "$institution".';
        });
        return;
      }

      if (!isCurrent && (endDateText.isEmpty || endDate == null)) {
        setState(() {
          _errorMessage =
              'Digite a data de fim em MM/AAAA ou marque "Curso atual" em "$institution".';
        });
        return;
      }

      if (!isCurrent && endDate != null && endDate.isBefore(startDate)) {
        setState(() {
          _errorMessage =
              'A data de fim não pode ser antes da data de início em "$institution".';
        });
        return;
      }

      if (description.isEmpty) {
        setState(() {
          _errorMessage = 'Descreva sua formação em "$institution".';
        });
        return;
      }

      if (description.length < 10) {
        setState(() {
          _errorMessage = 'A descrição de "$institution" está curta demais.';
        });
        return;
      }
    }

    final validEducations = touchedIndexes.map((index) {
      return EducationModel(
        institution: institutions[index].text.trim(),
        course: courses[index].text.trim(),
        description: descriptions[index].text.trim(),
        startDate: _parseMonthYear(startDateControllers[index].text.trim())!,
        endDate: isCurrentStudies[index]
            ? null
            : _parseMonthYear(endDateControllers[index].text.trim()),
        logoUrl: logoImages[index],
      );
    }).toList();

    try {
      setState(() {
        _isSaving = true;
      });

      await ref.read(profileProvider.notifier).updateEducations(validEducations);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SuccessScreen(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: AppHeader(
              title: 'Editar',
              showBackButton: true,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: AppSectionCard(
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
                                AppIcons.cap,
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Formações',
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
                          if (institutions.isNotEmpty)
                            Column(
                              children: List.generate(institutions.length, (index) {
                                return Column(
                                  children: [
                                    _educationItem(index),
                                    if (index != institutions.length - 1)
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
                            onPressed: _addEducation,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar formação'),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (!_hasChanged || _isSaving) ? null : _save,
                              child: Text(
                                _isSaving ? 'Salvando...' : 'Salvar',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _educationItem(int index) {
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
                  label: 'Logo da instituição',
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
                    tooltip: isFixedItem ? 'Item fixo' : 'Remover formação',
                    onPressed: () => _removeEducation(index),
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
            label: 'Instituição',
          ),
          const SizedBox(height: 8),
          AppValidatedInputField(
            controller: institutions[index],
            hint: 'Instituição (ex: UTFPR)',
            maxLength: 80,
            hasError: _institutionHasError(index),
            isValid: _institutionIsValidState(index),
            inputFormatters: [
              EducationTitleInputFormatter(),
            ],
            onChanged: (_) {
              _errorMessage = null;
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          _fieldLabel(
            svgIcon: AppIcons.role,
            label: 'Curso',
          ),
          const SizedBox(height: 8),
          AppValidatedInputField(
            controller: courses[index],
            hint: 'Curso (ex: Análise e Desenvolvimento de Sistemas)',
            maxLength: 100,
            hasError: _courseHasError(index),
            isValid: _courseIsValidState(index),
            inputFormatters: [
              EducationTitleInputFormatter(),
            ],
            onChanged: (_) {
              _errorMessage = null;
              setState(() {});
            },
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
                      hint: isCurrentStudies[index] ? 'Atual' : 'MM/AAAA',
                      maxLength: 7,
                      enabled: !isCurrentStudies[index],
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
            onTap: () => _toggleCurrentStudy(index, !isCurrentStudies[index]),
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
                    value: isCurrentStudies[index],
                    onChanged: (value) => _toggleCurrentStudy(index, value),
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Curso atual',
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
            hint: 'Descreva sua formação...',
            minLines: 3,
            maxLines: null,
            maxLength: 300,
            keyboardType: TextInputType.multiline,
            hasError: _descriptionHasError(index),
            isValid: _descriptionIsValidState(index),
            inputFormatters: [
              EducationDescriptionInputFormatter(),
            ],
            onChanged: (_) {
              _errorMessage = null;
              setState(() {});
            },
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
                'Adicione a imagem de LOGO da instituição.',
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
    assert(svgIcon != null || iconData != null);

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