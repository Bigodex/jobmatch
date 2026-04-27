// =======================================================
// STEP COMPANY JOBS
// -------------------------------------------------------
// Cadastro inicial de vagas da empresa
// - exige ao menos 1 vaga
// - seleção via modal no estilo da referência
// - estados/cidades via onboardingProvider
// =======================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/company/providers/company_onboarding_provider.dart';
import 'package:jobmatch/features/onboarding/providers/onboarding_provider.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';
import 'package:jobmatch/shared/widgets/app_validated_input_field.dart';
import 'package:jobmatch/shared/widgets/app_validated_selector_field.dart';

class StepCompanyJobs extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final Function(String?) onJobuMessageChange;

  const StepCompanyJobs({
    super.key,
    required this.onNext,
    required this.onJobuMessageChange,
  });

  @override
  ConsumerState<StepCompanyJobs> createState() => _StepCompanyJobsState();
}

class _StepCompanyJobsState extends ConsumerState<StepCompanyJobs> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _salaryController;

  String? _selectedLevel;
  String? _selectedWorkMode;
  String? _selectedUf;
  String? _selectedCity;

  bool _titleHasError = false;
  bool _descriptionHasError = false;
  bool _levelHasError = false;
  bool _workModeHasError = false;
  bool _stateHasError = false;
  bool _cityHasError = false;
  bool _jobsListHasError = false;
  bool _isNavigating = false;

  int? _editingIndex;

  final List<Map<String, String>> _jobs = [];

  static const List<_OptionItem> _levels = [
    _OptionItem(label: 'Estágio', icon: AppIcons.one),
    _OptionItem(label: 'Júnior', icon: AppIcons.two),
    _OptionItem(label: 'Pleno', icon: AppIcons.three),
    _OptionItem(label: 'Sênior', icon: AppIcons.four),
    _OptionItem(label: 'Especialista', icon: AppIcons.five),
    _OptionItem(label: 'Liderança', icon: AppIcons.six),
  ];

  static const List<_OptionItem> _workModes = [
    _OptionItem(label: 'Presencial', icon: AppIcons.presencial),
    _OptionItem(label: 'Híbrido', icon: AppIcons.hybrid),
    _OptionItem(label: 'Home Office', icon: AppIcons.homeoffice),
  ];

  bool get _isTitleValid => _titleController.text.trim().length >= 3;
  bool get _isDescriptionValid =>
      _descriptionController.text.trim().length >= 10;
  bool get _isLevelValid =>
      _selectedLevel != null && _selectedLevel!.trim().isNotEmpty;
  bool get _isWorkModeValid =>
      _selectedWorkMode != null && _selectedWorkMode!.trim().isNotEmpty;
  bool get _isStateValid =>
      _selectedUf != null && _selectedUf!.trim().isNotEmpty;
  bool get _isCityValid =>
      _selectedCity != null && _selectedCity!.trim().isNotEmpty;

  _OptionItem? get _selectedLevelOption {
    for (final item in _levels) {
      if (item.label == _selectedLevel) return item;
    }
    return null;
  }

  _OptionItem? get _selectedWorkModeOption {
    for (final item in _workModes) {
      if (item.label == _selectedWorkMode) return item;
    }
    return null;
  }

  static String _iconForLevel(String value) {
    for (final item in _levels) {
      if (item.label == value) return item.icon;
    }
    return AppIcons.three;
  }

  static String _iconForWorkMode(String value) {
    for (final item in _workModes) {
      if (item.label == value) return item.icon;
    }
    return AppIcons.model;
  }

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _salaryController = TextEditingController();

    final company = ref.read(companyOnboardingProvider);
    _jobs.addAll(
      company.jobs.map((job) {
        final locationParts = job.location.split(' - ');
        final city = locationParts.isNotEmpty ? locationParts.first : '';
        final uf = locationParts.length > 1 ? locationParts.last : '';

        return {
          'title': job.title,
          'description': job.description,
          'level': job.seniority,
          'levelIcon': _iconForLevel(job.seniority),
          'workMode': job.workModel,
          'workModeIcon': _iconForWorkMode(job.workModel),
          'uf': uf,
          'city': city,
          'salary': job.salary,
        };
      }),
    );

    Future.microtask(() async {
      await ref.read(onboardingProvider.notifier).loadStates();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _showJobuMessageAndWait(
    String message, {
    int minMilliseconds = 1400,
  }) async {
    widget.onJobuMessageChange(message);

    final estimated =
        (message.replaceAll('\n', ' ').trim().length * 42).clamp(1100, 2200);

    await Future.delayed(
      Duration(
        milliseconds: estimated > minMilliseconds ? estimated : minMilliseconds,
      ),
    );
  }

  void _clearCurrentForm() {
    _titleController.clear();
    _descriptionController.clear();
    _salaryController.clear();

    _selectedLevel = null;
    _selectedWorkMode = null;
    _selectedUf = null;
    _selectedCity = null;

    _titleHasError = false;
    _descriptionHasError = false;
    _levelHasError = false;
    _workModeHasError = false;
    _stateHasError = false;
    _cityHasError = false;
    _editingIndex = null;
  }

  void _handleAddOrUpdateJob() {
    setState(() {
      _titleHasError = !_isTitleValid;
      _descriptionHasError = !_isDescriptionValid;
      _levelHasError = !_isLevelValid;
      _workModeHasError = !_isWorkModeValid;
      _stateHasError = !_isStateValid;
      _cityHasError = !_isCityValid;
    });

    if (_titleHasError) {
      widget.onJobuMessageChange('Digite o título da vaga.');
      return;
    }

    if (_descriptionHasError) {
      widget.onJobuMessageChange('Descreva melhor a vaga.');
      return;
    }

    if (_levelHasError) {
      widget.onJobuMessageChange('Escolha o nível da vaga.');
      return;
    }

    if (_workModeHasError) {
      widget.onJobuMessageChange('Escolha o modelo de trabalho.');
      return;
    }

    if (_stateHasError) {
      widget.onJobuMessageChange('Selecione o estado.');
      return;
    }

    if (_cityHasError) {
      widget.onJobuMessageChange('Selecione a cidade.');
      return;
    }

    final jobData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'level': _selectedLevel!.trim(),
      'levelIcon': _selectedLevelOption?.icon ?? AppIcons.three,
      'workMode': _selectedWorkMode!.trim(),
      'workModeIcon': _selectedWorkModeOption?.icon ?? AppIcons.model,
      'uf': _selectedUf!.trim(),
      'city': _selectedCity!.trim(),
      'salary': _salaryController.text.trim(),
    };

    setState(() {
      if (_editingIndex != null) {
        _jobs[_editingIndex!] = jobData;
      } else {
        _jobs.add(jobData);
      }

      _jobsListHasError = false;
      _clearCurrentForm();
    });

    widget.onJobuMessageChange(
      _editingIndex != null ? 'Vaga atualizada.' : 'Boa. Vaga adicionada.',
    );
  }

  void _startEditingJob(int index) {
    final job = _jobs[index];

    setState(() {
      _editingIndex = index;
      _titleController.text = job['title'] ?? '';
      _descriptionController.text = job['description'] ?? '';
      _salaryController.text = job['salary'] ?? '';
      _selectedLevel = job['level'];
      _selectedWorkMode = job['workMode'];
      _selectedUf = job['uf'];
      _selectedCity = job['city'];

      _titleHasError = false;
      _descriptionHasError = false;
      _levelHasError = false;
      _workModeHasError = false;
      _stateHasError = false;
      _cityHasError = false;
    });

    widget.onJobuMessageChange('Editando a vaga.');
  }

  void _removeJob(int index) {
    final wasEditingSameItem = _editingIndex == index;

    setState(() {
      _jobs.removeAt(index);

      if (wasEditingSameItem) {
        _clearCurrentForm();
      } else if (_editingIndex != null && index < _editingIndex!) {
        _editingIndex = _editingIndex! - 1;
      }
    });

    widget.onJobuMessageChange('Vaga removida.');
  }

  void _persistJobs() {
    final drafts = _jobs.map((job) {
      final city = (job['city'] ?? '').trim();
      final uf = (job['uf'] ?? '').trim();
      final location = city.isEmpty && uf.isEmpty ? '' : '${city} - ${uf}';

      return CompanyJobDraft(
        title: (job['title'] ?? '').trim(),
        seniority: (job['level'] ?? '').trim(),
        workModel: (job['workMode'] ?? '').trim(),
        location: location,
        salary: (job['salary'] ?? '').trim(),
        description: (job['description'] ?? '').trim(),
      );
    }).toList();

    ref.read(companyOnboardingProvider.notifier).setJobs(drafts);
  }

  Future<void> _handleContinue() async {
    if (_isNavigating) return;

    if (_jobs.isEmpty) {
      setState(() {
        _jobsListHasError = true;
      });

      widget.onJobuMessageChange('Adicione pelo menos uma vaga.');
      return;
    }

    _persistJobs();

    setState(() {
      _isNavigating = true;
    });

    await _showJobuMessageAndWait(
      'Show. Suas vagas iniciais foram preparadas.',
      minMilliseconds: 1200,
    );

    if (!mounted) return;

    setState(() {
      _isNavigating = false;
    });

    widget.onJobuMessageChange(null);
    widget.onNext();
  }

  Future<void> _openLevelSelector() async {
    final result = await _showOptionsBottomSheet<_OptionItem>(
      title: 'Nível da vaga',
      searchHint: 'Buscar nível',
      items: _levels,
      selectedCheck: (item) => item.label == _selectedLevel,
      titleBuilder: (item) => item.label,
      subtitleBuilder: (_) => '',
      iconBuilder: (item) => item.icon,
    );

    if (result == null) return;

    setState(() {
      _selectedLevel = result.label;
      _levelHasError = false;
    });

    widget.onJobuMessageChange(null);
  }

  Future<void> _openWorkModeSelector() async {
    final result = await _showOptionsBottomSheet<_OptionItem>(
      title: 'Modelo de trabalho',
      searchHint: 'Buscar modelo',
      items: _workModes,
      selectedCheck: (item) => item.label == _selectedWorkMode,
      titleBuilder: (item) => item.label,
      subtitleBuilder: (_) => '',
      iconBuilder: (item) => item.icon,
    );

    if (result == null) return;

    setState(() {
      _selectedWorkMode = result.label;
      _workModeHasError = false;
    });

    widget.onJobuMessageChange(null);
  }

  Future<void> _openStateSelector() async {
    final onboarding = ref.read(onboardingProvider);

    final result = await _showOptionsBottomSheet<Map<String, dynamic>>(
      title: 'Estado',
      searchHint: 'Buscar estado',
      items: List<Map<String, dynamic>>.from(onboarding.states),
      selectedCheck: (item) => (item['sigla'] ?? '').toString() == _selectedUf,
      titleBuilder: (item) => (item['nome'] ?? '').toString(),
      subtitleBuilder: (item) => (item['sigla'] ?? '').toString(),
      iconBuilder: (_) => AppIcons.state,
    );

    if (result == null) return;

    final uf = (result['sigla'] ?? '').toString();

    setState(() {
      _selectedUf = uf;
      _selectedCity = null;
      _stateHasError = false;
      _cityHasError = false;
    });

    await ref.read(onboardingProvider.notifier).loadCitiesByUf(uf);
    widget.onJobuMessageChange(null);
  }

  Future<void> _openCitySelector() async {
    if (_selectedUf == null || _selectedUf!.trim().isEmpty) {
      setState(() {
        _stateHasError = true;
        _cityHasError = true;
      });
      widget.onJobuMessageChange('Escolha primeiro o estado.');
      return;
    }

    final onboarding = ref.read(onboardingProvider);

    final result = await _showOptionsBottomSheet<Map<String, dynamic>>(
      title: 'Cidade',
      searchHint: 'Buscar cidade',
      items: List<Map<String, dynamic>>.from(onboarding.cities),
      selectedCheck: (item) => (item['nome'] ?? '').toString() == _selectedCity,
      titleBuilder: (item) => (item['nome'] ?? '').toString(),
      subtitleBuilder: (_) => '',
      iconBuilder: (_) => AppIcons.pin,
    );

    if (result == null) return;

    setState(() {
      _selectedCity = (result['nome'] ?? '').toString();
      _cityHasError = false;
    });

    widget.onJobuMessageChange(null);
  }

  Future<T?> _showOptionsBottomSheet<T>({
    required String title,
    required String searchHint,
    required List<T> items,
    required bool Function(T item) selectedCheck,
    required String Function(T item) titleBuilder,
    required String Function(T item) subtitleBuilder,
    required String Function(T item) iconBuilder,
  }) async {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    final controller = TextEditingController();

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: colors.cardTertiary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        final filtered = ValueNotifier<List<T>>(items);

        void applyFilter(String value) {
          final query = value.trim().toLowerCase();

          if (query.isEmpty) {
            filtered.value = items;
            return;
          }

          filtered.value = items.where((item) {
            final titleText = titleBuilder(item).toLowerCase();
            final subtitleText = subtitleBuilder(item).toLowerCase();
            return titleText.contains(query) || subtitleText.contains(query);
          }).toList();
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 0,
              right: 0,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: controller,
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
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.10),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ValueListenableBuilder<List<T>>(
                    valueListenable: filtered,
                    builder: (context, list, _) {
                      if (list.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            'Nenhum resultado encontrado.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.70),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: list.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: Colors.white.withOpacity(0.08),
                        ),
                        itemBuilder: (context, index) {
                          final item = list[index];
                          final selected = selectedCheck(item);
                          final subtitle = subtitleBuilder(item);

                          return InkWell(
                            onTap: () => Navigator.of(context).pop(item),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    iconBuilder(item),
                                    width: 18,
                                    height: 18,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          titleBuilder(item),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: selected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if (subtitle.trim().isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            subtitle,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white
                                                  .withOpacity(0.62),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (selected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 22,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getSelectedStateLabel(OnboardingState onboarding) {
    if (_selectedUf == null || _selectedUf!.trim().isEmpty) return '';

    final stateMap = onboarding.states.cast<Map<String, dynamic>?>().firstWhere(
          (item) => (item?['sigla'] ?? '').toString() == _selectedUf,
          orElse: () => null,
        );

    if (stateMap == null) return _selectedUf!;

    final nome = (stateMap['nome'] ?? '').toString();
    final sigla = (stateMap['sigla'] ?? '').toString();

    if (nome.isEmpty && sigla.isEmpty) return '';
    return '$nome - $sigla';
  }

  String _getCompanyName() {
    final company = ref.watch(companyOnboardingProvider);
    final name = company.companyName?.trim() ?? '';
    return name.isEmpty ? 'Sua empresa' : name;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final onboarding = ref.watch(onboardingProvider);
    final companyName = _getCompanyName();

    final stateValue = _getSelectedStateLabel(onboarding);
    final cityValue = _selectedCity ?? '';

    return Transform.translate(
      offset: const Offset(0, -6),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            AppSectionCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: 16,
                    top: 8,
                  ),
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
                            AppIcons.briefcase,
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Vagas',
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

                      _fieldTitle(
                        icon: AppIcons.briefcase,
                        title: 'Título da vaga',
                      ),
                      const SizedBox(height: 8),
                      AppValidatedInputField(
                        controller: _titleController,
                        hint: 'Ex: Desenvolvedor Flutter',
                        maxLength: 80,
                        hasError: _titleHasError,
                        isValid: _isTitleValid,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (value) {
                          setState(() {
                            if (_titleHasError) {
                              _titleHasError = value.trim().length < 3;
                            }
                          });
                          widget.onJobuMessageChange(null);
                        },
                      ),

                      const SizedBox(height: 10),

                      _fieldTitle(
                        icon: AppIcons.info,
                        title: 'Descrição da vaga',
                      ),
                      const SizedBox(height: 8),
                      AppValidatedInputField(
                        controller: _descriptionController,
                        hint:
                            'Descreva responsabilidades, requisitos e diferenciais.',
                        maxLength: 500,
                        maxLines: 5,
                        hasError: _descriptionHasError,
                        isValid: _isDescriptionValid,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (value) {
                          setState(() {
                            if (_descriptionHasError) {
                              _descriptionHasError = value.trim().length < 10;
                            }
                          });
                          widget.onJobuMessageChange(null);
                        },
                      ),

                      const SizedBox(height: 10),

                      _fieldTitle(
                        icon: AppIcons.chart,
                        title: 'Nível',
                      ),
                      const SizedBox(height: 8),
                      AppValidatedSelectorField(
                        hint: 'Selecione o nível da vaga',
                        value: _selectedLevel,
                        selectedIcon: _selectedLevelOption?.icon,
                        onTap: _openLevelSelector,
                        hasError: _levelHasError,
                        isValid: _isLevelValid,
                      ),

                      const SizedBox(height: 10),

                      _fieldTitle(
                        icon: AppIcons.model,
                        title: 'Modelo de trabalho',
                      ),
                      const SizedBox(height: 8),
                      AppValidatedSelectorField(
                        hint: 'Selecione o modelo da vaga',
                        value: _selectedWorkMode,
                        selectedIcon: _selectedWorkModeOption?.icon,
                        onTap: _openWorkModeSelector,
                        hasError: _workModeHasError,
                        isValid: _isWorkModeValid,
                      ),

                      const SizedBox(height: 10),

                      _fieldTitle(
                        icon: AppIcons.state,
                        title: 'Estado',
                      ),
                      const SizedBox(height: 8),
                      AppValidatedSelectorField(
                        hint: onboarding.isLoadingStates
                            ? 'Carregando estados...'
                            : 'Selecionar estado',
                        value: stateValue.isEmpty ? null : stateValue,
                        hasError: _stateHasError,
                        isValid: _isStateValid,
                        isLoading: onboarding.isLoadingStates,
                        enabled: !onboarding.isLoadingStates,
                        onTap: _openStateSelector,
                      ),

                      const SizedBox(height: 10),

                      _fieldTitle(
                        icon: AppIcons.pin,
                        title: 'Cidade',
                      ),
                      const SizedBox(height: 8),
                      AppValidatedSelectorField(
                        hint: _selectedUf == null
                            ? 'Selecione primeiro o estado'
                            : onboarding.isLoadingCities
                                ? 'Carregando cidades...'
                                : 'Selecionar cidade',
                        value: cityValue.isEmpty ? null : cityValue,
                        hasError: _cityHasError,
                        isValid: _isCityValid,
                        isLoading: onboarding.isLoadingCities,
                        enabled:
                            _selectedUf != null && !onboarding.isLoadingCities,
                        onTap: _openCitySelector,
                      ),

                      const SizedBox(height: 10),

                      _fieldTitle(
                        icon: AppIcons.bagmoney,
                        title: 'Salário (opcional)',
                      ),
                      const SizedBox(height: 8),
                      AppValidatedInputField(
                        controller: _salaryController,
                        hint: 'Ex: R\$ 4.000,00',
                        maxLength: 20,
                        hasError: false,
                        isValid: _salaryController.text.trim().isNotEmpty,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CurrencyPtBrInputFormatter(),
                        ],
                        onChanged: (_) {
                          setState(() {});
                          widget.onJobuMessageChange(null);
                        },
                      ),

                      const SizedBox(height: 16),

                      TextButton.icon(
                        onPressed: _handleAddOrUpdateJob,
                        icon: Icon(
                          _editingIndex != null ? Icons.edit : Icons.add,
                        ),
                        label: Text(
                          _editingIndex != null
                              ? 'Salvar edição da vaga'
                              : 'Adicionar vaga',
                        ),
                      ),

                      if (_editingIndex != null) ...[
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _clearCurrentForm();
                            });
                            widget.onJobuMessageChange('Edição cancelada.');
                          },
                          child: const Text('Cancelar edição'),
                        ),
                      ],

                      if (_jobs.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Divider(
                          color: Colors.white.withOpacity(0.08),
                          height: 1,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Vagas adicionadas',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_jobs.length, (index) {
                          final job = _jobs[index];

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _jobs.length - 1 ? 0 : 14,
                            ),
                            child: _jobCardSection(
                              companyName: companyName,
                              title: job['title'] ?? '',
                              description: job['description'] ?? '',
                              level: job['level'] ?? '',
                              levelIcon: job['levelIcon'] ?? AppIcons.three,
                              workMode: job['workMode'] ?? '',
                              workModeIcon:
                                  job['workModeIcon'] ?? AppIcons.model,
                              location:
                                  '${job['city'] ?? ''} - ${job['uf'] ?? ''}',
                              salary: job['salary'] ?? '',
                              onEdit: () => _startEditingJob(index),
                              onRemove: () => _removeJob(index),
                            ),
                          );
                        }),
                      ],

                      if (_jobsListHasError) ...[
                        const SizedBox(height: 14),
                        Text(
                          'Você precisa adicionar pelo menos uma vaga.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleContinue,
                          child: _isNavigating
                              ? const _LoadingDots(color: Colors.black)
                              : const Text('Continuar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldTitle({
    required String icon,
    required String title,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _jobCardSection({
    required String companyName,
    required String title,
    required String description,
    required String level,
    required String levelIcon,
    required String workMode,
    required String workModeIcon,
    required String location,
    required String salary,
    required VoidCallback onEdit,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 6, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onEdit,
                splashRadius: 18,
                icon: SvgPicture.asset(
                  AppIcons.pencil,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                onPressed: onRemove,
                splashRadius: 18,
                icon: SvgPicture.asset(
                  AppIcons.trash,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
        _jobCard(
          companyName: companyName,
          title: title,
          description: description,
          level: level,
          levelIcon: levelIcon,
          workMode: workMode,
          workModeIcon: workModeIcon,
          location: location,
          salary: salary,
        ),
      ],
    );
  }

  Widget _jobCard({
    required String companyName,
    required String title,
    required String description,
    required String level,
    required String levelIcon,
    required String workMode,
    required String workModeIcon,
    required String location,
    required String salary,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              companyName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '5★',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      levelIcon,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      level.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.10),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sobre a vaga',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _jobInfoLine(
                  icon: AppIcons.bagmoney,
                  text: salary.trim().isEmpty ? 'Salário a combinar' : salary,
                ),
                const SizedBox(height: 10),
                _jobInfoLine(
                  icon: AppIcons.buildingbriefcase,
                  text: location,
                ),
                const SizedBox(height: 10),
                _jobInfoLine(
                  icon: workModeIcon,
                  text: workMode,
                ),
                if (description.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobInfoLine({
    required String icon,
    required String text,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 17,
          height: 17,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.78),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionItem {
  final String label;
  final String icon;

  const _OptionItem({
    required this.label,
    required this.icon,
  });
}

class _CurrencyPtBrInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final value = int.parse(digits);
    final cents = value % 100;
    final reais = value ~/ 100;

    final reaisFormatted = _formatThousands(reais);
    final centsFormatted = cents.toString().padLeft(2, '0');
    final formatted = 'R\$ $reaisFormatted,$centsFormatted';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatThousands(int value) {
    final raw = value.toString();
    final chars = raw.split('').reversed.toList();
    final buffer = StringBuffer();

    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(chars[i]);
    }

    return buffer.toString().split('').reversed.join();
  }
}

// =======================================================
// LOADING DOTS
// =======================================================
class _LoadingDots extends StatefulWidget {
  final Color color;

  const _LoadingDots({
    this.color = Colors.white,
  });

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const double _dotSize = 5;
  static const double _spacing = 4;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _opacityForDot(int index) {
    final value = _controller.value;
    final phase = value * 3;

    if (phase >= index && phase < index + 1) {
      return 1.0;
    }

    return 0.28;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index == 2 ? 0 : _spacing,
              ),
              child: Opacity(
                opacity: _opacityForDot(index),
                child: Container(
                  width: _dotSize,
                  height: _dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}