// =======================================================
// EDIT RESUME SCREEN
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

import 'package:jobmatch/features/profile/models/resume_model.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';
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

  @override
  void initState() {
    super.initState();
    city = TextEditingController(text: widget.resume.city);
    description = TextEditingController(text: widget.resume.description);
    birth = widget.resume.birthDate;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: birth ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) setState(() => birth = picked);
  }

  Future<void> _save() async {
    final updated = widget.resume.copyWith(
      city: city.text,
      description: description.text,
      birthDate: birth,
    );

    await ref.read(profileProvider.notifier).updateResume(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados atualizados com sucesso')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Scaffold(
      body: Column(
        children: [
          // ===================================================
          // SAFE AREA + HEADER
          // ===================================================
          const SafeArea(
            bottom: false,
            child: AppHeader(title: 'Editar'),
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
                          // HEADER IGUAL AO PROFILE
                          // ===================================================
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
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
                            ],
                          ),

                          Divider(
                              color:
                                  theme.dividerColor.withOpacity(0.2)),
                          const SizedBox(height: 12),

                          // ===================================================
                          // DATA (EDITÁVEL)
                          // ===================================================
                          _editItem(
                            AppIcons.cake,
                            widget.resume.labels.birthDateLabel,
                            GestureDetector(
                              onTap: _pickDate,
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.white24),
                                ),
                                child: Text(
                                  birth != null
                                      ? '${birth!.day}/${birth!.month}/${birth!.year}'
                                      : 'Selecionar data',
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ===================================================
                          // CIDADE (EDITÁVEL)
                          // ===================================================
                          _editItem(
                            AppIcons.building,
                            widget.resume.labels.cityLabel,
                            TextField(
                              controller: city,
                              decoration: const InputDecoration(
                                hintText: 'Digite sua cidade',
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ===================================================
                          // DESCRIÇÃO (EDITÁVEL)
                          // ===================================================
                          _editItem(
                            AppIcons.info,
                            widget.resume.labels.descriptionLabel,
                            TextField(
                              controller: description,
                              maxLines: 6,
                              textCapitalization:
                                  TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                hintText: 'Fale sobre você...',
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ===================================================
                          // BOTÃO
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
  // ITEM PADRÃO (MESMA ESTRUTURA DO PROFILE)
  // =======================================================
  Widget _editItem(
    String icon,
    String title,
    Widget child,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(icon, width: 16, height: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              child,
            ],
          ),
        ),
      ],
    );
  }
}