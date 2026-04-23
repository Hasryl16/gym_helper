import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_colors.dart';

/// Bottom-positioned cue banner that fades in/out with form feedback.
class CueBanner extends StatelessWidget {
  const CueBanner({super.key, required this.cue});

  /// The cue message. When null, the banner fades out.
  final String? cue;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: cue != null ? 1.0 : 0.0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.78),
              Colors.black.withValues(alpha: 0.55),
              Colors.transparent,
            ],
          ),
        ),
        child: Text(
          cue ?? '',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1.4,
            shadows: [
              const Shadow(
                color: Colors.black,
                blurRadius: 6,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
