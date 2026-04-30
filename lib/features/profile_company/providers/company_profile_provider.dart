// =======================================================
// COMPANY PROFILE PROVIDER
// -------------------------------------------------------
// Estado da página empresarial criada ao finalizar o
// onboarding de empresa.
// =======================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:jobmatch/features/company/providers/company_onboarding_provider.dart';
import 'package:jobmatch/features/profile_company/models/company_profile_model.dart';
import 'package:jobmatch/features/profile_company/services/company_profile_service.dart';

class CompanyProfileNotifier
    extends StateNotifier<AsyncValue<CompanyProfileModel?>> {
  final CompanyProfileService _service;

  CompanyProfileNotifier(this._service) : super(const AsyncLoading()) {
    loadCompanyProfile();
  }

  Future<void> loadCompanyProfile() async {
    try {
      final profile = await _service.getCurrentCompanyProfile();
      state = AsyncData(profile);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> loadCompanyProfileById(String companyId) async {
    try {
      state = const AsyncLoading();
      final profile = await _service.getCompanyProfileById(companyId);
      state = AsyncData(profile);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<CompanyProfileModel> updateCompanyProfile(
    CompanyProfileModel profile,
  ) async {
    try {
      state = const AsyncLoading();
      await _service.saveCompanyProfile(profile);
      final updated = await _service.getCompanyProfileById(profile.id);
      final normalized = updated ?? profile;
      state = AsyncData(normalized);
      return normalized;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<CompanyProfileModel> createFromOnboarding(
    CompanyOnboardingState company,
  ) async {
    final profile = CompanyProfileModel(
      coverUrl: (company.coverUrl ?? '').trim(),
      logoUrl: (company.logoUrl ?? '').trim(),
      companyName: (company.companyName ?? '').trim(),
      companyCategory: (company.companyCategory ?? '').trim(),
      cnpj: (company.cnpj ?? '').trim(),
      slogan: (company.slogan ?? '').trim(),
      sector: (company.sector ?? '').trim(),
      companyType: (company.companyType ?? '').trim(),
      website: (company.website ?? '').trim(),
      description: (company.description ?? '').trim(),
      isHiring: company.isHiring,
      jobs: company.jobs
          .map(
            (job) => CompanyProfileJobModel(
              title: job.title.trim(),
              seniority: job.seniority.trim(),
              workModel: job.workModel.trim(),
              location: job.location.trim(),
              salary: job.salary.trim(),
              description: job.description.trim(),
            ),
          )
          .toList(),
      employeesCount: company.employeesCount ?? 0,
      companySize: (company.companySize ?? '').trim(),
    );

    state = AsyncData(profile);

    try {
      final savedProfile = await _service.createCompanyProfile(profile);
      state = AsyncData(savedProfile);
      return savedProfile;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final companyProfileServiceProvider = Provider<CompanyProfileService>((ref) {
  return CompanyProfileService();
});

final companyProfileProvider = StateNotifierProvider<CompanyProfileNotifier,
    AsyncValue<CompanyProfileModel?>>((ref) {
  final service = ref.watch(companyProfileServiceProvider);
  return CompanyProfileNotifier(service);
});

final companyProfilesProvider = FutureProvider.autoDispose<
    List<CompanyProfileModel>>((ref) async {
  final service = ref.watch(companyProfileServiceProvider);
  return service.getCompanyProfiles();
});

final companyProfileByIdProvider = FutureProvider.autoDispose
    .family<CompanyProfileModel?, String>((ref, companyId) async {
  final service = ref.watch(companyProfileServiceProvider);
  return service.getCompanyProfileById(companyId);
});
