// =======================================================
// PROFILE HEADER
// -------------------------------------------------------
// Agora encapsulado em AppSectionCard
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

import '../../../shared/widgets/app_cover.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_user_info.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../../shared/widgets/app_edit_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_icons.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

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
              const AppCover(),

              const Positioned(
                bottom: -40,
                child: AppAvatar(
                  size: 90,
                  imageUrl: 'https://i.pravatar.cc/150?img=3',
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          // ===================================================
          // NOME + PROFISSÃO
          // ===================================================
          const AppUserInfo(
            name: 'Pedro Piola',
            role: 'Desenvolvedor FullStack',
          ),

          const SizedBox(height: 20),

          // ===================================================
          // STATS
          // ===================================================
          Row(
            children: const [
              Expanded(
                child: _ProfileStat(
                  iconPath: AppIcons.group, // 🔥 SVG
                  label: '1000',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _ProfileStat(
                  iconPath: AppIcons.eye, // 🔥 SVG
                  label: '10.000',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ===================================================
          // BOTÃO EDITAR
          // ===================================================
          AppEditButton(
            // depois você liga a ação
            label: 'Editar perfil',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// =======================================================
// PROFILE STAT
// -------------------------------------------------------
// Card pequeno de métricas (com SVG + cardSecondary)
// =======================================================

class _ProfileStat extends StatelessWidget {
  final String iconPath;
  final String label;

  const _ProfileStat({required this.iconPath, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.cardTertiary, // 🔥 mesma cor dos cards novos
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ===================================================
          // ÍCONE SVG
          // ===================================================
          SvgPicture.asset(
            iconPath,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),

          const SizedBox(width: 8),

          // ===================================================
          // TEXTO
          // ===================================================
          Text(label),
        ],
      ),
    );
  }
}
