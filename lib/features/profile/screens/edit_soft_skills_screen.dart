// =======================================================
// EDIT SOFT SKILLS SCREEN
// -------------------------------------------------------
// Edição das habilidades comportamentais
// seguindo padrão do EditResumeScreen
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

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

  @override
  void initState() {
    super.initState();

    titles = widget.skills
        .map((e) => TextEditingController(text: e.title))
        .toList();

    descriptions = widget.skills
        .map((e) => TextEditingController(text: e.description))
        .toList();
  }

  // =======================================================
  // ADICIONAR NOVA SKILL
  // =======================================================
  void _addSkill() {
    setState(() {
      titles.add(TextEditingController());
      descriptions.add(TextEditingController());
    });
  }

  // =======================================================
  // REMOVER SKILL
  // =======================================================
  void _removeSkill(int index) {
    setState(() {
      titles.removeAt(index);
      descriptions.removeAt(index);
    });
  }

  // =======================================================
  // SALVAR
  // =======================================================
  Future<void> _save() async {
    final updated = List.generate(
      titles.length,
      (index) => SoftSkillModel(
        title: titles[index].text,
        description: descriptions[index].text,
      ),
    );

    await ref.read(profileProvider.notifier)
        .updateSoftSkills(updated);

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
          // ===================================================
          // HEADER
          // ===================================================
          const SafeArea(
            bottom: false,
            child: AppHeader(
              title: 'Editar',
              showBackButton: true,
            ),
          ),

          // ===================================================
          // CONTEÚDO
          // ===================================================
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

                          // ===================================================
                          // HEADER DO CARD
                          // ===================================================
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

                          Divider(
                            color: theme.dividerColor.withOpacity(0.2),
                          ),

                          const SizedBox(height: 12),

                          // ===================================================
                          // LISTA EDITÁVEL
                          // ===================================================
                          Column(
                            children: List.generate(titles.length, (index) {
                              return Column(
                                children: [
                                  _skillItem(index),

                                  if (index != titles.length - 1)
                                    Divider(
                                      height: 24,
                                      color: theme.dividerColor
                                          .withOpacity(0.2),
                                    ),
                                ],
                              );
                            }),
                          ),

                          const SizedBox(height: 16),

                          // ===================================================
                          // BOTÃO ADICIONAR
                          // ===================================================
                          TextButton.icon(
                            onPressed: _addSkill,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar habilidade'),
                          ),

                          const SizedBox(height: 20),

                          // ===================================================
                          // BOTÃO SALVAR
                          // ===================================================
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _save,
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

  // =======================================================
  // ITEM DE SKILL
  // =======================================================
  Widget _skillItem(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // TÍTULO + DELETE
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
        ),

        const SizedBox(height: 10),

        _inputField(
          controller: descriptions[index],
          hint: 'Descreva essa habilidade...',
          minLines: 3,
        ),
      ],
    );
  }

  // =======================================================
  // INPUT PADRÃO
  // =======================================================
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    int? minLines,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      minLines: minLines ?? 1,
      maxLines: null,
      keyboardType: TextInputType.multiline,
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