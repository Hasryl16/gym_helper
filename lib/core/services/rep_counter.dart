import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../constants/exercise_rules.dart';
import 'angle_calculator.dart';

/// Events emitted when rep state changes.
enum RepEvent { none, repCompleted, positionCheck }

/// Push-up rep counter using a strict state machine.
///
/// State transitions:
///   waiting → up   (elbow > [ExerciseRules.pushupElbowExtended])
///   up       → down (elbow < [ExerciseRules.pushupElbowFlexed])
///   down     → up   (elbow > [ExerciseRules.pushupElbowExtended]) → emits repCompleted
class RepCounter {
  _RepState _state = _RepState.waiting;
  int _count = 0;
  double _minElbowAngleThisRep = 180.0;
  double _maxElbowAngleThisRep = 0.0;

  // Captures the angles of the last completed rep BEFORE resetting for the
  // next rep. Getters read from these so callers always see the completed
  // rep's data, not the mid-reset zero values.
  double _lastCompletedMinElbow = 180.0;
  double _lastCompletedMaxElbow = 0.0;

  int get repCount => _count;

  /// Reset counters and state machine.
  void reset() {
    _state = _RepState.waiting;
    _count = 0;
    _minElbowAngleThisRep = 180.0;
    _maxElbowAngleThisRep = 0.0;
    _lastCompletedMinElbow = 180.0;
    _lastCompletedMaxElbow = 0.0;
  }

  /// Feed a new [Pose] frame into the state machine.
  /// Returns a [RepEvent] indicating if something notable happened.
  RepEvent processPose(Pose pose) {
    final elbowAngle = AngleCalculator.elbowAverage(pose);
    if (elbowAngle == null) return RepEvent.none;

    // Track extremes for this rep
    if (elbowAngle < _minElbowAngleThisRep) _minElbowAngleThisRep = elbowAngle;
    if (elbowAngle > _maxElbowAngleThisRep) _maxElbowAngleThisRep = elbowAngle;

    switch (_state) {
      case _RepState.waiting:
        // Wait until user is in the starting "up" position
        if (elbowAngle > ExerciseRules.pushupElbowExtended) {
          _state = _RepState.up;
          _resetRepAngles();
        }

      case _RepState.up:
        // User is going down
        if (elbowAngle < ExerciseRules.pushupElbowFlexed) {
          _state = _RepState.down;
        }

      case _RepState.down:
        // User is coming back up — rep completed
        if (elbowAngle > ExerciseRules.pushupElbowExtended) {
          // Capture completed-rep angles BEFORE resetting, so getters return
          // the correct values when the provider reads them after this call.
          _lastCompletedMinElbow = _minElbowAngleThisRep;
          _lastCompletedMaxElbow = _maxElbowAngleThisRep;
          _count++;
          _state = _RepState.up;
          _resetRepAngles();
          return RepEvent.repCompleted;
        }
    }

    return RepEvent.none;
  }

  /// Min elbow angle recorded during the last completed rep (for form analysis).
  double get lastMinElbow => _lastCompletedMinElbow;

  /// Max elbow angle recorded during the last completed rep.
  double get lastMaxElbow => _lastCompletedMaxElbow;

  void _resetRepAngles() {
    _minElbowAngleThisRep = 180.0;
    _maxElbowAngleThisRep = 0.0;
  }
}

enum _RepState { waiting, up, down }
