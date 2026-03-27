// =======================================================
// HOME HEADER
// -------------------------------------------------------
// Apenas exibição dos dados do profile
// (reativo com Riverpod)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_cover.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_user_info.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_section_card.dart';

import '../../profile/providers/profile_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (e, _) => const Center(child: Text('Erro ao carregar perfil')),

      data: (profile) {
        final user = profile.user;

        return AppSectionCard(
          child: Column(
            children: [

              // ===================================================
              // COVER + AVATAR
              // ===================================================
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [

                  AppCover(
                    imageUrl: user.coverUrl,
                  ),

                  Positioned(
                    bottom: -45,
                    child: AppAvatar(
                      imageUrl: user.avatarUrl,
                      size: 90,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // ===================================================
              // USER INFO
              // ===================================================
              AppUserInfo(
                name: user.name,
                role: user.role,
              ),

              const SizedBox(height: 16),

              // ===================================================
              // BUTTON
              // ===================================================
              AppPrimaryButton(
                text: 'Ver meu currículo',
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}