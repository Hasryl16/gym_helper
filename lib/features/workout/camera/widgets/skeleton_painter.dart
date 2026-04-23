import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../../shared/theme/app_colors.dart';

/// CustomPainter that draws the 16-connection skeleton overlay
/// using electric cyan for bones and color-coded joints.
class SkeletonPainter extends CustomPainter {
  const SkeletonPainter({
    required this.pose,
    required this.imageSize,
    required this.screenSize,
  });

  final Pose pose;
  final Size imageSize;
  final Size screenSize;

  static const _connections = [
    // Face
    [PoseLandmarkType.leftEar, PoseLandmarkType.leftEye],
    [PoseLandmarkType.leftEye, PoseLandmarkType.nose],
    [PoseLandmarkType.nose, PoseLandmarkType.rightEye],
    [PoseLandmarkType.rightEye, PoseLandmarkType.rightEar],

    // Torso
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],

    // Left arm
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],

    // Right arm
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],

    // Left leg
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],

    // Right leg
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final bonePaint = Paint()
      ..color = AppColors.accentCyan.withValues(alpha: 0.75)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw connection lines
    for (final connection in _connections) {
      final a = pose.landmarks[connection[0]];
      final b = pose.landmarks[connection[1]];
      if (a == null || b == null) continue;
      if (a.likelihood < 0.4 || b.likelihood < 0.4) continue;

      canvas.drawLine(
        _toScreen(a.x, a.y),
        _toScreen(b.x, b.y),
        bonePaint,
      );
    }

    // Draw joint circles
    for (final entry in pose.landmarks.entries) {
      final landmark = entry.value;
      if (landmark.likelihood < 0.4) continue;

      final offset = _toScreen(landmark.x, landmark.y);
      final isKeyJoint = _keyJoints.contains(entry.key);

      // Outer circle
      canvas.drawCircle(
        offset,
        isKeyJoint ? 6.0 : 4.0,
        Paint()..color = AppColors.accentCyan.withValues(alpha: 0.9),
      );
      // Inner dot
      canvas.drawCircle(
        offset,
        isKeyJoint ? 3.0 : 2.0,
        Paint()..color = AppColors.textPrimary,
      );
    }
  }

  Offset _toScreen(double x, double y) {
    final scaleX = screenSize.width / imageSize.width;
    final scaleY = screenSize.height / imageSize.height;
    return Offset(x * scaleX, y * scaleY);
  }

  static const _keyJoints = {
    PoseLandmarkType.leftShoulder,
    PoseLandmarkType.rightShoulder,
    PoseLandmarkType.leftElbow,
    PoseLandmarkType.rightElbow,
    PoseLandmarkType.leftWrist,
    PoseLandmarkType.rightWrist,
    PoseLandmarkType.leftHip,
    PoseLandmarkType.rightHip,
    PoseLandmarkType.leftKnee,
    PoseLandmarkType.rightKnee,
  };

  @override
  bool shouldRepaint(SkeletonPainter oldDelegate) =>
      oldDelegate.pose != pose;
}
