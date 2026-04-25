import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../models/report_model.dart';

/// Typed Firestore wrapper.
class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ---------------------------------------------------------------------------
  // Collection references
  // ---------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection('sessions');

  CollectionReference<Map<String, dynamic>> get _reports =>
      _db.collection('reports');

  // ---------------------------------------------------------------------------
  // Users
  // ---------------------------------------------------------------------------

  /// Create or overwrite a user document (called after auth sign-up).
  Future<void> createUserDoc(UserModel user) async {
    await _users.doc(user.uid).set(user.toFirestore(), SetOptions(merge: true));
  }

  /// Real-time stream of the user document.
  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserModel.fromFirestore(snap, null);
    });
  }

  /// Update the user's fitness level.
  Future<void> updateUserLevel(String uid, FitnessLevel level) async {
    await _users.doc(uid).update({'fitnessLevel': level.name});
  }

  /// Mark onboarding as completed.
  Future<void> markOnboardingComplete(String uid) async {
    await _users.doc(uid).update({'onboardingComplete': true});
  }

  // ---------------------------------------------------------------------------
  // Sessions
  // ---------------------------------------------------------------------------

  /// Persist a completed workout session. Returns the generated session ID.
  Future<String> createSession(SessionModel session) async {
    final ref = _sessions.doc(session.sessionId.isEmpty
        ? _sessions.doc().id
        : session.sessionId);
    await ref.set(session.toFirestore());

    // Increment user totals
    await _users.doc(session.userId).update({
      'totalSessions': FieldValue.increment(1),
      'totalReps': FieldValue.increment(session.totalReps),
    });

    return ref.id;
  }

  /// Real-time stream of sessions for a user, ordered by start time desc.
  Stream<List<SessionModel>> watchSessions(String userId) {
    return _sessions
        .where('userId', isEqualTo: userId)
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => SessionModel.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                  null,
                ))
            .toList());
  }

  // ---------------------------------------------------------------------------
  // Reports
  // ---------------------------------------------------------------------------

  /// Fetch a report by session ID (O(1) direct doc lookup).
  Stream<ReportModel?> watchReport(String sessionId) {
    return _reports.doc(sessionId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return ReportModel.fromFirestore(snap, null);
    });
  }

  /// Real-time stream of a single session document.
  Stream<SessionModel?> watchSession(String sessionId) {
    return _sessions.doc(sessionId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return SessionModel.fromFirestore(snap, null);
    });
  }

  // ---------------------------------------------------------------------------
  // Streak
  // ---------------------------------------------------------------------------

  /// Increment the user's streak transactionally.
  /// Resets to 1 if last session was more than 2 days ago.
  Future<void> incrementStreak(String uid) async {
    await _db.runTransaction((transaction) async {
      final userRef = _users.doc(uid);
      final snap = await transaction.get(userRef);
      if (!snap.exists) return;

      final data = snap.data()!;
      final lastSessionTs = data['lastSessionAt'] as Timestamp?;
      final now = DateTime.now();
      int newStreak;

      if (lastSessionTs == null) {
        newStreak = 1;
      } else {
        final lastSession = lastSessionTs.toDate();
        final diff = now.difference(lastSession).inHours;
        if (diff < 48) {
          // Within 2 days — increment
          newStreak = (data['currentStreak'] as int? ?? 0) + 1;
        } else {
          // Gap too large — reset
          newStreak = 1;
        }
      }

      transaction.update(userRef, {
        'currentStreak': newStreak,
        'lastSessionAt': Timestamp.fromDate(now),
      });
    });
  }
}
