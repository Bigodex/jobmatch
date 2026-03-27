// =======================================================
// APP AVATAR
// -------------------------------------------------------
// Agora editável
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_icons.dart';

class AppAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  final bool isEditable;
  final VoidCallback? onEdit;

  const AppAvatar({
    super.key,
    required this.imageUrl,
    this.size = 80,
    this.isEditable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isEditable ? onEdit : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
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
          ),

          // 🔥 ÍCONE DE EDIÇÃO
          if (isEditable)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.7),
                ),
                child: SvgPicture.asset(
                  AppIcons.group,
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}