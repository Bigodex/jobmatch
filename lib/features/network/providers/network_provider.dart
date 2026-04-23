// =======================================================
// NETWORK PROVIDER
// -------------------------------------------------------
// Provider da tela de networking
// + conexão entre usuários
// + status da conexão
// + listagem de conexões
// + conexões em comum
// =======================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:jobmatch/features/profile/providers/profile_provider.dart';
import 'package:jobmatch/features/profile/providers/public_profile_provider.dart';

import '../models/network_discover_profile_model.dart';
import '../services/network_service.dart';

// =======================================================
// SERVICE PROVIDER
// =======================================================
final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

// =======================================================
// BUSCA / EXPLORAR
// =======================================================
final networkProfilesProvider =
    FutureProvider.autoDispose<List<NetworkDiscoverProfileModel>>((ref) async {
  final service = ref.watch(networkServiceProvider);
  return service.getDiscoverProfiles();
});

// =======================================================
// SEARCH
// =======================================================
final networkSearchProvider = StateProvider<String>((ref) {
  return '';
});

// =======================================================
// STATUS DE CONEXÃO COM UM USUÁRIO
// -------------------------------------------------------
// true  -> já conectado
// false -> ainda não conectado
// =======================================================
final networkConnectionStatusProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, userId) async {
  final service = ref.watch(networkServiceProvider);
  return service.isConnectedWith(userId);
});

// =======================================================
// MINHAS CONEXÕES
// =======================================================
final myConnectionsProvider =
    FutureProvider.autoDispose<List<NetworkDiscoverProfileModel>>((ref) async {
  final service = ref.watch(networkServiceProvider);
  return service.getConnections();
});

// =======================================================
// CONEXÕES DE UM USUÁRIO ESPECÍFICO
// -------------------------------------------------------
// útil para tela pública / lista de amigos do perfil
// =======================================================
final userConnectionsProvider = FutureProvider.autoDispose
    .family<List<NetworkDiscoverProfileModel>, String>((ref, userId) async {
  final service = ref.watch(networkServiceProvider);
  return service.getConnections(userId: userId);
});

// =======================================================
// CONEXÕES EM COMUM
// -------------------------------------------------------
// cruza:
// - minhas conexões
// - conexões do usuário visitado
// =======================================================
final mutualConnectionsProvider = FutureProvider.autoDispose
    .family<List<NetworkDiscoverProfileModel>, String>((ref, userId) async {
  final myConnections = await ref.watch(myConnectionsProvider.future);
  final otherUserConnections = await ref.watch(
    userConnectionsProvider(userId).future,
  );

  final myConnectionIds = myConnections.map((item) => item.id).toSet();

  final mutualConnections = otherUserConnections.where((item) {
    return myConnectionIds.contains(item.id);
  }).toList();

  return mutualConnections;
});

// =======================================================
// CONTROLLER
// -------------------------------------------------------
// Responsável por conectar / desconectar e atualizar
// os providers relacionados
// =======================================================
class NetworkConnectionController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final NetworkService _service;

  NetworkConnectionController({
    required this.ref,
    required NetworkService service,
  })  : _service = service,
        super(const AsyncData(null));

  // =====================================================
  // CONECTAR
  // =====================================================
  Future<void> connect(String targetUserId) async {
    state = const AsyncLoading();

    try {
      await _service.connectWithUser(targetUserId);
      _invalidateAfterConnectionChange(targetUserId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // =====================================================
  // DESCONECTAR
  // =====================================================
  Future<void> disconnect(String targetUserId) async {
    state = const AsyncLoading();

    try {
      await _service.disconnectFromUser(targetUserId);
      _invalidateAfterConnectionChange(targetUserId);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // =====================================================
  // REFRESH MANUAL
  // =====================================================
  Future<void> refreshConnections({String? userId}) async {
    ref.invalidate(networkProfilesProvider);
    ref.invalidate(myConnectionsProvider);

    if (userId != null && userId.trim().isNotEmpty) {
      ref.invalidate(userConnectionsProvider(userId));
      ref.invalidate(mutualConnectionsProvider(userId));
      ref.invalidate(networkConnectionStatusProvider(userId));
      ref.invalidate(publicProfileProvider(userId));
    }

    ref.invalidate(profileProvider);
  }

  // =====================================================
  // INVALIDAÇÕES APÓS MUDANÇA DE CONEXÃO
  // =====================================================
  void _invalidateAfterConnectionChange(String targetUserId) {
    ref.invalidate(networkProfilesProvider);

    // status do botão conectar / conectado
    ref.invalidate(networkConnectionStatusProvider(targetUserId));

    // lista de conexões do usuário logado
    ref.invalidate(myConnectionsProvider);

    // lista de conexões do perfil público aberto
    ref.invalidate(userConnectionsProvider(targetUserId));

    // conexões em comum do perfil público aberto
    ref.invalidate(mutualConnectionsProvider(targetUserId));

    // atualiza contadores e dados do perfil do usuário logado
    ref.invalidate(profileProvider);

    // atualiza contador e dados do perfil público do alvo
    ref.invalidate(publicProfileProvider(targetUserId));
  }
}

// =======================================================
// CONTROLLER PROVIDER
// =======================================================
final networkConnectionControllerProvider =
    StateNotifierProvider<NetworkConnectionController, AsyncValue<void>>((ref) {
  final service = ref.read(networkServiceProvider);

  return NetworkConnectionController(
    ref: ref,
    service: service,
  );
});