// =======================================================
// STEP SOFT SKILLS
// -------------------------------------------------------
// Soft skills no onboarding
// - Layout baseado na tela de edição
// - Item com título + descrição
// - Remove input único com botão +
// - Corrigido erro de modificação de provider no initState
// - Validações faladas pelo Jobu
// - Título e descrição começando com letra maiúscula
// - Labels + ícones sobre os campos
// - Contadores ocultos
// - Primeiro item fixo, não removível
// - Não permite continuar sem preencher ao menos uma habilidade
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/features/profile/models/soft_skill_model.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

// =======================================================
// TITLE / DESCRIPTION FORMATTER
// =======================================================
class SoftSkillTextInputFormatter extends TextInputFormatter {
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

class StepSoftSkills extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Function(String?) onJobuMessageChange;

  const StepSoftSkills({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepSoftSkills> createState() => _StepSoftSkillsState();
}

class _StepSoftSkillsState extends ConsumerState<StepSoftSkills> {
  late List<TextEditingController> titles;
  late List<TextEditingController> descriptions;

  @override
  void initState() {
    super.initState();

    final onboarding = ref.read(onboardingProvider);

    final initialSkills = onboarding.softSkills.isNotEmpty
        ? onboarding.softSkills
        : [
            SoftSkillModel(
              title: '',
              description: '',
            ),
          ];

    titles = initialSkills
        .map(
          (e) => TextEditingController(
            text: SoftSkillTextInputFormatter._toTitleCase(e.title),
          ),
        )
        .toList();

    descriptions = initialSkills
        .map(
          (e) => TextEditingController(
            text: SoftSkillTextInputFormatter._toTitleCase(e.description),
          ),
        )
        .toList();

    for (final t in titles) {
      t.addListener(_handleFieldChanged);
    }

    for (final d in descriptions) {
      d.addListener(_handleFieldChanged);
    }
  }

  @override
  void dispose() {
    for (final t in titles) {
      t.dispose();
    }

    for (final d in descriptions) {
      d.dispose();
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

  List<SoftSkillModel> _buildSkills() {
    return List.generate(
      titles.length,
      (index) => SoftSkillModel(
        title: titles[index].text.trim(),
        description: descriptions[index].text.trim(),
      ),
    );
  }

  void _sync() {
    ref.read(onboardingProvider.notifier).setSoftSkills(_buildSkills());
  }

  void _addSkill() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    titleController.addListener(_handleFieldChanged);
    descriptionController.addListener(_handleFieldChanged);

    setState(() {
      titles.add(titleController);
      descriptions.add(descriptionController);
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  void _removeSkill(int index) {
    if (index == 0) {
      _showJobuMessage(
        'O primeiro item é fixo para \nte orientar.',
      );
      return;
    }

    titles[index].dispose();
    descriptions[index].dispose();

    setState(() {
      titles.removeAt(index);
      descriptions.removeAt(index);
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  void _handleContinue() {
    final rawSkills = List.generate(
      titles.length,
      (index) => SoftSkillModel(
        title: titles[index].text.trim(),
        description: descriptions[index].text.trim(),
      ),
    );

    final filledSkills = rawSkills
        .where(
          (skill) => skill.title.isNotEmpty || skill.description.isNotEmpty,
        )
        .toList();

    if (filledSkills.isEmpty) {
      _showJobuMessage(
        'Preencha pelo menos uma \nhabilidade ou clica em pular.',
      );
      return;
    }

    for (final skill in filledSkills) {
      if (skill.title.isEmpty) {
        _showJobuMessage(
          'Preencha o título da habilidade \nou remova o item vazio.',
        );
        return;
      }

      if (skill.title.length < 2) {
        _showJobuMessage('O título da habilidade está \ncurto demais.');
        return;
      }

      if (skill.description.isEmpty) {
        _showJobuMessage('Descreva melhor a habilidade \n"${skill.title}".');
        return;
      }

      if (skill.description.length < 10) {
        _showJobuMessage(
          'A descrição de "${skill.title}" \nestá curta demais.',
        );
        return;
      }
    }

    final normalizedTitles = filledSkills
        .map((e) => e.title.trim().toLowerCase())
        .toList();

    if (normalizedTitles.toSet().length != normalizedTitles.length) {
      _showJobuMessage('Você adicionou habilidades \nrepetidas.');
      return;
    }

    ref.read(onboardingProvider.notifier).setSoftSkills(filledSkills);
    widget.onJobuMessageChange(null);
    widget.onNext();
  }

  void _handleSkip() {
    ref.read(onboardingProvider.notifier).setSoftSkills([]);
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
                          AppIcons.softskills,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Habilidades Comportamentais',
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
                    if (titles.isNotEmpty)
                      Column(
                        children: List.generate(titles.length, (index) {
                          return Column(
                            children: [
                              _skillItem(index),
                              if (index != titles.length - 1)
                                Divider(
                                  height: 24,
                                  color: theme.dividerColor.withOpacity(0.2),
                                ),
                            ],
                          );
                        }),
                      ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _addSkill,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar habilidade'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _handleSkip,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: theme.colorScheme.primary.withOpacity(1.0),
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

  Widget _skillItem(int index) {
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
                  AppIcons.softskills,
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Habilidade',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Opacity(
              opacity: isFixedItem ? 0.35 : 1,
              child: IconButton(
                onPressed: () => _removeSkill(index),
                icon: const Icon(Icons.delete, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        _fieldLabel(
          icon: AppIcons.softskillsitem,
          label: 'Nome da Habilidade',
        ),
        const SizedBox(height: 8),
        _inputField(
          controller: titles[index],
          hint: 'Ex: Comunicação',
          maxLength: 40,
          inputFormatters: [
            SoftSkillTextInputFormatter(),
          ],
        ),

        const SizedBox(height: 12),

        _fieldLabel(
          icon: AppIcons.info,
          label: 'Descrição da Habilidade',
        ),
        const SizedBox(height: 8),
        _inputField(
          controller: descriptions[index],
          hint: 'Descreva essa habilidade...',
          minLines: 3,
          maxLength: 200,
          textAlign: TextAlign.justify,
          inputFormatters: [
            SoftSkillTextInputFormatter(),
          ],
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
    TextAlign textAlign = TextAlign.start,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      minLines: minLines ?? 1,
      maxLines: null,
      maxLength: maxLength,
      keyboardType: TextInputType.multiline,
      textAlign: textAlign,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
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