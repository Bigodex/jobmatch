// =======================================================
// STEP EXPERIENCE
// -------------------------------------------------------
// Experiências no onboarding
// - Mesmo modelo de soft/hard skills
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
import 'package:jobmatch/features/profile/models/experience_model.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

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
  late List<TextEditingController> companies;
  late List<TextEditingController> roles;
  late List<TextEditingController> descriptions;
  late List<TextEditingController> logoUrls;

  late List<DateTime> startDates;
  late List<DateTime?> endDates;

  @override
  void initState() {
    super.initState();

    final onboarding = ref.read(onboardingProvider);

    final initialExperiences = onboarding.experiences.isNotEmpty
        ? onboarding.experiences
        : [
            ExperienceModel(
              company: '',
              role: '',
              description: '',
              startDate: DateTime.now(),
              endDate: null,
              logoUrl: null,
            ),
          ];

    companies = initialExperiences
        .map(
          (e) => TextEditingController(
            text: ExperienceTitleInputFormatter._toTitleCase(e.company),
          ),
        )
        .toList();

    roles = initialExperiences
        .map(
          (e) => TextEditingController(
            text: ExperienceTitleInputFormatter._toTitleCase(e.role),
          ),
        )
        .toList();

    descriptions = initialExperiences
        .map(
          (e) => TextEditingController(
            text: ExperienceDescriptionInputFormatter._capitalizeFirst(
              e.description,
            ),
          ),
        )
        .toList();

    logoUrls = initialExperiences
        .map((e) => TextEditingController(text: e.logoUrl ?? ''))
        .toList();

    startDates = initialExperiences.map((e) => e.startDate).toList();
    endDates = initialExperiences.map((e) => e.endDate).toList();

    for (final controller in companies) {
      controller.addListener(_handleFieldChanged);
    }

    for (final controller in roles) {
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
    for (final controller in companies) {
      controller.dispose();
    }

    for (final controller in roles) {
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

  List<ExperienceModel> _buildExperiences() {
    return List.generate(
      companies.length,
      (index) => ExperienceModel(
        company: companies[index].text.trim(),
        role: roles[index].text.trim(),
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
    ref.read(onboardingProvider.notifier).setExperiences(
          _buildExperiences(),
        );
  }

  void _addExperience() {
    final companyController = TextEditingController();
    final roleController = TextEditingController();
    final descriptionController = TextEditingController();
    final logoController = TextEditingController();

    companyController.addListener(_handleFieldChanged);
    roleController.addListener(_handleFieldChanged);
    descriptionController.addListener(_handleFieldChanged);
    logoController.addListener(_handleFieldChanged);

    setState(() {
      companies.add(companyController);
      roles.add(roleController);
      descriptions.add(descriptionController);
      logoUrls.add(logoController);
      startDates.add(DateTime.now());
      endDates.add(null);
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  void _removeExperience(int index) {
    if (index == 0) {
      _showJobuMessage(
        'O primeiro item é fixo para te orientar.',
      );
      return;
    }

    companies[index].dispose();
    roles[index].dispose();
    descriptions[index].dispose();
    logoUrls[index].dispose();

    setState(() {
      companies.removeAt(index);
      roles.removeAt(index);
      descriptions.removeAt(index);
      logoUrls.removeAt(index);
      startDates.removeAt(index);
      endDates.removeAt(index);
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  void _handleContinue() {
    final rawExperiences = List.generate(
      companies.length,
      (index) => ExperienceModel(
        company: companies[index].text.trim(),
        role: roles[index].text.trim(),
        description: descriptions[index].text.trim(),
        startDate: startDates[index],
        endDate: endDates[index],
        logoUrl: logoUrls[index].text.trim().isEmpty
            ? null
            : logoUrls[index].text.trim(),
      ),
    );

    final filledExperiences = rawExperiences.where((item) {
      return item.company.isNotEmpty ||
          item.role.isNotEmpty ||
          item.description.isNotEmpty ||
          (item.logoUrl?.isNotEmpty ?? false);
    }).toList();

    if (filledExperiences.isEmpty) {
      _showJobuMessage(
        'Preencha pelo menos uma experiência \nou clique em pular.',
      );
      return;
    }

    for (final item in filledExperiences) {
      if (item.company.isEmpty) {
        _showJobuMessage('Preencha a empresa ou remova o item vazio.');
        return;
      }

      if (item.company.length < 2) {
        _showJobuMessage('O nome da empresa está curto demais.');
        return;
      }

      if (item.role.isEmpty) {
        _showJobuMessage('Preencha o cargo da experiência ${item.company}.');
        return;
      }

      if (item.role.length < 2) {
        _showJobuMessage(
          'O cargo da experiência ${item.company} está curto demais.',
        );
        return;
      }

      if (item.description.isEmpty) {
        _showJobuMessage('Descreva sua atuação em ${item.company}.');
        return;
      }

      if (item.description.length < 10) {
        _showJobuMessage('A descrição de ${item.company} está curta demais.');
        return;
      }
    }

    ref.read(onboardingProvider.notifier).setExperiences(filledExperiences);
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
                            fontSize: 16
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

  Widget _experienceItem(int index) {
    final isFixedItem = index == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  AppIcons.briefcase,
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Experiência',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Opacity(
              opacity: isFixedItem ? 0.35 : 1,
              child: IconButton(
                onPressed: () => _removeExperience(index),
                icon: const Icon(Icons.delete, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        _fieldLabel(
          icon: AppIcons.building,
          label: 'Empresa',
        ),
        const SizedBox(height: 8),
        _inputField(
          controller: companies[index],
          hint: 'Empresa (ex: Google)',
          maxLength: 60,
          inputFormatters: [
            ExperienceTitleInputFormatter(),
          ],
        ),

        const SizedBox(height: 12),

        _fieldLabel(
          icon: AppIcons.role,
          label: 'Cargo',
        ),
        const SizedBox(height: 8),
        _inputField(
          controller: roles[index],
          hint: 'Cargo (ex: Desenvolvedor)',
          maxLength: 60,
          inputFormatters: [
            ExperienceTitleInputFormatter(),
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
          hint: 'Descreva sua atuação...',
          minLines: 3,
          maxLength: 300,
          inputFormatters: [
            ExperienceDescriptionInputFormatter(),
          ],
        ),

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
    required String icon,
    required String label,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 16,
          height: 16,
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
}