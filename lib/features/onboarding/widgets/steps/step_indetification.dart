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
  late final TextEditingController cpf;

  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();

    final data = ref.read(onboardingProvider);
    final savedCpf = data.userDocument?.cpf ?? '';

    fullName = TextEditingController(
      text: FullNameInputFormatter._toTitleCase(data.fullName),
    );
    cpf = TextEditingController(text: _formatCpf(savedCpf));
    _birthDate = data.userDocument?.birthDate ?? data.birthDate;
  }

  @override
  void dispose() {
    fullName.dispose();
    cpf.dispose();
    super.dispose();
  }

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

  // ===================================================
  // DATE PICKER
  // ===================================================
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _birthDate = picked);

      ref.read(onboardingProvider.notifier).setBirthDate(picked);
      _syncUserDocument();
      widget.onJobuMessageChange(null);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    return '${date.day} de ${months[date.month]} de ${date.year}';
  }

  // ===================================================
  // CONTINUE
  // ===================================================
  void _continue() {
    final fullNameValue = fullName.text.trim();

    if (!_hasNameAndLastName(fullNameValue)) {
      widget.onJobuMessageChange(
        'Digite nome e sobrenome no \nmesmo campo.',
      );
      return;
    }

    if (_birthDate == null) {
      widget.onJobuMessageChange(
        'Preciso da sua data de \nnascimento para continuar!',
      );
      return;
    }

    if (!_hasCompleteCpf(cpf.text)) {
      widget.onJobuMessageChange(
        'Preciso do número do seu \nCPF completo!',
      );
      return;
    }

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
                      child: _inputField(
                        controller: fullName,
                        hint: 'Digite seu nome e sobrenome',
                        maxLength: 60,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: [
                          FullNameInputFormatter(),
                        ],
                        onChanged: (_) {
                          widget.onJobuMessageChange(null);
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // DATA NASCIMENTO
                    _editItem(
                      icon: AppIcons.calendar,
                      title: 'Data de Nascimento',
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            _birthDate == null
                                ? 'Selecionar data'
                                : _formatDate(_birthDate!),
                            style: TextStyle(
                              fontSize: 13,
                              color: _birthDate == null
                                  ? Colors.white54
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // CPF
                    _editItem(
                      icon: AppIcons.id2,
                      title: 'CPF',
                      child: _inputField(
                        controller: cpf,
                        hint: 'Digite seu CPF',
                        maxLength: 14,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          CpfInputFormatter(),
                        ],
                        onChanged: (_) {
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

  // ===================================================
  // INPUT PADRÃO
  // ===================================================
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required int maxLength,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      onChanged: (value) {
        setState(() {});
        onChanged?.call(value);
      },
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
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