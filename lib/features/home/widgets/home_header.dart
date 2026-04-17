// =======================================================
// HOME HEADER
// -------------------------------------------------------
// Apenas exibição dos dados do profile
// (reativo com Riverpod)
// - cargo com ícone da especialidade
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_cover.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../core/constants/app_icons.dart';

import '../../profile/providers/profile_provider.dart';

class HomeHeader extends ConsumerWidget {
  final bool forceLoading;

  const HomeHeader({
    super.key,
    this.forceLoading = false,
  });

  String _getRoleIcon(String role) {
    switch (role.trim()) {
      case 'UI/UX Designer':
        return AppIcons.paint;
      case 'Frontend Developer':
        return AppIcons.code;
      case 'Backend Developer':
        return AppIcons.database;
      case 'QA Engineer':
        return AppIcons.shield;
      case 'Product Manager':
        return AppIcons.box;
      case 'Data Analyst':
        return AppIcons.data;
      case 'Mobile Developer':
        return AppIcons.mobile;
      case 'DevOps Engineer':
        return AppIcons.devops;
      default:
        return AppIcons.briefcase;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (forceLoading) {
      return const _HomeHeaderSkeleton();
    }

    final profileAsync = ref.watch(profileProvider);
    final theme = Theme.of(context);

    return profileAsync.when(
      loading: () => const _HomeHeaderSkeleton(),
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
              Text(
                user.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    _getRoleIcon(user.role),
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      user.role,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.72),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ===================================================
              // BUTTON
              // ===================================================
              AppPrimaryButton(
                text: 'Ver meu currículo',
                onPressed: () {
                  context.go('/profile');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// =======================================================
// HOME HEADER SKELETON
// -------------------------------------------------------
// Placeholder no mesmo layout do header
// =======================================================

class _HomeHeaderSkeleton extends StatelessWidget {
  const _HomeHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        children: const [
          SizedBox(
            height: 185,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppSkeleton(
                    width: double.infinity,
                    height: 140,
                    borderRadius: 16,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: AppSkeleton(
                    width: 90,
                    height: 90,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          AppSkeleton(
            width: 170,
            height: 20,
            borderRadius: 8,
          ),
          SizedBox(height: 10),
          AppSkeleton(
            width: 120,
            height: 16,
            borderRadius: 8,
          ),
          SizedBox(height: 16),
          AppSkeleton(
            width: double.infinity,
            height: 48,
            borderRadius: 14,
          ),
        ],
      ),
    );
  }
}