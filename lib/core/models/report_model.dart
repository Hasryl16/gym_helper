import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise_type.dart';

/// AI-generated post-session report stored in Firestore.
class ReportModel {
  const ReportModel({
    required this.reportId,
    required this.sessionId,
    required this.userId,
    required this.exerciseType,
    required this.generatedAt,
    required this.overallScore,
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.nextSessionGoal,
  });

  final String reportId;
  final String sessionId;
  final String userId;
  final ExerciseType exerciseType;
  final DateTime generatedAt;
  final double overallScore;
  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final String nextSessionGoal;

  factory ReportModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return ReportModel(
      reportId: snapshot.id,
      sessionId: data['sessionId'] as String,
      userId: data['userId'] as String,
      exerciseType: ExerciseType.values.firstWhere(
        (e) => e.name == (data['exerciseType'] as String),
        orElse: () => ExerciseType.pushup,
      ),
      generatedAt: (data['generatedAt'] as Timestamp).toDate(),
      overallScore: (data['overallScore'] as num).toDouble(),
      summary: data['summary'] as String? ?? '',
      strengths: List<String>.from(data['strengths'] as List? ?? []),
      improvements: List<String>.from(data['improvements'] as List? ?? []),
      nextSessionGoal: data['nextSessionGoal'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'sessionId': sessionId,
        'userId': userId,
        'exerciseType': exerciseType.name,
        'generatedAt': Timestamp.fromDate(generatedAt),
        'overallScore': overallScore,
        'summary': summary,
        'strengths': strengths,
        'improvements': improvements,
        'nextSessionGoal': nextSessionGoal,
      };
}
