// =======================================================
// NETWORK PROFILE CARD
// -------------------------------------------------------
// Card de perfil do usuário no topo da tela de rede
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/network/models/network_profile_stats_model.dart';
import 'package:jobmatch/features/network/widgets/network_profile_card_skeleton.dart';
import 'package:jobmatch/features/network/widgets/network_profile_identity.dart';
import 'package:jobmatch/features/network/widgets/network_profile_trophies.dart';
import 'package:jobmatch/features/network/widgets/network_quick_actions.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class NetworkProfileCard extends ConsumerWidget {
  final NetworkProfileStatsModel stats;
  final VoidCallback? onConnectionsTap;
  final VoidCallback? onCompaniesTap;
  final VoidCallback? onRequestsTap;

  const NetworkProfileCard({
    super.key,
    this.stats = const NetworkProfileStatsModel.mock(),
    this.onConnectionsTap,
    this.onCompaniesTap,
    this.onRequestsTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () => const NetworkProfileCardSkeleton(),
      error: (_, __) => AppSectionCard(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: appColors.cardTertiary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          child: Center(
            child: Text(
              'Erro ao carregar perfil da rede.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.70),
              ),
            ),
          ),
        ),
      ),
      data: (profile) {
        final user = profile.user;

        final resolvedStats = stats.copyWith(
          connectionsCount:
              user.connections > 0 ? user.connections : stats.connectionsCount,
        );

        return AppSectionCard(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              final contentPadding =
                  (width * 0.045).clamp(14.0, 20.0).toDouble();
              final sectionSpacing =
                  (width * 0.035).clamp(12.0, 18.0).toDouble();
              final avatarSize =
                  (width * 0.17).clamp(70.0, 92.0).toDouble();
              final badgeSize =
                  (width * 0.9).clamp(32.0, 42.0).toDouble();
              final trophyBoxSize =
                  (width * 0.20).clamp(48.0, 70.0).toDouble();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(contentPadding),
                    decoration: BoxDecoration(
                      color: appColors.cardTertiary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NetworkProfileIdentity(
                          userName: user.name,
                          userRole: user.role,
                          avatarUrl: user.avatarUrl,
                          connectionsCount: resolvedStats.connectionsCount,
                          avatarSize: avatarSize,
                          badgeSize: badgeSize,
                        ),
                        SizedBox(height: sectionSpacing),
                        NetworkProfileTrophies(
                          stats: resolvedStats,
                          trophyBoxSize: trophyBoxSize,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  NetworkQuickActions(
                    onConnectionsTap: onConnectionsTap ?? () {},
                    onCompaniesTap: onCompaniesTap ?? () {},
                    onRequestsTap: onRequestsTap ?? () {},
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}