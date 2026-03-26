// =======================================================
// PROFILE PROVIDER
// -------------------------------------------------------
// Gerencia o estado do perfil (Riverpod)
// =======================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

final profileProvider = FutureProvider<ProfileModel>((ref) async {
  final service = ProfileService();
  return service.getProfile();
});