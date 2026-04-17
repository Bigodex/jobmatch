// lib/features/network/widgets/network_profile_trophies.dart

// =======================================================
// NETWORK PROFILE TROPHIES
// -------------------------------------------------------
// Bloco inferior do card com troféus e progresso
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/features/network/models/network_profile_stats_model.dart';

class NetworkProfileTrophies extends StatelessWidget {
  final NetworkProfileStatsModel stats;
  final double trophyBoxSize;

  const NetworkProfileTrophies({
    super.key,
    required this.stats,
    required this.trophyBoxSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = stats.trophiesMax == 0
        ? 0.0
        : (stats.trophiesCount / stats.trophiesMax).clamp(0.0, 1.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: trophyBoxSize,
          height: trophyBoxSize,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Icon(
            Icons.emoji_events_rounded,
            size: trophyBoxSize * 0.42,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: trophyBoxSize * 0.24),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AchievementBadge(label: 'Iniciante'),
              const SizedBox(height: 4),
              Text(
                'Quantidade de Troféus',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.62),
                ),
              ),

              SizedBox(height: trophyBoxSize * 0.08),
              _NetworkTrophyProgressBar(
                progress: progress,
                trophiesCount: stats.trophiesCount,
                height: (trophyBoxSize * 0.10).clamp(10.0, 14.0).toDouble(),
                badgeSize: (trophyBoxSize * 0.30).clamp(22.0, 28.0).toDouble(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final String label;

  const _AchievementBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkTrophyProgressBar extends StatelessWidget {
  final double progress;
  final int trophiesCount;
  final double height;
  final double badgeSize;

  const _NetworkTrophyProgressBar({
    required this.progress,
    required this.trophiesCount,
    required this.height,
    required this.badgeSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final fillWidth = totalWidth * progress;
        final barAreaHeight = badgeSize > height ? badgeSize : height;
        final trackTop = (barAreaHeight - height) / 4;
        final badgeTop = (barAreaHeight - badgeSize) / 2;
        final badgeLeft = (fillWidth - (badgeSize / 2)).clamp(
          0.0,
          totalWidth - badgeSize,
        );

        return SizedBox(
          height: barAreaHeight,
          child: Stack(
            children: [
              Positioned(
                top: trackTop,
                left: 0,
                right: 0,
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height / 2),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                  ),
                ),
              ),
              Positioned(
                top: trackTop,
                left: 0,
                child: Container(
                  width: fillWidth,
                  height: height,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
              Positioned(
                top: badgeTop,
                left: badgeLeft,
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 3.5,
                    ),
                  ),
                  child: Text(
                    '$trophiesCount',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: badgeSize * 0.34,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
