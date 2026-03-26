// =======================================================
// APP COVER
// -------------------------------------------------------
// Componente de capa com gradiente
// =======================================================

import 'package:flutter/material.dart';

class AppCover extends StatelessWidget {
  const AppCover({super.key, required String imageUrl});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF68E3FF), Color(0xFF3A8DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
