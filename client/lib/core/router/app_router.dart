import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:client/core/router/router_refresh_stream.dart';
import 'package:client/presentation/auth/screens/auth_screen.dart';
import 'package:client/presentation/game/screens/ai_difficulty_selection_screen.dart';
import 'package:client/presentation/game/screens/profile_screen.dart';
import 'package:client/presentation/game/screens/layout_selection_screen.dart';
import 'package:client/presentation/game/screens/local_match_screen.dart';
import 'package:client/presentation/game/screens/offline_match_setup_screen.dart';
import 'package:client/presentation/game/screens/tutorial_list_screen.dart';
import 'package:client/presentation/game/screens/tutorial_screen.dart';

/// Provider for the application's GoRouter instance.
/// It uses a refreshListenable to handle auth redirects dynamically.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    redirect: (context, state) async {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuth = session != null;
      final isGoingToAuth = state.matchedLocation == '/';

      // Check if we have internet access
      final isOnline = await InternetConnection().hasInternetAccess;

      // If offline and trying to go to Auth, bypass to Menu
      if (!isOnline && isGoingToAuth) {
        return '/menu';
      }

      // If offline, allow unauthenticated access to the game
      if (!isOnline) {
        return null;
      }

      // Redirect unauthenticated users to the auth screen (when online)
      if (!isAuth && !isGoingToAuth) {
        return '/';
      }

      // Redirect authenticated users away from the auth screen
      if (isAuth && isGoingToAuth) {
        return '/menu';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/menu',
        name: 'menu',
        builder: (context, state) => const LayoutSelectionScreen(),
      ),
      GoRoute(
        path: '/offline_setup',
        name: 'offline_setup',
        builder: (context, state) => const OfflineMatchSetupScreen(),
      ),
      GoRoute(
        path: '/local_match',
        name: 'local_match',
        builder: (context, state) => const LocalMatchScreen(),
      ),
      GoRoute(
        path: '/bot_setup',
        name: 'bot_setup',
        builder: (context, state) => const AiDifficultySelectionScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/tutorial',
        name: 'tutorial',
        builder: (context, state) => const TutorialListScreen(),
        routes: [
          GoRoute(
            path: 'play',
            name: 'tutorial_play',
            builder: (context, state) {
              final moduleId = state.extra as String? ?? 'basics';
              return TutorialScreen(moduleId: moduleId);
            },
          ),
        ],
      ),
    ],
  );
});
