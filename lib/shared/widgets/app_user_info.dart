// =======================================================
// APP USER INFO
// -------------------------------------------------------
// Nome + cargo do usuário
// =======================================================

import 'package:flutter/material.dart';

class AppUserInfo extends StatelessWidget {
  final String name;
  final String role;

  const AppUserInfo({
    super.key,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [

        Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20
          ),
        ),

        const SizedBox(height: 4),

        Text(
          role,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}