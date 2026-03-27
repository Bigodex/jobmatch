// =======================================================
// PROFILE HEADER
// -------------------------------------------------------
// - edição de capa
// - edição de avatar
// - edição de nome e cargo (UX melhorada)
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:jobmatch/core/services/cloudinary_service.dart';

import 'package:jobmatch/features/profile/models/user_model.dart';
import 'package:jobmatch/features/profile/providers/profile_provider.dart';

import '../../../shared/widgets/app_cover.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_user_info.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../../shared/widgets/app_edit_button.dart';
import '../../../core/constants/app_icons.dart';

class ProfileHeader extends ConsumerStatefulWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

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

  @override
  Widget build(BuildContext context) {
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
                isEditable: isEditing,
                onEdit: () {
                  if (isEditing) _pickAndUploadCover();
                },
              ),

              Positioned(
                bottom: -40,
                child: GestureDetector(
                  onTap: () {
                    if (isEditing) _pickAndUploadAvatar();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AppAvatar(size: 90, imageUrl: widget.user.avatarUrl),

                      if (isEditing)
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
          // USER INFO (🔥 CORRIGIDO)
          // ===================================================
          isEditing
              ? Column(
                  children: [
                    // =========================
                    // NOME
                    // =========================
                    TextField(
                      controller: nameController,
                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        fontSize: 16, // 🔥 menor
                        fontWeight: FontWeight.w500,
                      ),

                      decoration: InputDecoration(
                        labelText: 'Nome',
                        hintText: 'Digite seu nome',

                        isDense: true, // 🔥 reduz altura geral

                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, // 🔥 aqui controla a altura real
                          horizontal: 12,
                        ),

                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // leve ajuste visual
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // =========================
                    // CARGO
                    // =========================
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

                        isDense: true, // 🔥 reduz altura
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),

                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : AppUserInfo(name: widget.user.name, role: widget.user.role),

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
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProfileStat(
                  iconPath: AppIcons.eye,
                  label: widget.user.views.toString(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ===================================================
          // BOTÃO
          // ===================================================
          AppEditButton(
            label: isEditing ? 'Salvar' : 'Editar perfil',

            color: isEditing ? Theme.of(context).colorScheme.primary : null,

            onPressed: () {
              if (isEditing) {
                // 🔥 VALIDAÇÃO
                if (nameController.text.trim().isEmpty ||
                    roleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preencha todos os campos')),
                  );
                  return;
                }

                ref
                    .read(profileProvider.notifier)
                    .updateUserInfo(
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

  const _ProfileStat({required this.iconPath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
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
  }
}
