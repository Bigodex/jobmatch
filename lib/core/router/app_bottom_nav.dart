// =======================================================
// APP BOTTOM NAV
// -------------------------------------------------------
// Barra de navegação inferior integrada com GoRouter
// usando Theme + SVGs centralizados
// =======================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_icons.dart';

class AppBottomNav extends StatelessWidget {
  final Widget child;

  const AppBottomNav({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/chat')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/chat');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  Widget _buildIcon(BuildContext context, String asset, bool isActive) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🔥 Barra superior (indicador)
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 3,
          width: 20,
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isActive ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        // 🔥 Ícone
        SvgPicture.asset(
          asset,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.6),
            BlendMode.srcIn,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(
              context,
              currentIndex == 0 ? AppIcons.housefull : AppIcons.house,
              currentIndex == 0,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(
              context,
              currentIndex == 1 ? AppIcons.chatfull : AppIcons.chat,
              currentIndex == 1,
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(
              context,
              currentIndex == 2 ? AppIcons.user : AppIcons.userempty,
              currentIndex == 2,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}