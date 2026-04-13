// =======================================================
// STEP IDENTIFICATION
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// CORE
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';

// MODEL
import 'package:jobmatch/features/profile/models/user_document_model.dart';

// SHARED
import 'package:jobmatch/shared/widgets/app_section_card.dart';
import 'package:jobmatch/shared/widgets/app_validated_input_field.dart';

// =======================================================
// CPF FORMATTER
// =======================================================
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    final formatted = _formatCpf(digits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  static String _formatCpf(String digits) {
    if (digits.isEmpty) return '';

    if (digits.length <= 3) {
      return digits;
    } else if (digits.length <= 6) {
      return '${digits.substring(0, 3)}.${digits.substring(3)}';
    } else if (digits.length <= 9) {
      return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6)}';
    } else {
      return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
    }
  }
}

// =======================================================
// DATE FORMATTER
// =======================================================
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 8) {
      digits = digits.substring(0, 8);
    }

    final formatted = _formatDate(digits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  static String _formatDate(String digits) {
    if (digits.isEmpty) return '';

    if (digits.length <= 2) {
      return digits;
    } else if (digits.length <= 4) {
      return '${digits.substring(0, 2)}/${digits.substring(2)}';
    } else {
      return '${digits.substring(0, 2)}/${digits.substring(2, 4)}/${digits.substring(4)}';
    }
  }
}

// =======================================================
// FULL NAME FORMATTER
// =======================================================
class FullNameInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = _toTitleCase(newValue.text);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }

  static String _toTitleCase(String value) {
    if (value.isEmpty) return value;

    final lower = value.toLowerCase();
    final buffer = StringBuffer();
    bool capitalizeNext = true;

    for (int i = 0; i < lower.length; i++) {
      final char = lower[i];

      if (capitalizeNext && RegExp(r'[a-zà-ÿ]').hasMatch(char)) {
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

class StepIdentification extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final Function(String?) onJobuMessageChange;

  const StepIdentification({
    super.key,
    required this.onNext,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepIdentification> createState() =>
      _StepIdentificationState();
}

class _StepIdentificationState extends ConsumerState<StepIdentification> {
  late final TextEditingController fullName;
  late final TextEditingController birthDate;
  late final TextEditingController cpf;
  late final FocusNode _birthDateFocusNode;

  DateTime? _birthDate;

  bool _fullNameHasError = false;
  bool _birthDateHasError = false;
  bool _cpfHasError = false;

  static const Map<String, int> _monthsMap = {
    'janeiro': 1,
    'fevereiro': 2,
    'marco': 3,
    'março': 3,
    'abril': 4,
    'maio': 5,
    'junho': 6,
    'julho': 7,
    'agosto': 8,
    'setembro': 9,
    'outubro': 10,
    'novembro': 11,
    'dezembro': 12,
  };

  @override
  void initState() {
    super.initState();

    final data = ref.read(onboardingProvider);
    final savedUserDocument = data.userDocument;
    final savedCpf = savedUserDocument?.cpf ?? '';

    _birthDate = savedUserDocument != null
        ? savedUserDocument.birthDate
        : data.birthDate;

    _birthDateFocusNode = FocusNode();
    _birthDateFocusNode.addListener(_handleBirthDateFocusChange);

    fullName = TextEditingController(
      text: FullNameInputFormatter._toTitleCase(data.fullName),
    );

    birthDate = TextEditingController(
      text: _birthDate != null ? _formatDateLong(_birthDate!) : '',
    );

    cpf = TextEditingController(text: _formatCpf(savedCpf));
  }

  @override
  void dispose() {
    _birthDateFocusNode.removeListener(_handleBirthDateFocusChange);
    _birthDateFocusNode.dispose();
    fullName.dispose();
    birthDate.dispose();
    cpf.dispose();
    super.dispose();
  }

  void _handleBirthDateFocusChange() {
    if (!mounted) return;

    if (_birthDateFocusNode.hasFocus) {
      _showBirthDateForEditing();
    } else {
      _finalizeBirthDateField();
    }
  }

  void _showBirthDateForEditing() {
    if (_birthDate == null) return;

    final formatted = _formatDateInput(_birthDate!);

    if (birthDate.text == formatted) return;

    birthDate.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  void _finalizeBirthDateField() {
    final rawText = birthDate.text.trim();
    final parsed = _parseBirthDate(rawText);

    setState(() {
      _birthDate = parsed;

      if (_birthDateHasError && rawText.isNotEmpty) {
        _birthDateHasError = parsed == null;
      }
    });

    if (parsed != null) {
      final formatted = _formatDateLong(parsed);

      birthDate.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
        composing: TextRange.empty,
      );

      ref.read(onboardingProvider.notifier).setBirthDate(parsed);
    }

    _syncUserDocument();
  }

  // ===================================================
  // GETTERS DE VALIDAÇÃO
  // ===================================================
  bool get _isFullNameValid => _hasNameAndLastName(fullName.text.trim());
  bool get _isBirthDateValid => _resolveBirthDateFromField() != null;
  bool get _isCpfValid => _hasCompleteCpf(cpf.text);

  // ===================================================
  // FORMAT CPF
  // ===================================================
  String _formatCpf(String value) {
    String digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    return CpfInputFormatter._formatCpf(digits);
  }

  // ===================================================
  // FORMATAR DATA PARA INPUT
  // ===================================================
  String _formatDateInput(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  // ===================================================
  // VALIDAR NOME COMPLETO
  // ===================================================
  bool _hasNameAndLastName(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    return parts.length >= 2;
  }

  // ===================================================
  // VALIDAR CPF COMPLETO
  // ===================================================
  bool _hasCompleteCpf(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length == 11;
  }

  // ===================================================
  // NORMALIZAR TEXTO
  // ===================================================
  String _normalizeText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }

  // ===================================================
  // VALIDAR DATA FINAL
  // ===================================================
  DateTime? _validateDateParts({
    required int day,
    required int month,
    required int year,
  }) {
    if (month < 1 || month > 12) return null;
    if (year < 1950) return null;

    final parsed = DateTime(year, month, day);

    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (parsed.isAfter(today)) return null;

    return parsed;
  }

  // ===================================================
  // PARSE DATA NUMÉRICA
  // ===================================================
  DateTime? _tryParseBirthDateNumeric(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length != 8) return null;

    final day = int.tryParse(digits.substring(0, 2));
    final month = int.tryParse(digits.substring(2, 4));
    final year = int.tryParse(digits.substring(4, 8));

    if (day == null || month == null || year == null) return null;

    return _validateDateParts(
      day: day,
      month: month,
      year: year,
    );
  }

  // ===================================================
  // PARSE DATA POR EXTENSO
  // Ex: 23 de outubro de 1996
  // ===================================================
  DateTime? _tryParseBirthDateLong(String value) {
    final normalized = _normalizeText(value);

    final match = RegExp(
      r'^(\d{1,2})\s+de\s+([a-z]+)\s+de\s+(\d{4})$',
    ).firstMatch(normalized);

    if (match == null) return null;

    final day = int.tryParse(match.group(1) ?? '');
    final monthName = match.group(2) ?? '';
    final year = int.tryParse(match.group(3) ?? '');

    if (day == null || year == null) return null;

    final month = _monthsMap[monthName];
    if (month == null) return null;

    return _validateDateParts(
      day: day,
      month: month,
      year: year,
    );
  }

  // ===================================================
  // PARSE DATA GERAL
  // ===================================================
  DateTime? _parseBirthDate(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;

    final numericParsed = _tryParseBirthDateNumeric(text);
    if (numericParsed != null) return numericParsed;

    final longParsed = _tryParseBirthDateLong(text);
    if (longParsed != null) return longParsed;

    return null;
  }

  DateTime? _resolveBirthDateFromField() {
    final text = birthDate.text.trim();

    if (text.isEmpty) return null;

    final parsed = _parseBirthDate(text);
    if (parsed != null) return parsed;

    return _birthDate;
  }

  // ===================================================
  // SPLIT NOME COMPLETO
  // ===================================================
  Map<String, String> _splitFullName(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return {
        'name': '',
        'lastName': '',
      };
    }

    if (parts.length == 1) {
      return {
        'name': parts.first,
        'lastName': '',
      };
    }

    return {
      'name': parts.first,
      'lastName': parts.sublist(1).join(' '),
    };
  }

  // ===================================================
  // SYNC USER DOCUMENT
  // ===================================================
  void _syncUserDocument() {
    final doc = UserDocumentModel(
      cpf: cpf.text.replaceAll(RegExp(r'[^0-9]'), ''),
      birthDate: _birthDate,
    );

    ref.read(onboardingProvider.notifier).setUserDocument(doc);
  }

  String _formatDateLong(DateTime date) {
    const months = [
      '',
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    return '${date.day} de ${months[date.month]} de ${date.year}';
  }

  // ===================================================
  // CONTINUE
  // ===================================================
  void _continue() {
    final fullNameValue = fullName.text.trim();
    final parsedBirthDate = _resolveBirthDateFromField();

    setState(() {
      _fullNameHasError = !_hasNameAndLastName(fullNameValue);
      _birthDateHasError = parsedBirthDate == null;
      _cpfHasError = !_hasCompleteCpf(cpf.text);
    });

    if (_fullNameHasError) {
      widget.onJobuMessageChange(
        'Digite nome e sobrenome no mesmo campo.',
      );
      return;
    }

    if (_birthDateHasError) {
      widget.onJobuMessageChange(
        'Preciso da sua data de nascimento para continuar!',
      );
      return;
    }

    if (_cpfHasError) {
      widget.onJobuMessageChange(
        'Preciso do número do seu CPF completo!',
      );
      return;
    }

    _birthDate = parsedBirthDate;
    ref.read(onboardingProvider.notifier).setBirthDate(parsedBirthDate!);
    _syncUserDocument();

    final splitName = _splitFullName(fullNameValue);

    ref.read(onboardingProvider.notifier).setName(
          splitName['name'] ?? '',
          splitName['lastName'] ?? '',
        );

    widget.onJobuMessageChange(null);
    widget.onNext();
  }

  // ===================================================
  // BUILD
  // ===================================================
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

                    // HEADER
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.id,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Identificação',
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

                    // NOME COMPLETO
                    _editItem(
                      icon: AppIcons.user,
                      title: 'Nome Completo',
                      child: AppValidatedInputField(
                        controller: fullName,
                        hint: 'Digite seu nome e sobrenome',
                        maxLength: 60,
                        hasError: _fullNameHasError,
                        isValid: _isFullNameValid,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: [
                          FullNameInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (_fullNameHasError) {
                              _fullNameHasError =
                                  !_hasNameAndLastName(value.trim());
                            }
                          });

                          widget.onJobuMessageChange(null);
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // DATA NASCIMENTO
                    _editItem(
                      icon: AppIcons.cake,
                      title: 'Data de Nascimento',
                      child: AppValidatedInputField(
                        controller: birthDate,
                        focusNode: _birthDateFocusNode,
                        hint: 'DD/MM/AAAA',
                        maxLength: _birthDateFocusNode.hasFocus ? 10 : 30,
                        hasError: _birthDateHasError,
                        isValid: _isBirthDateValid,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          DateInputFormatter(),
                        ],
                        onEditingComplete: () {
                          _birthDateFocusNode.unfocus();
                          _finalizeBirthDateField();
                        },
                        onTapOutside: (_) {
                          _birthDateFocusNode.unfocus();
                          _finalizeBirthDateField();
                        },
                        onChanged: (value) {
                          final parsed = _parseBirthDate(value);

                          setState(() {
                            _birthDate = parsed;

                            if (_birthDateHasError) {
                              _birthDateHasError = parsed == null;
                            }
                          });

                          if (parsed != null) {
                            ref
                                .read(onboardingProvider.notifier)
                                .setBirthDate(parsed);
                          }

                          _syncUserDocument();
                          widget.onJobuMessageChange(null);
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // CPF
                    _editItem(
                      icon: AppIcons.id2,
                      title: 'CPF',
                      child: AppValidatedInputField(
                        controller: cpf,
                        hint: 'Digite seu CPF',
                        maxLength: 14,
                        hasError: _cpfHasError,
                        isValid: _isCpfValid,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          CpfInputFormatter(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (_cpfHasError) {
                              _cpfHasError = !_hasCompleteCpf(value);
                            }
                          });

                          _syncUserDocument();
                          widget.onJobuMessageChange(null);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _continue,
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
            SvgPicture.asset(icon, width: 16, height: 16),
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