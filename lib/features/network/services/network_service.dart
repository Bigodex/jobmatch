// =======================================================
// NETWORK SERVICE
// -------------------------------------------------------
// Service responsável pela camada de networking social.
//
// Responsabilidades:
// - buscar perfis para exploração
// - criar conexões entre usuários
// - remover conexões
// - verificar status de conexão
// - listar conexões públicas ou privadas
// - sincronizar contador de conexões
//
// Observação:
// - não usar print() direto aqui
// - não expor payloads completos no console
// - logs devem passar pelo AppLogger
// =======================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/app_logger.dart';
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
  // CURRENT UID
  // -------------------------------------------------------
  // Recupera o uid do usuário autenticado.
  // =======================================================
  String get _currentUid {
    final uid = _auth.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      throw Exception('Usuário não autenticado.');
    }

    return uid;
  }

  // =======================================================
  // GET DISCOVER PROFILES
  // -------------------------------------------------------
  // Busca perfis disponíveis para a tela de explorar rede.
  //
  // Remove da grade:
  // - o próprio usuário logado
  // - usuários já conectados
  //
  // Fluxo:
  // - tenta buscar primeiro em public_profiles
  // - se não houver dados públicos, usa profiles como fallback
  // =======================================================
  Future<List<NetworkDiscoverProfileModel>> getDiscoverProfiles() async {
    final currentUid = _auth.currentUser?.uid;

    try {
      final connectedUserIds = currentUid == null
          ? <String>{}
          : await _getConnectedUserIds(currentUid);

      final publicSnapshot =
          await _firestore.collection('public_profiles').get();

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

        AppLogger.info(
          'Perfis carregados de public_profiles: ${publicProfiles.length}.',
          name: 'NetworkService',
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

      AppLogger.info(
        'Perfis carregados de profiles fallback: ${profiles.length}.',
        name: 'NetworkService',
      );

      return profiles;
    } catch (e, st) {
      AppLogger.error(
        'Erro ao carregar perfis para explorar rede.',
        error: e,
        stackTrace: st,
        name: 'NetworkService',
      );

      rethrow;
    }
  }

  // =======================================================
  // CONNECT WITH USER
  // -------------------------------------------------------
  // Cria uma conexão bidirecional entre o usuário logado e
  // o usuário de destino.
  //
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
        AppLogger.debug(
          'Conexão já existente. Operação ignorada.',
          name: 'NetworkService',
        );

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

      AppLogger.info(
        'Conexão criada com sucesso.',
        name: 'NetworkService',
      );
    } catch (e, st) {
      AppLogger.error(
        'Erro ao criar conexão.',
        error: e,
        stackTrace: st,
        name: 'NetworkService',
      );

      rethrow;
    }
  }

  // =======================================================
  // DISCONNECT FROM USER
  // -------------------------------------------------------
  // Remove uma conexão bidirecional entre o usuário logado
  // e o usuário de destino.
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

      AppLogger.info(
        'Conexão removida com sucesso.',
        name: 'NetworkService',
      );
    } catch (e, st) {
      AppLogger.error(
        'Erro ao remover conexão.',
        error: e,
        stackTrace: st,
        name: 'NetworkService',
      );

      rethrow;
    }
  }

  // =======================================================
  // IS CONNECTED WITH
  // -------------------------------------------------------
  // Verifica se o usuário logado já está conectado com o
  // usuário informado.
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
    } catch (e, st) {
      AppLogger.error(
        'Erro ao verificar status de conexão.',
        error: e,
        stackTrace: st,
        name: 'NetworkService',
      );

      rethrow;
    }
  }

  // =======================================================
  // GET CONNECTIONS
  // -------------------------------------------------------
  // Lista conexões de um usuário.
  //
  // Se userId não for informado, usa o usuário logado.
  // Busca primeiro em public_profiles e usa profiles como
  // fallback quando necessário.
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
        AppLogger.debug(
          'Nenhuma conexão encontrada.',
          name: 'NetworkService',
        );

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

      AppLogger.info(
        'Conexões carregadas com sucesso: ${profiles.length}.',
        name: 'NetworkService',
      );

      return profiles;
    } catch (e, st) {
      AppLogger.error(
        'Erro ao listar conexões.',
        error: e,
        stackTrace: st,
        name: 'NetworkService',
      );

      rethrow;
    }
  }

  // =======================================================
  // SYNC CONNECTIONS COUNT
  // -------------------------------------------------------
  // Sincroniza o total de conexões nas coleções:
  // - profiles/{uid}.user.connections
  // - public_profiles/{uid}.connections
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

      AppLogger.debug(
        'Contador de conexões sincronizado.',
        name: 'NetworkService',
      );
    } catch (e, st) {
      AppLogger.error(
        'Erro ao sincronizar contador de conexões.',
        error: e,
        stackTrace: st,
        name: 'NetworkService',
      );

      rethrow;
    }
  }

  // =======================================================
  // GET CONNECTED USER IDS
  // -------------------------------------------------------
  // Retorna os ids dos usuários já conectados.
  // Usado para remover conexões existentes da tela Explorar.
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
  // MAP PROFILE DOC TO DISCOVER MODEL
  // -------------------------------------------------------
  // Converte um documento de profiles para o modelo usado
  // na tela de networking.
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
  // BUILD TAGS
  // -------------------------------------------------------
  // Gera tags simples a partir do cargo/especialidade.
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

  // =======================================================
  // IS RECRUITER
  // -------------------------------------------------------
  // Identifica perfis com indicação textual de recrutador/RH.
  // =======================================================
  bool _isRecruiter(String role) {
    final normalized = role.toLowerCase();

    return normalized.contains('recruit') ||
        normalized.contains('talent') ||
        normalized.contains('rh');
  }
}
