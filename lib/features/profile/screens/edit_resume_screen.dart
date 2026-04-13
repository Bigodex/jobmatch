// =======================================================
// EDIT RESUME SCREEN
// -------------------------------------------------------
// Agora no mesmo padrão do onboarding:
// - Email
// - Data de Nascimento
// - Estado
// - Cidade
// - Resumo
// - API de estados e cidades
// =======================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/auth/providers/auth_provider.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/features/profile/models/resume_model.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';
import 'package:jobmatch/features/profile/screens/success_screen.dart';
import 'package:jobmatch/shared/widgets/app_header.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';
import 'package:jobmatch/shared/widgets/app_validated_input_field.dart';
import 'package:jobmatch/shared/widgets/app_validated_selector_field.dart';

class EditResumeScreen extends ConsumerStatefulWidget {
  final ResumeModel resume;
  final String? email;

  const EditResumeScreen({
    super.key,
    required this.resume,
    this.email,
  });

  @override
  ConsumerState<EditResumeScreen> createState() => _EditResumeScreenState();
}

class _EditResumeScreenState extends ConsumerState<EditResumeScreen> {
  late final TextEditingController emailController;
  late final TextEditingController birthDateController;
  late final TextEditingController descriptionController;
  late final FocusNode _birthDateFocusNode;

  DateTime? _birthDate;
  String? selectedUf;
  String? selectedCity;

  bool _emailHasError = false;
  bool _birthDateHasError = false;
  bool _stateHasError = false;
  bool _cityHasError = false;
  bool _descriptionHasError = false;

  bool isValid = false;
  bool hasChanged = false;

  static const Map<String, int> _monthsMap = {
    'janeiro': 1,
    'fevereiro': 2,
    'marco': 3,
    'março': 3,
    'abril': 4,
    'maio': 5,
    'junho': 6,
    'julho': 7,
    'agosto': 8,
    'setembro': 9,
    'outubro': 10,
    'novembro': 11,
    'dezembro': 12,
  };

  @override
  void initState() {
    super.initState();

    final profileState = ref.read(profileProvider);
    final currentProfile = profileState.maybeWhen(
      data: (profile) => profile,
      orElse: () => null,
    );

    final initialEmail = widget.email ?? currentProfile?.user.email ?? '';

    emailController = TextEditingController(text: initialEmail);

    _birthDate = widget.resume.birthDate;
    birthDateController = TextEditingController(
      text: _birthDate != null ? _formatDateLong(_birthDate!) : '',
    );

    final parsedLocation = _parseStoredLocation(
      widget.resume.city,
      widget.resume.state,
    );

    selectedUf = parsedLocation.uf;
    selectedCity = parsedLocation.city;

    descriptionController = TextEditingController(
      text: widget.resume.description != null
          ? _capitalizeFirst(widget.resume.description!)
          : '',
    );

    _birthDateFocusNode = FocusNode();
    _birthDateFocusNode.addListener(_handleBirthDateFocusChange);

    emailController.addListener(_validate);
    descriptionController.addListener(_validate);

    Future.microtask(() async {
      await ref.read(onboardingProvider.notifier).loadStates();

      if (selectedUf != null && selectedUf!.isNotEmpty) {
        ref.read(onboardingProvider.notifier).setLocation(
          uf: selectedUf,
          city: selectedCity,
        );

        await ref.read(onboardingProvider.notifier).loadCitiesByUf(selectedUf!);
      }

      _validate();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    birthDateController.dispose();
    descriptionController.dispose();
    _birthDateFocusNode.removeListener(_handleBirthDateFocusChange);
    _birthDateFocusNode.dispose();
    super.dispose();
  }

  // ===================================================
  // FORMATTERS / HELPERS
  // ===================================================
  String _capitalizeFirst(String value) {
    if (value.isEmpty) return value;

    final firstIndex = value.indexOf(RegExp(r'[a-zà-ÿA-ZÀ-Ÿ]'));
    if (firstIndex == -1) return value;

    final firstChar = value[firstIndex];
    final upperFirst = firstChar.toUpperCase();

    return value.substring(0, firstIndex) +
        upperFirst +
        value.substring(firstIndex + 1);
  }

  String _normalizeText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }

  String _formatDateInput(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  String _formatDateLong(DateTime date) {
    const months = [
      '',
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    return '${date.day} de ${months[date.month]} de ${date.year}';
  }

  void _handleBirthDateFocusChange() {
    if (!mounted) return;

    if (_birthDateFocusNode.hasFocus) {
      _showBirthDateForEditing();
    } else {
      _finalizeBirthDateField();
    }
  }

  void _showBirthDateForEditing() {
    if (_birthDate == null) return;

    final formatted = _formatDateInput(_birthDate!);

    if (birthDateController.text == formatted) return;

    birthDateController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  void _finalizeBirthDateField() {
    final rawText = birthDateController.text.trim();
    final parsed = _parseBirthDate(rawText);

    setState(() {
      _birthDate = parsed;

      if (_birthDateHasError && rawText.isNotEmpty) {
        _birthDateHasError = parsed == null;
      }
    });

    if (parsed != null) {
      final formatted = _formatDateLong(parsed);

      birthDateController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
        composing: TextRange.empty,
      );
    }

    _validate();
  }

  bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(value.trim());
  }

  bool _validateDescription(String value) {
    return value.trim().length >= 10;
  }

  bool _validateDateParts({
    required int day,
    required int month,
    required int year,
  }) {
    if (month < 1 || month > 12) return false;
    if (year < 1950) return false;

    final parsed = DateTime(year, month, day);

    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return false;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (parsed.isAfter(today)) return false;

    return true;
  }

  DateTime? _tryParseBirthDateNumeric(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length != 8) return null;

    final day = int.tryParse(digits.substring(0, 2));
    final month = int.tryParse(digits.substring(2, 4));
    final year = int.tryParse(digits.substring(4, 8));

    if (day == null || month == null || year == null) return null;
    if (!_validateDateParts(day: day, month: month, year: year)) return null;

    return DateTime(year, month, day);
  }

  DateTime? _tryParseBirthDateLong(String value) {
    final normalized = _normalizeText(value);

    final match = RegExp(
      r'^(\d{1,2})\s+de\s+([a-z]+)\s+de\s+(\d{4})$',
    ).firstMatch(normalized);

    if (match == null) return null;

    final day = int.tryParse(match.group(1) ?? '');
    final monthName = match.group(2) ?? '';
    final year = int.tryParse(match.group(3) ?? '');

    if (day == null || year == null) return null;

    final month = _monthsMap[monthName];
    if (month == null) return null;

    if (!_validateDateParts(day: day, month: month, year: year)) return null;

    return DateTime(year, month, day);
  }

  DateTime? _parseBirthDate(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;

    final numericParsed = _tryParseBirthDateNumeric(text);
    if (numericParsed != null) return numericParsed;

    final longParsed = _tryParseBirthDateLong(text);
    if (longParsed != null) return longParsed;

    return null;
  }

  DateTime? _resolveBirthDateFromField() {
    final text = birthDateController.text.trim();

    if (text.isEmpty) return null;

    final parsed = _parseBirthDate(text);
    if (parsed != null) return parsed;

    return _birthDate;
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

  // ===================================================
  // VALIDATE
  // ===================================================
  void _validate() {
    final onboarding = ref.read(onboardingProvider);

    final emailValue = emailController.text.trim();
    final descriptionValue = descriptionController.text.trim();
    final parsedBirthDate = _resolveBirthDateFromField();

    final hasUf = selectedUf != null && selectedUf!.trim().isNotEmpty;
    final hasCity = selectedCity != null && selectedCity!.trim().isNotEmpty;

    final locationValid = hasUf &&
        hasCity &&
        _isCityFromSelectedUf(onboarding.cities, selectedCity!);

    _emailHasError = emailValue.isNotEmpty && !_isValidEmail(emailValue);
    _birthDateHasError =
        birthDateController.text.trim().isNotEmpty && parsedBirthDate == null;
    _stateHasError = false;
    _cityHasError = false;
    _descriptionHasError =
        descriptionValue.isNotEmpty && !_validateDescription(descriptionValue);

    final originalEmail = widget.email ??
        ref.read(profileProvider).maybeWhen(
              data: (profile) => profile.user.email,
              orElse: () => '',
            );

    hasChanged =
        emailValue != originalEmail?.trim() ||
        parsedBirthDate != widget.resume.birthDate ||
        (selectedUf ?? '') != (widget.resume.state ?? '') ||
        (selectedCity ?? '') != (widget.resume.city ?? '') ||
        descriptionValue != (widget.resume.description ?? '');

    isValid = emailValue.isNotEmpty &&
        !_emailHasError &&
        parsedBirthDate != null &&
        hasUf &&
        hasCity &&
        locationValid &&
        descriptionValue.isNotEmpty &&
        !_descriptionHasError;

    setState(() {});
  }

  // ===================================================
  // MODAIS
  // ===================================================
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
      selectedCity = null;
      _stateHasError = false;
      _cityHasError = false;
    });

    ref.read(onboardingProvider.notifier).setLocation(
          uf: uf,
          city: null,
        );

    await ref.read(onboardingProvider.notifier).loadCitiesByUf(uf);
    _validate();
  }

  Future<void> _openCitySelector(OnboardingState onboarding) async {
    if (selectedUf == null || selectedUf!.trim().isEmpty) {
      setState(() {
        _stateHasError = true;
        _cityHasError = true;
      });
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
        return nome == (selectedCity ?? '').trim().toLowerCase();
      },
    );

    if (selected == null) return;

    final cityName = (selected['nome'] ?? '').toString().trim();
    if (cityName.isEmpty) return;

    setState(() {
      selectedCity = cityName;
      _stateHasError = false;
      _cityHasError = false;
    });

    ref.read(onboardingProvider.notifier).setLocation(
          uf: selectedUf,
          city: cityName,
        );

    _validate();
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

  String _getSaveErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Esse e-mail já está em uso.';
        case 'invalid-email':
          return 'Digite um e-mail válido.';
        case 'requires-recent-login':
          return 'Faça login novamente para alterar seu e-mail.';
        case 'user-not-authenticated':
          return 'Nenhum usuário autenticado.';
        default:
          return error.message ?? 'Não foi possível alterar o e-mail.';
      }
    }

    return 'Não foi possível salvar as alterações.';
  }

  // ===================================================
  // SAVE
  // ===================================================
  Future<void> _save() async {
    final profile = ref.read(profileProvider).maybeWhen(
          data: (profile) => profile,
          orElse: () => null,
        );

    if (profile == null) return;

    final newEmail = emailController.text.trim();
    final currentEmail = (widget.email ?? profile.user.email).trim();
    final emailChanged = newEmail != currentEmail;

    try {
      if (emailChanged) {
        await ref
            .read(authControllerProvider.notifier)
            .updateCurrentUserEmail(newEmail);

        final authState = ref.read(authControllerProvider);

        if (authState.hasError) {
          throw authState.error!;
        }
      }

      final updatedResume = widget.resume.copyWith(
        birthDate: _resolveBirthDateFromField(),
        state: selectedUf,
        city: selectedCity,
        description: descriptionController.text.trim(),
      );

      final updatedProfile = profile.copyWith(
        user: profile.user.copyWith(
          email: newEmail,
        ),
        resume: updatedResume,
      );

      await ref.read(profileServiceProvider).updateProfile(updatedProfile);
      ref.invalidate(profileProvider);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SuccessScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade400,
          content: Text(_getSaveErrorMessage(e)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    final onboarding = ref.watch(onboardingProvider);

    final stateValue = _getSelectedUfLabel(onboarding);
    final cityValue = selectedCity ?? '';

    final stateEnabled =
        !onboarding.isLoadingStates && onboarding.states.isNotEmpty;

    final cityEnabled = selectedUf != null &&
        selectedUf!.trim().isNotEmpty &&
        !onboarding.isLoadingCities &&
        onboarding.cities.isNotEmpty;

    final stateIsValid = selectedUf != null &&
        selectedUf!.trim().isNotEmpty &&
        selectedCity != null &&
        selectedCity!.trim().isNotEmpty &&
        _isCityFromSelectedUf(onboarding.cities, selectedCity!);

    final cityIsValid = stateIsValid;

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
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            color: theme.dividerColor.withOpacity(0.2),
                          ),
                          const SizedBox(height: 12),
                          _editItem(
                            icon: AppIcons.mail,
                            title: 'Email',
                            child: AppValidatedInputField(
                              controller: emailController,
                              hint: 'Digite seu email',
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              hasError: _emailHasError,
                              isValid: emailController.text.trim().isNotEmpty &&
                                  !_emailHasError,
                              onChanged: (_) => _validate(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _editItem(
                            icon: AppIcons.cake,
                            title: widget.resume.labels.birthDateLabel,
                            child: AppValidatedInputField(
                              controller: birthDateController,
                              focusNode: _birthDateFocusNode,
                              hint: 'DD/MM/AAAA',
                              maxLength:
                                  _birthDateFocusNode.hasFocus ? 10 : 30,
                              hasError: _birthDateHasError,
                              isValid: _resolveBirthDateFromField() != null,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9/]'),
                                ),
                              ],
                              onEditingComplete: () {
                                _birthDateFocusNode.unfocus();
                                _finalizeBirthDateField();
                              },
                              onTapOutside: (_) {
                                _birthDateFocusNode.unfocus();
                                _finalizeBirthDateField();
                              },
                              onChanged: (_) => _validate(),
                            ),
                          ),
                          const SizedBox(height: 12),
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
                              hint: selectedUf == null ||
                                      selectedUf!.trim().isEmpty
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
                            title: widget.resume.labels.descriptionLabel,
                            child: AppValidatedInputField(
                              controller: descriptionController,
                              hint:
                                  'Fale um pouco sobre você, sua área e objetivo.',
                              maxLines: 5,
                              maxLength: 300,
                              hasError: _descriptionHasError,
                              isValid: descriptionController.text
                                      .trim()
                                      .isNotEmpty &&
                                  !_descriptionHasError,
                              inputFormatters: [
                                _CapitalizeFirstFormatter(),
                              ],
                              onChanged: (_) => _validate(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (isValid && hasChanged) ? _save : null,
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

class _CapitalizeFirstFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final value = newValue.text;

    if (value.isEmpty) return newValue;

    final firstIndex = value.indexOf(RegExp(r'[a-zà-ÿA-ZÀ-Ÿ]'));
    if (firstIndex == -1) return newValue;

    final firstChar = value[firstIndex].toUpperCase();
    final formatted = value.substring(0, firstIndex) +
        firstChar +
        value.substring(firstIndex + 1);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }
}