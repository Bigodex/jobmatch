// =======================================================
// CHAT TABS
// -------------------------------------------------------
// Visual alinhado à tela de conexões
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobmatch/core/constants/app_theme.dart';

import '../providers/chat_provider.dart';

class ChatTabs extends ConsumerWidget {
  const ChatTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(chatTabProvider);

    return Row(
      children: [
        Expanded(
          child: _ChatTopTab(
            label: 'Pessoas',
            isSelected: currentTab == ChatInboxTab.people,
            isLeft: true,
            onTap: () {
              ref.read(chatTabProvider.notifier).state = ChatInboxTab.people;
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ChatTopTab(
            label: 'Empresas',
            isSelected: currentTab == ChatInboxTab.companies,
            isLeft: false,
            onTap: () {
              ref.read(chatTabProvider.notifier).state = ChatInboxTab.companies;
            },
          ),
        ),
      ],
    );
  }
}

class _ChatTopTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isLeft;
  final VoidCallback onTap;

  const _ChatTopTab({
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