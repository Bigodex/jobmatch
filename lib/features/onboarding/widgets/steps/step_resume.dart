// =======================================================
// STEP RESUME
// -------------------------------------------------------
// Resumo inicial do perfil no onboarding
// =======================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';
import 'package:jobmatch/shared/widgets/app_validated_input_field.dart';
import 'package:jobmatch/shared/widgets/app_validated_selector_field.dart';

// =======================================================
// CITY FORMATTER
// =======================================================
class CityInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = _toTitleCase(newValue.text);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  static String _toTitleCase(String value) {
    if (value.isEmpty) return value;

    final buffer = StringBuffer();
    bool capitalizeNext = true;

    for (int i = 0; i < value.length; i++) {
      final char = value[i];

      if (capitalizeNext && RegExp(r'[a-zà-ÿA-ZÀ-Ÿ]').hasMatch(char)) {
        buffer.write(char.toUpperCase());
        capitalizeNext = false;
      } else {
        buffer.write(char);
        capitalizeNext = char == ' ' || char == '-' || char == '\'';
      }
    }

    return buffer.toString();
  }
}

// =======================================================
// DESCRIPTION FORMATTER
// =======================================================
class ResumeDescriptionInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = _capitalizeFirst(newValue.text);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  static String _capitalizeFirst(String value) {
    if (value.isEmpty) return value;

    final firstIndex = value.indexOf(RegExp(r'[a-zà-ÿA-ZÀ-Ÿ]'));

    if (firstIndex == -1) return value;

    final firstChar = value[firstIndex];
    final upperFirst = firstChar.toUpperCase();

    return value.substring(0, firstIndex) +
        upperFirst +
        value.substring(firstIndex + 1);
  }
}

class StepResume extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Function(String?) onJobuMessageChange;

  const StepResume({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepResume> createState() => _StepResumeState();
}

class _StepResumeState extends ConsumerState<StepResume> {
  late final TextEditingController cityController;
  late final TextEditingController descriptionController;

  String? selectedUf;

  bool _descriptionHasError = false;
  bool _stateHasError = false;
  bool _cityHasError = false;

  @override
  void initState() {
    super.initState();

    final onboarding = ref.read(onboardingProvider);

    final parsedLocation = _parseStoredLocation(
      onboarding.city,
      onboarding.selectedUf,
    );

    selectedUf = parsedLocation.uf;

    cityController = TextEditingController(
      text: parsedLocation.city != null
          ? CityInputFormatter._toTitleCase(parsedLocation.city!)
          : '',
    );

    descriptionController = TextEditingController(
      text: onboarding.resumeDescription != null
          ? ResumeDescriptionInputFormatter._capitalizeFirst(
              onboarding.resumeDescription!,
            )
          : '',
    );

    Future.microtask(() async {
      await ref.read(onboardingProvider.notifier).loadStates();

      if (selectedUf != null && selectedUf!.isNotEmpty) {
        ref.read(onboardingProvider.notifier).setLocation(
              uf: selectedUf,
              city: cityController.text.trim().isEmpty
                  ? null
                  : cityController.text.trim(),
            );

        await ref.read(onboardingProvider.notifier).loadCitiesByUf(selectedUf!);
      }
    });
  }

  @override
  void dispose() {
    cityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _showJobuMessage(String message) {
    widget.onJobuMessageChange(message);

    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        widget.onJobuMessageChange(null);
      }
    });
  }

  bool _validateCity(String value) {
    return value.trim().length >= 2;
  }

  bool _validateDescription(String value) {
    return value.trim().length >= 10;
  }

  bool get _hasUf => selectedUf != null && selectedUf!.trim().isNotEmpty;
  bool get _hasCity => cityController.text.trim().isNotEmpty;

  bool get _isDescriptionValid {
    final value = descriptionController.text.trim();
    if (value.isEmpty) return false;
    return _validateDescription(value);
  }

  bool _isCityFromSelectedUf(
    List<Map<String, dynamic>> cities,
    String cityName,
  ) {
    final normalized = cityName.trim().toLowerCase();

    return cities.any((city) {
      final name = (city['nome'] ?? '').toString().trim().toLowerCase();
      return name == normalized;
    });
  }

  bool _isLocationPairValid(OnboardingState onboarding) {
    if (!_hasUf || !_hasCity) return false;

    final city = cityController.text.trim();

    if (!_validateCity(city)) return false;

    return _isCityFromSelectedUf(onboarding.cities, city);
  }

  _ParsedLocation _parseStoredLocation(
    String? rawCity,
    String? rawUf,
  ) {
    if (rawUf != null &&
        rawUf.trim().isNotEmpty &&
        rawCity != null &&
        rawCity.trim().isNotEmpty) {
      return _ParsedLocation(
        city: rawCity.trim(),
        uf: rawUf.trim(),
      );
    }

    if (rawCity == null || rawCity.trim().isEmpty) {
      return const _ParsedLocation();
    }

    final value = rawCity.trim();
    final match = RegExp(r'^(.*)\s-\s([A-Z]{2})$').firstMatch(value);

    if (match != null) {
      return _ParsedLocation(
        city: match.group(1)?.trim(),
        uf: match.group(2)?.trim(),
      );
    }

    return _ParsedLocation(city: value);
  }

  bool _validateAndSave(OnboardingState onboarding) {
    final city = cityController.text.trim();
    final description = descriptionController.text.trim();

    final hasUf = _hasUf;
    final hasCity = _hasCity;
    final hasDescription = description.isNotEmpty;
    final descriptionValid = _validateDescription(description);
    final cityLengthValid = hasCity ? _validateCity(city) : true;
    final cityMatchesUf =
        hasUf && hasCity ? _isCityFromSelectedUf(onboarding.cities, city) : false;

    setState(() {
      _descriptionHasError = !hasDescription || !descriptionValid;
      _stateHasError = false;
      _cityHasError = false;

      if (!hasUf && !hasCity) {
        _stateHasError = true;
        _cityHasError = true;
      } else if (!hasUf) {
        _stateHasError = true;
      } else if (!hasCity) {
        _cityHasError = true;
      } else if (!cityLengthValid || !cityMatchesUf) {
        _stateHasError = true;
        _cityHasError = true;
      }
    });

    if (!hasUf && !hasCity) {
      _showJobuMessage(
        'Selecione seu estado e sua cidade para continuar.',
      );
      return false;
    }

    if (!hasUf) {
      _showJobuMessage(
        'Selecione seu estado para continuar.',
      );
      return false;
    }

    if (!hasCity) {
      _showJobuMessage(
        'Selecione sua cidade para continuar.',
      );
      return false;
    }

    if (!hasDescription) {
      _showJobuMessage(
        'Preencha seu resumo profissional para continuar ou clique em pular.',
      );
      return false;
    }

    if (!descriptionValid) {
      _showJobuMessage(
        'Seu resumo precisa ter pelo menos 10 caracteres.',
      );
      return false;
    }

    if (!cityLengthValid) {
      _showJobuMessage(
        'Sua cidade precisa ter pelo menos 2 caracteres.',
      );
      return false;
    }

    if (!cityMatchesUf) {
      _showJobuMessage(
        'Escolha uma cidade válida da lista para o estado selecionado.',
      );
      return false;
    }

    widget.onJobuMessageChange(null);

    ref.read(onboardingProvider.notifier).setResume(
          city: city,
          description: description,
          uf: selectedUf,
        );

    return true;
  }

  void _handleContinue(OnboardingState onboarding) {
    final ok = _validateAndSave(onboarding);
    if (!ok) return;
    widget.onNext();
  }

  void _handleSkip() {
    widget.onJobuMessageChange(null);
    widget.onSkip();
  }

  String _getSelectedUfLabel(OnboardingState onboarding) {
    if (selectedUf == null || selectedUf!.trim().isEmpty) {
      return '';
    }

    final stateMap = onboarding.states.cast<Map<String, dynamic>?>().firstWhere(
          (item) => (item?['sigla'] ?? '').toString() == selectedUf,
          orElse: () => null,
        );

    if (stateMap == null) return selectedUf!;

    final nome = (stateMap['nome'] ?? '').toString();
    final sigla = (stateMap['sigla'] ?? '').toString();

    if (nome.isEmpty && sigla.isEmpty) return '';
    return '$nome - $sigla';
  }

  Future<void> _openStateSelector(OnboardingState onboarding) async {
    if (onboarding.isLoadingStates || onboarding.states.isEmpty) return;

    final selected = await _showSelectionModal(
      title: 'Selecionar estado',
      searchHint: 'Buscar estado',
      items: onboarding.states,
      itemTitleBuilder: (item) => (item['nome'] ?? '').toString(),
      itemSubtitleBuilder: (item) => (item['sigla'] ?? '').toString(),
      filter: (item, query) {
        final nome = (item['nome'] ?? '').toString().toLowerCase();
        final sigla = (item['sigla'] ?? '').toString().toLowerCase();
        return nome.contains(query) || sigla.contains(query);
      },
      selectedItem: (item) => (item['sigla'] ?? '').toString() == selectedUf,
    );

    if (selected == null) return;

    final uf = (selected['sigla'] ?? '').toString();

    if (uf.isEmpty) return;

    setState(() {
      selectedUf = uf;
      cityController.clear();
      _stateHasError = false;
      _cityHasError = false;
    });

    widget.onJobuMessageChange(null);

    ref.read(onboardingProvider.notifier).setLocation(
          uf: uf,
          city: null,
        );

    await ref.read(onboardingProvider.notifier).loadCitiesByUf(uf);
  }

  Future<void> _openCitySelector(OnboardingState onboarding) async {
    if (selectedUf == null || selectedUf!.trim().isEmpty) {
      setState(() {
        _stateHasError = true;
        _cityHasError = true;
      });

      _showJobuMessage(
        'Escolha primeiro o estado.',
      );
      return;
    }

    if (onboarding.isLoadingCities || onboarding.cities.isEmpty) return;

    final selected = await _showSelectionModal(
      title: 'Selecionar cidade',
      searchHint: 'Buscar cidade',
      items: onboarding.cities,
      itemTitleBuilder: (item) => (item['nome'] ?? '').toString(),
      itemSubtitleBuilder: (_) => selectedUf ?? '',
      filter: (item, query) {
        final nome = (item['nome'] ?? '').toString().toLowerCase();
        return nome.contains(query);
      },
      selectedItem: (item) {
        final nome = (item['nome'] ?? '').toString().trim().toLowerCase();
        return nome == cityController.text.trim().toLowerCase();
      },
    );

    if (selected == null) return;

    final cityName = CityInputFormatter._toTitleCase(
      (selected['nome'] ?? '').toString(),
    );

    cityController.text = cityName;

    ref.read(onboardingProvider.notifier).setLocation(
          uf: selectedUf,
          city: cityName,
        );

    widget.onJobuMessageChange(null);

    setState(() {
      _stateHasError = false;
      _cityHasError = false;
    });
  }

  Future<Map<String, dynamic>?> _showSelectionModal({
    required String title,
    required String searchHint,
    required List<Map<String, dynamic>> items,
    required String Function(Map<String, dynamic>) itemTitleBuilder,
    required String Function(Map<String, dynamic>) itemSubtitleBuilder,
    required bool Function(Map<String, dynamic>, String query) filter,
    required bool Function(Map<String, dynamic>) selectedItem,
  }) async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colors = theme.extension<AppColorsExtension>()!;
        final searchController = TextEditingController();
        List<Map<String, dynamic>> filtered = List.from(items);

        return StatefulBuilder(
          builder: (context, setModalState) {
            void applyFilter(String value) {
              final query = value.trim().toLowerCase();

              setModalState(() {
                if (query.isEmpty) {
                  filtered = List.from(items);
                } else {
                  filtered = items.where((item) {
                    return filter(item, query);
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
                                  'Nenhum resultado encontrado.',
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
                                  final item = filtered[index];
                                  final isSelected = selectedItem(item);

                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(dialogContext).pop(item);
                                    },
                                    borderRadius: BorderRadius.circular(18),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                                .withOpacity(0.12)
                                            : Colors.white.withOpacity(0.035),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                                  .withOpacity(0.50)
                                              : Colors.white.withOpacity(0.06),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? theme.colorScheme.primary
                                                      .withOpacity(0.18)
                                                  : Colors.white
                                                      .withOpacity(0.05),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Icon(
                                              isSelected
                                                  ? Icons.check_rounded
                                                  : Icons.location_on_outlined,
                                              size: 20,
                                              color: isSelected
                                                  ? theme.colorScheme.primary
                                                  : Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  itemTitleBuilder(item),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  itemSubtitleBuilder(item),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white
                                                        .withOpacity(0.62),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    final onboarding = ref.watch(onboardingProvider);

    final stateValue = _getSelectedUfLabel(onboarding);
    final cityValue = cityController.text.trim();

    final stateEnabled =
        !onboarding.isLoadingStates && onboarding.states.isNotEmpty;

    final cityEnabled =
        selectedUf != null &&
        selectedUf!.trim().isNotEmpty &&
        !onboarding.isLoadingCities &&
        onboarding.cities.isNotEmpty;

    final stateIsValid = _isLocationPairValid(onboarding);
    final cityIsValid = _isLocationPairValid(onboarding);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    Row(
                      children: [
                        SvgPicture.asset(AppIcons.cv, width: 20, height: 20),
                        const SizedBox(width: 10),
                        const Text(
                          'Resumo Profissional',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: Colors.white.withOpacity(0.08),
                      height: 1,
                    ),
                    const SizedBox(height: 16),

                    _editItem(
                      icon: AppIcons.state,
                      title: 'Estado',
                      child: AppValidatedSelectorField(
                        hint: onboarding.isLoadingStates
                            ? 'Carregando estados...'
                            : 'Selecionar estado',
                        value: stateValue.isEmpty ? null : stateValue,
                        hasError: _stateHasError,
                        isValid: stateIsValid,
                        enabled: stateEnabled,
                        isLoading: onboarding.isLoadingStates,
                        onTap: () => _openStateSelector(onboarding),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _editItem(
                      icon: AppIcons.buildingfull,
                      title: 'Cidade',
                      child: AppValidatedSelectorField(
                        hint: selectedUf == null || selectedUf!.trim().isEmpty
                            ? 'Selecione primeiro o estado'
                            : onboarding.isLoadingCities
                                ? 'Carregando cidades...'
                                : onboarding.cities.isEmpty
                                    ? 'Nenhuma cidade encontrada'
                                    : 'Selecionar cidade',
                        value: cityValue.isEmpty ? null : cityValue,
                        hasError: _cityHasError,
                        isValid: cityIsValid,
                        enabled: cityEnabled,
                        isLoading: onboarding.isLoadingCities,
                        onTap: () => _openCitySelector(onboarding),
                      ),
                    ),

                    if (onboarding.locationError != null &&
                        onboarding.locationError!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        onboarding.locationError!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade300,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    _editItem(
                      icon: AppIcons.resume,
                      title: 'Resumo Profissional',
                      child: AppValidatedInputField(
                        controller: descriptionController,
                        hint: 'Fale um pouco sobre você, sua área e objetivo.',
                        maxLines: 5,
                        maxLength: 300,
                        hasError: _descriptionHasError,
                        isValid: _isDescriptionValid,
                        inputFormatters: [
                          ResumeDescriptionInputFormatter(),
                        ],
                        onChanged: (_) {
                          setState(() {
                            if (_descriptionHasError) {
                              _descriptionHasError = !_isDescriptionValid;
                            }
                          });
                          widget.onJobuMessageChange(null);
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _handleSkip,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: theme.colorScheme.primary,
                              ),
                              foregroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Pular'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleContinue(onboarding),
                            child: const Text('Continuar'),
                          ),
                        ),
                      ],
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
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: child),
      ],
    );
  }
}

class _ParsedLocation {
  final String? city;
  final String? uf;

  const _ParsedLocation({
    this.city,
    this.uf,
  });
}