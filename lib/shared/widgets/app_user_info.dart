// =======================================================
// APP USER INFO
// -------------------------------------------------------
// Exibe nome + cargo do usuário.
//
// Usado em áreas como:
// - header do perfil
// - cards de identidade
// - blocos públicos de usuário
//
// Ajustes:
// - remove withOpacity deprecated
// - usa AppColors para cor secundária
// - mantém assinatura pública do widget
// =======================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppUserInfo extends StatelessWidget {
  final String name;
  final String role;

  const AppUserInfo({
    super.key,
    required this.name,
    required this.role,
  });

  // ===================================================
  // BUILD
  // ---------------------------------------------------
  // Monta a coluna com nome e cargo do usuário.
  // ===================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          name,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          role,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
