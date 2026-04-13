// =======================================================
// EDIT LANGUAGE SCREEN
// -------------------------------------------------------
// Agora no mesmo padrão do StepLanguages:
// - Modal de seleção com busca
// - Mais idiomas
// - Validação visual ativa em tempo real
// - Item com borda de validação
// - Ícone de check / erro por item
// - Português padrão não pode ser removido
// - Botão inteligente de salvar
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/utils/validators.dart';

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

  late List<LanguageModel> _edited;

  String? languagesError;
  bool isValid = true;
  bool hasChanged = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.languages.isNotEmpty) {
      _edited = widget.languages
          .map(
            (e) => LanguageModel(
              name: e.name,
              flag: e.flag,
              level: e.level,
            ),
          )
          .toList();
    } else {
      _edited = [
        LanguageModel(
          name: 'Português',
          level: 100,
          flag: _languagesMap['Português'] ?? '🇧🇷',
        ),
      ];
    }

    _validate();
  }

  // ===================================================
  // VALIDAÇÃO GLOBAL
  // ===================================================
  void _validate() {
    languagesError = AppValidators.validateLanguagesFull(_edited);

    hasChanged = AppValidators.hasLanguagesChanged(widget.languages, _edited);

    isValid = languagesError == null;

    if (mounted) {
      setState(() {});
    }
  }

  bool _isLanguageLevelInvalid(LanguageModel lang) {
    return lang.level == 0 || lang.level == 5;
  }

  bool _isLanguageLevelValid(LanguageModel lang) {
    return !_isLanguageLevelInvalid(lang);
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

  // ===================================================
  // SAVE
  // ===================================================
  Future<void> _save() async {
    _validate();

    if (!isValid || !hasChanged) return;

    try {
      setState(() {
        isSaving = true;
      });

      await ref.read(profileProvider.notifier).updateLanguages(_edited);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SuccessScreen(),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ===================================================
  // ADD LANGUAGE
  // ===================================================
  Future<void> _addLanguage() async {
    final availableLanguages = _languagesMap.keys
        .where((name) => !_edited.any((e) => e.name == name))
        .toList();

    if (availableLanguages.isEmpty) return;

    final selected = await _showLanguageSelectionModal(
      title: 'Selecionar idioma',
      searchHint: 'Buscar idioma',
      languages: availableLanguages,
    );

    if (selected != null) {
      if (_edited.any((e) => e.name == selected)) return;

      setState(() {
        _edited.add(
          LanguageModel(
            name: selected,
            level: 50,
            flag: _languagesMap[selected] ?? '🌍',
          ),
        );
      });

      _validate();
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
                                              color: Colors.white.withOpacity(0.05),
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

  // ===================================================
  // REMOVE
  // ===================================================
  void _removeLanguage(int index) {
    if (_edited[index].name == 'Português') return;

    setState(() {
      _edited.removeAt(index);
    });

    _validate();
  }

  // ===================================================
  // UPDATE LEVEL
  // ===================================================
  void _updateLevel(int index, int value) {
    final current = _edited[index];

    setState(() {
      _edited[index] = LanguageModel(
        name: current.name,
        level: value,
        flag: current.flag,
      );
    });

    _validate();
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
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppIcons.language,
                                width: 20,
                              ),
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
                            children: List.generate(_edited.length, (index) {
                              final lang = _edited[index];

                              return Column(
                                children: [
                                  _item(lang, index),
                                  if (index != _edited.length - 1)
                                    const Divider(height: 24),
                                ],
                              );
                            }),
                          ),

                          if (languagesError != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              languagesError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ],

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
                              onPressed: (isValid && hasChanged && !isSaving)
                                  ? _save
                                  : null,
                              child: Text(
                                isSaving ? 'Salvando...' : 'Salvar',
                              ),
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

  Widget _item(LanguageModel lang, int index) {
    final theme = Theme.of(context);
    final isInvalid = _isLanguageLevelInvalid(lang);
    final isValidState = _isLanguageLevelValid(lang);

    final borderColor = isInvalid
        ? theme.colorScheme.error
        : isValidState
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
                        isValid: isValidState,
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
                  fontWeight: isInvalid || isValidState
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
              Text(
                '${lang.level}%',
                style: TextStyle(
                  color: isInvalid
                      ? theme.colorScheme.error
                      : isValidState
                          ? theme.colorScheme.primary
                          : null,
                  fontWeight: isInvalid || isValidState
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}