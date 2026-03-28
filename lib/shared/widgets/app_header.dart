// =======================================================
// APP HEADER
// -------------------------------------------------------
// Header padrão do app (layout fixo)
// - Menu (esquerda) OU Back
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

  // 🔥 NOVO
  final bool showBackButton;

  const AppHeader({
    super.key,
    required this.title,
    this.onMenuTap,
    this.onActionTap,
    this.showBackButton = false, // default mantém comportamento atual
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        color: appColors.header,
      ),
      child: Row(
        children: [
          // ===================================================
          // LEFT ICON (MENU OU BACK)
          // ===================================================

          GestureDetector(
            onTap: showBackButton
                ? () => Navigator.pop(context)
                : onMenuTap,
            child: SvgPicture.asset(
              showBackButton ? AppIcons.arrowleft : AppIcons.burger,
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
          // TITLE
          // ===================================================

          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          // ===================================================
          // ACTION ICON
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