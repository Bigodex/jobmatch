// =======================================================
// CHAT CONNECTIONS MODAL
// -------------------------------------------------------
// Modal para iniciar conversa com conexões
// - ordem alfabética
// - busca local
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobmatch/features/network/models/network_discover_profile_model.dart';
import 'package:jobmatch/features/network/providers/network_provider.dart';
import 'package:jobmatch/shared/widgets/app_avatar.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

Future<void> showChatConnectionsModal(BuildContext parentContext) {
  return showModalBottomSheet<void>(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ChatConnectionsModal(parentContext: parentContext),
  );
}

class _ChatConnectionsModal extends ConsumerStatefulWidget {
  final BuildContext parentContext;

  const _ChatConnectionsModal({
    required this.parentContext,
  });

  @override
  ConsumerState<_ChatConnectionsModal> createState() =>
      _ChatConnectionsModalState();
}

class _ChatConnectionsModalState
    extends ConsumerState<_ChatConnectionsModal> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(myConnectionsProvider);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refreshConnections() async {
    ref.invalidate(myConnectionsProvider);
    await ref.read(myConnectionsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connectionsAsync = ref.watch(myConnectionsProvider);
    final normalizedQuery = _query.trim().toLowerCase();

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 54,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Nova conversa',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.82),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onChanged: (value) {
                            setState(() {
                              _query = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar conexão',
                            border: InputBorder.none,
                            filled: false,
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                      if (_query.trim().isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _controller.clear();
                            setState(() {
                              _query = '';
                            });
                            FocusScope.of(context).unfocus();
                          },
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshConnections,
                  displacement: 24,
                  child: connectionsAsync.when(
                    loading: () => ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: const [
                        _ConnectionsLoadingCard(),
                      ],
                    ),
                    error: (error, _) => ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        _ConnectionsFeedbackCard(
                          message: 'Erro ao carregar conexões: $error',
                        ),
                      ],
                    ),
                    data: (connections) {
                      final sortedConnections = [...connections]
                        ..sort(
                          (a, b) => a.name.toLowerCase().compareTo(
                                b.name.toLowerCase(),
                              ),
                        );

                      final filteredConnections = sortedConnections.where((item) {
                        if (normalizedQuery.isEmpty) return true;

                        return item.name.toLowerCase().contains(normalizedQuery) ||
                            item.role.toLowerCase().contains(normalizedQuery) ||
                            item.city.toLowerCase().contains(normalizedQuery);
                      }).toList();

                      if (filteredConnections.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          children: const [
                            _ConnectionsFeedbackCard(
                              message:
                                  'Nenhuma conexão encontrada para iniciar conversa.',
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filteredConnections.length,
                        itemBuilder: (context, index) {
                          final item = filteredConnections[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ConnectionChatItem(
                              item: item,
                              parentContext: widget.parentContext,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionChatItem extends StatelessWidget {
  final NetworkDiscoverProfileModel item;
  final BuildContext parentContext;

  const _ConnectionChatItem({
    required this.item,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          parentContext.push('/chat/conversation/${item.id}');
        });
      },
      child: AppSectionCard(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              AppAvatar(
                imageUrl: item.avatarUrl,
                size: 56,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.isEmpty ? 'Usuário' : item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.role.isEmpty ? 'Profissional' : item.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.72),
                      ),
                    ),
                    if (item.city.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.52),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Conversar',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionsLoadingCard extends StatelessWidget {
  const _ConnectionsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _ConnectionsFeedbackCard extends StatelessWidget {
  final String message;

  const _ConnectionsFeedbackCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
          ),
        ),
      ),
    );
  }
}