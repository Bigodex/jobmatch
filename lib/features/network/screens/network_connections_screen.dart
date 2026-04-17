// =======================================================
// NETWORK CONNECTIONS SCREEN
// -------------------------------------------------------
// Tela de conexões com abas:
// - Explorar
// - Conexões
// - suporta minhas conexões
// - suporta conexões de outro usuário
// - pull-to-refresh em ambas as abas
// - barra de busca em ambas as abas
// - header dinâmico conforme aba selecionada
// - lista de conexões envolvida por um único AppSectionCard
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/network/models/network_discover_profile_model.dart';
import 'package:jobmatch/features/network/providers/network_provider.dart';
import 'package:jobmatch/features/network/widgets/network_discover_sections.dart';
import 'package:jobmatch/features/network/widgets/network_search_bar.dart';
import 'package:jobmatch/shared/widgets/app_avatar.dart';
import 'package:jobmatch/shared/widgets/app_header.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class NetworkConnectionsScreen extends ConsumerStatefulWidget {
  final String? userId;
  final String title;
  final int initialTabIndex;

  const NetworkConnectionsScreen({
    super.key,
    this.userId,
    this.title = 'Conexões',
    this.initialTabIndex = 1,
  });

  @override
  ConsumerState<NetworkConnectionsScreen> createState() =>
      _NetworkConnectionsScreenState();
}

class _NetworkConnectionsScreenState
    extends ConsumerState<NetworkConnectionsScreen> {
  late int _selectedTabIndex;

  @override
  void initState() {
    super.initState();

    _selectedTabIndex = widget.initialTabIndex.clamp(0, 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(networkProfilesProvider);
    });
  }

  Future<void> _refreshExplore() async {
    ref.invalidate(networkProfilesProvider);
    await ref.read(networkProfilesProvider.future);
  }

  Future<void> _refreshConnections() async {
    final controller = ref.read(networkConnectionControllerProvider.notifier);

    await controller.refreshConnections(userId: widget.userId);

    if (widget.userId != null && widget.userId!.trim().isNotEmpty) {
      await ref.read(userConnectionsProvider(widget.userId!).future);
      return;
    }

    await ref.read(myConnectionsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(networkSearchProvider);

    final headerTitle = _selectedTabIndex == 0
        ? 'Explorar Rede'
        : 'Minhas Conexões';

    final AsyncValue<List<NetworkDiscoverProfileModel>> connectionsAsync =
        widget.userId != null && widget.userId!.trim().isNotEmpty
        ? ref.watch(userConnectionsProvider(widget.userId!))
        : ref.watch(myConnectionsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: headerTitle,
              showBackButton: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: _NetworkTopTab(
                      label: 'Explorar',
                      isSelected: _selectedTabIndex == 0,
                      isLeft: true,
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = 0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _NetworkTopTab(
                      label: 'Conexões',
                      isSelected: _selectedTabIndex == 1,
                      isLeft: false,
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  RefreshIndicator(
                    onRefresh: _refreshExplore,
                    displacement: 24,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: Column(
                        children: const [
                          SizedBox(height: 6),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: NetworkSearchBar(),
                          ),
                          SizedBox(height: 20),
                          NetworkDiscoverSections(),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: _refreshConnections,
                    displacement: 24,
                    child: connectionsAsync.when(
                      loading: () => ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: NetworkSearchBar(),
                          ),
                          SizedBox(height: 16),
                          _ConnectionsLoading(),
                        ],
                      ),
                      error: (error, _) => ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: NetworkSearchBar(),
                          ),
                          const SizedBox(height: 16),
                          _ConnectionsFeedback(
                            message: 'Erro ao carregar conexões: $error',
                          ),
                        ],
                      ),
                      data: (connections) {
                        final filteredConnections = connections.where((item) {
                          return item.matchesSearch(query);
                        }).toList();

                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: NetworkSearchBar(),
                            ),
                            const SizedBox(height: 16),
                            if (filteredConnections.isEmpty)
                              const _ConnectionsFeedback(
                                message: 'Nenhuma conexão encontrada.',
                              )
                            else
                              AppSectionCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _ConnectionsLabel(
                                      count: connections.length,
                                    ),
                                    const SizedBox(height: 14),
                                    ...List.generate(
                                      filteredConnections.length,
                                      (index) {
                                        final item = filteredConnections[index];
                                        final isLast =
                                            index == filteredConnections.length - 1;

                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: isLast ? 0 : 12,
                                          ),
                                          child: _ConnectionTile(item: item),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkTopTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isLeft;
  final VoidCallback onTap;

  const _NetworkTopTab({
    required this.label,
    required this.isSelected,
    required this.isLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    final selectedRadius = BorderRadius.only(
      topLeft: const Radius.circular(30),
      topRight: const Radius.circular(30),
      bottomLeft: Radius.circular(isLeft ? 2 : 30),
      bottomRight: Radius.circular(isLeft ? 30 : 2),
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? appColors.cardTertiary : Colors.transparent,
          borderRadius: selectedRadius,
        ),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: isSelected
                ? Colors.white
                : Colors.white.withOpacity(0.78),
          ),
        ),
      ),
    );
  }
}

class _ConnectionsLabel extends StatelessWidget {
  final int count;

  const _ConnectionsLabel({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SvgPicture.asset(
          AppIcons.group,
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(
            theme.colorScheme.primary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Amigos ($count)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ConnectionTile extends StatelessWidget {
  final NetworkDiscoverProfileModel item;

  const _ConnectionTile({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        context.push('/network/user/${item.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: appColors.cardTertiary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            AppAvatar(
              imageUrl: item.avatarUrl,
              size: 58,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.role.isEmpty ? 'Profissional' : item.role,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.76),
                      height: 1.2,
                    ),
                  ),
                  if (item.city.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppIcons.buildingfull,
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.58),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.42),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionsLoading extends StatelessWidget {
  const _ConnectionsLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ConnectionsFeedback extends StatelessWidget {
  final String message;

  const _ConnectionsFeedback({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return AppSectionCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: appColors.cardTertiary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
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