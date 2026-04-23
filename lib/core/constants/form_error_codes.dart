/// String constants for form error codes.
/// Used in RepData.errors and FormAnalyzer output.
abstract final class FormErrorCodes {
  // Push-up errors
  static const String hipsDropping = 'hips_dropping';
  static const String partialRange = 'partial_range';
  static const String headDrop = 'head_drop';
  static const String elbowFlare = 'elbow_flare';

  // Sit-up errors
  static const String neckStrain = 'neck_strain';
  static const String hipFlexorDominant = 'hip_flexor_dominant';

  // Pull-up errors
  static const String kipping = 'kipping';
  static const String incompleteExtension = 'incomplete_extension';

  // Cue messages shown in the UI for each error
  static const Map<String, String> cueMessages = {
    hipsDropping: 'Keep hips level',
    partialRange: 'Go lower',
    headDrop: 'Keep head neutral',
    elbowFlare: 'Tuck your elbows',
    neckStrain: 'Relax your neck',
    hipFlexorDominant: 'Engage your core',
    kipping: 'Control the movement',
    incompleteExtension: 'Fully extend at bottom',
  };
}
