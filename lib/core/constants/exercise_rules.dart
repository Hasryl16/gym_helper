/// Biomechanical thresholds used for rep counting and form analysis.
abstract final class ExerciseRules {
  // ---------------------------------------------------------------------------
  // Push-up thresholds
  // ---------------------------------------------------------------------------

  /// Elbow angle above which the arm is considered fully extended (top position).
  static const double pushupElbowExtended = 160.0;

  /// Elbow angle below which the chest is considered near the floor (bottom position).
  static const double pushupElbowFlexed = 90.0;

  /// Minimum hip angle at bottom — below this means hips are dropping.
  static const double pushupHipStraight = 160.0;

  /// Minimum range-of-motion: if minimum elbow > this, rep is partial.
  static const double pushupMinRom = 100.0;

  // ---------------------------------------------------------------------------
  // Sit-up thresholds (for Phase 3 implementation)
  // ---------------------------------------------------------------------------

  /// Hip angle at top (sitting up).
  static const double situpHipFlexed = 80.0;

  /// Hip angle at bottom (lying down).
  static const double situpHipExtended = 150.0;

  // ---------------------------------------------------------------------------
  // Pull-up thresholds (for Phase 3 implementation)
  // ---------------------------------------------------------------------------

  /// Elbow angle at top (chin over bar).
  static const double pullupElbowFlexed = 60.0;

  /// Elbow angle at bottom (dead hang).
  static const double pullupElbowExtended = 160.0;

  // ---------------------------------------------------------------------------
  // Form scoring
  // ---------------------------------------------------------------------------

  /// Base score before any deductions.
  static const double baseScore = 100.0;

  /// Points deducted per form error per rep.
  static const double errorPenalty = 15.0;

  /// EMA alpha for pose smoothing (higher = more responsive, less stable).
  static const double emaAlpha = 0.4;
}
