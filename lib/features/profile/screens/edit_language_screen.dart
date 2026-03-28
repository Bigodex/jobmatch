// =======================================================
// EDIT LANGUAGE SCREEN
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/profile/models/language_model.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';
import 'package:jobmatch/features/profile/screens/success_screen.dart';
import 'package:jobmatch/shared/widgets/app_header.dart';

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

  // =======================================================
  // MAP DE IDIOMAS (flag automática)
  // =======================================================
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
  }

  // =======================================================
  // SAVE
  // =======================================================
  Future<void> _save() async {
    await ref.read(profileProvider.notifier).updateLanguages(_edited);

    if (!mounted) return;

    // 🔥 REDIRECIONA PARA SUCCESS
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SuccessScreen(),
      ),
    );
  }

  // =======================================================
  // ADD LANGUAGE
  // =======================================================
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
    }
  }

  // =======================================================
  // REMOVE LANGUAGE
  // =======================================================
  void _removeLanguage(int index) {
    setState(() {
      _edited.removeAt(index);
    });
  }

  // =======================================================
  // LEVEL LABEL
  // =======================================================
  String _getLevelLabel(int value) {
    if (value <= 33) return 'Iniciante';
    if (value <= 66) return 'Intermediário';
    return 'Avançado';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: Column(
          children: [

            // ===================================================
            // HEADER
            // ===================================================
            AppHeader(
              title: 'Editar',
              showBackButton: true,
              onMenuTap: () => Navigator.pop(context),
              onActionTap: null,
            ),

            // ===================================================
            // BOTÃO ADICIONAR
            // ===================================================
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _addLanguage,
                child: const Text('Adicionar idioma'),
              ),
            ),

            // ===================================================
            // LISTA
            // ===================================================
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _edited.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, index) {
                  final lang = _edited[index];

                  return _LanguageEditCard(
                    language: lang,
                    onChanged: (value) {
                      setState(() {
                        _edited[index] = LanguageModel(
                          name: lang.name,
                          flag: lang.flag,
                          level: value,
                        );
                      });
                    },
                    onDelete: () => _removeLanguage(index),
                    label: _getLevelLabel(lang.level),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: _save,
            child: const Text('Salvar'),
          ),
        ),
      ),
    );
  }
}

// =======================================================
// LANGUAGE EDIT CARD
// =======================================================

class _LanguageEditCard extends StatelessWidget {
  final LanguageModel language;
  final ValueChanged<int> onChanged;
  final VoidCallback onDelete;
  final String label;

  const _LanguageEditCard({
    required this.language,
    required this.onChanged,
    required this.onDelete,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardTertiary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // HEADER + DELETE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(language.flag, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text(
                    language.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),

              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Slider(
            value: language.level.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: (value) => onChanged(value.toInt()),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text('${language.level}%'),
            ],
          ),
        ],
      ),
    );
  }
}