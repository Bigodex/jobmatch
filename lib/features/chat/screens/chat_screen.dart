// =======================================================
// CHAT SCREEN
// -------------------------------------------------------
// Tela principal de chat
// - layout alinhado à tela de conexões
// - abas acima da busca
// - botão de nova conversa somente em Pessoas
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobmatch/core/constants/app_theme.dart';
import 'package:jobmatch/shared/widgets/app_section_card.dart';

import '../../../shared/widgets/app_header.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_connections_modal.dart';
import '../widgets/chat_list.dart';
import '../widgets/chat_search.dart';
import '../widgets/chat_tabs.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final currentTab = ref.watch(chatTabProvider);
    final showPlusButton = currentTab == ChatInboxTab.people;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Chat'),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ChatTabs(),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: ChatSearch(horizontalPadding: 0),
                  ),
                  if (showPlusButton) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        showChatConnectionsModal(context);
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: appColors.cardTertiary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: 28,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AppSectionCard(
                child: ChatList(
                  showCompaniesEmptyState:
                      currentTab == ChatInboxTab.companies,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}