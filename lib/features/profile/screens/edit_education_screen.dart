// =======================================================
// EDIT EDUCATION SCREEN
// -------------------------------------------------------
// Edição das formações acadêmicas
// PADRÃO PREMIUM (igual experience)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

import 'package:jobmatch/features/profile/models/education_model.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';
import 'package:jobmatch/features/profile/screens/success_screen.dart';

import 'package:jobmatch/shared/widgets/app_header.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class EditEducationScreen extends ConsumerStatefulWidget {
  final List<EducationModel> educations;

  const EditEducationScreen({
    super.key,
    required this.educations,
  });

  @override
  ConsumerState<EditEducationScreen> createState() =>
      _EditEducationScreenState();
}

class _EditEducationScreenState
    extends ConsumerState<EditEducationScreen> {

  late List<TextEditingController> institutions;
  late List<TextEditingController> courses;
  late List<TextEditingController> descriptions;
  late List<TextEditingController> logoUrls;

  late List<DateTime> startDates;
  late List<DateTime?> endDates;

  @override
  void initState() {
    super.initState();

    institutions = widget.educations
        .map((e) => TextEditingController(text: e.institution))
        .toList();

    courses = widget.educations
        .map((e) => TextEditingController(text: e.course))
        .toList();

    descriptions = widget.educations
        .map((e) => TextEditingController(text: e.description))
        .toList();

    logoUrls = widget.educations
        .map((e) => TextEditingController(text: e.logoUrl ?? ''))
        .toList();

    startDates = widget.educations.map((e) => e.startDate).toList();
    endDates = widget.educations.map((e) => e.endDate).toList();
  }

  void _addEducation() {
    setState(() {
      institutions.add(TextEditingController());
      courses.add(TextEditingController());
      descriptions.add(TextEditingController());
      logoUrls.add(TextEditingController());
      startDates.add(DateTime.now());
      endDates.add(null);
    });
  }

  void _removeEducation(int index) {
    setState(() {
      institutions.removeAt(index);
      courses.removeAt(index);
      descriptions.removeAt(index);
      logoUrls.removeAt(index);
      startDates.removeAt(index);
      endDates.removeAt(index);
    });
  }

  Future<void> _save() async {
    final updated = List.generate(
      institutions.length,
      (index) => EducationModel(
        institution: institutions[index].text,
        course: courses[index].text,
        description: descriptions[index].text,
        startDate: startDates[index],
        endDate: endDates[index],
        logoUrl: logoUrls[index].text.isEmpty
            ? null
            : logoUrls[index].text,
      ),
    );

    await ref.read(profileProvider.notifier)
        .updateEducations(updated);

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

                          // HEADER
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.cap,
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Formações',
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
                            children: List.generate(institutions.length, (index) {
                              return Column(
                                children: [
                                  _educationItem(index),

                                  if (index != institutions.length - 1)
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
                            onPressed: _addEducation,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar formação'),
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
  // ITEM DE EDIÇÃO
  // =======================================================
  Widget _educationItem(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // HEADER ITEM
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  AppIcons.cap,
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Formação',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            IconButton(
              onPressed: () => _removeEducation(index),
              icon: const Icon(Icons.delete, size: 18),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _input(institutions[index], 'Instituição (ex: Unidep)'),

        const SizedBox(height: 10),

        _input(courses[index], 'Curso (ex: ADS)'),

        const SizedBox(height: 10),

        _input(
          descriptions[index],
          'Descreva sua formação...',
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