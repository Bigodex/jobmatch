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

  DateTime? _birthDate;

  bool _fullNameHasError = false;
  bool _birthDateHasError = false;
  bool _cpfHasError = false;

  @override
  void initState() {
    super.initState();

    final data = ref.read(onboardingProvider);
    final savedUserDocument = data.userDocument;
    final savedCpf = savedUserDocument?.cpf ?? '';

    _birthDate = savedUserDocument != null
        ? savedUserDocument.birthDate
        : data.birthDate;

    fullName = TextEditingController(
      text: FullNameInputFormatter._toTitleCase(data.fullName),
    );

    birthDate = TextEditingController(
      text: _birthDate != null ? _formatDateInput(_birthDate!) : '',
    );

    cpf = TextEditingController(text: _formatCpf(savedCpf));
  }

  @override
  void dispose() {
    fullName.dispose();
    birthDate.dispose();
    cpf.dispose();
    super.dispose();
  }

  // ===================================================
  // GETTERS DE VALIDAÇÃO
  // ===================================================
  bool get _isFullNameValid => _hasNameAndLastName(fullName.text.trim());
  bool get _isBirthDateValid => _tryParseBirthDate(birthDate.text) != null;
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
  // PARSE DATA
  // ===================================================
  DateTime? _tryParseBirthDate(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length != 8) return null;

    final day = int.tryParse(digits.substring(0, 2));
    final month = int.tryParse(digits.substring(2, 4));
    final year = int.tryParse(digits.substring(4, 8));

    if (day == null || month == null || year == null) return null;
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

  String _formatDate(DateTime date) {
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
    final parsedBirthDate = _tryParseBirthDate(birthDate.text);

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppValidatedInputField(
                            controller: birthDate,
                            hint: 'DD/MM/AAAA',
                            maxLength: 10,
                            hasError: _birthDateHasError,
                            isValid: _isBirthDateValid,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              DateInputFormatter(),
                            ],
                            onChanged: (value) {
                              final parsed = _tryParseBirthDate(value);

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
                          if (_birthDate != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _formatDate(_birthDate!),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.72),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
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