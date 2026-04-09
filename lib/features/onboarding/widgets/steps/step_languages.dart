// =======================================================
// STEP LANGUAGES
// -------------------------------------------------------
// Idiomas do onboarding
// - Mais idiomas
// - Bandeiras persistidas no model
// - Sem atualizar provider no initState
// - Validação Jobu para nível muito baixo
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
  final Function(String?) onJobuMessageChange;

  const StepLanguages({
    super.key,
    required this.onNext,
    required this.onJobuMessageChange,
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
    'Italiano': '🇮🇹',
    'Japonês': '🇯🇵',
    'Coreano': '🇰🇷',
    'Chinês': '🇨🇳',
    'Russo': '🇷🇺',
    'Árabe': '🇸🇦',
    'Hindi': '🇮🇳',
    'Turco': '🇹🇷',
    'Holandês': '🇳🇱',
    'Sueco': '🇸🇪',
    'Polonês': '🇵🇱',
    'Ucraniano': '🇺🇦',
    'Grego': '🇬🇷',
    'Hebraico': '🇮🇱',
    'Tailandês': '🇹🇭',
  };

  late List<LanguageModel> _languages;

  bool get _isValid => _languages.isNotEmpty;

  @override
  void initState() {
    super.initState();

    final data = ref.read(onboardingProvider);

    if (data.languages.isNotEmpty) {
      _languages = List<LanguageModel>.from(data.languages);
    } else {
      _languages = [
        LanguageModel(
          name: 'Português',
          level: 100,
          flag: _languagesMap['Português'] ?? '🇧🇷',
        ),
      ];
    }
  }

  void _sync() {
    ref.read(onboardingProvider.notifier).setLanguages(
          List<LanguageModel>.from(_languages),
        );
  }

  void _addLanguage() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) {
        final availableLanguages = _languagesMap.keys
            .where((name) => !_languages.any((e) => e.name == name))
            .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: availableLanguages.map((name) {
            return ListTile(
              leading: Text(
                _languagesMap[name] ?? '🌍',
                style: const TextStyle(fontSize: 20),
              ),
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
            flag: _languagesMap[selected] ?? '🌍',
          ),
        );
      });

      _sync();
    }
  }

  void _removeLanguage(int index) {
    if (_languages[index].name == 'Português') return;

    setState(() {
      _languages.removeAt(index);
    });

    _sync();
  }

  void _updateLevel(int index, int value) {
    final current = _languages[index];

    setState(() {
      _languages[index] = LanguageModel(
        name: current.name,
        level: value,
        flag: current.flag,
      );
    });

    _sync();
  }

  void _continue() {
    final invalidLanguage = _languages.cast<LanguageModel?>().firstWhere(
          (lang) => lang != null && (lang.level == 0 || lang.level == 5),
          orElse: () => null,
        );

    if (invalidLanguage != null) {
      widget.onJobuMessageChange(
        'Nível de idioma "${invalidLanguage.name}" \nmuito baixo.',
      );
      return;
    }

    widget.onJobuMessageChange(null);
    _sync();
    widget.onNext();
  }

  String _getLevelLabel(int value) {
    if (value == 100) return 'Nativo';
    if (value >= 90) return 'Expert';
    if (value >= 61) return 'Avançado';
    if (value >= 40) return 'Intermediário';
    if (value >= 21) return 'Iniciante';
    if (value >= 10) return 'Básico';
    return 'Muito baixo';
  }

  String _getFlag(LanguageModel lang) {
    if (lang.flag.trim().isNotEmpty) return lang.flag;
    return _languagesMap[lang.name] ?? '🌍';
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SvgPicture.asset(AppIcons.language, width: 20),
                        const SizedBox(width: 10),
                        const Text(
                          'Idiomas',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      color: Colors.white.withOpacity(0.08),
                      height: 1,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: List.generate(_languages.length, (index) {
                        final lang = _languages[index];

                        return Column(
                          children: [
                            _item(lang, index),
                            if (index != _languages.length - 1)
                              const Divider(height: 24),
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
                        onPressed: _isValid ? _continue : null,
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
                Text(
                  _getFlag(lang),
                  style: const TextStyle(fontSize: 20),
                ),
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
              style: TextStyle(
                color: theme.colorScheme.primary,
              ),
            ),
            Text('${lang.level}%'),
          ],
        ),
      ],
    );
  }
}