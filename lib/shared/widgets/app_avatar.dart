// =======================================================
// APP AVATAR
// -------------------------------------------------------
// Avatar padrão do app (customizável)
// =======================================================

import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const AppAvatar({
    super.key,
    required this.imageUrl,
    this.size = 80, // 🔥 padrão
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF68E3FF), Color(0xFF00C2FF)],
        ),
      ),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: theme.colorScheme.surface,
        child: CircleAvatar(
          radius: (size / 2) - 4,
          backgroundImage: NetworkImage(imageUrl),
        ),
      ),
    );
  }
}
