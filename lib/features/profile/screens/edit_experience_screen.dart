// =======================================================
// EDIT EXPERIENCE SCREEN
// -------------------------------------------------------
// Edição das experiências profissionais
// PADRÃO PREMIUM (igual soft skills)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

import 'package:jobmatch/features/profile/models/experience_model.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';
import 'package:jobmatch/features/profile/screens/success_screen.dart';

import 'package:jobmatch/shared/widgets/app_header.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class EditExperienceScreen extends ConsumerStatefulWidget {
  final List<ExperienceModel> experiences;

  const EditExperienceScreen({
    super.key,
    required this.experiences,
  });

  @override
  ConsumerState<EditExperienceScreen> createState() =>
      _EditExperienceScreenState();
}

class _EditExperienceScreenState
    extends ConsumerState<EditExperienceScreen> {

  late List<TextEditingController> companies;
  late List<TextEditingController> roles;
  late List<TextEditingController> descriptions;
  late List<TextEditingController> logoUrls;

  late List<DateTime> startDates;
  late List<DateTime?> endDates;

  @override
  void initState() {
    super.initState();

    companies =
        widget.experiences.map((e) => TextEditingController(text: e.company)).toList();

    roles =
        widget.experiences.map((e) => TextEditingController(text: e.role)).toList();

    descriptions =
        widget.experiences.map((e) => TextEditingController(text: e.description)).toList();

    logoUrls =
        widget.experiences.map((e) => TextEditingController(text: e.logoUrl ?? '')).toList();

    startDates = widget.experiences.map((e) => e.startDate).toList();
    endDates = widget.experiences.map((e) => e.endDate).toList();
  }

  void _addExperience() {
    setState(() {
      companies.add(TextEditingController());
      roles.add(TextEditingController());
      descriptions.add(TextEditingController());
      logoUrls.add(TextEditingController());
      startDates.add(DateTime.now());
      endDates.add(null);
    });
  }

  void _removeExperience(int index) {
    setState(() {
      companies.removeAt(index);
      roles.removeAt(index);
      descriptions.removeAt(index);
      logoUrls.removeAt(index);
      startDates.removeAt(index);
      endDates.removeAt(index);
    });
  }

  Future<void> _save() async {
    final updated = List.generate(
      companies.length,
      (index) => ExperienceModel(
        company: companies[index].text,
        role: roles[index].text,
        description: descriptions[index].text,
        startDate: startDates[index],
        endDate: endDates[index],
        logoUrl: logoUrls[index].text.isEmpty
            ? null
            : logoUrls[index].text,
      ),
    );

    await ref.read(profileProvider.notifier)
        .updateExperiences(updated);

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

                          // HEADER CARD
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.briefcase,
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Experiências',
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

                          // LISTA
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
  // ITEM PREMIUM (IGUAL SOFT SKILLS)
  // =======================================================
  Widget _experienceItem(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // HEADER
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
            IconButton(
              onPressed: () => _removeExperience(index),
              icon: const Icon(Icons.delete, size: 18),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _input(companies[index], 'Empresa (ex: Google)'),

        const SizedBox(height: 10),

        _input(roles[index], 'Cargo (ex: Desenvolvedor)'),

        const SizedBox(height: 10),

        _input(
          descriptions[index],
          'Descreva sua atuação...',
          minLines: 3,
        ),

        const SizedBox(height: 10),

        _input(logoUrls[index], 'URL do logo (opcional)'),
      ],
    );
  }

  // =======================================================
  // INPUT PADRÃO
  // =======================================================
  Widget _input(
    TextEditingController controller,
    String hint, {
    int? minLines,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      minLines: minLines ?? 1,
      maxLines: null,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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