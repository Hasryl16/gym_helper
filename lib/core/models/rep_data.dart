/// Data captured for a single completed repetition.
class RepData {
  const RepData({
    required this.repNumber,
    required this.completedAt,
    required this.formScore,
    required this.errors,
    required this.minElbowAngle,
    required this.maxElbowAngle,
    required this.minHipAngle,
  });

  final int repNumber;
  final DateTime completedAt;
  final double formScore; // 0–100
  final List<String> errors; // form_error_codes
  final double minElbowAngle;
  final double maxElbowAngle;
  final double minHipAngle;

  Map<String, dynamic> toMap() => {
        'repNumber': repNumber,
        'completedAt': completedAt.toIso8601String(),
        'formScore': formScore,
        'errors': errors,
        'minElbowAngle': minElbowAngle,
        'maxElbowAngle': maxElbowAngle,
        'minHipAngle': minHipAngle,
      };

  factory RepData.fromMap(Map<String, dynamic> map) => RepData(
        repNumber: map['repNumber'] as int,
        completedAt: DateTime.parse(map['completedAt'] as String),
        formScore: (map['formScore'] as num).toDouble(),
        errors: List<String>.from(map['errors'] as List? ?? []),
        minElbowAngle: (map['minElbowAngle'] as num).toDouble(),
        maxElbowAngle: (map['maxElbowAngle'] as num).toDouble(),
        minHipAngle: (map['minHipAngle'] as num).toDouble(),
      );
}
