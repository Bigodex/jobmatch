// =======================================================
// HOME CARD
// -------------------------------------------------------
// Card interno (item)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

class HomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final VoidCallback onTap;
  final double imageSize; // 🔥 tamanho configurável

  const HomeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.onTap,
    this.imageSize = 40, // padrão
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: appColors.cardSecondary,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Row(
          children: [

            // ===================================================
            // IMAGE (SUBSTITUI ÍCONE)
            // ===================================================

            SvgPicture.asset(
              image,
              width: imageSize,
              height: imageSize,
            ),

            const SizedBox(width: 16),

            // ===================================================
            // TEXTS
            // ===================================================

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      // ignore: deprecated_member_use
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 16
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}