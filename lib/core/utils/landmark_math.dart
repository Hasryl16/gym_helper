import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Math utilities for working with pose landmarks.
abstract final class LandmarkMath {
  /// Compute the angle (degrees) at [vertex] given two other landmarks.
  /// Uses atan2 to find the angle between the two vectors radiating from vertex.
  static double angleAtVertex(
    PoseLandmark a,
    PoseLandmark vertex,
    PoseLandmark b,
  ) {
    final ax = a.x - vertex.x;
    final ay = a.y - vertex.y;
    final bx = b.x - vertex.x;
    final by = b.y - vertex.y;

    final dotProduct = ax * bx + ay * by;
    final magnitudeA = math.sqrt(ax * ax + ay * ay);
    final magnitudeB = math.sqrt(bx * bx + by * by);

    if (magnitudeA == 0 || magnitudeB == 0) return 0.0;

    final cosAngle = (dotProduct / (magnitudeA * magnitudeB)).clamp(-1.0, 1.0);
    return math.acos(cosAngle) * (180.0 / math.pi);
  }

  /// Check if a landmark has sufficient confidence to be used.
  static bool isReliable(PoseLandmark landmark, {double threshold = 0.5}) {
    return landmark.likelihood >= threshold;
  }
}
