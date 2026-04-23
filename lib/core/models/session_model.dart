import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise_type.dart';
import 'rep_data.dart';

/// A completed workout session stored in Firestore.
class SessionModel {
  const SessionModel({
    required this.sessionId,
    required this.userId,
    required this.exerciseType,
    required this.startedAt,
    required this.endedAt,
    required this.totalReps,
    required this.goodReps,
    required this.formScore,
    required this.commonErrors,
    required this.reps,
  });

  final String sessionId;
  final String userId;
  final ExerciseType exerciseType;
  final DateTime startedAt;
  final DateTime endedAt;
  final int totalReps;
  final int goodReps;
  final double formScore; // aggregate 0–100
  final List<String> commonErrors;
  final List<RepData> reps;

  Duration get duration => endedAt.difference(startedAt);

  factory SessionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return SessionModel(
      sessionId: snapshot.id,
      userId: data['userId'] as String,
      exerciseType: ExerciseType.values.firstWhere(
        (e) => e.name == (data['exerciseType'] as String),
        orElse: () => ExerciseType.pushup,
      ),
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      endedAt: (data['endedAt'] as Timestamp).toDate(),
      totalReps: data['totalReps'] as int,
      goodReps: data['goodReps'] as int,
      formScore: (data['formScore'] as num).toDouble(),
      commonErrors: List<String>.from(data['commonErrors'] as List? ?? []),
      reps: const [], // reps stored in sub-collection for large sets
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'exerciseType': exerciseType.name,
        'startedAt': Timestamp.fromDate(startedAt),
        'endedAt': Timestamp.fromDate(endedAt),
        'totalReps': totalReps,
        'goodReps': goodReps,
        'formScore': formScore,
        'commonErrors': commonErrors,
      };
}
