import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../constants/exercise_rules.dart';
import '../models/exercise_type.dart';
import 'angle_calculator.dart';

/// Events emitted when rep state changes.
enum RepEvent { none, repCompleted, positionCheck }

/// Rep counter using a per-exercise state machine.
///
/// Push-up  — tracks elbow angle (extended → flexed → extended).
/// Sit-up   — tracks hip angle  (extended/lying → flexed/sitting → extended).
/// Pull-up  — tracks elbow angle (extended → flexed → extended).
class RepCounter {
  RepCounter({this.exerciseType = ExerciseType.pushup});

  final ExerciseType exerciseType;

  _RepState _state = _RepState.waiting;
  int _count = 0;

  double _minPrimaryThisRep = 180.0;
  double _maxPrimaryThisRep = 0.0;
  double _lastCompletedMin = 180.0;
  double _lastCompletedMax = 0.0;

  int get repCount => _count;

  /// Min primary angle of the last completed rep (elbow for push/pull, hip for sit).
  double get lastMinAngle => _lastCompletedMin;
  double get lastMaxAngle => _lastCompletedMax;

  // Keep named getters so existing call-sites compile unchanged.
  double get lastMinElbow => _lastCompletedMin;
  double get lastMaxElbow => _lastCompletedMax;
  double get lastMinHip => _lastCompletedMin;

  void reset() {
    _state = _RepState.waiting;
    _count = 0;
    _minPrimaryThisRep = 180.0;
    _maxPrimaryThisRep = 0.0;
    _lastCompletedMin = 180.0;
    _lastCompletedMax = 0.0;
  }

  /// Feed a new [Pose] frame into the state machine.
  RepEvent processPose(Pose pose) {
    switch (exerciseType) {
      case ExerciseType.situp:
        return _processSitup(pose);
      case ExerciseType.pushup:
      case ExerciseType.pullup:
        return _processPushupOrPullup(pose);
    }
  }

  // ---------------------------------------------------------------------------
  // Push-up / Pull-up  (elbow angle: waiting → up → down → up = rep)
  // ---------------------------------------------------------------------------

  RepEvent _processPushupOrPullup(Pose pose) {
    final angle = exerciseType == ExerciseType.pullup
        ? AngleCalculator.elbowAverage(pose)
        : AngleCalculator.elbowAverage(pose);
    if (angle == null) return RepEvent.none;

    _trackExtremes(angle);

    final extendedThreshold = exerciseType == ExerciseType.pullup
        ? ExerciseRules.pullupElbowExtended
        : ExerciseRules.pushupElbowExtended;
    final flexedThreshold = exerciseType == ExerciseType.pullup
        ? ExerciseRules.pullupElbowFlexed
        : ExerciseRules.pushupElbowFlexed;

    switch (_state) {
      case _RepState.waiting:
        if (angle > extendedThreshold) {
          _state = _RepState.extended;
          _resetRepAngles();
        }
      case _RepState.extended:
        if (angle < flexedThreshold) _state = _RepState.flexed;
      case _RepState.flexed:
        if (angle > extendedThreshold) return _completeRep();
    }
    return RepEvent.none;
  }

  // ---------------------------------------------------------------------------
  // Sit-up  (torso angle from horizontal: 0°=lying, 90°=upright)
  //   waiting  → extended (torso < situpTorsoLying = recognise start position)
  //   extended → flexed   (torso > situpTorsoUp    = fully sitting up)
  //   flexed   → extended (torso < situpTorsoLying  = back down → rep counted)
  // ---------------------------------------------------------------------------

  RepEvent _processSitup(Pose pose) {
    final angle = AngleCalculator.torsoAngleFromHorizontal(pose);
    if (angle == null) return RepEvent.none;

    _trackExtremes(angle);

    switch (_state) {
      case _RepState.waiting:
        if (angle < ExerciseRules.situpTorsoLying) {
          _state = _RepState.extended;
          _resetRepAngles();
        }
      case _RepState.extended:
        if (angle > ExerciseRules.situpTorsoUp) _state = _RepState.flexed;
      case _RepState.flexed:
        if (angle < ExerciseRules.situpTorsoLying) return _completeRep();
    }
    return RepEvent.none;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  RepEvent _completeRep() {
    _lastCompletedMin = _minPrimaryThisRep;
    _lastCompletedMax = _maxPrimaryThisRep;
    _count++;
    _state = _RepState.extended;
    _resetRepAngles();
    return RepEvent.repCompleted;
  }

  void _trackExtremes(double angle) {
    if (angle < _minPrimaryThisRep) _minPrimaryThisRep = angle;
    if (angle > _maxPrimaryThisRep) _maxPrimaryThisRep = angle;
  }

  void _resetRepAngles() {
    _minPrimaryThisRep = 180.0;
    _maxPrimaryThisRep = 0.0;
  }
}

enum _RepState { waiting, extended, flexed }
