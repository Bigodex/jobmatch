// =======================================================
// PROFILE HEADER
// -------------------------------------------------------
// - edição de capa
// - edição de avatar
// - edição de nome e cargo (UX melhorada)
// - cargo com ícone da especialidade
// - suporte a modo público (somente leitura)
// - botão público dinâmico
// - card de conexões clicável
// - contador de views vindo do provider de visualizações
// =======================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobmatch/core/services/cloudinary_service.dart';

import 'package:jobmatch/features/profile/models/user_model.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';
import 'package:jobmatch/features/network/providers/profile_views_provider.dart';

import '../../../shared/widgets/app_cover.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../../shared/widgets/app_edit_button.dart';
import '../../../core/constants/app_icons.dart';

class ProfileHeader extends ConsumerStatefulWidget {
  final UserModel user;
  final bool isPublic;
  final VoidCallback? onConnect;
  final VoidCallback? onConnectionsTap;
  final VoidCallback? onPublicSecondaryTap;

  // =====================================================
  // BOTÃO PÚBLICO DINÂMICO
  // =====================================================
  final String? publicButtonLabel;
  final Widget? publicButtonIcon;
  final Color? publicButtonColor;
  final String? publicSecondaryStatLabel;
  final String? publicSecondaryStatIconPath;

  const ProfileHeader({
    super.key,
    required this.user,
    this.isPublic = false,
    this.onConnect,
    this.onConnectionsTap,
    this.onPublicSecondaryTap,
    this.publicButtonLabel,
    this.publicButtonIcon,
    this.publicButtonColor,
    this.publicSecondaryStatLabel,
    this.publicSecondaryStatIconPath,
  });

  @override
  ConsumerState<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<ProfileHeader> {
  bool isEditing = false;

  late TextEditingController nameController;
  late TextEditingController roleController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.user.name);
    roleController = TextEditingController(text: widget.user.role);
  }

  @override
  void didUpdateWidget(covariant ProfileHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.user.name != widget.user.name) {
      nameController.text = widget.user.name;
    }

    if (oldWidget.user.role != widget.user.role) {
      roleController.text = widget.user.role;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    roleController.dispose();
    super.dispose();
  }

  // ===================================================
  // COVER
  // ===================================================
  Future<void> _pickAndUploadCover() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    final url = await CloudinaryService.uploadImage(File(picked.path));

    if (url != null) {
      ref.read(profileProvider.notifier).updateCover(url);
    }
  }

  // ===================================================
  // AVATAR
  // ===================================================
  Future<void> _pickAndUploadAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    final url = await CloudinaryService.uploadImage(File(picked.path));

    if (url != null) {
      ref.read(profileProvider.notifier).updateAvatar(url);
    }
  }

  // ===================================================
  // MAPA DE ÍCONES DA ESPECIALIDADE
  // ===================================================
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
        return AppIcons.briefcase;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canEdit = !widget.isPublic;
    final showEditing = canEdit && isEditing;

    final publicLabel = widget.publicButtonLabel ?? 'Conectar';
    final publicIcon =
        widget.publicButtonIcon ??
        SvgPicture.asset(
          AppIcons.connections,
          width: 18,
          height: 18,
          colorFilter: const ColorFilter.mode(
            Colors.black,
            BlendMode.srcIn,
          ),
        );
    final publicColor = widget.publicButtonColor ?? theme.colorScheme.primary;

    final myViewsAsync = ref.watch(myProfileViewsProvider);

    final viewsCount = widget.isPublic
        ? widget.user.views
        : myViewsAsync.maybeWhen(
            data: (views) => views.length,
            orElse: () => widget.user.views,
          );

    return AppSectionCard(
      child: Column(
        children: [
          // ===================================================
          // COVER + AVATAR
          // ===================================================
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              AppCover(
                imageUrl: widget.user.coverUrl,
                isEditable: showEditing,
                onEdit: () {
                  if (showEditing) _pickAndUploadCover();
                },
              ),
              Positioned(
                bottom: -40,
                child: GestureDetector(
                  onTap: () {
                    if (showEditing) _pickAndUploadAvatar();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AppAvatar(size: 90, imageUrl: widget.user.avatarUrl),
                      if (showEditing)
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.4),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          // ===================================================
          // USER INFO
          // ===================================================
          showEditing
              ? Column(
                  children: [
                    TextField(
                      controller: nameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        hintText: 'Digite seu nome',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roleController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Cargo',
                        hintText: 'Ex: Desenvolvedor Flutter',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Text(
                      widget.user.name,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          _getRoleIcon(widget.user.role),
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.user.role,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.72),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                  label: widget.user.connections.toString(),
                  onTap: widget.onConnectionsTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProfileStat(
                  iconPath: widget.isPublic
                      ? (widget.publicSecondaryStatIconPath ?? AppIcons.chatfull)
                      : AppIcons.eye,
                  label: widget.isPublic
                      ? (widget.publicSecondaryStatLabel ?? 'Chat')
                      : viewsCount.toString(),
                  onTap: widget.isPublic
                      ? widget.onPublicSecondaryTap
                      : () {
                          context.push('/viewers');
                        },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ===================================================
          // BOTÃO
          // ===================================================
          AppEditButton(
            label: widget.isPublic
                ? publicLabel
                : isEditing
                    ? 'Salvar'
                    : 'Editar perfil',
            icon: widget.isPublic ? publicIcon : const Icon(Icons.edit, size: 18),
            color: widget.isPublic
                ? publicColor
                : isEditing
                    ? theme.colorScheme.primary
                    : null,
            onPressed: () {
              if (widget.isPublic) {
                widget.onConnect?.call();
                return;
              }

              if (isEditing) {
                if (nameController.text.trim().isEmpty ||
                    roleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preencha todos os campos')),
                  );
                  return;
                }

                ref.read(profileProvider.notifier).updateUserInfo(
                  name: nameController.text,
                  role: roleController.text,
                );
              }

              setState(() {
                isEditing = !isEditing;
              });
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
  final VoidCallback? onTap;

  const _ProfileStat({
    required this.iconPath,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
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
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: content,
      ),
    );
  }
}