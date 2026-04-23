import 'dart:math';
import '../models/exercise_type.dart';
import '../models/rep_data.dart';
import '../models/session_model.dart';

/// Accumulates per-rep data during a workout session.
/// Call [recordRep] for each completed rep, then [finalize] to get [SessionModel].
class SessionRecorder {
  SessionRecorder({
    required this.userId,
    required this.exerciseType,
  }) : _startedAt = DateTime.now();

  final String userId;
  final ExerciseType exerciseType;
  final DateTime _startedAt;
  final List<RepData> _reps = [];

  /// Record data for one completed rep.
  void recordRep({
    required double formScore,
    required List<String> errors,
    required double minElbowAngle,
    required double maxElbowAngle,
    required double minHipAngle,
  }) {
    _reps.add(RepData(
      repNumber: _reps.length + 1,
      completedAt: DateTime.now(),
      formScore: formScore,
      errors: List.unmodifiable(errors),
      minElbowAngle: minElbowAngle,
      maxElbowAngle: maxElbowAngle,
      minHipAngle: minHipAngle,
    ));
  }

  /// Build and return the finalized [SessionModel].
  SessionModel finalize() {
    final endedAt = DateTime.now();
    final totalReps = _reps.length;

    // Aggregate form score
    final avgFormScore = totalReps > 0
        ? _reps.map((r) => r.formScore).reduce((a, b) => a + b) / totalReps
        : 0.0;

    // Count "good" reps (form score >= 70)
    final goodReps = _reps.where((r) => r.formScore >= 70.0).length;

    // Find most common errors
    final errorCounts = <String, int>{};
    for (final rep in _reps) {
      for (final error in rep.errors) {
        errorCounts[error] = (errorCounts[error] ?? 0) + 1;
      }
    }
    final sortedErrors = errorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final commonErrors = sortedErrors.take(3).map((e) => e.key).toList();

    return SessionModel(
      sessionId: _generateId(),
      userId: userId,
      exerciseType: exerciseType,
      startedAt: _startedAt,
      endedAt: endedAt,
      totalReps: totalReps,
      goodReps: goodReps,
      formScore: avgFormScore,
      commonErrors: commonErrors,
      reps: List.unmodifiable(_reps),
    );
  }

  int get repCount => _reps.length;

  /// Generate a random UUID-like identifier without external packages.
  static String _generateId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    // Set version 4 and variant bits
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
