// =======================================================
// NETWORK PROFILE CARD SKELETON
// -------------------------------------------------------
// Loading do card de perfil da rede
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';
import 'package:jobmatch/shared/widgets/app_skeleton.dart';

class NetworkProfileCardSkeleton extends StatelessWidget {
  const NetworkProfileCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return AppSectionCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: appColors.cardTertiary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: Column(
          children: const [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(
                  width: 92,
                  height: 92,
                  shape: BoxShape.circle,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeleton(
                          width: 180,
                          height: 22,
                          borderRadius: 8,
                        ),
                        SizedBox(height: 10),
                        AppSkeleton(
                          width: 150,
                          height: 16,
                          borderRadius: 8,
                        ),
                        SizedBox(height: 10),
                        AppSkeleton(
                          width: 120,
                          height: 16,
                          borderRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                AppSkeleton(
                  width: 52,
                  height: 52,
                  shape: BoxShape.circle,
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                AppSkeleton(
                  width: 70,
                  height: 70,
                  borderRadius: 18,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton(
                        width: 220,
                        height: 22,
                        borderRadius: 8,
                      ),
                      SizedBox(height: 8),
                      AppSkeleton(
                        width: 140,
                        height: 14,
                        borderRadius: 8,
                      ),
                      SizedBox(height: 16),
                      AppSkeleton(
                        width: double.infinity,
                        height: 18,
                        borderRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}