// lib/features/network/widgets/network_discover_sections.dart

// =======================================================
// NETWORK DISCOVER SECTIONS
// -------------------------------------------------------
// Seção de usuários reais
// Cards em 2 colunas com altura acompanhando o conteúdo
// Busca centralizada via provider
// - sem filtros pré-prontos
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/network/models/network_discover_profile_model.dart';
import 'package:jobmatch/features/network/providers/network_provider.dart';
import 'package:jobmatch/shared/widgets/app_avatar.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class NetworkDiscoverSections extends ConsumerWidget {
  const NetworkDiscoverSections({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(networkProfilesProvider);
    final query = ref.watch(networkSearchProvider);

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Usuários da Rede',
            subtitle: 'Se conecte e sempre se mantenha ligado!',
          ),
          const SizedBox(height: 18),
          profilesAsync.when(
            loading: () => const _DiscoverLoading(),
            error: (error, _) => const _DiscoverFeedback(
              message: 'Erro ao carregar perfis da rede.',
            ),
            data: (profiles) {
              final filteredProfiles = profiles.where((profile) {
                return profile.matchesSearch(query);
              }).toList();

              if (filteredProfiles.isEmpty) {
                return const _DiscoverFeedback(
                  message: 'Nenhum perfil encontrado com essa busca.',
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 16.0;
                  final itemWidth = (constraints.maxWidth - spacing) / 2;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: filteredProfiles.map((profile) {
                      return SizedBox(
                        width: itemWidth,
                        child: _DiscoverCard(item: profile),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.62),
          ),
        ),
      ],
    );
  }
}

class _DiscoverCard extends ConsumerWidget {
  final NetworkDiscoverProfileModel item;

  const _DiscoverCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    final connectionStatusAsync =
        ref.watch(networkConnectionStatusProvider(item.id));
    final connectionActionState = ref.watch(networkConnectionControllerProvider);
    final connectionController =
        ref.read(networkConnectionControllerProvider.notifier);

    final isCheckingConnection = connectionStatusAsync.isLoading;
    final isActionLoading = connectionActionState.isLoading;
    final isConnected = connectionStatusAsync.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );

    final isBusy = isCheckingConnection || isActionLoading;

    final buttonBackground = isConnected
        ? appColors.cardTertiary
        : theme.colorScheme.primary;

    final buttonBorderColor = isConnected
        ? theme.colorScheme.primary.withOpacity(0.28)
        : Colors.transparent;

    final buttonTextColor = isConnected ? Colors.white : Colors.black;

    final buttonIcon = isConnected ? AppIcons.group : AppIcons.adduser;

    final buttonLabel = isCheckingConnection
        ? 'Verificando'
        : isActionLoading
        ? 'Conectando...'
        : isConnected
        ? 'Conectado'
        : 'Conectar';

    return Container(
      decoration: BoxDecoration(
        color: appColors.cardTertiary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 74,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: _DiscoverCoverImage(coverUrl: item.coverUrl),
                    ),
                  ),
                  const SizedBox(height: 46),
                ],
              ),
              Positioned(
                top: 26,
                child: item.isCompany
                    ? Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: appColors.cardTertiary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.10),
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppIcons.buildingfull,
                            width: 30,
                            height: 30,
                            colorFilter: ColorFilter.mode(
                              theme.colorScheme.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      )
                    : AppAvatar(
                        imageUrl: item.avatarUrl,
                        size: 84,
                      ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    context.push('/network/user/${item.id}');
                  },
                  child: Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.role.isEmpty ? 'Profissional' : item.role,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.78),
                    height: 1.2,
                  ),
                ),
                if (item.city.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.city,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.58),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (item.isCompany) return;
                      if (isBusy || isConnected) return;

                      await connectionController.connect(item.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonBackground,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: buttonBorderColor,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isBusy)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else
                          SvgPicture.asset(
                            item.isCompany ? AppIcons.buildingfull : buttonIcon,
                            width: 18,
                            height: 18,
                            colorFilter: ColorFilter.mode(
                              buttonTextColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item.isCompany ? 'Seguir' : buttonLabel,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: buttonTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverCoverImage extends StatelessWidget {
  final String coverUrl;

  const _DiscoverCoverImage({
    required this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (coverUrl.isEmpty) {
      return SvgPicture.asset(
        'assets/images/banner.svg',
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      coverUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return SvgPicture.asset(
          'assets/images/banner.svg',
          fit: BoxFit.cover,
        );
      },
    );
  }
}

class _DiscoverLoading extends StatelessWidget {
  const _DiscoverLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _DiscoverFeedback extends StatelessWidget {
  final String message;

  const _DiscoverFeedback({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.72),
          ),
        ),
      ),
    );
  }
}