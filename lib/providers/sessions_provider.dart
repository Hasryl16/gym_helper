import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/models/session_model.dart';
import '../core/services/firestore_service.dart';

class SessionsProvider extends ChangeNotifier {
  SessionsProvider({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? FirestoreService();

  final FirestoreService _firestore;
  StreamSubscription<List<SessionModel>>? _sub;

  List<SessionModel> _sessions = const [];
  bool _isLoading = false;
  String? _error;

  List<SessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SessionModel? get lastSession =>
      _sessions.isEmpty ? null : _sessions.first;

  List<double> get formScoreTrend =>
      _sessions.reversed.map((s) => s.formScore).toList();

  double get scoreImprovement {
    if (_sessions.length < 2) return 0.0;
    return _sessions.first.formScore - _sessions.last.formScore;
  }

  double get avgGoodRepRate {
    if (_sessions.isEmpty) return 0.0;
    final total = _sessions
        .map((s) => s.totalReps == 0 ? 0.0 : s.goodReps / s.totalReps)
        .reduce((a, b) => a + b);
    return total / _sessions.length;
  }

  void watchSessions(String uid) {
    _sub?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();

    _sub = _firestore.watchSessions(uid).listen(
      (sessions) {
        _sessions = sessions;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void clear() {
    _sub?.cancel();
    _sub = null;
    _sessions = const [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
