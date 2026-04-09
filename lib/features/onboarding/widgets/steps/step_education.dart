// =======================================================
// STEP EDUCATION
// -------------------------------------------------------
// Experiências acadêmicas no onboarding
// - Mesmo modelo de experience
// - Labels + ícones acima dos campos
// - Primeiro item fixo, não removível
// - Validações faladas pelo Jobu
// - Sem validação para URL do logo
// - Contadores ocultos
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/features/profile/models/education_model.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

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

class StepEducation extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Function(String?) onJobuMessageChange;

  const StepEducation({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepEducation> createState() => _StepEducationState();
}

class _StepEducationState extends ConsumerState<StepEducation> {
  late List<TextEditingController> institutions;
  late List<TextEditingController> courses;
  late List<TextEditingController> descriptions;
  late List<TextEditingController> logoUrls;

  late List<DateTime> startDates;
  late List<DateTime?> endDates;

  @override
  void initState() {
    super.initState();

    final onboarding = ref.read(onboardingProvider);

    final initialEducations = onboarding.education.isNotEmpty
        ? onboarding.education
        : [
            EducationModel(
              institution: '',
              course: '',
              description: '',
              startDate: DateTime.now(),
              endDate: null,
              logoUrl: null,
            ),
          ];

    institutions = initialEducations
        .map(
          (e) => TextEditingController(
            text: EducationTitleInputFormatter._toTitleCase(e.institution),
          ),
        )
        .toList();

    courses = initialEducations
        .map(
          (e) => TextEditingController(
            text: EducationTitleInputFormatter._toTitleCase(e.course),
          ),
        )
        .toList();

    descriptions = initialEducations
        .map(
          (e) => TextEditingController(
            text: EducationDescriptionInputFormatter._capitalizeFirst(
              e.description,
            ),
          ),
        )
        .toList();

    logoUrls = initialEducations
        .map((e) => TextEditingController(text: e.logoUrl ?? ''))
        .toList();

    startDates = initialEducations.map((e) => e.startDate).toList();
    endDates = initialEducations.map((e) => e.endDate).toList();

    for (final controller in institutions) {
      controller.addListener(_handleFieldChanged);
    }

    for (final controller in courses) {
      controller.addListener(_handleFieldChanged);
    }

    for (final controller in descriptions) {
      controller.addListener(_handleFieldChanged);
    }

    for (final controller in logoUrls) {
      controller.addListener(_handleFieldChanged);
    }
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

    for (final controller in logoUrls) {
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

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  List<EducationModel> _buildEducations() {
    return List.generate(
      institutions.length,
      (index) => EducationModel(
        institution: institutions[index].text.trim(),
        course: courses[index].text.trim(),
        description: descriptions[index].text.trim(),
        startDate: startDates[index],
        endDate: endDates[index],
        logoUrl: logoUrls[index].text.trim().isEmpty
            ? null
            : logoUrls[index].text.trim(),
      ),
    );
  }

  void _sync() {
    ref.read(onboardingProvider.notifier).setEducation(
          _buildEducations(),
        );
  }

  Future<void> _pickStartDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDates[index],
      firstDate: DateTime(1980),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked == null) return;

    setState(() {
      startDates[index] = picked;

      if (endDates[index] != null && endDates[index]!.isBefore(picked)) {
        endDates[index] = null;
      }
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  Future<void> _pickEndDate(int index) async {
    final initialDate = endDates[index] ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1980),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked == null) return;

    if (picked.isBefore(startDates[index])) {
      _showJobuMessage(
        'A data de fim não pode ser antes da data de início.',
      );
      return;
    }

    setState(() {
      endDates[index] = picked;
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  void _toggleCurrentStudy(int index, bool value) {
    setState(() {
      if (value) {
        endDates[index] = null;
      }
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  void _addEducation() {
    final institutionController = TextEditingController();
    final courseController = TextEditingController();
    final descriptionController = TextEditingController();
    final logoController = TextEditingController();

    institutionController.addListener(_handleFieldChanged);
    courseController.addListener(_handleFieldChanged);
    descriptionController.addListener(_handleFieldChanged);
    logoController.addListener(_handleFieldChanged);

    setState(() {
      institutions.add(institutionController);
      courses.add(courseController);
      descriptions.add(descriptionController);
      logoUrls.add(logoController);
      startDates.add(DateTime.now());
      endDates.add(null);
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  void _removeEducation(int index) {
    if (index == 0) {
      _showJobuMessage(
        'O primeiro item é fixo para te orientar.',
      );
      return;
    }

    institutions[index].dispose();
    courses[index].dispose();
    descriptions[index].dispose();
    logoUrls[index].dispose();

    setState(() {
      institutions.removeAt(index);
      courses.removeAt(index);
      descriptions.removeAt(index);
      logoUrls.removeAt(index);
      startDates.removeAt(index);
      endDates.removeAt(index);
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  void _handleContinue() {
    final rawEducations = List.generate(
      institutions.length,
      (index) => EducationModel(
        institution: institutions[index].text.trim(),
        course: courses[index].text.trim(),
        description: descriptions[index].text.trim(),
        startDate: startDates[index],
        endDate: endDates[index],
        logoUrl: logoUrls[index].text.trim().isEmpty
            ? null
            : logoUrls[index].text.trim(),
      ),
    );

    final filledEducations = rawEducations.where((item) {
      return item.institution.isNotEmpty ||
          item.course.isNotEmpty ||
          item.description.isNotEmpty ||
          (item.logoUrl?.isNotEmpty ?? false);
    }).toList();

    if (filledEducations.isEmpty) {
      _showJobuMessage(
        'Preencha pelo menos uma experiência acadêmica \nou clique em pular.',
      );
      return;
    }

    for (final item in filledEducations) {
      if (item.institution.isEmpty) {
        _showJobuMessage('Preencha a instituição ou remova o item vazio.');
        return;
      }

      if (item.institution.length < 2) {
        _showJobuMessage('O nome da instituição está curto demais.');
        return;
      }

      if (item.course.isEmpty) {
        _showJobuMessage(
          'Preencha o curso da experiência acadêmica ${item.institution}.',
        );
        return;
      }

      if (item.course.length < 2) {
        _showJobuMessage(
          'O curso da experiência acadêmica ${item.institution} está curto demais.',
        );
        return;
      }

      if (item.description.isEmpty) {
        _showJobuMessage(
          'Descreva sua formação em ${item.institution}.',
        );
        return;
      }

      if (item.description.length < 10) {
        _showJobuMessage(
          'A descrição de ${item.institution} está curta demais.',
        );
        return;
      }

      if (item.endDate != null && item.endDate!.isBefore(item.startDate)) {
        _showJobuMessage(
          'A data de fim de ${item.institution} não pode ser antes do início.',
        );
        return;
      }
    }

    ref.read(onboardingProvider.notifier).setEducation(filledEducations);
    widget.onJobuMessageChange(null);
    widget.onNext();
  }

  void _handleSkip() {
    ref.read(onboardingProvider.notifier).setEducation([]);
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
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(
                          Icons.school_outlined,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Experiências Acadêmicas',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      color: theme.dividerColor.withOpacity(0.2),
                    ),
                    const SizedBox(height: 12),
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
                      label: const Text('Adicionar experiência acadêmica'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _handleSkip,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.3),
                              ),
                              foregroundColor: theme.colorScheme.primary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
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

  Widget _educationItem(int index) {
    Theme.of(context);
    final isFixedItem = index == 0;
    final isCurrent = endDates[index] == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.school_outlined,
                  size: 16,
                ),
                SizedBox(width: 10),
                Text(
                  'Experiência Acadêmica',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Opacity(
              opacity: isFixedItem ? 0.35 : 1,
              child: IconButton(
                onPressed: () => _removeEducation(index),
                icon: const Icon(Icons.delete, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        _fieldLabel(
          icon: AppIcons.building,
          label: 'Instituição',
        ),
        const SizedBox(height: 8),
        _inputField(
          controller: institutions[index],
          hint: 'Instituição (ex: UTFPR)',
          maxLength: 80,
          inputFormatters: [
            EducationTitleInputFormatter(),
          ],
        ),

        const SizedBox(height: 12),

        _fieldLabel(
          icon: AppIcons.role,
          label: 'Curso',
        ),
        const SizedBox(height: 8),
        _inputField(
          controller: courses[index],
          hint: 'Curso (ex: Análise e Desenvolvimento de Sistemas)',
          maxLength: 100,
          inputFormatters: [
            EducationTitleInputFormatter(),
          ],
        ),

        const SizedBox(height: 12),

        _fieldLabel(
          icon: AppIcons.info,
          label: 'Descrição',
        ),
        const SizedBox(height: 8),
        _inputField(
          controller: descriptions[index],
          hint: 'Descreva sua formação...',
          minLines: 3,
          maxLength: 300,
          inputFormatters: [
            EducationDescriptionInputFormatter(),
          ],
        ),

        const SizedBox(height: 12),

        _fieldLabel(
          materialIcon: Icons.calendar_month_outlined,
          label: 'Período',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _dateButton(
                label: 'Início',
                value: _formatDate(startDates[index]),
                onTap: () => _pickStartDate(index),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _dateButton(
                label: 'Fim',
                value: isCurrent
                    ? 'Cursando'
                    : _formatDate(endDates[index]!),
                onTap: isCurrent ? null : () => _pickEndDate(index),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Checkbox(
              value: isCurrent,
              onChanged: (value) {
                _toggleCurrentStudy(index, value ?? false);
              },
            ),
            const Expanded(
              child: Text(
                'Ainda estou cursando',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),

        if (!isCurrent) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _pickEndDate(index),
              icon: const Icon(Icons.edit_calendar_outlined, size: 18),
              label: const Text('Alterar data de fim'),
            ),
          ),
        ],

        const SizedBox(height: 12),

        _fieldLabel(
          icon: AppIcons.hashtag,
          label: 'URL do Logo',
        ),
        const SizedBox(height: 8),
        _inputField(
          controller: logoUrls[index],
          hint: 'URL do logo (opcional)',
          maxLength: 200,
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _fieldLabel({
    String? icon,
    IconData? materialIcon,
    required String label,
  }) {
    return Row(
      children: [
        if (icon != null)
          SvgPicture.asset(
            icon,
            width: 16,
            height: 16,
          )
        else if (materialIcon != null)
          Icon(
            materialIcon,
            size: 16,
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

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    int? minLines,
    required int maxLength,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      minLines: minLines ?? 1,
      maxLines: null,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
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
      onChanged: (_) {
        widget.onJobuMessageChange(null);
        setState(() {});
      },
    );
  }

  Widget _dateButton({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: onTap == null
                ? Colors.white12
                : Colors.white24,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.65),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: onTap == null
                    ? Colors.white.withOpacity(0.75)
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}