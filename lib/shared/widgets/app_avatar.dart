// =======================================================
// APP AVATAR
// -------------------------------------------------------
// Avatar reutilizável do app.
//
// Suporta:
// - imagem remota
// - avatar padrão em SVG
// - modo editável
// - ícone de edição
//
// Ajustes:
// - remove cores hardcoded principais
// - usa AppColors
// - troca withOpacity por withValues via AppColors
// - corrige unnecessary_underscores no errorBuilder
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  final bool isEditable;
  final VoidCallback? onEdit;

  static const String _defaultProfileAsset = 'assets/images/jobu_profile.svg';

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.size = 80,
    this.isEditable = false,
    this.onEdit,
  });

  // ===================================================
  // HAS IMAGE
  // ---------------------------------------------------
  // Verifica se existe URL válida para imagem remota.
  // ===================================================
  bool get _hasImage {
    return imageUrl != null && imageUrl!.trim().isNotEmpty;
  }

  // ===================================================
  // BUILD
  // ---------------------------------------------------
  // Monta o avatar com borda em gradiente e, quando
  // editável, exibe o botão visual de edição.
  // ===================================================
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditable ? onEdit : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildAvatarContainer(),
          if (isEditable) _buildEditButton(),
        ],
      ),
    );
  }

  // ===================================================
  // BUILD AVATAR CONTAINER
  // ---------------------------------------------------
  // Cria o container circular com borda em gradiente.
  // ===================================================
  Widget _buildAvatarContainer() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            Color(0xFF00C2FF),
          ],
        ),
      ),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.cardSecondary,
        child: ClipOval(
          child: SizedBox(
            width: size - 8,
            height: size - 8,
            child: _hasImage ? _buildRemoteAvatar() : _buildDefaultAvatar(),
          ),
        ),
      ),
    );
  }

  // ===================================================
  // BUILD REMOTE AVATAR
  // ---------------------------------------------------
  // Renderiza a imagem remota. Caso falhe, volta para o
  // avatar padrão do Jobu.
  // ===================================================
  Widget _buildRemoteAvatar() {
    return Image.network(
      imageUrl!.trim(),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildDefaultAvatar();
      },
    );
  }

  // ===================================================
  // BUILD EDIT BUTTON
  // ---------------------------------------------------
  // Botão circular exibido no canto inferior direito
  // quando o avatar está em modo editável.
  // ===================================================
  Widget _buildEditButton() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.blackOverlay(0.7),
        ),
        child: SvgPicture.asset(
          AppIcons.group,
          width: 14,
          height: 14,
          colorFilter: const ColorFilter.mode(
            AppColors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  // ===================================================
  // BUILD DEFAULT AVATAR
  // ---------------------------------------------------
  // Avatar padrão usado quando não existe imagem remota
  // ou quando a imagem remota falha ao carregar.
  // ===================================================
  Widget _buildDefaultAvatar() {
    return SvgPicture.asset(
      _defaultProfileAsset,
      fit: BoxFit.cover,
    );
  }
}
