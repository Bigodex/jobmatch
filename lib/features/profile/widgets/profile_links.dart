// =======================================================
// PROFILE LINKS
// -------------------------------------------------------
// Agora no padrão dos demais cards do profile
// - Card único com header
// - Badge de pendência e sucesso
// - Navegação direta para edição
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/features/profile/models/social_link_model.dart';

class ProfileLinks extends StatelessWidget {
  final List<SocialLinkModel> links;

  const ProfileLinks({
    super.key,
    required this.links,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardTertiary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===================================================
            // HEADER
            // ===================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.links,
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Links',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    context.push(
                      '/edit-links',
                      extra: links,
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                ),
              ],
            ),

            Divider(color: theme.dividerColor.withOpacity(0.2)),
            const SizedBox(height: 8),

            // ===================================================
            // CONTEÚDO
            // ===================================================
            if (links.isEmpty)
              const _PendingLinkItem(
                fieldName: 'links',
              )
            else
              Column(
                children: List.generate(links.length, (index) {
                  final link = links[index];

                  return Column(
                    children: [
                      _LinkItem(link: link),
                      if (index != links.length - 1)
                        Divider(
                          height: 20,
                          color: theme.dividerColor.withOpacity(0.2),
                        ),
                    ],
                  );
                }),
              ),

            const SizedBox(height: 14),

            // ===================================================
            // BOTÃO ADD
            // ===================================================
            _AddLinkButton(
              onTap: () {
                context.push(
                  '/edit-links',
                  extra: links,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// LINK ITEM
// =======================================================

class _LinkItem extends StatelessWidget {
  final SocialLinkModel link;

  const _LinkItem({
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    final label = link.label.trim();
    final url = link.url.trim();

    final hasLabel = label.isNotEmpty;
    final hasUrl = url.isNotEmpty;
    final isPending = !hasLabel || !hasUrl;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusIcon(
          icon: AppIcons.links,
          isPending: isPending,
        ),
        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasLabel)
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                _pendingText(
                  context: context,
                  fieldName: 'nome do link',
                ),

              const SizedBox(height: 4),

              if (hasUrl)
                Text(
                  url,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withOpacity(0.62),
                  ),
                )
              else
                _pendingText(
                  context: context,
                  fieldName: 'url',
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// =======================================================
// ITEM PENDENTE (LISTA VAZIA)
// =======================================================

class _PendingLinkItem extends StatelessWidget {
  final String fieldName;

  const _PendingLinkItem({
    required this.fieldName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusIcon(
          icon: AppIcons.links,
          isPending: true,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _pendingText(
            context: context,
            fieldName: fieldName,
          ),
        ),
      ],
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
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.cardSecondary.withOpacity(0.45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: const Center(
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

// =======================================================
// TEXTO DE PENDÊNCIA
// =======================================================

Widget _pendingText({
  required BuildContext context,
  required String fieldName,
}) {
  final pendingColor = Colors.amber.shade300;

  return RichText(
    textAlign: TextAlign.start,
    text: TextSpan(
      style: TextStyle(
        fontSize: 13,
        height: 1.4,
        color: Colors.white.withOpacity(0.78),
      ),
      children: [
        const TextSpan(
          text: 'Preencha os dados de ',
        ),
        TextSpan(
          text: fieldName,
          style: TextStyle(
            color: pendingColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const TextSpan(
          text: ', que no momento se encontra pendente.',
        ),
      ],
    ),
  );
}

// =======================================================
// ÍCONE COM BADGE DE STATUS
// -------------------------------------------------------
// - Pendente -> badge amarela com exclamação preta
// - Preenchido -> badge azul com check preto
// =======================================================

class _StatusIcon extends StatelessWidget {
  final String icon;
  final bool isPending;

  const _StatusIcon({
    required this.icon,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColorsExtension>()!;
    final pendingColor = Colors.amber.shade300;
    final successColor = theme.colorScheme.primary;

    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              icon,
              width: 16,
              height: 16,
            ),
          ),
          Positioned(
            right: -3,
            bottom: -3,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: isPending ? pendingColor : successColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.cardTertiary,
                  width: 1.2,
                ),
              ),
              child: Icon(
                isPending ? Icons.priority_high_rounded : Icons.check_rounded,
                size: 8,
                color: Colors.black.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}