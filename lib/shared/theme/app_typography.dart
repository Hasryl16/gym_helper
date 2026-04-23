import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// GymHelper typography system.
/// Display: BarlowCondensed (bold geometric numerics, titles)
/// Body/UI: DM Sans (clean labels, body, buttons)
abstract final class AppTypography {
  // ---------------------------------------------------------------------------
  // Display — BarlowCondensed
  // ---------------------------------------------------------------------------

  /// 72/80 w700 — rep counts, hero numbers
  static TextStyle get displayXL => GoogleFonts.barlowCondensed(
        fontSize: 72,
        height: 80 / 72,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -1.0,
      );

  /// 48/56 w700 — screen titles, scores
  static TextStyle get displayL => GoogleFonts.barlowCondensed(
        fontSize: 48,
        height: 56 / 48,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  /// 36/44 w700 — section headers
  static TextStyle get displayM => GoogleFonts.barlowCondensed(
        fontSize: 36,
        height: 44 / 36,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  // ---------------------------------------------------------------------------
  // Headline / Title — DM Sans
  // ---------------------------------------------------------------------------

  /// 24/32 w600
  static TextStyle get headline => GoogleFonts.dmSans(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// 20/28 w600
  static TextStyle get title => GoogleFonts.dmSans(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // ---------------------------------------------------------------------------
  // Body — DM Sans
  // ---------------------------------------------------------------------------

  /// 16/24 w500
  static TextStyle get bodyL => GoogleFonts.dmSans(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  /// 14/20 w500
  static TextStyle get body => GoogleFonts.dmSans(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  /// 12/16 w500 uppercase with letter-spacing — labels, caps, tags
  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      );

  // ---------------------------------------------------------------------------
  // Button label — DM Sans SemiBold
  // ---------------------------------------------------------------------------

  static TextStyle get button => GoogleFonts.dmSans(
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnAccent,
        letterSpacing: 1.2,
      );
}
