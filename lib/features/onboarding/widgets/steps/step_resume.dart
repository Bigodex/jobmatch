// =======================================================
// STEP RESUME
// -------------------------------------------------------
// Resumo inicial do perfil no onboarding
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

// =======================================================
// CITY FORMATTER
// =======================================================
class CityInputFormatter extends TextInputFormatter {
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

// =======================================================
// DESCRIPTION FORMATTER
// =======================================================
class ResumeDescriptionInputFormatter extends TextInputFormatter {
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

class StepResume extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Function(String?) onJobuMessageChange;

  const StepResume({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepResume> createState() => _StepResumeState();
}

class _StepResumeState extends ConsumerState<StepResume> {
  late final TextEditingController cityController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();

    final onboarding = ref.read(onboardingProvider);

    cityController = TextEditingController(
      text: onboarding.city != null
          ? CityInputFormatter._toTitleCase(onboarding.city!)
          : '',
    );

    descriptionController = TextEditingController(
      text: onboarding.resumeDescription != null
          ? ResumeDescriptionInputFormatter._capitalizeFirst(
              onboarding.resumeDescription!,
            )
          : '',
    );
  }

  @override
  void dispose() {
    cityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _showJobuMessage(String message) {
    widget.onJobuMessageChange(message);

    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        widget.onJobuMessageChange(null);
      }
    });
  }

  bool _validateCity(String value) {
    return value.trim().length >= 2;
  }

  bool _validateDescription(String value) {
    return value.trim().length >= 10;
  }

  bool _validateAndSave() {
    final city = cityController.text.trim();
    final description = descriptionController.text.trim();

    if (city.isEmpty && description.isEmpty) {
      _showJobuMessage(
        'Você pode preencher seu resumo \nagora ou pular, cê que sabe.',
      );
      return false;
    }

    if (city.isNotEmpty && !_validateCity(city)) {
      _showJobuMessage(
        'Sua cidade precisa ter pelo \nmenos 2 caracteres.',
      );
      return false;
    }

    if (description.isNotEmpty && !_validateDescription(description)) {
      _showJobuMessage(
        'Seu resumo precisa ter pelo \nmenos 10 caracteres.',
      );
      return false;
    }

    widget.onJobuMessageChange(null);

    ref.read(onboardingProvider.notifier).setResume(
          city: city.isEmpty ? null : city,
          description: description.isEmpty ? null : description,
        );

    return true;
  }

  void _handleContinue() {
    final ok = _validateAndSave();
    if (!ok) return;
    widget.onNext();
  }

  void _handleSkip() {
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
                        SvgPicture.asset(AppIcons.cv, width: 20, height: 20),
                        const SizedBox(width: 10),
                        const Text(
                          'Resumo Profissional',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: Colors.white.withOpacity(0.08),
                      height: 1,
                    ),
                    const SizedBox(height: 16),

                    _editItem(
                      icon: AppIcons.building,
                      title: 'Cidade',
                      child: _inputField(
                        controller: cityController,
                        hint: 'Ex: Pato Branco - PR',
                        maxLines: 1,
                        inputFormatters: [
                          CityInputFormatter(),
                        ],
                        onChanged: (_) {
                          widget.onJobuMessageChange(null);
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    _editItem(
                      icon: AppIcons.user,
                      title: 'Resumo Profissional',
                      child: _inputField(
                        controller: descriptionController,
                        hint: 'Fale um pouco sobre você, sua área e objetivo.',
                        maxLines: 5,
                        maxLength: 300,
                        inputFormatters: [
                          ResumeDescriptionInputFormatter(),
                        ],
                        onChanged: (_) {
                          widget.onJobuMessageChange(null);
                        },
                      ),
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

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
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