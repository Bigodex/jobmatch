// =======================================================
// EDIT HARD SKILLS SCREEN (VALIDAÇÃO INLINE)
// =======================================================

import 'package:flutter/material.dart';
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
  late List<TextEditingController> techControllers;

  // ===================================================
  // VALIDAÇÃO
  // ===================================================
  String? skillsError;
  bool isValid = true;
  bool hasChanged = false;

  @override
  void initState() {
    super.initState();

    titles = widget.skills
        .map((e) => TextEditingController(text: e.title))
        .toList();

    levels = widget.skills
        .map((e) => e.level.toDouble())
        .toList();

    tools = widget.skills
        .map((e) => List<String>.from(e.tools))
        .toList();

    techControllers = List.generate(
      widget.skills.length,
      (_) => TextEditingController(),
    );

    _validate(); // 🔥 inicial
  }

  // ===================================================
  // VALIDATE
  // ===================================================
  void _validate() {
    final updated = List.generate(
      titles.length,
      (index) => TechSkillModel(
        title: titles[index].text.trim(),
        level: levels[index].toInt(),
        tools: tools[index],
      ),
    );

    skillsError = AppValidators.validateHardSkills(updated);

    hasChanged = AppValidators.hasHardSkillsChanged(
      widget.skills,
      updated,
    );

    isValid = skillsError == null;

    setState(() {});
  }

  // ===================================================
  // ADD / REMOVE
  // ===================================================
  void _addSkill() {
    setState(() {
      titles.add(TextEditingController());
      levels.add(50);
      tools.add([]);
      techControllers.add(TextEditingController());
    });

    _validate();
  }

  void _removeSkill(int index) {
    setState(() {
      titles.removeAt(index);
      levels.removeAt(index);
      tools.removeAt(index);
      techControllers.removeAt(index);
    });

    _validate();
  }

  void _addTool(int index) {
    final value = techControllers[index].text.trim();
    if (value.isEmpty) return;

    setState(() {
      tools[index].add(value);
      techControllers[index].clear();
    });

    _validate();
  }

  void _removeTool(int index, String tool) {
    setState(() {
      tools[index].remove(tool);
    });

    _validate();
  }

  // ===================================================
  // SAVE
  // ===================================================
  Future<void> _save() async {
    final updated = List.generate(
      titles.length,
      (index) => TechSkillModel(
        title: titles[index].text.trim(),
        level: levels[index].toInt(),
        tools: tools[index],
      ),
    );

    await ref.read(profileProvider.notifier)
        .updateHardSkills(updated);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SuccessScreen(),
      ),
    );
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
            child: AppHeader(title: 'Editar', showBackButton: true),
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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.code,
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Habilidades Técnicas',
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

                          const SizedBox(height: 8),

                          // ===================================================
                          // LISTA
                          // ===================================================
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

                          // ===================================================
                          // ERRO GLOBAL (🔥 IGUAL LANGUAGES)
                          // ===================================================
                          if (skillsError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                skillsError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          TextButton.icon(
                            onPressed: _addSkill,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar habilidade'),
                          ),

                          const SizedBox(height: 20),

                          // ===================================================
                          // BOTÃO INTELIGENTE
                          // ===================================================
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  (isValid && hasChanged)
                                      ? _save
                                      : null,
                              child: const Text('Salvar'),
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

  // ===================================================
  // ITEM
  // ===================================================
  Widget _skillItem(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Habilidade'),
            IconButton(
              onPressed: () => _removeSkill(index),
              icon: const Icon(Icons.delete, size: 18),
            ),
          ],
        ),

        const SizedBox(height: 8),

        _inputField(
          controller: titles[index],
          hint: 'Ex: Flutter',
          onChanged: (_) => _validate(),
        ),

        const SizedBox(height: 12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nível: ${levels[index].toInt()}'),
            Slider(
              value: levels[index],
              min: 0,
              max: 100,
              divisions: 4,
              onChanged: (value) {
                setState(() => levels[index] = value);
                _validate();
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tools[index]
              .map((tool) => Chip(
                    label: Text(tool),
                    onDeleted: () => _removeTool(index, tool),
                  ))
              .toList(),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _inputField(
                controller: techControllers[index],
                hint: 'Adicionar Tag',
              ),
            ),
            IconButton(
              onPressed: () => _addTool(index),
              icon: const Icon(Icons.add),
            )
          ],
        ),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
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
    );
  }
}