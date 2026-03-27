// =======================================================
// APP EDIT BUTTON
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

class AppEditButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Color? color;

  const AppEditButton({
    super.key,
    required this.onPressed,
    this.label = 'Editar',
    this.icon = Icons.edit,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    final background = color ?? colors.cardTertiary;

    // 🔥 REGRA: se for primary → texto preto
    final isPrimary =
        background == theme.colorScheme.primary;

    final foreground = isPrimary ? Colors.black : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,

        icon: Icon(
          icon,
          size: 18,
        ),

        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground, // 🔥 DINÂMICO
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}