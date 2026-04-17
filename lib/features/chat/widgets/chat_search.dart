// =======================================================
// CHAT SEARCH
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

import '../providers/chat_provider.dart';

class ChatSearch extends ConsumerStatefulWidget {
  final double horizontalPadding;

  const ChatSearch({
    super.key,
    this.horizontalPadding = 20,
  });

  @override
  ConsumerState<ChatSearch> createState() => _ChatSearchState();
}

class _ChatSearchState extends ConsumerState<ChatSearch> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final query = ref.watch(chatSearchProvider);

    if (_controller.text != query) {
      _controller.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colors.cardTertiary,
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
                  ref.read(chatSearchProvider.notifier).state = value;
                },
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Buscar conversa',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
            if (query.trim().isNotEmpty)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  ref.read(chatSearchProvider.notifier).state = '';
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
    );
  }
}