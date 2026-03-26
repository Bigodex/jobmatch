// =======================================================
// PROFILE LINKS
// -------------------------------------------------------
// Agora conectado ao ProfileLinkModel (dinâmico)
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/profile/models/social_link_model.dart';

class ProfileLinks extends StatelessWidget {
  final List<SocialLinkModel> links;
  final VoidCallback? onAdd;
  final Function(SocialLinkModel)? onEdit;

  const ProfileLinks({
    super.key,
    required this.links,
    this.onAdd,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [

          // ===================================================
          // LISTA DINÂMICA
          // ===================================================
          ...links.map((link) => Column(
                children: [
                  _LinkItem(
                    link: link,
                    onEdit: () => onEdit?.call(link),
                  ),
                  const SizedBox(height: 12),
                ],
              )),

          // ===================================================
          // BOTÃO ADD
          // ===================================================
          _AddLinkButton(onTap: onAdd),
        ],
      ),
    );
  }
}

// =======================================================
// LINK ITEM
// =======================================================

class _LinkItem extends StatelessWidget {
  final SocialLinkModel link;
  final VoidCallback? onEdit;

  const _LinkItem({
    required this.link,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.cardTertiary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // TEXTO
          Text(
            link.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          // EDIT
          GestureDetector(
            onTap: onEdit,
            child: const Icon(Icons.edit, size: 18),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// ADD BUTTON
// =======================================================

class _AddLinkButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddLinkButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.cardTertiary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}