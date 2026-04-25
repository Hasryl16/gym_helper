import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/firestore_service.dart';

String _keyForUid(String? uid) => 'onboarding_complete:${uid ?? 'anonymous'}';

/// Persists onboarding completion state.
///
/// Source of truth priority:
///   1. SharedPreferences (fast, local)
///   2. Firestore user doc (fallback for fresh install / new device)
///
/// Call [loadForUser] whenever the authenticated UID changes.
class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? FirestoreService();

  final FirestoreService _firestore;

  bool _completed = false;
  bool _initialized = false;
  String? _currentUid;

  bool get completed => _completed;
  bool get initialized => _initialized;

  Future<void> loadForUser(String? uid) async {
    if (_currentUid == uid && _initialized) return;

    _currentUid = uid;
    _initialized = false;
    _completed = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final localDone = prefs.getBool(_keyForUid(uid)) ?? false;

    if (localDone) {
      _completed = true;
    } else if (uid != null) {
      // Fallback: check Firestore so returning users on a fresh install
      // don't get sent back through onboarding.
      try {
        final user = await _firestore.getUser(uid);
        if (user?.onboardingComplete == true) {
          _completed = true;
          // Cache locally so next launch is instant
          await prefs.setBool(_keyForUid(uid), true);
        }
      } catch (_) {
        // Firestore unavailable (offline) — stay incomplete, let them re-onboard
      }
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> init() => loadForUser(null);

  Future<void> markCompleted() async {
    if (_completed) return;
    _completed = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyForUid(_currentUid), true);
  }

  Future<void> reset() async {
    _completed = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForUid(_currentUid));
  }
}
