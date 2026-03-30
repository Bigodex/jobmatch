// =======================================================
// EDIT LANGUAGE SCREEN (COM VALIDAÇÃO)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/utils/validators.dart'; // 🔥 NOVO

import 'package:jobmatch/features/profile/models/language_model.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';
import 'package:jobmatch/features/profile/screens/success_screen.dart';

import 'package:jobmatch/shared/widgets/app_header.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class EditLanguageScreen extends ConsumerStatefulWidget {
  final List<LanguageModel> languages;

  const EditLanguageScreen({
    super.key,
    required this.languages,
  });

  @override
  ConsumerState<EditLanguageScreen> createState() =>
      _EditLanguageScreenState();
}

class _EditLanguageScreenState extends ConsumerState<EditLanguageScreen> {

  late List<LanguageModel> _edited;

  // ===================================================
  // VALIDAÇÃO
  // ===================================================
  String? languagesError;
  bool isValid = true;
  bool hasChanged = false;

  final Map<String, String> _languagesMap = {
    'Português': '🇧🇷',
    'Inglês': '🇺🇸',
    'Espanhol': '🇪🇸',
    'Francês': '🇫🇷',
    'Alemão': '🇩🇪',
    'Italiano': '🇮🇹',
  };

  @override
  void initState() {
    super.initState();

    _edited = widget.languages
        .map((e) => LanguageModel(
              name: e.name,
              flag: e.flag,
              level: e.level,
            ))
        .toList();

    _validate(); // 🔥 inicial
  }

  // ===================================================
  // VALIDAÇÃO GLOBAL
  // ===================================================
  void _validate() {
    languagesError =
        AppValidators.validateLanguagesFull(_edited);

    hasChanged = AppValidators.hasLanguagesChanged(
      widget.languages,
      _edited,
    );

    isValid = languagesError == null;

    setState(() {});
  }

  // ===================================================
  // SAVE
  // ===================================================
  Future<void> _save() async {
    await ref.read(profileProvider.notifier).updateLanguages(_edited);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SuccessScreen(),
      ),
    );
  }

  // ===================================================
  // ADD LANGUAGE
  // ===================================================
  void _addLanguage() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: _languagesMap.keys.map((name) {
            return ListTile(
              title: Text(name),
              onTap: () => Navigator.pop(context, name),
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _edited.add(
          LanguageModel(
            name: selected,
            flag: _languagesMap[selected]!,
            level: 50,
          ),
        );
      });

      _validate(); // 🔥 importante
    }
  }

  // ===================================================
  // REMOVE
  // ===================================================
  void _removeLanguage(int index) {
    setState(() {
      _edited.removeAt(index);
    });

    _validate();
  }

  // ===================================================
  // LABEL
  // ===================================================
  String _getLevelLabel(int value) {
    if (value <= 33) return 'Iniciante';
    if (value <= 66) return 'Intermediário';
    return 'Avançado';
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

                          const Text(
                            'Idiomas',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Divider(
                            color: theme.dividerColor.withOpacity(0.2),
                          ),

                          const SizedBox(height: 12),

                          // ===================================================
                          // LISTA
                          // ===================================================
                          Column(
                            children: List.generate(_edited.length, (index) {
                              final lang = _edited[index];

                              return Column(
                                children: [
                                  _languageItem(lang, index),

                                  if (index != _edited.length - 1)
                                    Divider(
                                      height: 24,
                                      color: theme.dividerColor.withOpacity(0.2),
                                    ),
                                ],
                              );
                            }),
                          ),

                          // ===================================================
                          // ERRO GLOBAL
                          // ===================================================
                          if (languagesError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                languagesError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          TextButton.icon(
                            onPressed: _addLanguage,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar idioma'),
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

  // =======================================================
  // ITEM DE IDIOMA
  // =======================================================
  Widget _languageItem(LanguageModel lang, int index) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(lang.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(lang.name),
              ],
            ),
            IconButton(
              onPressed: () => _removeLanguage(index),
              icon: const Icon(Icons.delete, size: 18),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Slider(
          value: lang.level.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (value) {
            setState(() {
              _edited[index] = LanguageModel(
                name: lang.name,
                flag: lang.flag,
                level: value.toInt(),
              );
            });

            _validate(); // 🔥 valida ao mover slider
          },
        ),

        const SizedBox(height: 6),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getLevelLabel(lang.level),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text('${lang.level}%'),
          ],
        ),
      ],
    );
  }
}