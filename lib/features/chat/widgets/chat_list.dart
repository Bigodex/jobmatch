// =======================================================
// CHAT LIST
// =======================================================

import 'package:flutter/material.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.cardColor, // 🔥 BACKGROUND DO CARD

      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 8,
        ),
        itemCount: 12,

        // ===================================================
        // DIVIDER SUAVE
        // ===================================================
        separatorBuilder: (_, _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(
            color: Colors.white.withOpacity(0.05),
            thickness: 1,
          ),
        ),

        itemBuilder: (_, index) {
          return const _ChatItem();
        },
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  const _ChatItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: Row(
        children: [

          // ===================================================
          // AVATAR
          // ===================================================
          const CircleAvatar(
            radius: 34,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?img=3',
            ),
          ),

          const SizedBox(width: 12),

          // ===================================================
          // TEXTO
          // ===================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  'Nicolas Vellozo',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 4),

                Text(
                  'Olá tudo bem? Vejo que...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // ===================================================
          // TEMPO + DOT
          // ===================================================
          Column(
            children: [

              Text(
                '11m',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 6),

              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF68E3FF),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}