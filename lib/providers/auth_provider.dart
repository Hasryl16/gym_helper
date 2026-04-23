import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/services/auth_service.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

/// Tracks Firebase authentication state and exposes it to the widget tree.
class AppAuthProvider extends ChangeNotifier {
  AppAuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _sub = _authService.authStateChanges.listen(_onAuthChanged);
  }

  final AuthService _authService;
  late final StreamSubscription<User?> _sub;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  AuthService get authService => _authService;

  void _onAuthChanged(User? user) {
    _user = user;
    _status =
        user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign in with email/password. Returns true on success.
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signInWithEmail(email: email, password: password);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up with email/password/displayName. Returns true on success.
  Future<bool> signUpWithEmail(
      String email, String password, String displayName) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Google. Returns true on success.
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final result = await _authService.signInWithGoogle();
      return result != null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
