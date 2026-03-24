// =======================================================
// CHAT SCREEN
// -------------------------------------------------------
// Tela principal de chat
// =======================================================

import 'package:flutter/material.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

import '../../../shared/widgets/app_header.dart';

import '../widgets/chat_search.dart';
import '../widgets/chat_tabs.dart';
import '../widgets/chat_list.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            // ===================================================
            // HEADER FIXO
            // ===================================================
            const AppHeader(title: 'Chat'),

            // ===================================================
            // CONTEÚDO
            // ===================================================
            Expanded(
              child: Column(
                children: const [
                  SizedBox(height: 30),

                  ChatSearch(),

                  SizedBox(height: 30),

                  AppSectionCard(child: ChatTabs()),

                  Expanded(child: AppSectionCard(child: ChatList())),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
