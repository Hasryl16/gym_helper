import 'package:flutter/material.dart';

/// Supported exercise types in Phase 1/2.
enum ExerciseType {
  pushup,
  situp,
  pullup;

  String get displayName {
    switch (this) {
      case ExerciseType.pushup:
        return 'Push-Up';
      case ExerciseType.situp:
        return 'Sit-Up';
      case ExerciseType.pullup:
        return 'Pull-Up';
    }
  }

  String get shortName {
    switch (this) {
      case ExerciseType.pushup:
        return 'PUSH-UP';
      case ExerciseType.situp:
        return 'SIT-UP';
      case ExerciseType.pullup:
        return 'PULL-UP';
    }
  }

  IconData get icon {
    switch (this) {
      case ExerciseType.pushup:
        return Icons.fitness_center;
      case ExerciseType.situp:
        return Icons.accessibility_new;
      case ExerciseType.pullup:
        return Icons.airline_seat_flat;
    }
  }

  String get description {
    switch (this) {
      case ExerciseType.pushup:
        return 'Chest, shoulders & triceps compound movement.';
      case ExerciseType.situp:
        return 'Core abdominal strength and endurance.';
      case ExerciseType.pullup:
        return 'Back, biceps and upper body pulling strength.';
    }
  }

  String get cameraPlacement {
    switch (this) {
      case ExerciseType.pushup:
        return 'Place your phone on the floor, 1–2m to your side, at chest height. Ensure your full body is visible.';
      case ExerciseType.situp:
        return 'Place your phone on the floor, 1–2m to your side. Ensure your full torso is visible.';
      case ExerciseType.pullup:
        return 'Place your phone 2–3m in front of the bar. Ensure your full body from head to hips is visible.';
    }
  }
}
