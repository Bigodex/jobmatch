// =======================================================
// COMPANY PROFILE SERVICE
// -------------------------------------------------------
// Persistência da página empresarial no Firebase.
// =======================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:jobmatch/core/utils/app_logger.dart';
import 'package:jobmatch/features/profile_company/models/company_profile_model.dart';

class CompanyProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    return user.uid;
  }

  Future<CompanyProfileModel?> getCurrentCompanyProfile() async {
    try {
      final profiles = await getCompanyProfiles();

      if (profiles.isEmpty) {
        return null;
      }

      return profiles.first;
    } catch (e, st) {
      AppLogger.error(
        'Erro ao carregar perfil empresarial.',
        error: e,
        stackTrace: st,
        name: 'CompanyProfileService',
      );

      rethrow;
    }
  }

  Future<CompanyProfileModel?> getCompanyProfileById(String companyId) async {
    try {
      final safeCompanyId = companyId.trim();
      if (safeCompanyId.isEmpty) return null;

      final doc = await _firestore
          .collection('company_profiles')
          .doc(safeCompanyId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final profile = CompanyProfileModel.fromMap(
        doc.data()!,
        id: doc.id,
      );

      if (profile.ownerId.trim().isNotEmpty && profile.ownerId != _uid) {
        throw Exception('Página empresarial não pertence ao usuário atual.');
      }

      return profile.copyWith(ownerId: _uid);
    } catch (e, st) {
      AppLogger.error(
        'Erro ao carregar perfil empresarial por id.',
        error: e,
        stackTrace: st,
        name: 'CompanyProfileService',
      );

      rethrow;
    }
  }

  Future<List<CompanyProfileModel>> getCompanyProfiles() async {
    try {
      final snapshot = await _firestore
          .collection('company_profiles')
          .where('ownerId', isEqualTo: _uid)
          .get();

      final profiles = snapshot.docs
          .map(
            (doc) => CompanyProfileModel.fromMap(
              doc.data(),
              id: doc.id,
            ).copyWith(ownerId: _uid),
          )
          .toList();

      profiles.sort((a, b) {
        final left = a.companyName.trim().toLowerCase();
        final right = b.companyName.trim().toLowerCase();
        return left.compareTo(right);
      });

      return profiles;
    } catch (e, st) {
      AppLogger.error(
        'Erro ao listar páginas empresariais.',
        error: e,
        stackTrace: st,
        name: 'CompanyProfileService',
      );

      rethrow;
    }
  }

  Future<CompanyProfileModel> createCompanyProfile(
    CompanyProfileModel profile,
  ) async {
    try {
      final docRef = _firestore.collection('company_profiles').doc();
      final normalized = profile.copyWith(
        id: docRef.id,
        ownerId: _uid,
      );

      await saveCompanyProfile(normalized);

      return normalized;
    } catch (e, st) {
      AppLogger.error(
        'Erro ao criar perfil empresarial.',
        error: e,
        stackTrace: st,
        name: 'CompanyProfileService',
      );

      rethrow;
    }
  }

  Future<void> saveCompanyProfile(CompanyProfileModel profile) async {
    try {
      final docId = profile.id.trim().isNotEmpty ? profile.id.trim() : _uid;
      final normalizedProfile = profile.copyWith(
        id: docId,
        ownerId: _uid,
      );

      final normalized = normalizedProfile.toMap()
        ..['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('company_profiles')
          .doc(docId)
          .set(normalized, SetOptions(merge: true));

      await _syncPublicCompanyProfile(normalizedProfile);
    } catch (e, st) {
      AppLogger.error(
        'Erro ao salvar perfil empresarial.',
        error: e,
        stackTrace: st,
        name: 'CompanyProfileService',
      );

      rethrow;
    }
  }

  Future<void> _syncPublicCompanyProfile(CompanyProfileModel profile) async {
    final tags = _buildTags(profile);
    final publicId = profile.id.trim().isNotEmpty
        ? '${profile.id}_company'
        : '${_uid}_company';

    await _firestore.collection('public_profiles').doc(publicId).set({
      'uid': publicId,
      'ownerId': _uid,
      'companyProfileId': profile.id.trim(),
      'name': profile.companyName.trim(),
      'role': profile.companyCategory.trim(),
      'avatarUrl': profile.logoUrl.trim(),
      'coverUrl': profile.coverUrl.trim(),
      'city': '',
      'state': '',
      'connections': 0,
      'views': 0,
      'tags': tags,
      'searchable': _buildSearchableText(profile, tags),
      'isRecruiter': true,
      'isCompany': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  List<String> _buildTags(CompanyProfileModel profile) {
    final tags = <String>{'empresa'};

    if (profile.companyCategory.trim().isNotEmpty) {
      tags.add(profile.companyCategory.trim().toLowerCase());
    }

    if (profile.companyType.trim().isNotEmpty) {
      tags.add(profile.companyType.trim().toLowerCase());
    }

    if (profile.isHiring || profile.jobs.isNotEmpty) {
      tags.add('contratando');
    }

    return tags.toList();
  }

  String _buildSearchableText(
    CompanyProfileModel profile,
    List<String> tags,
  ) {
    final parts = [
      profile.companyName,
      profile.companyCategory,
      profile.companyType,
      profile.sector,
      profile.description,
      ...tags,
    ];

    return parts
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .join(' ')
        .toLowerCase();
  }
}
