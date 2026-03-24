// =======================================================
// CHAT SEARCH
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

class ChatSearch extends StatelessWidget {
  const ChatSearch({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),

        decoration: BoxDecoration(
          color: colors.cardTertiary,
          borderRadius: BorderRadius.circular(12),
        ),

        child: Row(
          children: [

            const Icon(Icons.search, size: 20),

            const SizedBox(width: 12),

            Text(
              'Buscar por mensagens',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}