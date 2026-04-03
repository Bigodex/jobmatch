// =======================================================
// EDIT SOFT SKILLS SCREEN (COM JUSTIFY)
// =======================================================

import 'package:flutter/material.dart';
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

  String? error;
  bool isValid = true;
  bool hasChanged = false;

  @override
  void initState() {
    super.initState();

    titles = widget.skills
        .map((e) => TextEditingController(text: e.title))
        .toList();

    descriptions = widget.skills
        .map((e) => TextEditingController(text: e.description))
        .toList();

    for (final t in titles) {
      t.addListener(_validate);
    }

    for (final d in descriptions) {
      d.addListener(_validate);
    }

    _validate();
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

  void _validate() {
    final list = List.generate(
      titles.length,
      (i) => SoftSkillModel(
        title: titles[i].text,
        description: descriptions[i].text,
      ),
    );

    error = AppValidators.validateSoftSkills(list);

    hasChanged = AppValidators.hasSoftSkillsChanged(
      widget.skills,
      list,
    );

    isValid = error == null;

    setState(() {});
  }

  void _addSkill() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    titleController.addListener(_validate);
    descriptionController.addListener(_validate);

    setState(() {
      titles.add(titleController);
      descriptions.add(descriptionController);
    });

    _validate();
  }

  void _removeSkill(int index) {
    titles[index].dispose();
    descriptions[index].dispose();

    setState(() {
      titles.removeAt(index);
      descriptions.removeAt(index);
    });

    _validate();
  }

  Future<void> _save() async {
    final updated = List.generate(
      titles.length,
      (index) => SoftSkillModel(
        title: titles[index].text.trim(),
        description: descriptions[index].text.trim(),
      ),
    );

    await ref.read(profileProvider.notifier).updateSoftSkills(updated);

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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.softskills,
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Habilidades Comportamentais',
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
                          if (error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                error!,
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
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (isValid && hasChanged) ? _save : null,
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

  Widget _skillItem(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  AppIcons.softskillsitem,
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
            IconButton(
              onPressed: () => _removeSkill(index),
              icon: const Icon(Icons.delete, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _inputField(
          controller: titles[index],
          hint: 'Ex: Comunicação',
          maxLength: 40,
        ),
        const SizedBox(height: 10),
        _inputField(
          controller: descriptions[index],
          hint: 'Descreva essa habilidade...',
          minLines: 3,
          maxLength: 200,
        ),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    int? minLines,
    required int maxLength,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      minLines: minLines ?? 1,
      maxLines: null,
      maxLength: maxLength,
      keyboardType: TextInputType.multiline,
      textAlign: TextAlign.justify, // 🔥 AQUI
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        counterText: '${controller.text.length}/$maxLength',
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
      onChanged: (_) => setState(() {}),
    );
  }
}