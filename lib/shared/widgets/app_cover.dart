// =======================================================
// APP COVER
// -------------------------------------------------------
// Capa com suporte a:
// - imagem (profile)
// - gradient (default/home)
// - modo edição
// =======================================================

import 'package:flutter/material.dart';

class AppCover extends StatelessWidget {
  final String? imageUrl;
  final bool isEditable;
  final VoidCallback? onEdit;

  const AppCover({
    super.key,
    this.imageUrl,
    this.isEditable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditable ? onEdit : null,

      child: Stack(
        children: [
          Container(
            height: 140,
            width: double.infinity,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),

              // ===================================================
              // IMAGEM OU GRADIENT
              // ===================================================
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,

              gradient: imageUrl == null
                  ? const LinearGradient(
                      colors: [Color(0xFF68E3FF), Color(0xFF3A8DFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
          ),

          // ===================================================
          // OVERLAY DE EDIÇÃO
          // ===================================================
          if (isEditable)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}