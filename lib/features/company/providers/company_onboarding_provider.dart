// =======================================================
// COMPANY ONBOARDING PROVIDER
// -------------------------------------------------------
// Controla o estado do fluxo de cadastro da página
// empresarial
// =======================================================

import 'package:flutter_riverpod/legacy.dart';

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
  CompanyOnboardingController() : super(const CompanyOnboardingState());

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
    final allowedSizes = getAllowedCompanySizes(safeCount);

    final nextSize = allowedSizes.contains(state.companySize)
        ? state.companySize
        : autoSize;

    state = state.copyWith(
      employeesCount: safeCount,
      companySize: nextSize,
    );
  }

  void setCompanySize(String size) {
    final employeesCount = state.employeesCount;

    if (employeesCount == null || employeesCount < 1) {
      state = state.copyWith(companySize: size);
      return;
    }

    final allowedSizes = getAllowedCompanySizes(employeesCount);

    if (!allowedSizes.contains(size)) {
      return;
    }

    state = state.copyWith(companySize: size);
  }

  void setTeamData({
    required int employeesCount,
    String? companySize,
  }) {
    final safeCount = employeesCount < 1 ? 1 : employeesCount;
    final allowedSizes = getAllowedCompanySizes(safeCount);
    final autoSize = getAutomaticCompanySize(safeCount);

    final resolvedSize = companySize != null && allowedSizes.contains(companySize)
        ? companySize
        : autoSize;

    state = state.copyWith(
      employeesCount: safeCount,
      companySize: resolvedSize,
    );
  }

  // ===================================================
  // REGRAS DE PORTE EMPRESARIAL
  // ---------------------------------------------------
  // Regras coesas e restritas para não permitir
  // combinações irreais
  // ===================================================
  String getAutomaticCompanySize(int employeesCount) {
    if (employeesCount <= 9) {
      return 'Microempresa';
    }

    if (employeesCount <= 49) {
      return 'Pequena empresa';
    }

    if (employeesCount <= 99) {
      return 'Média empresa';
    }

    return 'Grande empresa';
  }

  List<String> getAllowedCompanySizes(int employeesCount) {
    if (employeesCount <= 9) {
      return const ['Microempresa'];
    }

    if (employeesCount <= 49) {
      return const ['Pequena empresa'];
    }

    if (employeesCount <= 99) {
      return const ['Média empresa'];
    }

    return const ['Grande empresa'];
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
  return CompanyOnboardingController();
});