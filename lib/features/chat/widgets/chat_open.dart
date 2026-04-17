// =======================================================
// CHAT OPEN
// -------------------------------------------------------
// Tela de conversa real
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_header.dart';
import '../models/chat_message_model.dart';
import '../providers/chat_provider.dart';

class ChatOpen extends ConsumerStatefulWidget {
  final String otherUserId;

  const ChatOpen({
    super.key,
    required this.otherUserId,
  });

  @override
  ConsumerState<ChatOpen> createState() => _ChatOpenState();
}

class _ChatOpenState extends ConsumerState<ChatOpen> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      await ref.read(chatServiceProvider).sendMessage(
            otherUserId: widget.otherUserId,
            text: text,
          );

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar mensagem: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  bool _shouldShowTime(List<ChatMessageModel> messages, int index) {
    if (index == messages.length - 1) return true;

    final current = messages[index].createdAt;
    final next = messages[index + 1].createdAt;

    if (current == null || next == null) return true;

    return current.difference(next).inMinutes.abs() >= 15;
  }

  @override
  Widget build(BuildContext context) {
    final previewAsync = ref.watch(chatUserPreviewProvider(widget.otherUserId));
    final messagesAsync = ref.watch(chatMessagesProvider(widget.otherUserId));
    final currentUid = ref.watch(chatServiceProvider).currentUid;

    final title = previewAsync.maybeWhen(
      data: (user) {
        if (user == null || user.name.trim().isEmpty) return 'Conversa';
        return user.name;
      },
      orElse: () => 'Conversa',
    );

    messagesAsync.whenData((messages) {
      if (messages.isNotEmpty) {
        ref
            .read(chatServiceProvider)
            .markConversationAsRead(widget.otherUserId);

        _scrollToBottom();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: title,
              showBackButton: true,
            ),

            previewAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (user) {
                if (user == null) return const SizedBox.shrink();

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      AppAvatar(
                        imageUrl: user.avatarUrl,
                        size: 42,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name.isEmpty ? 'Usuário' : user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (user.role.trim().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                user.role,
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
                    ],
                  ),
                );
              },
            ),

            Expanded(
              child: messagesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Erro ao carregar mensagens:\n$error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (messages) {
                  if (messages.isEmpty) {
                    return const _EmptyConversation();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == currentUid;
                      final showTime = _shouldShowTime(messages, index);

                      return _MessageBubble(
                        message: message,
                        isMe: isMe,
                        showTime: showTime,
                      );
                    },
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: 'Escreva sua mensagem...',
                          border: InputBorder.none,
                          filled: false,
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sending ? null : _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(_sending ? 0.45 : 1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: _sending
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.black,
                            ),
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

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;
  final bool showTime;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showTime,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isMe
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 6),
                  bottomRight: Radius.circular(isMe ? 6 : 18),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  height: 1.35,
                  color: isMe ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showTime && message.createdAt != null) ...[
              const SizedBox(height: 6),
              Text(
                DateFormat('HH:mm').format(message.createdAt!),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.42),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 36,
              color: Colors.white.withOpacity(0.28),
            ),
            const SizedBox(height: 14),
            const Text(
              'Nenhuma mensagem ainda',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manda a primeira mensagem e essa conversa passa a aparecer na lista principal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.56),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}