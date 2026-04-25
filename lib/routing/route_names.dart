/// Named route path constants for GoRouter.
abstract final class RouteNames {
  // Splash / loading
  static const String splash = '/';

  // Auth
  static const String welcome = '/welcome';
  static const String signIn = '/signin';
  static const String signUp = '/signup';

  // Onboarding
  static const String onboardingLevel = '/onboarding/level';
  static const String onboardingCamera = '/onboarding/camera';

  // Main shell tabs
  static const String home = '/home';
  static const String workout = '/workout';
  static const String workoutPositionGuide = '/workout/position-guide';
  static const String workoutLive = '/workout/position-guide/live';
  static const String workoutSummary = '/workout/position-guide/live/summary';
  static const String reports = '/reports';
  static const String profile = '/profile';
  static const String reportDetail = '/report/:sessionId';
  static String reportDetailFor(String sessionId) => '/report/$sessionId';
}
