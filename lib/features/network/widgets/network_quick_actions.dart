// lib/features/network/widgets/network_quick_actions.dart

// =======================================================
// NETWORK QUICK ACTIONS
// -------------------------------------------------------
// Bloco com os 3 botões da tela de rede
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

class NetworkQuickActions extends StatelessWidget {
  final VoidCallback onConnectionsTap;
  final VoidCallback onCompaniesTap;
  final VoidCallback onRequestsTap;

  const NetworkQuickActions({
    super.key,
    required this.onConnectionsTap,
    required this.onCompaniesTap,
    required this.onRequestsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _NetworkQuickActionButton(
            icon: AppIcons.group,
            label: 'Conexões',
            onTap: onConnectionsTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NetworkQuickActionButton(
            icon: AppIcons.buildingfull,
            label: 'Empresas',
            onTap: onCompaniesTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NetworkQuickActionButton(
            icon: AppIcons.adduser,
            label: 'Solicitações',
            onTap: onRequestsTap,
          ),
        ),
      ],
    );
  }
}

class _NetworkQuickActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _NetworkQuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: 100,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: appColors.cardTertiary,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}