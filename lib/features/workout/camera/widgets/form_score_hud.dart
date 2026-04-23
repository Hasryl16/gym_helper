import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_colors.dart';

/// Top-right form score pill HUD overlay.
/// Color: lime ≥85, cyan ≥60, orange <60.
class FormScoreHud extends StatelessWidget {
  const FormScoreHud({super.key, required this.score});

  final double score;

  Color get _scoreColor {
    if (score >= 85) return AppColors.accentPrimary;
    if (score >= 60) return AppColors.accentCyan;
    return const Color(0xFFFFB020);
  }

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${score.round()}',
            style: GoogleFonts.barlowCondensed(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.0,
            ),
          ),
          Text(
            'FORM',
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
