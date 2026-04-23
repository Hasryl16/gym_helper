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

  int get repCount => _count;
  _RepState get state => _state;

  /// Reset counters and state machine.
  void reset() {
    _state = _RepState.waiting;
    _count = 0;
    _minElbowAngleThisRep = 180.0;
    _maxElbowAngleThisRep = 0.0;
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
          _count++;
          _state = _RepState.up;
          _resetRepAngles();
          return RepEvent.repCompleted;
        }
    }

    return RepEvent.none;
  }

  /// Min elbow angle recorded during the current/last rep (for form analysis).
  double get lastMinElbow => _minElbowAngleThisRep;

  /// Max elbow angle recorded during the current/last rep.
  double get lastMaxElbow => _maxElbowAngleThisRep;

  void _resetRepAngles() {
    _minElbowAngleThisRep = 180.0;
    _maxElbowAngleThisRep = 0.0;
  }
}

enum _RepState { waiting, up, down }
