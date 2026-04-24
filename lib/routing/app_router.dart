import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../features/auth/screens/sign_in_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/onboarding/screens/welcome_screen.dart';
import '../features/onboarding/screens/level_setup_screen.dart';
import '../features/onboarding/screens/camera_permission_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/workout/exercise_select/exercise_select_screen.dart';
import '../features/workout/position_guide/position_guide_screen.dart';
import '../features/workout/camera/live_camera_screen.dart';
import '../features/workout/camera/session_summary_screen.dart';
import '../features/reports/screens/reports_list_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'main_shell.dart';
import 'route_names.dart';

/// Central GoRouter configuration.
class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    final authProvider = context.read<AppAuthProvider>();
    final onboardingProvider = context.read<OnboardingProvider>();

    return GoRouter(
      initialLocation: RouteNames.home,
      debugLogDiagnostics: false,
      redirect: (context, state) {
        final authStatus = authProvider.status;
        final onboardingComplete = onboardingProvider.completed;
        final location = state.matchedLocation;

        // Don't redirect while onboarding state is still loading from
        // SharedPreferences — avoids a brief flash to /onboarding/level.
        if (!onboardingProvider.initialized) return null;

        // Still resolving auth state
        if (authStatus == AuthStatus.unknown) return null;

        final isAuthRoute = location == RouteNames.welcome ||
            location == RouteNames.signIn ||
            location == RouteNames.signUp;
        final isOnboardingRoute = location.startsWith('/onboarding');

        // Unauthenticated → always go to welcome
        if (authStatus == AuthStatus.unauthenticated) {
          if (isAuthRoute) return null;
          return RouteNames.welcome;
        }

        // Authenticated but onboarding not done
        if (!onboardingComplete) {
          if (isOnboardingRoute) return null;
          return RouteNames.onboardingLevel;
        }

        // Authenticated + onboarding done → redirect away from auth/onboarding
        if (isAuthRoute || isOnboardingRoute) {
          return RouteNames.home;
        }

        return null;
      },
      refreshListenable: _CombinedListenable([authProvider, onboardingProvider]),
      routes: [
        // --------------- Auth ---------------
        GoRoute(
          path: RouteNames.welcome,
          builder: (_, __) => const WelcomeScreen(),
        ),
        GoRoute(
          path: RouteNames.signIn,
          builder: (_, __) => const SignInScreen(),
        ),
        GoRoute(
          path: RouteNames.signUp,
          builder: (_, __) => const SignUpScreen(),
        ),

        // --------------- Onboarding ---------------
        GoRoute(
          path: RouteNames.onboardingLevel,
          builder: (_, __) => const LevelSetupScreen(),
        ),
        GoRoute(
          path: RouteNames.onboardingCamera,
          builder: (_, __) => const CameraPermissionScreen(),
        ),

        // --------------- Main Shell (tabs) ---------------
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShell(navigationShell: navigationShell);
          },
          branches: [
            // Home tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.home,
                  builder: (_, __) => const HomeScreen(),
                ),
              ],
            ),
            // Workout tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.workout,
                  builder: (_, __) => const ExerciseSelectScreen(),
                  routes: [
                    GoRoute(
                      path: 'position-guide',
                      builder: (_, __) => const PositionGuideScreen(),
                      routes: [
                        GoRoute(
                          path: 'live',
                          builder: (_, __) => const LiveCameraScreen(),
                          routes: [
                            GoRoute(
                              path: 'summary',
                              builder: (_, __) => const SessionSummaryScreen(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // Reports tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.reports,
                  builder: (_, __) => const ReportsListScreen(),
                ),
              ],
            ),
            // Profile tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.profile,
                  builder: (_, __) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Merges multiple [Listenable]s into one for GoRouter.refreshListenable.
class _CombinedListenable extends ChangeNotifier {
  _CombinedListenable(this._listenables) {
    for (final l in _listenables) {
      l.addListener(notifyListeners);
    }
  }

  final List<ChangeNotifier> _listenables;

  @override
  void dispose() {
    for (final l in _listenables) {
      l.removeListener(notifyListeners);
    }
    super.dispose();
  }
}
