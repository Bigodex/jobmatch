// =======================================================
// PROFILE VIEWS PROVIDER
// -------------------------------------------------------
// Busca as visualizações do perfil do usuário logado
// =======================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile_view_model.dart';
import '../services/profile_views_service.dart';
import '../../auth/providers/auth_provider.dart';

final myProfileViewsProvider = FutureProvider<List<ProfileViewModel>>((
  ref,
) async {
  final service = ref.watch(profileViewsServiceProvider);
  final authUser = ref.watch(authStateProvider).value;

  if (authUser == null || authUser.uid.isEmpty) {
    return [];
  }

  return service.getViewsForUser(authUser.uid);
});