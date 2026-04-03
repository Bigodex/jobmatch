// =======================================================
// STEP LANGUAGES (SEM MODEL LOCAL - FINAL)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// CORE
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

// MODEL
import 'package:jobmatch/features/profile/models/language_model.dart';

class StepLanguages extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const StepLanguages({
    super.key,
    required this.onNext,
  });

  @override
  ConsumerState<StepLanguages> createState() => _StepLanguagesState();
}

class _StepLanguagesState extends ConsumerState<StepLanguages> {

  final Map<String, String> _languagesMap = {
    'Português': '🇧🇷',
    'Inglês': '🇺🇸',
    'Espanhol': '🇪🇸',
    'Francês': '🇫🇷',
    'Alemão': '🇩🇪',
  };

  late List<LanguageModel> _languages;

  bool get _isValid => _languages.isNotEmpty;

  // ===================================================
  // INIT (SEM MEXER NO PROVIDER)
  // ===================================================
  @override
  void initState() {
    super.initState();

    final data = ref.read(onboardingProvider);

    if (data.languages.isNotEmpty) {
      _languages = List.from(data.languages);
    } else {
      // default visual
      _languages = [
        LanguageModel(
          name: 'Português',
          level: 100,
          flag: '',
        ),
      ];
    }
  }

  // ===================================================
  // SYNC
  // ===================================================
  void _sync() {
    ref.read(onboardingProvider.notifier).setLanguages(
      List.from(_languages),
    );
  }

  // ===================================================
  // ADD
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
      if (_languages.any((e) => e.name == selected)) return;

      setState(() {
        _languages.add(
          LanguageModel(
            name: selected,
            level: 50,
            flag: '',
          ),
        );
      });

      _sync();
    }
  }

  // ===================================================
  // REMOVE
  // ===================================================
  void _removeLanguage(int index) {
    if (_languages[index].name == 'Português') return;

    setState(() {
      _languages.removeAt(index);
    });

    _sync();
  }

  // ===================================================
  // UPDATE LEVEL
  // ===================================================
  void _updateLevel(int index, int value) {
    setState(() {
      _languages[index] = LanguageModel(
        name: _languages[index].name,
        level: value,
        flag: '',
      );
    });

    _sync();
  }

  // ===================================================
  // LABEL
  // ===================================================
  String _getLevelLabel(int value) {
    if (value == 100) return 'Nativo';
    if (value >= 90) return 'Expert';
    if (value >= 61) return 'Avançado';
    if (value >= 40) return 'Intermediário';
    if (value >= 21) return 'Iniciante';
    if (value >= 10) return 'Básico';
    return 'Muito baixo';
  }

  String _getFlag(String name) {
    return _languagesMap[name] ?? '🌍';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return SingleChildScrollView(
      child: Column(
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
                  children: [

                    Row(
                      children: [
                        SvgPicture.asset(AppIcons.language, width: 16),
                        const SizedBox(width: 10),
                        const Text('Idiomas'),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Column(
                      children: List.generate(_languages.length, (index) {
                        final lang = _languages[index];

                        return Column(
                          children: [
                            _item(lang, index),
                            if (index != _languages.length - 1)
                              Divider(height: 24),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    TextButton.icon(
                      onPressed: _addLanguage,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar idioma'),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isValid
                            ? () {
                                _sync();
                                widget.onNext();
                              }
                            : null,
                        child: const Text('Continuar'),
                      ),
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

  Widget _item(LanguageModel lang, int index) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(_getFlag(lang.name), style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(lang.name),
              ],
            ),
            if (lang.name != 'Português')
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
          divisions: 20,
          onChanged: (value) {
            _updateLevel(index, value.toInt());
          },
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getLevelLabel(lang.level),
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            Text('${lang.level}%'),
          ],
        ),
      ],
    );
  }
}