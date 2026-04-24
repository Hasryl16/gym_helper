import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Returns the SharedPreferences key scoped to a specific user UID so that
/// onboarding state is not shared between different accounts on the same device.
String _keyForUid(String? uid) => 'onboarding_complete:${uid ?? 'anonymous'}';

/// Persists onboarding completion state via SharedPreferences.
///
/// Call [loadForUser] whenever the authenticated UID changes (e.g. sign-in,
/// sign-out, or account switch). This replaces the old static [init] method.
class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider();

  bool _completed = false;
  bool _initialized = false;
  String? _currentUid;

  bool get completed => _completed;

  /// True once [loadForUser] (or [init]) has finished reading from
  /// SharedPreferences. The router must not redirect until this is true to
  /// avoid a flash to the onboarding screen on cold start.
  bool get initialized => _initialized;

  /// Load onboarding state for [uid].
  ///
  /// Safe to call repeatedly — if [uid] hasn't changed the call is a no-op
  /// (state is already loaded and [initialized] is already true).
  Future<void> loadForUser(String? uid) async {
    if (_currentUid == uid && _initialized) return;

    _currentUid = uid;
    _initialized = false;
    _completed = false;
    // Notify so the router sees initialized == false and withholds redirects
    // while we wait for SharedPreferences.
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _completed = prefs.getBool(_keyForUid(uid)) ?? false;
    _initialized = true;
    notifyListeners();
  }

  /// Convenience wrapper for the initial (unauthenticated / anonymous) load.
  /// Kept for backwards compatibility with existing [app.dart] call sites.
  Future<void> init() => loadForUser(null);

  /// Mark onboarding as done and persist for the current user.
  Future<void> markCompleted() async {
    if (_completed) return;
    _completed = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyForUid(_currentUid), true);
  }

  /// Reset onboarding state for the current user (for testing / re-run).
  Future<void> reset() async {
    _completed = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForUid(_currentUid));
  }
}
