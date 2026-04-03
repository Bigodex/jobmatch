// =======================================================
// EDIT RESUME SCREEN (COM VALIDAÇÃO + CONTADOR)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/utils/validators.dart';

import 'package:jobmatch/features/profile/models/resume_model.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';
import 'package:jobmatch/features/profile/screens/success_screen.dart';
import 'package:jobmatch/shared/widgets/app_header.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class EditResumeScreen extends ConsumerStatefulWidget {
  final ResumeModel resume;

  const EditResumeScreen({super.key, required this.resume});

  @override
  ConsumerState<EditResumeScreen> createState() =>
      _EditResumeScreenState();
}

class _EditResumeScreenState extends ConsumerState<EditResumeScreen> {
  late TextEditingController city;
  late TextEditingController description;
  DateTime? birth;

  String? cityError;
  String? descriptionError;
  String? birthError;

  bool isValid = false;
  bool hasChanged = false;

  @override
  void initState() {
    super.initState();

    city = TextEditingController(text: widget.resume.city);
    description = TextEditingController(text: widget.resume.description);
    birth = widget.resume.birthDate;

    city.addListener(_validate);
    description.addListener(_validate);

    _validate();
  }

  // ===================================================
  // VALIDAÇÃO
  // ===================================================
  void _validate() {
    final newCity = city.text;
    final newDescription = description.text;

    cityError = AppValidators.validateCity(newCity);
    descriptionError =
        AppValidators.validateDescription(newDescription);
    birthError = AppValidators.validateBirthDate(birth);

    hasChanged = AppValidators.hasResumeChanged(
      originalCity: widget.resume.city ?? '',
      newCity: newCity,
      originalDescription: widget.resume.description ?? '',
      newDescription: newDescription,
      originalBirth: widget.resume.birthDate,
      newBirth: birth,
    );

    isValid = cityError == null &&
        descriptionError == null &&
        birthError == null;

    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: birth ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => birth = picked);
      _validate();
    }
  }

  Future<void> _save() async {
    final updated = widget.resume.copyWith(
      city: city.text,
      description: description.text,
      birthDate: birth,
    );

    await ref.read(profileProvider.notifier).updateResume(updated);

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
                                AppIcons.cv,
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.resume.labels.title,
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(
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

                          // DATA
                          _editItem(
                            icon: AppIcons.cake,
                            title: widget.resume.labels.birthDateLabel,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: _pickDate,
                                  child: _inputContainer(
                                    context,
                                    child: Text(
                                      birth != null
                                          ? '${birth!.day}/${birth!.month}/${birth!.year}'
                                          : 'Selecionar data',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                                if (birthError != null)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 6),
                                    child: Text(
                                      birthError!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // CIDADE
                          _editItem(
                            icon: AppIcons.building,
                            title: widget.resume.labels.cityLabel,
                            child: _inputField(
                              controller: city,
                              hint: 'Digite sua cidade',
                              error: cityError,
                              maxLength: 60,
                            ),
                          ),

                          const SizedBox(height: 0),

                          // DESCRIÇÃO
                          _editItem(
                            icon: AppIcons.info,
                            title: widget.resume.labels.descriptionLabel,
                            child: _inputField(
                              controller: description,
                              hint: 'Fale sobre você...',
                              minLines: 3,
                              error: descriptionError,
                              maxLength: 500,
                            ),
                          ),

                          const SizedBox(height: 20),

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

  // =======================================================
  // INPUT COM CONTADOR
  // =======================================================
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    String? error,
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
      style: const TextStyle(fontSize: 13),

      onChanged: (_) => setState(() {}),

      decoration: InputDecoration(
        hintText: hint,
        errorText: error,
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
    );
  }

  Widget _editItem({
    required String icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(icon, width: 16, height: 16),
            const SizedBox(width: 10),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: child),
      ],
    );
  }

  Widget _inputContainer(
    BuildContext context, {
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }
}