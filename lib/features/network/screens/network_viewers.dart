// =======================================================
// VIEWERS SCREEN
// -------------------------------------------------------
// Lista de visualizadores do perfil com abas:
// - Empresas
// - Pessoas
// - header dinâmico por aba
// - sem campo de busca
// - usa ProfileViewModel
// - mostra quando visualizou
// - lista apenas pessoas
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:jobmatch/core/constants/app_icons.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/features/network/models/profile_view_model.dart';
import 'package:jobmatch/features/network/providers/profile_views_provider.dart';
import 'package:jobmatch/shared/widgets/app_avatar.dart';
import 'package:jobmatch/shared/widgets/app_header.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

class ViewersScreen extends ConsumerStatefulWidget {
  const ViewersScreen({super.key});

  @override
  ConsumerState<ViewersScreen> createState() => _ViewersScreenState();
}

class _ViewersScreenState extends ConsumerState<ViewersScreen> {
  int _selectedTabIndex = 1;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(myProfileViewsProvider);
    });
  }

  Future<void> _refreshViewers() async {
    ref.invalidate(myProfileViewsProvider);
    await ref.read(myProfileViewsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final headerTitle = _selectedTabIndex == 0
        ? 'Empresas que viram seu Perfil'
        : 'Pessoas que viram seu Perfil';

    final viewersAsync = ref.watch(myProfileViewsProvider);

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
                    child: _ViewerTopTab(
                      label: 'Empresas',
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
                    child: _ViewerTopTab(
                      label: 'Pessoas',
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
              child: RefreshIndicator(
                onRefresh: _refreshViewers,
                displacement: 24,
                child: viewersAsync.when(
                  loading: () => ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                    children: const [
                      _ViewersLoading(),
                    ],
                  ),
                  error: (error, _) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                    children: [
                      _ViewersFeedback(
                        message: 'Erro ao carregar visualizadores: $error',
                      ),
                    ],
                  ),
                  data: (views) {
                    final peopleViews = views;
                    final companyViews = <ProfileViewModel>[];

                    final filteredViews = _selectedTabIndex == 0
                        ? companyViews
                        : peopleViews;

                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                      children: [
                        if (filteredViews.isEmpty)
                          _ViewersFeedback(
                            message: _selectedTabIndex == 0
                                ? 'Empresas ainda não possuem perfil para exibir visualizações.'
                                : 'Ninguém visualizou seu perfil nos últimos 7 dias.',
                          )
                        else
                          AppSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ViewersLabel(
                                  count: filteredViews.length,
                                  isCompaniesTab: _selectedTabIndex == 0,
                                ),
                                const SizedBox(height: 14),
                                ...List.generate(
                                  filteredViews.length,
                                  (index) {
                                    final item = filteredViews[index];
                                    final isLast =
                                        index == filteredViews.length - 1;

                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: isLast ? 0 : 12,
                                      ),
                                      child: _ViewerTile(item: item),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewerTopTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isLeft;
  final VoidCallback onTap;

  const _ViewerTopTab({
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

class _ViewersLabel extends StatelessWidget {
  final int count;
  final bool isCompaniesTab;

  const _ViewersLabel({
    required this.count,
    required this.isCompaniesTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SvgPicture.asset(
          isCompaniesTab ? AppIcons.buildingfull : AppIcons.group,
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(
            theme.colorScheme.primary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isCompaniesTab ? 'Empresas ($count)' : 'Pessoas ($count)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ViewerTile extends StatelessWidget {
  final ProfileViewModel item;

  const _ViewerTile({
    required this.item,
  });

  String _formatViewedPeriod(DateTime viewedAt) {
    final now = DateTime.now();
    final difference = now.difference(viewedAt);

    if (difference.inMinutes < 1) {
      return 'Visualizou agora mesmo';
    }

    if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return minutes == 1
          ? 'Visualizou há 1 minuto'
          : 'Visualizou há $minutes minutos';
    }

    if (difference.inDays < 1) {
      final hours = difference.inHours;
      return hours == 1
          ? 'Visualizou há 1 hora'
          : 'Visualizou há $hours horas';
    }

    if (difference.inDays == 1) {
      return 'Visualizou há 1 dia';
    }

    return 'Visualizou há ${difference.inDays} dias';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        context.push('/network/user/${item.viewerId}');
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
                  const SizedBox(height: 6),
                  Text(
                    _formatViewedPeriod(item.viewedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
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

class _ViewersLoading extends StatelessWidget {
  const _ViewersLoading();

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

class _ViewersFeedback extends StatelessWidget {
  final String message;

  const _ViewersFeedback({
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