// =======================================================
// APP EDIT BUTTON
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

class AppEditButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Widget icon;
  final Color? color;

  const AppEditButton({
    super.key,
    required this.onPressed,
    this.label = 'Editar',
    this.icon = const Icon(Icons.edit, size: 18),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    final background = color ?? colors.cardTertiary;
    final isPrimary = background == theme.colorScheme.primary;
    final foreground = isPrimary ? Colors.black : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: IconTheme(
          data: IconThemeData(color: foreground, size: 18),
          child: icon,
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
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}