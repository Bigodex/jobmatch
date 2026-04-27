// =======================================================
// COMPANY ONBOARDING PROVIDER
// -------------------------------------------------------
// Controla o estado do fluxo de cadastro da página
// empresarial
// =======================================================

import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

import 'package:jobmatch/features/onboarding/services/ibge_localidades_service.dart';

// =======================================================
// SENTINELA PARA COPYWITH
// =======================================================
const Object _unset = Object();

// =======================================================
// JOB DRAFT MODEL
// -------------------------------------------------------
// Modelo simples para vagas em rascunho durante o fluxo
// =======================================================
class CompanyJobDraft {
  final String title;
  final String seniority;
  final String workModel;
  final String location;
  final String salary;
  final String description;

  const CompanyJobDraft({
    this.title = '',
    this.seniority = '',
    this.workModel = '',
    this.location = '',
    this.salary = '',
    this.description = '',
  });

  CompanyJobDraft copyWith({
    String? title,
    String? seniority,
    String? workModel,
    String? location,
    String? salary,
    String? description,
  }) {
    return CompanyJobDraft(
      title: title ?? this.title,
      seniority: seniority ?? this.seniority,
      workModel: workModel ?? this.workModel,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'seniority': seniority,
      'workModel': workModel,
      'location': location,
      'salary': salary,
      'description': description,
    };
  }

  factory CompanyJobDraft.fromMap(Map<String, dynamic> map) {
    return CompanyJobDraft(
      title: (map['title'] ?? '').toString(),
      seniority: (map['seniority'] ?? '').toString(),
      workModel: (map['workModel'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      salary: (map['salary'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
    );
  }
}

// =======================================================
// STATE
// =======================================================
class CompanyOnboardingState {
  // ===================================================
  // HEADER
  // ===================================================
  final String? coverUrl;
  final String? logoUrl;

  // ===================================================
  // IDENTIDADE
  // ===================================================
  final String? companyName;
  final String? companyCategory;
  final String? cnpj;

  // ===================================================
  // SOBRE
  // ===================================================
  final String? slogan;
  final String? sector;
  final String? companyType;
  final String? website;
  final String? description;

  // ===================================================
  // LOCALIZAÇÃO / IBGE
  // ===================================================
  final List<Map<String, dynamic>> states;
  final List<Map<String, dynamic>> cities;
  final bool isLoadingStates;
  final bool isLoadingCities;
  final String? locationError;

  // ===================================================
  // CONTRATAÇÃO / VAGAS
  // ===================================================
  final bool isHiring;
  final List<CompanyJobDraft> jobs;

  // ===================================================
  // COLABORADORES
  // ===================================================
  final int? employeesCount;
  final String? companySize;

  const CompanyOnboardingState({
    this.coverUrl,
    this.logoUrl,
    this.companyName,
    this.companyCategory,
    this.cnpj,
    this.slogan,
    this.sector,
    this.companyType,
    this.website,
    this.description,
    this.states = const [],
    this.cities = const [],
    this.isLoadingStates = false,
    this.isLoadingCities = false,
    this.locationError,
    this.isHiring = false,
    this.jobs = const [],
    this.employeesCount,
    this.companySize,
  });

  // ===================================================
  // COPY WITH
  // ===================================================
  CompanyOnboardingState copyWith({
    Object? coverUrl = _unset,
    Object? logoUrl = _unset,
    Object? companyName = _unset,
    Object? companyCategory = _unset,
    Object? cnpj = _unset,
    Object? slogan = _unset,
    Object? sector = _unset,
    Object? companyType = _unset,
    Object? website = _unset,
    Object? description = _unset,
    List<Map<String, dynamic>>? states,
    List<Map<String, dynamic>>? cities,
    bool? isLoadingStates,
    bool? isLoadingCities,
    Object? locationError = _unset,
    bool? isHiring,
    List<CompanyJobDraft>? jobs,
    Object? employeesCount = _unset,
    Object? companySize = _unset,
  }) {
    return CompanyOnboardingState(
      coverUrl: identical(coverUrl, _unset) ? this.coverUrl : coverUrl as String?,
      logoUrl: identical(logoUrl, _unset) ? this.logoUrl : logoUrl as String?,
      companyName: identical(companyName, _unset)
          ? this.companyName
          : companyName as String?,
      companyCategory: identical(companyCategory, _unset)
          ? this.companyCategory
          : companyCategory as String?,
      cnpj: identical(cnpj, _unset) ? this.cnpj : cnpj as String?,
      slogan: identical(slogan, _unset) ? this.slogan : slogan as String?,
      sector: identical(sector, _unset) ? this.sector : sector as String?,
      companyType: identical(companyType, _unset)
          ? this.companyType
          : companyType as String?,
      website: identical(website, _unset) ? this.website : website as String?,
      description: identical(description, _unset)
          ? this.description
          : description as String?,
      states: states ?? this.states,
      cities: cities ?? this.cities,
      isLoadingStates: isLoadingStates ?? this.isLoadingStates,
      isLoadingCities: isLoadingCities ?? this.isLoadingCities,
      locationError: identical(locationError, _unset)
          ? this.locationError
          : locationError as String?,
      isHiring: isHiring ?? this.isHiring,
      jobs: jobs ?? this.jobs,
      employeesCount: identical(employeesCount, _unset)
          ? this.employeesCount
          : employeesCount as int?,
      companySize: identical(companySize, _unset)
          ? this.companySize
          : companySize as String?,
    );
  }

  // ===================================================
  // DERIVADOS
  // ===================================================
  bool get hasHeaderContent {
    final hasCover = (coverUrl ?? '').trim().isNotEmpty;
    final hasLogo = (logoUrl ?? '').trim().isNotEmpty;
    return hasCover || hasLogo;
  }

  bool get hasIdentityData {
    return (companyName?.trim().isNotEmpty ?? false) &&
        (companyCategory?.trim().isNotEmpty ?? false) &&
        (cnpj?.trim().isNotEmpty ?? false);
  }

  bool get hasAboutData {
    return (sector?.trim().isNotEmpty ?? false) &&
        (companyType?.trim().isNotEmpty ?? false) &&
        (description?.trim().isNotEmpty ?? false);
  }

  bool get hasTeamData {
    return employeesCount != null &&
        employeesCount! > 0 &&
        (companySize?.trim().isNotEmpty ?? false);
  }
}

// =======================================================
// CONTROLLER
// =======================================================
class CompanyOnboardingController
    extends StateNotifier<CompanyOnboardingState> {
  final IbgeLocalidadesService _ibgeService;

  CompanyOnboardingController(this._ibgeService)
      : super(const CompanyOnboardingState());

  // ===================================================
  // HEADER
  // ===================================================
  void setHeader({
    String? coverUrl,
    String? logoUrl,
  }) {
    state = state.copyWith(
      coverUrl: coverUrl ?? state.coverUrl,
      logoUrl: logoUrl ?? state.logoUrl,
    );
  }

  void setCoverUrl(String? value) {
    state = state.copyWith(coverUrl: value);
  }

  void setLogoUrl(String? value) {
    state = state.copyWith(logoUrl: value);
  }

  void clearHeader() {
    state = state.copyWith(
      coverUrl: null,
      logoUrl: null,
    );
  }

  // ===================================================
  // IDENTIDADE
  // ===================================================
  void setIdentity({
    required String companyName,
    required String companyCategory,
    required String cnpj,
  }) {
    state = state.copyWith(
      companyName: companyName,
      companyCategory: companyCategory,
      cnpj: cnpj,
    );
  }

  // ===================================================
  // SOBRE
  // ===================================================
  void setAbout({
    String? slogan,
    required String sector,
    required String companyType,
    String? website,
    required String description,
  }) {
    state = state.copyWith(
      slogan: slogan,
      sector: sector,
      companyType: companyType,
      website: website,
      description: description,
    );
  }

  // ===================================================
  // IBGE - ESTADOS
  // ===================================================
  Future<void> loadStates() async {
    if (state.isLoadingStates) return;
    if (state.states.isNotEmpty) return;

    state = state.copyWith(
      isLoadingStates: true,
      locationError: null,
    );

    try {
      final result = await _ibgeService.fetchStates();

      state = state.copyWith(
        states: result,
        isLoadingStates: false,
        locationError: null,
      );
    } catch (_) {
      state = state.copyWith(
        states: const [],
        isLoadingStates: false,
        locationError: 'Erro ao carregar estados.',
      );
    }
  }

  // ===================================================
  // IBGE - CIDADES POR UF
  // ===================================================
  Future<void> loadCitiesByUf(String uf) async {
    final safeUf = uf.trim();
    if (safeUf.isEmpty) return;

    state = state.copyWith(
      cities: const [],
      isLoadingCities: true,
      locationError: null,
    );

    try {
      final result = await _ibgeService.fetchCitiesByUf(safeUf);

      state = state.copyWith(
        cities: result,
        isLoadingCities: false,
        locationError: null,
      );
    } catch (_) {
      state = state.copyWith(
        cities: const [],
        isLoadingCities: false,
        locationError: 'Erro ao carregar cidades.',
      );
    }
  }

  // ===================================================
  // LIMPAR CIDADES
  // ===================================================
  void clearCities() {
    state = state.copyWith(
      cities: const [],
      isLoadingCities: false,
      locationError: null,
    );
  }

  // ===================================================
  // CONTRATAÇÃO
  // ===================================================
  void setHiring(bool value) {
    state = state.copyWith(
      isHiring: value,
      jobs: value ? state.jobs : const [],
    );
  }

  // ===================================================
  // VAGAS
  // ===================================================
  void setJobs(List<CompanyJobDraft> jobs) {
    state = state.copyWith(jobs: jobs);
  }

  void addJob(CompanyJobDraft job) {
    state = state.copyWith(
      jobs: [...state.jobs, job],
    );
  }

  void updateJob(int index, CompanyJobDraft job) {
    if (index < 0 || index >= state.jobs.length) return;

    final updated = [...state.jobs];
    updated[index] = job;

    state = state.copyWith(jobs: updated);
  }

  void removeJob(int index) {
    if (index < 0 || index >= state.jobs.length) return;

    final updated = [...state.jobs]..removeAt(index);

    state = state.copyWith(jobs: updated);
  }

  void clearJobs() {
    state = state.copyWith(jobs: const []);
  }

  // ===================================================
  // COLABORADORES
  // ===================================================
  void setEmployeesCount(int count) {
    final safeCount = count < 1 ? 1 : count;
    final autoSize = getAutomaticCompanySize(safeCount);

    state = state.copyWith(
      employeesCount: safeCount,
      companySize: autoSize,
    );
  }

  void setCompanySize(String size) {
    // O porte empresarial é calculado automaticamente pela quantidade
    // de colaboradores. Este método fica preservado para compatibilidade
    // com chamadas antigas do fluxo.
    state = state.copyWith(companySize: size);
  }

  void setTeamData({
    required int employeesCount,
    String? companySize,
  }) {
    final safeCount = employeesCount < 1 ? 1 : employeesCount;
    final autoSize = getAutomaticCompanySize(safeCount);

    state = state.copyWith(
      employeesCount: safeCount,
      companySize: autoSize,
    );
  }

  // ===================================================
  // REGRAS DE PORTE EMPRESARIAL
  // ---------------------------------------------------
  // Classificação automática usada pelo step de
  // colaboradores. A régua começa em pequena empresa e
  // evolui até multinacional.
  // ===================================================
  String getAutomaticCompanySize(int employeesCount) {
    if (employeesCount <= 49) {
      return 'Pequena empresa';
    }

    if (employeesCount <= 249) {
      return 'Média empresa';
    }

    if (employeesCount <= 999) {
      return 'Grande empresa';
    }

    return 'Multinacional';
  }

  List<String> getAllowedCompanySizes(int employeesCount) {
    return [getAutomaticCompanySize(employeesCount)];
  }

  // ===================================================
  // RESET
  // ===================================================
  void reset() {
    state = const CompanyOnboardingState();
  }
}

// =======================================================
// PROVIDER
// =======================================================
final companyOnboardingProvider = StateNotifierProvider<
    CompanyOnboardingController, CompanyOnboardingState>((ref) {
  final client = http.Client();
  final service = IbgeLocalidadesService(client);

  return CompanyOnboardingController(service);
});