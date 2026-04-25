// =======================================================
// PUBLIC NETWORK CONNECTIONS SCREEN
// -------------------------------------------------------
// Tela pública de conexões de outro usuário
// - abas:
//   - Conexões
//   - Em Comum
// - usa o layout base da tela de conexões existente
// - pull-to-refresh
// - barra de busca
// - aba "Em Comum" ligada ao provider real
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/network/models/network_discover_profile_model.dart';
import 'package:jobmatch/features/network/providers/network_provider.dart';
import 'package:jobmatch/features/network/widgets/network_search_bar.dart';
import 'package:jobmatch/shared/widgets/app_avatar.dart';
import 'package:jobmatch/shared/widgets/app_header.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class PublicNetworkConnectionsScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const PublicNetworkConnectionsScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<PublicNetworkConnectionsScreen> createState() =>
      _PublicNetworkConnectionsScreenState();
}

class _PublicNetworkConnectionsScreenState
    extends ConsumerState<PublicNetworkConnectionsScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(userConnectionsProvider(widget.userId));
      ref.invalidate(mutualConnectionsProvider(widget.userId));
    });
  }

  Future<void> _refreshConnections() async {
    final controller = ref.read(networkConnectionControllerProvider.notifier);

    await controller.refreshConnections(userId: widget.userId);
    await ref.read(userConnectionsProvider(widget.userId).future);
  }

  Future<void> _refreshMutualConnections() async {
    final controller = ref.read(networkConnectionControllerProvider.notifier);

    await controller.refreshConnections(userId: widget.userId);
    await ref.read(mutualConnectionsProvider(widget.userId).future);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(networkSearchProvider);

    final headerTitle = _selectedTabIndex == 0
        ? 'Conexões de ${widget.userName}'
        : 'Conexões em comum';

    final connectionsAsync = ref.watch(userConnectionsProvider(widget.userId));
    final mutualConnectionsAsync = ref.watch(
      mutualConnectionsProvider(widget.userId),
    );

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
                    child: _PublicNetworkTopTab(
                      label: 'Conexões',
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
                    child: _PublicNetworkTopTab(
                      label: 'Em Comum',
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
                          _PublicConnectionsLoading(),
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
                          _PublicConnectionsFeedback(
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
                              const _PublicConnectionsFeedback(
                                message:
                                    'Esse usuário ainda não possui conexões visíveis.',
                              )
                            else
                              AppSectionCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _PublicConnectionsLabel(
                                      title: 'Amigos',
                                      count: filteredConnections.length,
                                    ),
                                    const SizedBox(height: 14),
                                    ...List.generate(
                                      filteredConnections.length,
                                      (index) {
                                        final item = filteredConnections[index];
                                        final isLast =
                                            index ==
                                            filteredConnections.length - 1;

                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: isLast ? 0 : 12,
                                          ),
                                          child: _PublicConnectionTile(item: item),
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
                  RefreshIndicator(
                    onRefresh: _refreshMutualConnections,
                    displacement: 24,
                    child: mutualConnectionsAsync.when(
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
                          _PublicConnectionsLoading(),
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
                          _PublicConnectionsFeedback(
                            message:
                                'Erro ao carregar conexões em comum: $error',
                          ),
                        ],
                      ),
                      data: (mutualConnections) {
                        final filteredMutualConnections =
                            mutualConnections.where((item) {
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
                            if (filteredMutualConnections.isEmpty)
                              const _PublicConnectionsFeedback(
                                message:
                                    'Vocês ainda não possuem conexões em comum.',
                              )
                            else
                              AppSectionCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _PublicConnectionsLabel(
                                      title: 'Em Comum',
                                      count: filteredMutualConnections.length,
                                    ),
                                    const SizedBox(height: 14),
                                    ...List.generate(
                                      filteredMutualConnections.length,
                                      (index) {
                                        final item =
                                            filteredMutualConnections[index];
                                        final isLast =
                                            index ==
                                            filteredMutualConnections.length - 1;

                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: isLast ? 0 : 12,
                                          ),
                                          child: _PublicConnectionTile(item: item),
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

class _PublicNetworkTopTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isLeft;
  final VoidCallback onTap;

  const _PublicNetworkTopTab({
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

class _PublicConnectionsLabel extends StatelessWidget {
  final String title;
  final int count;

  const _PublicConnectionsLabel({
    required this.title,
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
          '$title ($count)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _PublicConnectionTile extends StatelessWidget {
  final NetworkDiscoverProfileModel item;

  const _PublicConnectionTile({
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

class _PublicConnectionsLoading extends StatelessWidget {
  const _PublicConnectionsLoading();

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

class _PublicConnectionsFeedback extends StatelessWidget {
  final String message;

  const _PublicConnectionsFeedback({
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