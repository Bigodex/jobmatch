// =======================================================
// NETWORK SERVICE
// -------------------------------------------------------
// Busca perfis reais para a tela de networking
// + cria / remove conexões
// + verifica status de conexão
// + lista conexões do usuário
// + sincroniza contador em profiles e public_profiles
// =======================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/network_discover_profile_model.dart';

class NetworkService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NetworkService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // =======================================================
  // UID ATUAL
  // =======================================================
  String get _currentUid {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('Usuário não autenticado.');
    }
    return uid;
  }

  // =======================================================
  // EXPLORAR PERFIS
  // -------------------------------------------------------
  // Remove da grade:
  // - o próprio usuário logado
  // - usuários já conectados
  // =======================================================
  Future<List<NetworkDiscoverProfileModel>> getDiscoverProfiles() async {
    final currentUid = _auth.currentUser?.uid;

    try {
      final connectedUserIds = currentUid == null
          ? <String>{}
          : await _getConnectedUserIds(currentUid);

      final publicSnapshot = await _firestore.collection('public_profiles').get();

      final publicProfiles = publicSnapshot.docs
          .map(
            (doc) => NetworkDiscoverProfileModel.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .where((profile) => profile.id != currentUid)
          .where((profile) => !connectedUserIds.contains(profile.id))
          .where((profile) => profile.name.isNotEmpty)
          .toList();

      if (publicProfiles.isNotEmpty) {
        publicProfiles.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );

        print(
          '✅ NETWORK: ${publicProfiles.length} perfis carregados de public_profiles',
        );

        return publicProfiles;
      }

      final profileSnapshot = await _firestore.collection('profiles').get();

      final profiles = profileSnapshot.docs
          .map((doc) {
            final data = doc.data();

            final user = Map<String, dynamic>.from(data['user'] ?? {});
            final resume = Map<String, dynamic>.from(data['resume'] ?? {});

            final name = (user['name'] ?? '').toString().trim();
            final role = (user['role'] ?? '').toString().trim();
            final avatarUrl = (user['avatarUrl'] ?? '').toString().trim();
            final coverUrl = (user['coverUrl'] ?? '').toString().trim();
            final city = (resume['city'] ?? '').toString().trim();

            return NetworkDiscoverProfileModel(
              id: doc.id,
              name: name,
              role: role,
              avatarUrl: avatarUrl,
              coverUrl: coverUrl,
              city: city,
              tags: _buildTags(role),
              isRecruiter: _isRecruiter(role),
              isCompany: false,
            );
          })
          .where((profile) => profile.id != currentUid)
          .where((profile) => !connectedUserIds.contains(profile.id))
          .where((profile) => profile.name.isNotEmpty)
          .toList();

      profiles.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      print(
        '✅ NETWORK: ${profiles.length} perfis carregados de profiles (fallback)',
      );

      return profiles;
    } catch (e) {
      print('❌ NETWORK ERROR: $e');
      rethrow;
    }
  }

  // =======================================================
  // CRIAR CONEXÃO
  // -------------------------------------------------------
  // Estrutura:
  // connections/{uid}/friends/{friendUid}
  // =======================================================
  Future<void> connectWithUser(String targetUserId) async {
    final currentUid = _currentUid;

    if (targetUserId.trim().isEmpty) {
      throw Exception('Usuário de destino inválido.');
    }

    if (currentUid == targetUserId) {
      throw Exception('Você não pode se conectar com você mesmo.');
    }

    try {
      final currentRef = _firestore
          .collection('connections')
          .doc(currentUid)
          .collection('friends')
          .doc(targetUserId);

      final targetRef = _firestore
          .collection('connections')
          .doc(targetUserId)
          .collection('friends')
          .doc(currentUid);

      final alreadyConnected = await currentRef.get();
      if (alreadyConnected.exists) {
        print('ℹ️ NETWORK: conexão já existe entre $currentUid e $targetUserId');
        return;
      }

      final batch = _firestore.batch();

      batch.set(currentRef, {
        'userId': targetUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.set(targetRef, {
        'userId': currentUid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      await Future.wait([
        _syncConnectionsCount(currentUid),
        _syncConnectionsCount(targetUserId),
      ]);

      print('✅ NETWORK: conexão criada entre $currentUid e $targetUserId');
    } catch (e) {
      print('❌ NETWORK CONNECT ERROR: $e');
      rethrow;
    }
  }

  // =======================================================
  // REMOVER CONEXÃO
  // =======================================================
  Future<void> disconnectFromUser(String targetUserId) async {
    final currentUid = _currentUid;

    if (targetUserId.trim().isEmpty) {
      throw Exception('Usuário de destino inválido.');
    }

    if (currentUid == targetUserId) {
      return;
    }

    try {
      final currentRef = _firestore
          .collection('connections')
          .doc(currentUid)
          .collection('friends')
          .doc(targetUserId);

      final targetRef = _firestore
          .collection('connections')
          .doc(targetUserId)
          .collection('friends')
          .doc(currentUid);

      final batch = _firestore.batch();
      batch.delete(currentRef);
      batch.delete(targetRef);

      await batch.commit();

      await Future.wait([
        _syncConnectionsCount(currentUid),
        _syncConnectionsCount(targetUserId),
      ]);

      print('✅ NETWORK: conexão removida entre $currentUid e $targetUserId');
    } catch (e) {
      print('❌ NETWORK DISCONNECT ERROR: $e');
      rethrow;
    }
  }

  // =======================================================
  // VERIFICAR SE JÁ ESTÁ CONECTADO
  // =======================================================
  Future<bool> isConnectedWith(String targetUserId) async {
    final currentUid = _currentUid;

    if (targetUserId.trim().isEmpty) return false;
    if (currentUid == targetUserId) return false;

    try {
      final doc = await _firestore
          .collection('connections')
          .doc(currentUid)
          .collection('friends')
          .doc(targetUserId)
          .get();

      return doc.exists;
    } catch (e) {
      print('❌ NETWORK CHECK CONNECTION ERROR: $e');
      rethrow;
    }
  }

  // =======================================================
  // LISTAR CONEXÕES
  // -------------------------------------------------------
  // Se userId não for informado, usa o usuário logado
  // =======================================================
  Future<List<NetworkDiscoverProfileModel>> getConnections({
    String? userId,
  }) async {
    final sourceUid = (userId != null && userId.trim().isNotEmpty)
        ? userId.trim()
        : _currentUid;

    try {
      final snapshot = await _firestore
          .collection('connections')
          .doc(sourceUid)
          .collection('friends')
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final connectionIds = snapshot.docs
          .map((doc) => (doc.data()['userId'] ?? '').toString().trim())
          .where((id) => id.isNotEmpty)
          .toList();

      final profiles = <NetworkDiscoverProfileModel>[];

      for (final id in connectionIds) {
        final publicDoc =
            await _firestore.collection('public_profiles').doc(id).get();

        if (publicDoc.exists && publicDoc.data() != null) {
          final data = publicDoc.data()!;
          profiles.add(
            NetworkDiscoverProfileModel.fromMap(publicDoc.id, data),
          );
          continue;
        }

        final profileDoc = await _firestore.collection('profiles').doc(id).get();

        if (profileDoc.exists && profileDoc.data() != null) {
          profiles.add(
            _mapProfileDocToDiscoverModel(profileDoc),
          );
        }
      }

      return profiles;
    } catch (e) {
      print('❌ NETWORK GET CONNECTIONS ERROR: $e');
      rethrow;
    }
  }

  // =======================================================
  // SINCRONIZAR CONTADOR
  // -------------------------------------------------------
  // Atualiza:
  // profiles/{uid}.user.connections
  // public_profiles/{uid}.connections
  // =======================================================
  Future<void> _syncConnectionsCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('connections')
          .doc(userId)
          .collection('friends')
          .get();

      final total = snapshot.docs.length;

      await _firestore.collection('profiles').doc(userId).set({
        'user': {
          'connections': total,
        },
      }, SetOptions(merge: true));

      await _firestore.collection('public_profiles').doc(userId).set({
        'connections': total,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ NETWORK: contador sincronizado para $userId = $total');
    } catch (e) {
      print('❌ NETWORK SYNC COUNT ERROR: $e');
      rethrow;
    }
  }

  // =======================================================
  // IDS JÁ CONECTADOS
  // =======================================================
  Future<Set<String>> _getConnectedUserIds(String userId) async {
    final snapshot = await _firestore
        .collection('connections')
        .doc(userId)
        .collection('friends')
        .get();

    return snapshot.docs
        .map((doc) => (doc.data()['userId'] ?? '').toString().trim())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  // =======================================================
  // FALLBACK -> PROFILE PARA DISCOVER MODEL
  // =======================================================
  NetworkDiscoverProfileModel _mapProfileDocToDiscoverModel(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final user = Map<String, dynamic>.from(data['user'] ?? {});
    final resume = Map<String, dynamic>.from(data['resume'] ?? {});

    final role = (user['role'] ?? '').toString().trim();

    return NetworkDiscoverProfileModel(
      id: doc.id,
      name: (user['name'] ?? '').toString().trim(),
      role: role,
      avatarUrl: (user['avatarUrl'] ?? '').toString().trim(),
      coverUrl: (user['coverUrl'] ?? '').toString().trim(),
      city: (resume['city'] ?? '').toString().trim(),
      tags: _buildTags(role),
      isRecruiter: _isRecruiter(role),
      isCompany: false,
    );
  }

  // =======================================================
  // HELPERS
  // =======================================================
  List<String> _buildTags(String role) {
    final normalized = role.toLowerCase();
    final tags = <String>{};

    if (normalized.contains('design') ||
        normalized.contains('ux') ||
        normalized.contains('ui')) {
      tags.add('design');
    }

    if (normalized.contains('produto') ||
        normalized.contains('product') ||
        normalized.contains('pm')) {
      tags.add('produto');
    }

    if (normalized.contains('recruit') ||
        normalized.contains('talent') ||
        normalized.contains('rh')) {
      tags.add('recrutadores');
    }

    if (tags.isEmpty) {
      tags.add('tecnologia');
    }

    return tags.toList();
  }

  bool _isRecruiter(String role) {
    final normalized = role.toLowerCase();

    return normalized.contains('recruit') ||
        normalized.contains('talent') ||
        normalized.contains('rh');
  }
}