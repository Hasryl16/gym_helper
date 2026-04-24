import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/user_provider.dart';
import 'providers/workout_session_provider.dart';
import 'routing/app_router.dart';
import 'shared/theme/app_theme.dart';

/// Root widget. Wires providers and the router.
class GymHelperApp extends StatefulWidget {
  const GymHelperApp({super.key});

  @override
  State<GymHelperApp> createState() => _GymHelperAppState();
}

class _GymHelperAppState extends State<GymHelperApp> {
  late final AppAuthProvider _authProvider;
  late final OnboardingProvider _onboardingProvider;
  late final UserProvider _userProvider;
  late final WorkoutSessionProvider _workoutProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AppAuthProvider();
    _onboardingProvider = OnboardingProvider();
    _userProvider = UserProvider();
    _workoutProvider = WorkoutSessionProvider();
    // Load persisted onboarding state
    _onboardingProvider.init();
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _onboardingProvider.dispose();
    _userProvider.dispose();
    _workoutProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppAuthProvider>.value(value: _authProvider),
        // Reload onboarding state whenever the auth UID changes so that the
        // key used for SharedPreferences is always scoped to the active user.
        ChangeNotifierProxyProvider<AppAuthProvider, OnboardingProvider>(
          create: (_) => _onboardingProvider,
          update: (_, auth, onboardingProv) {
            final provider = onboardingProv ?? _onboardingProvider;
            provider.loadForUser(auth.user?.uid);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AppAuthProvider, UserProvider>(
          create: (_) => _userProvider,
          update: (_, auth, userProv) {
            final provider = userProv ?? _userProvider;
            if (auth.isAuthenticated && auth.user != null) {
              provider.watchUser(auth.user!.uid);
            } else {
              provider.clear();
            }
            return provider;
          },
        ),
        ChangeNotifierProvider<WorkoutSessionProvider>.value(
          value: _workoutProvider,
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.createRouter(context);
          return MaterialApp.router(
            title: 'GYM HELPER',
            theme: AppTheme.dark,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
