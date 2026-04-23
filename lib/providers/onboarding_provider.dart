import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kOnboardingKey = 'onboarding_complete';

/// Persists onboarding completion state via SharedPreferences.
class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider();

  bool _completed = false;
  bool _initialized = false;

  bool get completed => _completed;
  bool get initialized => _initialized;

  /// Load the persisted state. Must be called at app startup.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _completed = prefs.getBool(_kOnboardingKey) ?? false;
    _initialized = true;
    notifyListeners();
  }

  /// Mark onboarding as done and persist.
  Future<void> markCompleted() async {
    if (_completed) return;
    _completed = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingKey, true);
  }

  /// Reset onboarding (for testing / re-run).
  Future<void> reset() async {
    _completed = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kOnboardingKey);
  }
}
