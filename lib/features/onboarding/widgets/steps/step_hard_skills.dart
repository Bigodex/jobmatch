// =======================================================
// STEP HARD SKILLS
// -------------------------------------------------------
// Hard skills no onboarding
// - Layout no mesmo modelo de soft skills
// - Labels + ícones acima dos campos
// - Validações faladas pelo Jobu
// - Primeiro item fixo, não removível
// - Não permite continuar sem preencher ao menos uma habilidade
// - Contadores ocultos
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/features/profile/models/tech_skill_model.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

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

class StepHardSkills extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Function(String?) onJobuMessageChange;

  const StepHardSkills({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepHardSkills> createState() => _StepHardSkillsState();
}

class _StepHardSkillsState extends ConsumerState<StepHardSkills> {
  late List<TextEditingController> titles;
  late List<double> levels;
  late List<List<String>> tools;
  late List<TextEditingController> tagControllers;

  @override
  void initState() {
    super.initState();

    final onboarding = ref.read(onboardingProvider);

    final initialSkills = onboarding.techSkills.isNotEmpty
        ? onboarding.techSkills
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
        .map((e) => e.level.toDouble())
        .toList();

    tools = initialSkills
        .map((e) => List<String>.from(e.tools))
        .toList();

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

  List<TechSkillModel> _buildSkills() {
    return List.generate(
      titles.length,
      (index) => TechSkillModel(
        title: titles[index].text.trim(),
        level: levels[index].toInt(),
        tools: List<String>.from(tools[index]),
      ),
    );
  }

  void _sync() {
    ref.read(onboardingProvider.notifier).setTechSkills(_buildSkills());
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
    tagControllers[index].dispose();

    setState(() {
      titles.removeAt(index);
      levels.removeAt(index);
      tools.removeAt(index);
      tagControllers.removeAt(index);
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  void _updateLevel(int index, double value) {
    setState(() {
      levels[index] = value;
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  void _addTool(int index) {
    final value = tagControllers[index].text.trim();

    if (value.isEmpty) {
      _showJobuMessage('Digite uma tag antes de adicionar.');
      return;
    }

    if (value.length < 2) {
      _showJobuMessage('Essa tag está curta demais.');
      return;
    }

    final exists = tools[index].any(
      (tool) => tool.toLowerCase() == value.toLowerCase(),
    );

    if (exists) {
      _showJobuMessage('Essa tag já foi adicionada.');
      return;
    }

    setState(() {
      tools[index].add(TechSkillTextInputFormatter._toTitleCase(value));
      tagControllers[index].clear();
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  void _removeTool(int skillIndex, int toolIndex) {
    setState(() {
      tools[skillIndex].removeAt(toolIndex);
    });

    _sync();
    widget.onJobuMessageChange(null);
  }

  void _handleContinue() {
    final hasPendingTag = tagControllers.any(
      (controller) => controller.text.trim().isNotEmpty,
    );

    if (hasPendingTag) {
      _showJobuMessage(
        'Você digitou uma tag e ainda não adicionou.',
      );
      return;
    }

    final rawSkills = List.generate(
      titles.length,
      (index) => TechSkillModel(
        title: titles[index].text.trim(),
        level: levels[index].toInt(),
        tools: List<String>.from(tools[index]),
      ),
    );

    final filledSkills = rawSkills
        .where((skill) => skill.title.isNotEmpty || skill.tools.isNotEmpty)
        .toList();

    if (filledSkills.isEmpty) {
      _showJobuMessage(
        'Preencha pelo menos uma \nhabilidade ou clique em pular.',
      );
      return;
    }

    for (final skill in filledSkills) {
      if (skill.title.isEmpty) {
        _showJobuMessage(
          'Preencha o nome da habilidade \nou remova o item vazio.',
        );
        return;
      }

      if (skill.title.length < 2) {
        _showJobuMessage('O nome da habilidade está \ncurto demais.');
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

    ref.read(onboardingProvider.notifier).setTechSkills(filledSkills);
    widget.onJobuMessageChange(null);
    widget.onNext();
  }

  void _handleSkip() {
    ref.read(onboardingProvider.notifier).setTechSkills([]);
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
                          AppIcons.code,
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _handleSkip,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: theme.colorScheme.primary.withOpacity(0.3),
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
    final theme = Theme.of(context);
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
                  AppIcons.code,
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
          icon: AppIcons.paint,
          label: 'Nome da Habilidade',
        ),
        const SizedBox(height: 8),
        _inputField(
          controller: titles[index],
          hint: 'Ex: Flutter',
          maxLength: 40,
          inputFormatters: [
            TechSkillTextInputFormatter(),
          ],
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
          min: 0,
          max: 100,
          divisions: 20,
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
              child: _inputField(
                controller: tagControllers[index],
                hint: 'Adicionar Tag',
                maxLength: 20,
                inputFormatters: [
                  TechSkillTextInputFormatter(),
                ],
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
    required int maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        hintStyle: const TextStyle(fontSize: 13),
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