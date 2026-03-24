// =======================================================
// APP HEADER
// -------------------------------------------------------
// Header padrão do app (layout fixo)
// - Menu (esquerda)
// - Título dinâmico
// - Ação (direita)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

import '../../core/constants/app_icons.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final VoidCallback? onActionTap;

  const AppHeader({
    super.key,
    required this.title,
    this.onMenuTap,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,

      decoration: BoxDecoration(
        color: appColors.header, // 🔥 vindo do theme
      ),

      child: Row(
        children: [

          // ===================================================
          // MENU ICON (ESQUERDA)
          // ===================================================

          GestureDetector(
            onTap: onMenuTap,
            child: SvgPicture.asset(
              AppIcons.burger,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ===================================================
          // TITLE (DINÂMICO)
          // ===================================================

          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // ===================================================
          // ACTION ICON (DIREITA)
          // ===================================================

          GestureDetector(
            onTap: onActionTap,
            child: SvgPicture.asset(
              AppIcons.bell,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}