// =======================================================
// EDIT SOFT SKILLS SCREEN
// -------------------------------------------------------
// Agora no mesmo padrão do StepSoftSkills:
// - Labels + ícones sobre os campos
// - AppValidatedInputField
// - Primeiro item fixo
// - Título em Title Case
// - Descrição com primeira letra maiúscula
// - Remove itens extras
// - Validação por campo
// - Salva apenas itens preenchidos
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/utils/validators.dart';

import 'package:jobmatch/features/profile/models/soft_skill_model.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';
import 'package:jobmatch/features/profile/screens/success_screen.dart';

import 'package:jobmatch/shared/widgets/app_header.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';
import 'package:jobmatch/shared/widgets/app_validated_input_field.dart';

// =======================================================
// FORMATTER DO TÍTULO
// -------------------------------------------------------
// Mantém cada palavra iniciando com maiúscula
// =======================================================
class SoftSkillTitleInputFormatter extends TextInputFormatter {
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
// FORMATTER DA DESCRIÇÃO
// -------------------------------------------------------
// Apenas a primeira letra do texto fica maiúscula
// =======================================================
class SoftSkillDescriptionInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = _toSentenceCase(newValue.text);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  static String _toSentenceCase(String value) {
    if (value.isEmpty) return value;

    final lower = value.toLowerCase();
    final chars = lower.split('');

    for (int i = 0; i < chars.length; i++) {
      if (RegExp(r'[a-zà-ÿA-ZÀ-Ÿ]').hasMatch(chars[i])) {
        chars[i] = chars[i].toUpperCase();
        break;
      }
    }

    return chars.join();
  }
}

class EditSoftSkillsScreen extends ConsumerStatefulWidget {
  final List<SoftSkillModel> skills;

  const EditSoftSkillsScreen({
    super.key,
    required this.skills,
  });

  @override
  ConsumerState<EditSoftSkillsScreen> createState() =>
      _EditSoftSkillsScreenState();
}

class _EditSoftSkillsScreenState
    extends ConsumerState<EditSoftSkillsScreen> {
  late List<TextEditingController> titles;
  late List<TextEditingController> descriptions;

  bool _validationTriggered = false;
  bool _hasChanged = false;
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final initialSkills = widget.skills.isNotEmpty
        ? widget.skills
        : [
            SoftSkillModel(
              title: '',
              description: '',
            ),
          ];

    titles = initialSkills
        .map(
          (e) => TextEditingController(
            text: SoftSkillTitleInputFormatter._toTitleCase(e.title),
          ),
        )
        .toList();

    descriptions = initialSkills
        .map(
          (e) => TextEditingController(
            text: SoftSkillDescriptionInputFormatter._toSentenceCase(
              e.description,
            ),
          ),
        )
        .toList();

    for (final t in titles) {
      t.addListener(_handleFieldChanged);
    }

    for (final d in descriptions) {
      d.addListener(_handleFieldChanged);
    }

    _recalculateState();
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
    _errorMessage = null;
    _recalculateState();
  }

  void _recalculateState() {
    final sanitized = _buildSanitizedSkills();

    _hasChanged = AppValidators.hasSoftSkillsChanged(
      widget.skills,
      sanitized,
    );

    if (mounted) {
      setState(() {});
    }
  }

  List<SoftSkillModel> _buildRawSkills() {
    return List.generate(
      titles.length,
      (index) => SoftSkillModel(
        title: titles[index].text.trim(),
        description: descriptions[index].text.trim(),
      ),
    );
  }

  List<SoftSkillModel> _buildSanitizedSkills() {
    final raw = _buildRawSkills();

    return raw
        .where(
          (skill) => skill.title.isNotEmpty || skill.description.isNotEmpty,
        )
        .toList();
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

    _recalculateState();
  }

  void _removeSkill(int index) {
    if (index == 0) {
      setState(() {
        _validationTriggered = true;
        _errorMessage = 'O primeiro item é fixo para te orientar.';
      });
      return;
    }

    titles[index].dispose();
    descriptions[index].dispose();

    setState(() {
      titles.removeAt(index);
      descriptions.removeAt(index);
      _errorMessage = null;
    });

    _recalculateState();
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

  String? _buildValidationMessage() {
    final rawSkills = _buildRawSkills();

    final filledSkills = rawSkills
        .where(
          (skill) => skill.title.isNotEmpty || skill.description.isNotEmpty,
        )
        .toList();

    if (filledSkills.isEmpty) {
      return 'Preencha pelo menos uma habilidade.';
    }

    for (final skill in filledSkills) {
      if (skill.title.isEmpty) {
        return 'Preencha o título da habilidade ou remova o item vazio.';
      }

      if (skill.title.length < 2) {
        return 'O título da habilidade está curto demais.';
      }

      if (skill.description.isEmpty) {
        return 'Descreva melhor a habilidade "${skill.title}".';
      }

      if (skill.description.length < 10) {
        return 'A descrição de "${skill.title}" está curta demais.';
      }
    }

    final normalizedTitles = filledSkills
        .map((e) => e.title.trim().toLowerCase())
        .toList();

    if (normalizedTitles.toSet().length != normalizedTitles.length) {
      return 'Você adicionou habilidades repetidas.';
    }

    final validatorError = AppValidators.validateSoftSkills(filledSkills);
    if (validatorError != null) {
      return validatorError;
    }

    return null;
  }

  Future<void> _save() async {
    setState(() {
      _validationTriggered = true;
      _errorMessage = null;
    });

    final validationMessage = _buildValidationMessage();

    if (validationMessage != null) {
      setState(() {
        _errorMessage = validationMessage;
      });
      return;
    }

    final updated = _buildSanitizedSkills();

    try {
      setState(() {
        _isSaving = true;
      });

      await ref
          .read(profileProvider.notifier)
          .updateSoftSkills(updated)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              throw Exception('Tempo limite ao salvar.');
            },
          );

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
              SoftSkillTitleInputFormatter(),
            ],
            onChanged: (_) {
              _errorMessage = null;
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
              SoftSkillDescriptionInputFormatter(),
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