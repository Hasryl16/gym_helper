import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../constants/exercise_rules.dart';
import '../constants/form_error_codes.dart';
import 'angle_calculator.dart';

/// Result of a single-frame form check.
class FormCheckResult {
  const FormCheckResult({
    required this.errors,
    required this.score,
    required this.activeCue,
  });

  final List<String> errors;
  final double score;
  final String? activeCue; // message to show in the cue banner
}

/// Analyzes push-up form from a [Pose] frame.
/// Returns a [FormCheckResult] with errors and per-rep score.
abstract final class FormAnalyzer {
  /// Evaluate form during a push-up.
  ///
  /// [pose] — current smoothed pose.
  /// [minElbowAngle] — minimum elbow angle seen this rep (for range check).
  static FormCheckResult analyzePushup(Pose pose, double minElbowAngle) {
    final errors = <String>[];

    // Check 1: Hip dropping (check hip angle — should be near 180° for plank)
    final hipAngle = AngleCalculator.hipAverage(pose);
    if (hipAngle != null && hipAngle < ExerciseRules.pushupHipStraight) {
      errors.add(FormErrorCodes.hipsDropping);
    }

    // Check 2: Partial range of motion
    if (minElbowAngle > ExerciseRules.pushupMinRom) {
      errors.add(FormErrorCodes.partialRange);
    }

    // Check 3: Head drop — compare nose to shoulder height
    final nose = pose.landmarks[PoseLandmarkType.nose];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    if (nose != null && leftShoulder != null && rightShoulder != null) {
      final shoulderY = (leftShoulder.y + rightShoulder.y) / 2.0;
      // In image coords, larger Y = lower on screen.
      // Head dropping = nose Y > shoulder Y by significant margin
      if (nose.y > shoulderY + 40) {
        errors.add(FormErrorCodes.headDrop);
      }
    }

    final score = (ExerciseRules.baseScore -
            errors.length * ExerciseRules.errorPenalty)
        .clamp(0.0, 100.0);

    // Highest-priority cue message
    final activeCue = errors.isNotEmpty
        ? FormErrorCodes.cueMessages[errors.first]
        : null;

    return FormCheckResult(
      errors: errors,
      score: score,
      activeCue: activeCue,
    );
  }
}
