// =======================================================
// GO ROUTER
// -------------------------------------------------------
// Roteamento central do app
// Estrutura preparada para escalar com features
// =======================================================

import 'package:go_router/go_router.dart';

// =======================================================
// SCREENS
// =======================================================

// Onboarding
import '../../features/onboarding/screens/intro_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';

// Home / Chat / Profile
import '../../features/home/screens/home_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

// Bottom Nav
import 'app_bottom_nav.dart';

// =======================================================
// APP ROUTER
// =======================================================

final GoRouter appRouter = GoRouter(

  // -----------------------------------------------------
  // ROTA INICIAL
  // -----------------------------------------------------
  initialLocation: '/intro',

  // -----------------------------------------------------
  // ROTAS
  // -----------------------------------------------------
  routes: [

    // ==================================================
    // ONBOARDING
    // ==================================================

    GoRoute(
      path: '/intro',
      name: 'intro',
      builder: (context, state) => const IntroScreen(),
    ),

    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),

    // ==================================================
    // SHELL (BOTTOM NAV)
    // ==================================================

    ShellRoute(
      builder: (context, state, child) {
        return AppBottomNav(child: child);
      },

      routes: [

        // ----------------------------------------------
        // HOME
        // ----------------------------------------------
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),

        // ----------------------------------------------
        // CHAT
        // ----------------------------------------------
        GoRoute(
          path: '/chat',
          name: 'chat',
          builder: (context, state) => const ChatScreen(),
        ),

        // ----------------------------------------------
        // PROFILE
        // ----------------------------------------------
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);