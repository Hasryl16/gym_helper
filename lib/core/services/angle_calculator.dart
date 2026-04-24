import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../utils/landmark_math.dart';

/// Named angle helpers built on top of [LandmarkMath.angleAtVertex].
abstract final class AngleCalculator {
  // ---------------------------------------------------------------------------
  // Elbow angles
  // ---------------------------------------------------------------------------

  static double? elbowLeft(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final elbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final wrist = pose.landmarks[PoseLandmarkType.leftWrist];
    if (shoulder == null || elbow == null || wrist == null) return null;
    if (!LandmarkMath.isReliable(shoulder) ||
        !LandmarkMath.isReliable(elbow) ||
        !LandmarkMath.isReliable(wrist)) {
      return null;
    }
    return LandmarkMath.angleAtVertex(shoulder, elbow, wrist);
  }

  static double? elbowRight(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final elbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final wrist = pose.landmarks[PoseLandmarkType.rightWrist];
    if (shoulder == null || elbow == null || wrist == null) return null;
    if (!LandmarkMath.isReliable(shoulder) ||
        !LandmarkMath.isReliable(elbow) ||
        !LandmarkMath.isReliable(wrist)) {
      return null;
    }
    return LandmarkMath.angleAtVertex(shoulder, elbow, wrist);
  }

  /// Average of left and right elbow angles (uses available side if only one).
  static double? elbowAverage(Pose pose) {
    final left = elbowLeft(pose);
    final right = elbowRight(pose);
    if (left != null && right != null) return (left + right) / 2.0;
    return left ?? right;
  }

  // ---------------------------------------------------------------------------
  // Hip angles (hip-knee-ankle for hip extension)
  // ---------------------------------------------------------------------------

  static double? hipLeft(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final knee = pose.landmarks[PoseLandmarkType.leftKnee];
    if (shoulder == null || hip == null || knee == null) return null;
    if (!LandmarkMath.isReliable(shoulder) ||
        !LandmarkMath.isReliable(hip) ||
        !LandmarkMath.isReliable(knee)) {
      return null;
    }
    return LandmarkMath.angleAtVertex(shoulder, hip, knee);
  }

  static double? hipRight(Pose pose) {
    final shoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final hip = pose.landmarks[PoseLandmarkType.rightHip];
    final knee = pose.landmarks[PoseLandmarkType.rightKnee];
    if (shoulder == null || hip == null || knee == null) return null;
    if (!LandmarkMath.isReliable(shoulder) ||
        !LandmarkMath.isReliable(hip) ||
        !LandmarkMath.isReliable(knee)) {
      return null;
    }
    return LandmarkMath.angleAtVertex(shoulder, hip, knee);
  }

  static double? hipAverage(Pose pose) {
    final left = hipLeft(pose);
    final right = hipRight(pose);
    if (left != null && right != null) return (left + right) / 2.0;
    return left ?? right;
  }

  // ---------------------------------------------------------------------------
  // Shoulder angles (for pull-up overhead alignment)
  // ---------------------------------------------------------------------------

  static double? shoulderLeft(Pose pose) {
    final elbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final shoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    if (elbow == null || shoulder == null || hip == null) return null;
    if (!LandmarkMath.isReliable(elbow) ||
        !LandmarkMath.isReliable(shoulder) ||
        !LandmarkMath.isReliable(hip)) {
      return null;
    }
    return LandmarkMath.angleAtVertex(elbow, shoulder, hip);
  }

  static double? shoulderRight(Pose pose) {
    final elbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final shoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final hip = pose.landmarks[PoseLandmarkType.rightHip];
    if (elbow == null || shoulder == null || hip == null) return null;
    if (!LandmarkMath.isReliable(elbow) ||
        !LandmarkMath.isReliable(shoulder) ||
        !LandmarkMath.isReliable(hip)) {
      return null;
    }
    return LandmarkMath.angleAtVertex(elbow, shoulder, hip);
  }
}
