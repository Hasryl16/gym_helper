import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/models/user_model.dart';
import '../core/services/firestore_service.dart';

/// Holds the current user's [UserModel] from Firestore.
/// Subscribes to real-time updates for the given UID.
class UserProvider extends ChangeNotifier {
  UserProvider({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? FirestoreService();

  final FirestoreService _firestore;
  StreamSubscription<UserModel?>? _sub;

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  /// Start watching the Firestore document for [uid].
  void watchUser(String uid) {
    _sub?.cancel();
    _isLoading = true;
    notifyListeners();

    _sub = _firestore.watchUser(uid).listen(
      (user) {
        _user = user;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Stop watching — called on sign out.
  void clear() {
    _sub?.cancel();
    _sub = null;
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Update the user's fitness level both in Firestore and locally.
  Future<void> setLevel(FitnessLevel level) async {
    final uid = _user?.uid;
    if (uid == null) return;
    await _firestore.updateUserLevel(uid, level);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
