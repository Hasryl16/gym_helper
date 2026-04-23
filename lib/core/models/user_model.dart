import 'package:cloud_firestore/cloud_firestore.dart';

/// Fitness levels available during onboarding.
enum FitnessLevel {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case FitnessLevel.beginner:
        return 'Beginner';
      case FitnessLevel.intermediate:
        return 'Intermediate';
      case FitnessLevel.advanced:
        return 'Advanced';
    }
  }
}

/// Core user data document stored in Firestore at /users/{uid}.
class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.fitnessLevel = FitnessLevel.beginner,
    this.onboardingComplete = false,
    this.currentStreak = 0,
    this.totalSessions = 0,
    this.totalReps = 0,
    this.photoUrl,
  });

  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final FitnessLevel fitnessLevel;
  final bool onboardingComplete;
  final int currentStreak;
  final int totalSessions;
  final int totalReps;
  final String? photoUrl;

  /// Construct from a Firestore document snapshot.
  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return UserModel(
      uid: snapshot.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fitnessLevel: FitnessLevel.values.firstWhere(
        (l) => l.name == (data['fitnessLevel'] as String?),
        orElse: () => FitnessLevel.beginner,
      ),
      onboardingComplete: data['onboardingComplete'] as bool? ?? false,
      currentStreak: data['currentStreak'] as int? ?? 0,
      totalSessions: data['totalSessions'] as int? ?? 0,
      totalReps: data['totalReps'] as int? ?? 0,
      photoUrl: data['photoUrl'] as String?,
    );
  }

  /// Serialize to Firestore document map.
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'fitnessLevel': fitnessLevel.name,
      'onboardingComplete': onboardingComplete,
      'currentStreak': currentStreak,
      'totalSessions': totalSessions,
      'totalReps': totalReps,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
    FitnessLevel? fitnessLevel,
    bool? onboardingComplete,
    int? currentStreak,
    int? totalSessions,
    int? totalReps,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      currentStreak: currentStreak ?? this.currentStreak,
      totalSessions: totalSessions ?? this.totalSessions,
      totalReps: totalReps ?? this.totalReps,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
