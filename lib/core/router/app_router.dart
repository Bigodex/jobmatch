// =======================================================
// GO ROUTER
// =======================================================

import 'package:go_router/go_router.dart';
import 'package:jobmatch/features/menu/screens/menu_screen.dart';

import '../../features/profile/screens/public_profile_screen.dart';
import '../../features/network/screens/network_connections_screen.dart';

// =======================================================
// MODELS
// =======================================================

import 'package:jobmatch/features/profile/models/resume_model.dart';
import 'package:jobmatch/features/profile/models/language_model.dart';
import 'package:jobmatch/features/profile/models/soft_skill_model.dart';
import 'package:jobmatch/features/profile/models/tech_skill_model.dart';
import 'package:jobmatch/features/profile/models/experience_model.dart';
import 'package:jobmatch/features/profile/models/education_model.dart';
import 'package:jobmatch/features/profile/models/social_link_model.dart';

// =======================================================
// SCREENS
// =======================================================

// Onboarding
import '../../features/intro/screens/intro_screen.dart';
import '../../features/intro/screens/welcome_screen.dart';

// AUTH
import '../../features/auth/screens/login_screen.dart';

// ONBOARDING
import '../../features/onboarding/screens/onboarding_flow_screen.dart';

// Home / Chat / Profile / Menu
import '../../features/home/screens/home_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/chat/widgets/chat_open.dart';
import '../../features/profile/screens/profile_screen.dart';

// TELAS FULLSCREEN
import '../../features/profile/screens/edit_resume_screen.dart';
import '../../features/profile/screens/edit_language_screen.dart';
import '../../features/profile/screens/edit_soft_skills_screen.dart';
import '../../features/profile/screens/edit_hard_skills_screen.dart';
import '../../features/profile/screens/edit_experience_screen.dart';
import '../../features/profile/screens/edit_education_screen.dart';
import '../../features/profile/screens/edit_links_screen.dart';

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
    // INTRO
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
    // AUTH
    // ==================================================
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // ==================================================
    // ONBOARDING
    // ==================================================
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingFlowScreen(),
    ),

    // ==================================================
    // MENU / FULLSCREEN
    // ==================================================
    GoRoute(
      path: '/menu',
      name: 'menu',
      builder: (context, state) => const MenuScreen(),
    ),

    // ==================================================
    // NETWORK
    // --------------------------------------------------
    // HOME -> abre em EXPLORAR
    // PROFILE -> abre em CONEXÕES
    // ==================================================
    GoRoute(
      path: '/network',
      name: 'network',
      builder: (context, state) => const NetworkConnectionsScreen(
        initialTabIndex: 0,
      ),
    ),

    GoRoute(
      path: '/network/connections',
      name: 'network-connections',
      builder: (context, state) => const NetworkConnectionsScreen(
        initialTabIndex: 1,
      ),
    ),

    GoRoute(
      path: '/network/user/:userId/connections',
      name: 'network-user-connections',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return NetworkConnectionsScreen(
          userId: userId,
          initialTabIndex: 1,
        );
      },
    ),

    // ==================================================
    // PERFIL PÚBLICO
    // ==================================================
    GoRoute(
      path: '/network/user/:userId',
      name: 'network-user-profile',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return PublicProfileScreen(userId: userId);
      },
    ),

    // ==================================================
    // TELAS FULLSCREEN (SEM BOTTOM NAV)
    // ==================================================
    GoRoute(
      path: '/edit-resume',
      name: 'edit-resume',
      builder: (context, state) {
        final resume = state.extra as ResumeModel;
        return EditResumeScreen(resume: resume);
      },
    ),

    GoRoute(
      path: '/edit-languages',
      name: 'edit-languages',
      builder: (context, state) {
        final languages = state.extra as List<LanguageModel>;
        return EditLanguageScreen(languages: languages);
      },
    ),

    GoRoute(
      path: '/edit-soft-skills',
      name: 'edit-soft-skills',
      builder: (context, state) {
        final skills = state.extra as List<SoftSkillModel>;
        return EditSoftSkillsScreen(skills: skills);
      },
    ),

    GoRoute(
      path: '/edit-hard-skills',
      name: 'edit-hard-skills',
      builder: (context, state) {
        final skills = state.extra as List<TechSkillModel>;
        return EditHardSkillsScreen(skills: skills);
      },
    ),

    GoRoute(
      path: '/edit-experience',
      name: 'edit-experience',
      builder: (context, state) {
        final experiences = state.extra as List<ExperienceModel>;
        return EditExperienceScreen(experiences: experiences);
      },
    ),

    GoRoute(
      path: '/edit-education',
      name: 'edit-education',
      builder: (context, state) {
        final educations = state.extra as List<EducationModel>;
        return EditEducationScreen(educations: educations);
      },
    ),

    GoRoute(
      path: '/edit-links',
      name: 'edit-links',
      builder: (context, state) {
        final links = state.extra as List<SocialLinkModel>;
        return EditLinksScreen(links: links);
      },
    ),

    GoRoute(
      path: '/chat/conversation/:otherUserId',
      name: 'chat-conversation',
      builder: (context, state) {
        final otherUserId = state.pathParameters['otherUserId']!;
        return ChatOpen(otherUserId: otherUserId);
      },
    ),

    // ==================================================
    // SHELL (BOTTOM NAV)
    // ==================================================
    ShellRoute(
      builder: (context, state, child) {
        return AppBottomNav(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),

        GoRoute(
          path: '/chat',
          name: 'chat',
          builder: (context, state) => const ChatScreen(),
        ),

        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);