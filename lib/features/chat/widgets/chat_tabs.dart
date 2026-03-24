// =======================================================
// CHAT TABS
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

class ChatTabs extends StatelessWidget {
  const ChatTabs({super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),

      child: Row(
        children: const [
          Expanded(child: _TabItem(label: 'Pessoas', active: true)),
          SizedBox(width: 12),
          Expanded(child: _TabItem(label: 'Empresas')),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool active;

  const _TabItem({
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      height: 44,
      alignment: Alignment.center,

      decoration: BoxDecoration(
        color: active ? colors.cardSecondary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),

      child: Text(label),
    );
  }
}