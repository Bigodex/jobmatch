// =======================================================
// PROFILE VIEWS SERVICE
// -------------------------------------------------------
// Responsável por:
// - registrar visualização de perfil
// - buscar visualizações do usuário
// - considerar expiração em 7 dias
// - sincronizar contador de views no perfil
// =======================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile_view_model.dart';

// =======================================================
// PROVIDER
// =======================================================

final profileViewsServiceProvider = Provider<ProfileViewsService>((ref) {
  return ProfileViewsService(FirebaseFirestore.instance);
});

// =======================================================
// SERVICE
// =======================================================

class ProfileViewsService {
  final FirebaseFirestore _firestore;

  ProfileViewsService(this._firestore);

  // =====================================================
  // COLLECTIONS
  // =====================================================

  CollectionReference<Map<String, dynamic>> get _viewsCollection =>
      _firestore.collection('profile_views');

  CollectionReference<Map<String, dynamic>> get _profilesCollection =>
      _firestore.collection('profiles');

  // =====================================================
  // REGISTER PROFILE VIEW
  // -----------------------------------------------------
  // Cria ou atualiza a visualização de um usuário em
  // determinado perfil.
  //
  // Estratégia:
  // - 1 documento por combinação viewedUserId + viewerId
  // - se a mesma pessoa visualizar de novo, atualiza viewedAt
  // - depois sincroniza o contador no perfil
  // =====================================================

  Future<void> registerProfileView({
    required String viewedUserId,
    required String viewerId,
    required String viewerName,
    required String viewerRole,
    required String viewerCity,
    required String viewerAvatarUrl,
  }) async {
    if (viewedUserId.trim() == viewerId.trim()) return;

    final now = DateTime.now();
    final expiresAt = now.add(const Duration(days: 7));
    final docId = '${viewedUserId}_$viewerId';

    await _viewsCollection.doc(docId).set({
      'viewerId': viewerId,
      'viewedUserId': viewedUserId,
      'name': viewerName,
      'role': viewerRole,
      'city': viewerCity,
      'avatarUrl': viewerAvatarUrl,
      'viewedAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(expiresAt),
    }, SetOptions(merge: true));

    await _syncProfileViewsCount(viewedUserId);
  }

  // =====================================================
  // GET VIEWS FOR USER
  // -----------------------------------------------------
  // Busca apenas visualizações ainda válidas (últimos 7 dias)
  // e ordena da mais recente para a mais antiga no app
  // =====================================================

  Future<List<ProfileViewModel>> getViewsForUser(String userId) async {
    final now = DateTime.now();

    final snapshot = await _viewsCollection
        .where('viewedUserId', isEqualTo: userId)
        .get();

    final expiredDocIds = <String>[];
    final validViews = <ProfileViewModel>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final viewedAtTimestamp = data['viewedAt'];
      final expiresAtTimestamp = data['expiresAt'];

      if (viewedAtTimestamp is! Timestamp) continue;
      if (expiresAtTimestamp is! Timestamp) continue;

      final viewedAt = viewedAtTimestamp.toDate();
      final expiresAt = expiresAtTimestamp.toDate();

      if (expiresAt.isBefore(now)) {
        expiredDocIds.add(doc.id);
        continue;
      }

      validViews.add(
        ProfileViewModel(
          id: doc.id,
          viewerId: (data['viewerId'] ?? '') as String,
          viewedUserId: (data['viewedUserId'] ?? '') as String,
          name: (data['name'] ?? '') as String,
          role: (data['role'] ?? '') as String,
          city: (data['city'] ?? '') as String,
          avatarUrl: (data['avatarUrl'] ?? '') as String,
          viewedAt: viewedAt,
        ),
      );
    }

    validViews.sort((a, b) => b.viewedAt.compareTo(a.viewedAt));

    if (expiredDocIds.isNotEmpty) {
      await _deleteExpiredDocs(expiredDocIds);
      await _syncProfileViewsCount(userId);
    }

    return validViews;
  }

  // =====================================================
  // SYNC PROFILE VIEWS COUNT
  // -----------------------------------------------------
  // Conta apenas views válidas e grava no profile.views
  // =====================================================

  Future<void> _syncProfileViewsCount(String viewedUserId) async {
    final now = DateTime.now();

    final snapshot = await _viewsCollection
        .where('viewedUserId', isEqualTo: viewedUserId)
        .get();

    final expiredDocIds = <String>[];
    var validCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final expiresAt = data['expiresAt'];

      if (expiresAt is! Timestamp) continue;

      if (expiresAt.toDate().isBefore(now)) {
        expiredDocIds.add(doc.id);
      } else {
        validCount++;
      }
    }

    if (expiredDocIds.isNotEmpty) {
      await _deleteExpiredDocs(expiredDocIds);
    }

    await _profilesCollection.doc(viewedUserId).set({
      'views': validCount,
    }, SetOptions(merge: true));
  }

  // =====================================================
  // DELETE EXPIRED DOCS
  // =====================================================

  Future<void> _deleteExpiredDocs(List<String> docIds) async {
    if (docIds.isEmpty) return;

    final batch = _firestore.batch();

    for (final docId in docIds) {
      batch.delete(_viewsCollection.doc(docId));
    }

    await batch.commit();
  }

  // =====================================================
  // OPTIONAL MANUAL CLEANUP
  // =====================================================

  Future<void> cleanupExpiredViewsForUser(String userId) async {
    final now = DateTime.now();

    final snapshot = await _viewsCollection
        .where('viewedUserId', isEqualTo: userId)
        .get();

    final expiredDocIds = snapshot.docs
        .where((doc) {
          final data = doc.data();
          final expiresAt = data['expiresAt'];

          if (expiresAt is! Timestamp) return false;
          return expiresAt.toDate().isBefore(now);
        })
        .map((doc) => doc.id)
        .toList();

    if (expiredDocIds.isNotEmpty) {
      await _deleteExpiredDocs(expiredDocIds);
    }

    await _syncProfileViewsCount(userId);
  }
}