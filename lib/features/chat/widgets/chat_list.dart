// =======================================================
// CHAT LIST
// -------------------------------------------------------
// Lista somente de conversas
// + swipe para excluir sala
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/app_avatar.dart';
import '../models/chat_room_model.dart';
import '../providers/chat_provider.dart';

class ChatList extends ConsumerWidget {
  final bool showCompaniesEmptyState;

  const ChatList({
    super.key,
    this.showCompaniesEmptyState = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (showCompaniesEmptyState) {
      return const _ChatEmptyState(
        title: 'Empresas em breve',
        subtitle: 'Essa aba vai receber as conversas com empresas depois.',
      );
    }

    final roomsAsync = ref.watch(chatRoomsProvider);
    final query = ref.watch(chatSearchProvider).trim().toLowerCase();
    final service = ref.watch(chatServiceProvider);

    return roomsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ChatErrorState(message: error.toString()),
      data: (rooms) {
        final filteredRooms = rooms.where((room) {
          final other = room.otherParticipant(service.currentUid);
          final otherName = other?.name.toLowerCase() ?? '';
          final otherRole = other?.role.toLowerCase() ?? '';
          final lastMessage = room.lastMessageText.toLowerCase();

          if (query.isEmpty) return true;

          return otherName.contains(query) ||
              otherRole.contains(query) ||
              lastMessage.contains(query);
        }).toList();

        if (filteredRooms.isEmpty) {
          return const _ChatEmptyState(
            title: 'Nenhuma conversa por aqui',
            subtitle:
                'Use o botão de + para abrir suas conexões e iniciar uma nova conversa.',
          );
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          children: filteredRooms
              .map((room) => _ChatRoomItem(room: room))
              .toList(),
        );
      },
    );
  }
}

class _ChatRoomItem extends ConsumerWidget {
  final ChatRoomModel room;

  const _ChatRoomItem({required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(chatServiceProvider);
    final other = room.otherParticipant(service.currentUid);

    if (other == null) {
      return const SizedBox.shrink();
    }

    final hasUnread = room.hasUnread(service.currentUid);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(room.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.redAccent.withOpacity(0.26),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                'Excluir',
                style: TextStyle(
                  color: Colors.redAccent.withOpacity(0.95),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (_) async {
          final shouldDelete = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Excluir conversa?'),
                content: Text(
                  'A sala com ${other.name.isEmpty ? 'este usuário' : other.name} será removida.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                    child: const Text('Excluir'),
                  ),
                ],
              );
            },
          );

          if (shouldDelete != true) {
            return false;
          }

          try {
            await ref.read(chatServiceProvider).deleteConversation(other.uid);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversa excluída com sucesso.'),
                ),
              );
            }

            return true;
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao excluir conversa: $e'),
                ),
              );
            }

            return false;
          }
        },
        child: GestureDetector(
          onTap: () {
            context.push('/chat/conversation/${other.uid}');
          },
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
                  imageUrl: other.avatarUrl,
                  size: 56,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        other.name.isEmpty ? 'Usuário' : other.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (other.role.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          other.role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.48),
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        room.lastMessageText.isEmpty
                            ? 'Conversa iniciada'
                            : room.lastMessageText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.68),
                          fontWeight:
                              hasUnread ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatRoomTime(room.lastMessageAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (hasUnread)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      )
                    else
                      const SizedBox(width: 10, height: 10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ChatEmptyState({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 34,
              color: Colors.white.withOpacity(0.28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatErrorState extends StatelessWidget {
  final String message;

  const _ChatErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'Erro ao carregar chat:\n$message',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

String _formatRoomTime(DateTime? date) {
  if (date == null) return '';

  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inMinutes < 1) return 'agora';
  if (difference.inMinutes < 60) return '${difference.inMinutes}m';
  if (difference.inHours < 24) return '${difference.inHours}h';
  if (difference.inDays < 7) return '${difference.inDays}d';

  return DateFormat('dd/MM').format(date);
}