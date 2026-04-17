// =======================================================
// PUBLIC PROFILE PROVIDER
// -------------------------------------------------------
// Busca perfil público de outro usuário por id
// =======================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile_model.dart';
import 'profile_provider.dart';

final publicProfileProvider =
    FutureProvider.autoDispose.family<ProfileModel, String>((ref, userId) async {
  final service = ref.watch(profileServiceProvider);
  return service.getProfileById(userId);
});