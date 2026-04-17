// =======================================================
// APP COVER
// -------------------------------------------------------
// Capa com suporte a:
// - imagem remota
// - banner padrão em SVG
// - modo edição
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppCover extends StatelessWidget {
  final String? imageUrl;
  final bool isEditable;
  final VoidCallback? onEdit;

  static const String _defaultBannerAsset = 'assets/images/banner.svg';

  const AppCover({
    super.key,
    this.imageUrl,
    this.isEditable = false,
    this.onEdit,
  });

  bool get _hasImage =>
      imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditable ? onEdit : null,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: _hasImage
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return _buildDefaultBanner();
                      },
                    )
                  : _buildDefaultBanner(),
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

  Widget _buildDefaultBanner() {
    return SvgPicture.asset(
      _defaultBannerAsset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 140,
    );
  }
}