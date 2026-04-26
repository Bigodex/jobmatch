// =======================================================
// APP COVER
// -------------------------------------------------------
// Capa reutilizável do app.
//
// Suporta:
// - imagem remota
// - banner padrão em SVG
// - modo edição com overlay
//
// Ajustes:
// - usa AppColors
// - troca withOpacity por withValues via AppColors
// - corrige unnecessary_underscores no errorBuilder
// - mantém a mesma assinatura pública do widget
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_colors.dart';

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

  // ===================================================
  // HAS IMAGE
  // ---------------------------------------------------
  // Verifica se existe uma URL válida para imagem remota.
  // ===================================================
  bool get _hasImage {
    return imageUrl != null && imageUrl!.trim().isNotEmpty;
  }

  // ===================================================
  // BUILD
  // ---------------------------------------------------
  // Monta a capa e aplica overlay de edição quando
  // necessário.
  // ===================================================
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditable ? onEdit : null,
      child: Stack(
        children: [
          _buildCoverImage(),
          if (isEditable) _buildEditOverlay(),
        ],
      ),
    );
  }

  // ===================================================
  // BUILD COVER IMAGE
  // ---------------------------------------------------
  // Renderiza imagem remota ou banner padrão.
  // Caso a imagem remota falhe, usa o banner padrão.
  // ===================================================
  Widget _buildCoverImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 140,
        width: double.infinity,
        child: _hasImage ? _buildRemoteCover() : _buildDefaultBanner(),
      ),
    );
  }

  // ===================================================
  // BUILD REMOTE COVER
  // ---------------------------------------------------
  // Renderiza a capa remota do usuário.
  // ===================================================
  Widget _buildRemoteCover() {
    return Image.network(
      imageUrl!.trim(),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildDefaultBanner();
      },
    );
  }

  // ===================================================
  // BUILD EDIT OVERLAY
  // ---------------------------------------------------
  // Overlay escuro com ícone de câmera para indicar
  // que a capa pode ser alterada.
  // ===================================================
  Widget _buildEditOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.blackOverlay(0.3),
        ),
        child: const Center(
          child: Icon(
            Icons.camera_alt,
            color: AppColors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  // ===================================================
  // BUILD DEFAULT BANNER
  // ---------------------------------------------------
  // Banner padrão usado quando não há imagem remota.
  // ===================================================
  Widget _buildDefaultBanner() {
    return SvgPicture.asset(
      _defaultBannerAsset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 140,
    );
  }
}
