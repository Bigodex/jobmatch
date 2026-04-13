// =======================================================
// STEP LANGUAGES
// -------------------------------------------------------
// Idiomas do onboarding
// - Mais idiomas
// - Bandeiras persistidas no model
// - Validação visual ativa em tempo real
// - Primeiro item padrão já nasce validado
// - Novo item adicionado já aparece com validação correta
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

  bool _isLanguageLevelInvalid(LanguageModel lang) {
    return lang.level == 0 || lang.level == 5;
  }

  bool _isLanguageLevelValid(LanguageModel lang) {
    return !_isLanguageLevelInvalid(lang);
  }

  bool _hasInvalidLanguages() {
    return _languages.any(_isLanguageLevelInvalid);
  }

  Future<void> _addLanguage() async {
    final availableLanguages = _languagesMap.keys
        .where((name) => !_languages.any((e) => e.name == name))
        .toList();

    if (availableLanguages.isEmpty) return;

    final selected = await _showLanguageSelectionModal(
      title: 'Selecionar idioma',
      searchHint: 'Buscar idioma',
      languages: availableLanguages,
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

      widget.onJobuMessageChange(null);
      _sync();
    }
  }

  Future<String?> _showLanguageSelectionModal({
    required String title,
    required String searchHint,
    required List<String> languages,
  }) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colors = theme.extension<AppColorsExtension>()!;
        final searchController = TextEditingController();
        List<String> filtered = List.from(languages);

        return StatefulBuilder(
          builder: (context, setModalState) {
            void applyFilter(String value) {
              final query = value.trim().toLowerCase();

              setModalState(() {
                if (query.isEmpty) {
                  filtered = List.from(languages);
                } else {
                  filtered = languages.where((name) {
                    return name.toLowerCase().contains(query);
                  }).toList();
                }
              });
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 460,
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.72,
                ),
                decoration: BoxDecoration(
                  color: colors.cardTertiary,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.28),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 14, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.of(dialogContext).pop(),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                      child: TextField(
                        controller: searchController,
                        onChanged: applyFilter,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: searchHint,
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Colors.white54,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.04),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.white.withOpacity(0.06),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Nenhum idioma encontrado.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.70),
                                  ),
                                ),
                              ),
                            )
                          : Scrollbar(
                              thumbVisibility: true,
                              radius: const Radius.circular(999),
                              child: ListView.separated(
                                padding: const EdgeInsets.all(14),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final name = filtered[index];
                                  final flag = _languagesMap[name] ?? '🌍';

                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(dialogContext).pop(name);
                                    },
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.035),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.06),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.05),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Text(
                                              flag,
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color:
                                                Colors.white.withOpacity(0.35),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _removeLanguage(int index) {
    if (_languages[index].name == 'Português') return;

    setState(() {
      _languages.removeAt(index);
    });

    if (!_hasInvalidLanguages()) {
      widget.onJobuMessageChange(null);
    }

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

    if (!_hasInvalidLanguages()) {
      widget.onJobuMessageChange(null);
    }

    _sync();
  }

  void _continue() {
    final invalidLanguage = _languages.cast<LanguageModel?>().firstWhere(
          (lang) => lang != null && _isLanguageLevelInvalid(lang),
          orElse: () => null,
        );

    if (invalidLanguage != null) {
      widget.onJobuMessageChange(
        'Nível de idioma "${invalidLanguage.name}" muito baixo.',
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

  Widget _buildValidationIcon({
    required BuildContext context,
    required bool isInvalid,
    required bool isValid,
  }) {
    if (isInvalid) {
      return Icon(
        Icons.error_outline_rounded,
        size: 20,
        color: Theme.of(context).colorScheme.error,
      );
    }

    if (isValid) {
      return Icon(
        Icons.check_circle_rounded,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

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
                        onPressed: _continue,
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
    final isInvalid = _isLanguageLevelInvalid(lang);
    final isValid = _isLanguageLevelValid(lang);

    final borderColor = isInvalid
        ? theme.colorScheme.error
        : isValid
            ? theme.colorScheme.primary
            : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      _getFlag(lang),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lang.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (lang.name != 'Português')
                    IconButton(
                      onPressed: () => _removeLanguage(index),
                      icon: const Icon(Icons.delete, size: 18),
                    ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Padding(
                      key: ValueKey('${lang.name}-${lang.level}'),
                      padding: const EdgeInsets.only(right: 6),
                      child: _buildValidationIcon(
                        context: context,
                        isInvalid: isInvalid,
                        isValid: isValid,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                  color: isInvalid
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  fontWeight:
                      isInvalid || isValid ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              Text(
                '${lang.level}%',
                style: TextStyle(
                  color: isInvalid
                      ? theme.colorScheme.error
                      : isValid
                          ? theme.colorScheme.primary
                          : null,
                  fontWeight:
                      isInvalid || isValid ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}