// =======================================================
// PROFILE LINKS
// -------------------------------------------------------
// Card de links externos do usuário
//
// Estrutura:
// - Lista de links
// - Botão adicionar
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

class ProfileLinks extends StatelessWidget {
  const ProfileLinks({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),

      child: Column(
        children: const [

          _LinkItem(label: 'Behance'),
          SizedBox(height: 12),

          _LinkItem(label: 'GitHub'),
          SizedBox(height: 12),

          _AddLinkButton(),
        ],
      ),
    );
  }
}

// =======================================================
// LINK ITEM
// =======================================================

class _LinkItem extends StatelessWidget {
  final String label;

  const _LinkItem({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),

      decoration: BoxDecoration(
        color: colors.cardTertiary,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // TEXTO
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          // EDIT
          const Icon(Icons.edit, size: 18),
        ],
      ),
    );
  }
}

// =======================================================
// ADD BUTTON
// =======================================================

class _AddLinkButton extends StatelessWidget {
  const _AddLinkButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Container(
      height: 56,
      width: double.infinity,

      decoration: BoxDecoration(
        color: colors.cardTertiary,
        borderRadius: BorderRadius.circular(14),
      ),

      child: const Center(
        child: Icon(Icons.add),
      ),
    );
  }
}