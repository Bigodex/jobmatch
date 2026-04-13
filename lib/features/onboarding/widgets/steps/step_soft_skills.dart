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
// - Validação visual com shared input
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
import 'package:jobmatch/shared/widgets/app_validated_input_field.dart';

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

  bool _validationTriggered = false;

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
        'O primeiro item é fixo para te orientar.',
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

  bool _isTitleValid(String value) {
    return value.trim().length >= 2;
  }

  bool _isDescriptionValid(String value) {
    return value.trim().length >= 10;
  }

  bool _isSkillCompletelyEmpty(int index) {
    return titles[index].text.trim().isEmpty &&
        descriptions[index].text.trim().isEmpty;
  }

  bool _isDuplicateTitleAt(int index) {
    final current = titles[index].text.trim().toLowerCase();
    if (current.isEmpty) return false;

    final occurrences = titles.where((controller) {
      return controller.text.trim().toLowerCase() == current;
    }).length;

    return occurrences > 1;
  }

  bool _titleHasError(int index) {
    if (!_validationTriggered) return false;

    final title = titles[index].text.trim();
    final description = descriptions[index].text.trim();
    final hasAnyContent = title.isNotEmpty || description.isNotEmpty;
    final allSkillsEmpty =
        List.generate(titles.length, (i) => _isSkillCompletelyEmpty(i))
            .every((item) => item);

    if (allSkillsEmpty && index == 0) {
      return true;
    }

    if (!hasAnyContent) {
      return false;
    }

    return title.isEmpty || !_isTitleValid(title) || _isDuplicateTitleAt(index);
  }

  bool _descriptionHasError(int index) {
    if (!_validationTriggered) return false;

    final title = titles[index].text.trim();
    final description = descriptions[index].text.trim();
    final hasAnyContent = title.isNotEmpty || description.isNotEmpty;
    final allSkillsEmpty =
        List.generate(titles.length, (i) => _isSkillCompletelyEmpty(i))
            .every((item) => item);

    if (allSkillsEmpty && index == 0) {
      return true;
    }

    if (!hasAnyContent) {
      return false;
    }

    return description.isEmpty || !_isDescriptionValid(description);
  }

  bool _titleIsValidState(int index) {
    final value = titles[index].text.trim();
    if (value.isEmpty) return false;
    return _isTitleValid(value) && !_isDuplicateTitleAt(index);
  }

  bool _descriptionIsValidState(int index) {
    final value = descriptions[index].text.trim();
    if (value.isEmpty) return false;
    return _isDescriptionValid(value);
  }

  void _handleContinue() {
    setState(() {
      _validationTriggered = true;
    });

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
        'Preencha pelo menos uma habilidade ou clica em pular.',
      );
      return;
    }

    for (final skill in filledSkills) {
      if (skill.title.isEmpty) {
        _showJobuMessage(
          'Preencha o título da habilidade ou remova o item vazio.',
        );
        return;
      }

      if (skill.title.length < 2) {
        _showJobuMessage(
          'O título da habilidade está curto demais.',
        );
        return;
      }

      if (skill.description.isEmpty) {
        _showJobuMessage(
          'Descreva melhor a habilidade "${skill.title}".',
        );
        return;
      }

      if (skill.description.length < 10) {
        _showJobuMessage(
          'A descrição de "${skill.title}" está curta demais.',
        );
        return;
      }
    }

    final normalizedTitles = filledSkills
        .map((e) => e.title.trim().toLowerCase())
        .toList();

    if (normalizedTitles.toSet().length != normalizedTitles.length) {
      _showJobuMessage(
        'Você adicionou habilidades repetidas.',
      );
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

  Widget _skillItem(int index) {
    final isFixedItem = index == 0;
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
                  icon: AppIcons.softskillsitem,
                  label: 'Nome da Habilidade',
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
                    tooltip: isFixedItem ? 'Item fixo' : 'Remover habilidade',
                    onPressed: () => _removeSkill(index),
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
          AppValidatedInputField(
            controller: titles[index],
            hint: 'Ex: Comunicação',
            maxLength: 40,
            hasError: _titleHasError(index),
            isValid: _titleIsValidState(index),
            inputFormatters: [
              SoftSkillTextInputFormatter(),
            ],
            onChanged: (_) {
              widget.onJobuMessageChange(null);
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          _fieldLabel(
            icon: AppIcons.info,
            label: 'Descrição da Habilidade',
          ),
          const SizedBox(height: 8),
          AppValidatedInputField(
            controller: descriptions[index],
            hint: 'Descreva essa habilidade...',
            minLines: 3,
            maxLines: null,
            maxLength: 200,
            textAlign: TextAlign.justify,
            keyboardType: TextInputType.multiline,
            hasError: _descriptionHasError(index),
            isValid: _descriptionIsValidState(index),
            inputFormatters: [
              SoftSkillTextInputFormatter(),
            ],
            onChanged: (_) {
              widget.onJobuMessageChange(null);
              setState(() {});
            },
          ),
        ],
      ),
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
}