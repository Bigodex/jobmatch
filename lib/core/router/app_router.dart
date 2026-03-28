// =======================================================
// GO ROUTER
// =======================================================

import 'package:go_router/go_router.dart';

// =======================================================
// MODELS
// =======================================================

import 'package:jobmatch/features/profile/models/resume_model.dart';
import 'package:jobmatch/features/profile/models/language_model.dart';
import 'package:jobmatch/features/profile/models/soft_skill_model.dart';
import 'package:jobmatch/features/profile/models/tech_skill_model.dart';
import 'package:jobmatch/features/profile/models/experience_model.dart'; // 🔥 ADD

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

// 🔥 TELAS FULLSCREEN
import '../../features/profile/screens/edit_resume_screen.dart';
import '../../features/profile/screens/edit_language_screen.dart';
import '../../features/profile/screens/edit_soft_skills_screen.dart';
import '../../features/profile/screens/edit_hard_skills_screen.dart';
import '../../features/profile/screens/edit_experience_screen.dart'; // 🔥 ADD

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
    // 🔥 TELAS FULLSCREEN (SEM BOTTOM NAV)
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

    // ==================================================
    // EDIT SOFT SKILLS
    // ==================================================

    GoRoute(
      path: '/edit-soft-skills',
      name: 'edit-soft-skills',
      builder: (context, state) {
        final skills = state.extra as List<SoftSkillModel>;
        return EditSoftSkillsScreen(skills: skills);
      },
    ),

    // ==================================================
    // EDIT HARD SKILLS
    // ==================================================

    GoRoute(
      path: '/edit-hard-skills',
      name: 'edit-hard-skills',
      builder: (context, state) {
        final skills = state.extra as List<TechSkillModel>;
        return EditHardSkillsScreen(skills: skills);
      },
    ),

    // ==================================================
    // 🔥 EDIT EXPERIENCE (NOVO)
    // ==================================================

    GoRoute(
      path: '/edit-experience',
      name: 'edit-experience',
      builder: (context, state) {
        final experiences = state.extra as List<ExperienceModel>;
        return EditExperienceScreen(experiences: experiences);
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