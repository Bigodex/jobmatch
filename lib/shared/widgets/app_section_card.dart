// =======================================================
// APP SECTION CARD
// -------------------------------------------------------
// Container base reutilizável (bloco grande de UI)
// =======================================================

import 'package:flutter/material.dart';

class AppSectionCard extends StatelessWidget {
  final Widget child;

  const AppSectionCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
      ),

      child: child,
    );
  }
}