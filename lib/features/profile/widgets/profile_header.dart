// =======================================================
// PROFILE HEADER
// -------------------------------------------------------
// Agora conectado ao UserModel (dados dinâmicos)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/profile/models/user_model.dart';

import '../../../shared/widgets/app_cover.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_user_info.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../../shared/widgets/app_edit_button.dart';
import '../../../core/constants/app_icons.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        children: [
          // ===================================================
          // CAPA + AVATAR
          // ===================================================
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              AppCover(
                imageUrl: user.coverUrl, // 🔥 DINÂMICO
              ),

              Positioned(
                bottom: -40,
                child: AppAvatar(
                  size: 90,
                  imageUrl: user.avatarUrl, // 🔥 DINÂMICO
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          // ===================================================
          // NOME + PROFISSÃO
          // ===================================================
          AppUserInfo(
            name: user.name,   // 🔥 DINÂMICO
            role: user.role,   // 🔥 DINÂMICO
          ),

          const SizedBox(height: 20),

          // ===================================================
          // STATS
          // ===================================================
          Row(
            children: [
              Expanded(
                child: _ProfileStat(
                  iconPath: AppIcons.group,
                  label: user.connections.toString(), // 🔥 DINÂMICO
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProfileStat(
                  iconPath: AppIcons.eye,
                  label: user.views.toString(), // 🔥 DINÂMICO
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ===================================================
          // BOTÃO EDITAR
          // ===================================================
          AppEditButton(
            label: 'Editar perfil',
            onPressed: () {
              // 🔥 depois conecta com navegação / edição
            },
          ),
        ],
      ),
    );
  }
}

// =======================================================
// PROFILE STAT
// =======================================================

class _ProfileStat extends StatelessWidget {
  final String iconPath;
  final String label;

  const _ProfileStat({
    required this.iconPath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.cardTertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),

          const SizedBox(width: 8),

          Text(label),
        ],
      ),
    );
  }
}