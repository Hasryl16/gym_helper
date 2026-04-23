/// Centralized string constants for GymHelper.
abstract final class AppStrings {
  // --- App ---
  static const String appName = 'GYM HELPER';
  static const String appTagline = 'Real-time form correction. Powered by AI.';

  // --- Onboarding ---
  static const String welcomeTitle = 'GYM\nHELPER';
  static const String welcomeGetStarted = 'Get Started';
  static const String featureMediaPipe = 'MediaPipe Pose';
  static const String featureAiReports = 'AI Reports';
  static const String featureExercises = '3 Exercises';

  static const String levelTitle = "WHAT'S YOUR\nFITNESS LEVEL?";
  static const String levelConfirm = 'Confirm';
  static const String levelBeginner = 'Beginner';
  static const String levelIntermediate = 'Intermediate';
  static const String levelAdvanced = 'Advanced';
  static const String levelBeginnerDesc =
      'Getting started. Building foundational strength.';
  static const String levelIntermediateDesc =
      'Consistent training. Looking to improve form.';
  static const String levelAdvancedDesc =
      'Experienced athlete. Optimizing performance.';

  // --- Camera permission ---
  static const String cameraTitle = 'CAMERA ACCESS\nREQUIRED';
  static const String cameraExplanation =
      'GymHelper uses your camera to track body position in real time. '
      'Video is processed entirely on-device — nothing is uploaded or stored.';
  static const String cameraAllow = 'Allow Camera';
  static const String cameraNotNow = 'Not Now';
  static const String cameraPermissionDenied =
      'Camera permission is required for form analysis.';

  // --- Auth ---
  static const String signIn = 'Sign In';
  static const String signUp = 'Create Account';
  static const String signOut = 'Sign Out';
  static const String continueWithGoogle = 'Continue with Google';
  static const String emailLabel = 'Email address';
  static const String passwordLabel = 'Password';
  static const String displayNameLabel = 'Your name';
  static const String forgotPassword = 'Forgot password?';
  static const String noAccount = "Don't have an account?";
  static const String hasAccount = 'Already have an account?';
  static const String signInLink = 'Sign in';
  static const String signUpLink = 'Sign up';

  // --- Errors ---
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'Network error. Check your connection and try again.';
  static const String errorInvalidEmail = 'Enter a valid email address.';
  static const String errorWeakPassword =
      'Password must be at least 8 characters.';
  static const String errorEmailInUse =
      'This email is already registered. Try signing in.';
  static const String errorWrongPassword = 'Incorrect email or password.';
  static const String errorUserNotFound =
      'No account found for this email. Sign up first.';
  static const String errorRequiredField = 'This field is required.';
  static const String errorDisplayNameRequired = 'Enter your name to continue.';

  // --- Navigation labels ---
  static const String navHome = 'Home';
  static const String navWorkout = 'Workout';
  static const String navReports = 'Reports';
  static const String navProfile = 'Profile';
}
