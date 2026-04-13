// =======================================================
// EDIT HARD SKILLS SCREEN
// -------------------------------------------------------
// Agora no mesmo padrão do StepHardSkills:
// - Labels + ícones acima dos campos
// - AppValidatedInputField
// - Primeiro item fixo
// - Slider igual ao onboarding
// - Tags com validação
// - Não salva com tag pendente
// - Não salva habilidade sem tag
// - Não salva título duplicado
// - Salva apenas itens preenchidos
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/utils/validators.dart';

import 'package:jobmatch/features/profile/models/tech_skill_model.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';
import 'package:jobmatch/features/profile/screens/success_screen.dart';

import 'package:jobmatch/shared/widgets/app_header.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';
import 'package:jobmatch/shared/widgets/app_validated_input_field.dart';

// =======================================================
// TEXT FORMATTER
// =======================================================
class TechSkillTextInputFormatter extends TextInputFormatter {
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

class EditHardSkillsScreen extends ConsumerStatefulWidget {
  final List<TechSkillModel> skills;

  const EditHardSkillsScreen({
    super.key,
    required this.skills,
  });

  @override
  ConsumerState<EditHardSkillsScreen> createState() =>
      _EditHardSkillsScreenState();
}

class _EditHardSkillsScreenState
    extends ConsumerState<EditHardSkillsScreen> {
  late List<TextEditingController> titles;
  late List<double> levels;
  late List<List<String>> tools;
  late List<TextEditingController> tagControllers;

  bool _validationTriggered = false;
  bool _hasChanged = false;
  bool _isSaving = false;
  String? _errorMessage;

  Set<int> _tagAddValidationIndexes = {};
  Set<int> _pendingTagIndexes = {};

  @override
  void initState() {
    super.initState();

    final initialSkills = widget.skills.isNotEmpty
        ? widget.skills
        : [
            TechSkillModel(
              title: '',
              level: 50,
              tools: const [],
            ),
          ];

    titles = initialSkills
        .map(
          (e) => TextEditingController(
            text: TechSkillTextInputFormatter._toTitleCase(e.title),
          ),
        )
        .toList();

    levels = initialSkills
        .map((e) => e.level < 25 ? 25.0 : e.level.toDouble())
        .toList();

    tools = initialSkills.map((e) => List<String>.from(e.tools)).toList();

    tagControllers = List.generate(
      initialSkills.length,
      (_) => TextEditingController(),
    );

    for (final controller in titles) {
      controller.addListener(_handleFieldChanged);
    }

    for (final controller in tagControllers) {
      controller.addListener(_handleFieldChanged);
    }

    _recalculateState();
  }

  @override
  void dispose() {
    for (final controller in titles) {
      controller.dispose();
    }

    for (final controller in tagControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _handleFieldChanged() {
    _errorMessage = null;
    _recalculateState();
  }

  void _recalculateState() {
    final sanitized = _buildSanitizedSkills();

    _hasChanged = AppValidators.hasHardSkillsChanged(
      widget.skills,
      sanitized,
    );

    if (mounted) {
      setState(() {});
    }
  }

  List<TechSkillModel> _buildRawSkills() {
    return List.generate(
      titles.length,
      (index) => TechSkillModel(
        title: titles[index].text.trim(),
        level: levels[index].toInt(),
        tools: List<String>.from(tools[index]),
      ),
    );
  }

  List<TechSkillModel> _buildSanitizedSkills() {
    final raw = _buildRawSkills();

    return raw
        .where(
          (skill) => skill.title.isNotEmpty || skill.tools.isNotEmpty,
        )
        .toList();
  }

  void _addSkill() {
    final titleController = TextEditingController();
    final tagController = TextEditingController();

    titleController.addListener(_handleFieldChanged);
    tagController.addListener(_handleFieldChanged);

    setState(() {
      titles.add(titleController);
      levels.add(50);
      tools.add([]);
      tagControllers.add(tagController);
      _errorMessage = null;
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
    tagControllers[index].dispose();

    setState(() {
      titles.removeAt(index);
      levels.removeAt(index);
      tools.removeAt(index);
      tagControllers.removeAt(index);

      _tagAddValidationIndexes = _tagAddValidationIndexes
          .where((i) => i != index)
          .map((i) => i > index ? i - 1 : i)
          .toSet();

      _pendingTagIndexes = _pendingTagIndexes
          .where((i) => i != index)
          .map((i) => i > index ? i - 1 : i)
          .toSet();

      _errorMessage = null;
    });

    _recalculateState();
  }

  void _updateLevel(int index, double value) {
    setState(() {
      levels[index] = value < 25 ? 25 : value;
      _errorMessage = null;
    });

    _recalculateState();
  }

  bool _isTitleValid(String value) {
    return value.trim().length >= 2;
  }

  bool _isDuplicateTitleAt(int index) {
    final current = titles[index].text.trim().toLowerCase();
    if (current.isEmpty) return false;

    final occurrences = titles.where((controller) {
      return controller.text.trim().toLowerCase() == current;
    }).length;

    return occurrences > 1;
  }

  bool _isSkillCompletelyEmpty(int index) {
    return titles[index].text.trim().isEmpty &&
        tools[index].isEmpty &&
        tagControllers[index].text.trim().isEmpty;
  }

  bool _skillHasAnyContent(int index) {
    return titles[index].text.trim().isNotEmpty ||
        tools[index].isNotEmpty ||
        tagControllers[index].text.trim().isNotEmpty;
  }

  bool _titleHasError(int index) {
    if (!_validationTriggered) return false;

    final title = titles[index].text.trim();
    final hasAnyContent = _skillHasAnyContent(index);

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

  bool _titleIsValidState(int index) {
    final value = titles[index].text.trim();
    if (value.isEmpty) return false;
    return _isTitleValid(value) && !_isDuplicateTitleAt(index);
  }

  bool _tagAlreadyExists(int index, String value) {
    final normalized = value.trim().toLowerCase();

    return tools[index].any(
      (tool) => tool.trim().toLowerCase() == normalized,
    );
  }

  bool _tagFieldHasError(int index) {
    final value = tagControllers[index].text.trim();
    final hasAnyContent = _skillHasAnyContent(index);

    if (_pendingTagIndexes.contains(index) && value.isNotEmpty) {
      return true;
    }

    if (_tagAddValidationIndexes.contains(index)) {
      if (value.isEmpty) return true;
      if (value.length < 2) return true;
      if (_tagAlreadyExists(index, value)) return true;
    }

    if (_validationTriggered && hasAnyContent && tools[index].isEmpty) {
      if (value.isEmpty) return true;
      if (value.length < 2) return true;
      if (_tagAlreadyExists(index, value)) return true;
    }

    return false;
  }

  bool _tagFieldIsValid(int index) {
    final value = tagControllers[index].text.trim();

    if (tools[index].isNotEmpty &&
        value.isEmpty &&
        !_pendingTagIndexes.contains(index)) {
      return true;
    }

    if (value.isEmpty) return false;
    if (_pendingTagIndexes.contains(index)) return false;
    if (value.length < 2) return false;
    if (_tagAlreadyExists(index, value)) return false;

    return true;
  }

  void _addTool(int index) {
    final value = tagControllers[index].text.trim();

    if (value.isEmpty) {
      setState(() {
        _tagAddValidationIndexes.add(index);
        _errorMessage = 'Digite uma tag antes de adicionar.';
      });
      return;
    }

    if (value.length < 2) {
      setState(() {
        _tagAddValidationIndexes.add(index);
        _errorMessage = 'Essa tag está curta demais.';
      });
      return;
    }

    final exists = _tagAlreadyExists(index, value);

    if (exists) {
      setState(() {
        _tagAddValidationIndexes.add(index);
        _errorMessage = 'Essa tag já foi adicionada.';
      });
      return;
    }

    setState(() {
      tools[index].add(TechSkillTextInputFormatter._toTitleCase(value));
      tagControllers[index].clear();
      _tagAddValidationIndexes.remove(index);
      _pendingTagIndexes.remove(index);
      _errorMessage = null;
    });

    _recalculateState();
  }

  void _removeTool(int skillIndex, int toolIndex) {
    setState(() {
      tools[skillIndex].removeAt(toolIndex);
      _errorMessage = null;
    });

    _recalculateState();
  }

  String? _buildValidationMessage() {
    final hasPendingTag = tagControllers.any(
      (controller) => controller.text.trim().isNotEmpty,
    );

    if (hasPendingTag) {
      _pendingTagIndexes = {};
      for (int i = 0; i < tagControllers.length; i++) {
        if (tagControllers[i].text.trim().isNotEmpty) {
          _pendingTagIndexes.add(i);
        }
      }

      return 'Você digitou uma tag e ainda não adicionou.';
    }

    final rawSkills = _buildRawSkills();

    final filledSkills = rawSkills
        .where((skill) => skill.title.isNotEmpty || skill.tools.isNotEmpty)
        .toList();

    if (filledSkills.isEmpty) {
      return 'Preencha pelo menos uma habilidade.';
    }

    for (final skill in filledSkills) {
      if (skill.title.isEmpty) {
        return 'Preencha o nome da habilidade ou remova o item vazio.';
      }

      if (skill.title.length < 2) {
        return 'O nome da habilidade está curto demais.';
      }

      if (skill.level < 25) {
        return 'O nível da habilidade não pode ser abaixo de 25%.';
      }

      if (skill.tools.isEmpty) {
        return 'Adicione pelo menos uma tag para a habilidade "${skill.title}".';
      }
    }

    final normalizedTitles = filledSkills
        .map((e) => e.title.trim().toLowerCase())
        .toList();

    if (normalizedTitles.toSet().length != normalizedTitles.length) {
      return 'Você adicionou habilidades repetidas.';
    }

    final validatorError = AppValidators.validateHardSkills(filledSkills);
    if (validatorError != null) {
      return validatorError;
    }

    return null;
  }

  Future<void> _save() async {
    setState(() {
      _validationTriggered = true;
      _errorMessage = null;
      _pendingTagIndexes = {};
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

      await ref.read(profileProvider.notifier).updateHardSkills(updated);

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
                                AppIcons.laptop,
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Habilidades Técnicas',
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
    final theme = Theme.of(context);
    final isFixedItem = index == 0;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _fieldLabel(
                  icon: AppIcons.paint,
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
            hint: 'Ex: Flutter',
            maxLength: 40,
            hasError: _titleHasError(index),
            isValid: _titleIsValidState(index),
            inputFormatters: [
              TechSkillTextInputFormatter(),
            ],
            onChanged: (_) {
              _errorMessage = null;
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          _fieldLabel(
            icon: AppIcons.hardskillsitem,
            label: 'Nível da Habilidade',
          ),
          const SizedBox(height: 8),
          Text(
            'Nível: ${levels[index].toInt()}',
            style: const TextStyle(fontSize: 14),
          ),
          Slider(
            value: levels[index],
            min: 25,
            max: 100,
            divisions: 3,
            label: levels[index].toInt().toString(),
            onChanged: (value) => _updateLevel(index, value),
          ),
          const SizedBox(height: 4),
          _fieldLabel(
            icon: AppIcons.hashtag,
            label: 'Tags da Habilidade',
          ),
          const SizedBox(height: 8),
          if (tools[index].isNotEmpty) ...[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(
                tools[index].length,
                (toolIndex) => _tagChip(
                  label: tools[index][toolIndex],
                  onRemove: () => _removeTool(index, toolIndex),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppValidatedInputField(
                  controller: tagControllers[index],
                  hint: 'Adicionar Tag',
                  maxLength: 20,
                  hasError: _tagFieldHasError(index),
                  isValid: _tagFieldIsValid(index),
                  inputFormatters: [
                    TechSkillTextInputFormatter(),
                  ],
                  onChanged: (_) {
                    _errorMessage = null;
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _addTool(index),
                icon: Icon(
                  Icons.add,
                  size: 28,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
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

  Widget _tagChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}