// lib/features/network/widgets/network_profile_identity.dart

// =======================================================
// NETWORK PROFILE IDENTITY
// -------------------------------------------------------
// Bloco superior do card com avatar e dados do usuário
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/shared/widgets/app_avatar.dart';

class NetworkProfileIdentity extends StatelessWidget {
  final String userName;
  final String userRole;
  final String avatarUrl;
  final int connectionsCount;
  final double avatarSize;
  final double badgeSize;

  const NetworkProfileIdentity({
    super.key,
    required this.userName,
    required this.userRole,
    required this.avatarUrl,
    required this.connectionsCount,
    required this.avatarSize,
    required this.badgeSize,
  });

  String get _resolvedName {
    final value = userName.trim();
    return value.isEmpty ? 'Nome do usuário' : value;
  }

  String get _resolvedRole {
    final value = userRole.trim();
    return value.isEmpty ? 'Cargo não informado' : value;
  }

  String _getRoleIcon(String role) {
    switch (role.trim()) {
      case 'UI/UX Designer':
        return AppIcons.paint;
      case 'Frontend Developer':
        return AppIcons.code;
      case 'Backend Developer':
        return AppIcons.database;
      case 'QA Engineer':
        return AppIcons.shield;
      case 'Product Manager':
        return AppIcons.box;
      case 'Data Analyst':
        return AppIcons.data;
      case 'Mobile Developer':
        return AppIcons.mobile;
      case 'DevOps Engineer':
        return AppIcons.devops;
      default:
        return AppIcons.role;
    }
  }

  Widget _buildInfoRow({
    required String icon,
    required String text,
    required double iconSize,
    required double fontSize,
    required TextStyle? baseStyle,
    required FontWeight fontWeight,
    int maxLines = 1,
    double opacity = 0.78,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          icon,
          width: iconSize,
          height: iconSize,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: baseStyle?.copyWith(
              fontSize: fontSize,
              color: Colors.white.withOpacity(opacity),
              fontWeight: fontWeight,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleFontSize = (avatarSize * 0.20).clamp(18.0, 24.0).toDouble();
    final roleFontSize = (avatarSize * 0.19).clamp(13.0, 16.0).toDouble();
    final subtitleFontSize = (avatarSize * 0.18).clamp(12.0, 15.0).toDouble();
    final iconSize = (avatarSize * 0.18).clamp(14.0, 16.0).toDouble();
    final horizontalGap = (avatarSize * 0.18).clamp(12.0, 16.0).toDouble();
    final finalBadgeSize = (badgeSize * 0.78).clamp(18.0, badgeSize).toDouble();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(
          imageUrl: avatarUrl,
          size: avatarSize,
        ),
        SizedBox(width: horizontalGap),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: avatarSize * 0.08),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  icon: AppIcons.user,
                  text: _resolvedName,
                  iconSize: iconSize,
                  fontSize: titleFontSize,
                  baseStyle: theme.textTheme.titleMedium,
                  fontWeight: FontWeight.w700,
                  maxLines: 2,
                  opacity: 1,
                ),
                SizedBox(height: avatarSize * 0.08),
                _buildInfoRow(
                  icon: _getRoleIcon(_resolvedRole),
                  text: _resolvedRole,
                  iconSize: iconSize,
                  fontSize: roleFontSize,
                  baseStyle: theme.textTheme.bodyMedium,
                  fontWeight: FontWeight.w600,
                  opacity: 0.76,
                ),
                SizedBox(height: avatarSize * 0.08),
                _buildInfoRow(
                  icon: AppIcons.group,
                  text: '$connectionsCount amigos no JobMatch',
                  iconSize: iconSize,
                  fontSize: subtitleFontSize,
                  baseStyle: theme.textTheme.bodyMedium,
                  fontWeight: FontWeight.w500,
                  opacity: 0.58,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: avatarSize * 0.10),
        SizedBox(
          width: finalBadgeSize,
          height: finalBadgeSize,
          child: SvgPicture.asset(
            AppIcons.verify,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}