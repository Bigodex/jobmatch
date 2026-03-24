// =======================================================
// APP EDIT BUTTON
// -------------------------------------------------------
// Botão reutilizável para ações de edição.
//
// Usa AppColorsExtension para manter consistência visual
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

class AppEditButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const AppEditButton({
    super.key,
    required this.onPressed,
    this.label = 'Editar',
    this.icon = Icons.edit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ===================================================
    // EXTENSION (PEGA cardSecondary)
    // ===================================================
    final colors = theme.extension<AppColorsExtension>()!;

    return SizedBox(
      width: double.infinity,
      height: 48,

      child: ElevatedButton.icon(
        onPressed: onPressed,

        // ===================================================
        // ÍCONE
        // ===================================================
        icon: Icon(
          icon,
          size: 18,
        ),

        // ===================================================
        // TEXTO
        // ===================================================
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        // ===================================================
        // ESTILO
        // ===================================================
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.cardTertiary, // 🔥 AQUI
          foregroundColor: Colors.white,
          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}