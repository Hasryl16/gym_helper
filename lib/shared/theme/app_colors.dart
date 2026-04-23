import 'package:flutter/material.dart';

/// GymHelper design system color palette.
/// Dark, athletic performance dashboard aesthetic.
abstract final class AppColors {
  // --- Base backgrounds ---
  static const Color bgBase = Color(0xFF0A0B0D);
  static const Color bgElevated = Color(0xFF14161A);
  static const Color bgElevatedHi = Color(0xFF1C1F25);
  static const Color bgCard = Color(0xFF14161A);

  // --- Dividers / borders ---
  static const Color divider = Color(0xFF2A2E36);
  static const Color borderDefault = Color(0xFF2A2E36);

  // --- Signature accents ---
  static const Color accentPrimary = Color(0xFFCFFF50); // high-voltage lime
  static const Color accentPressed = Color(0xFFB8E83D); // darker lime for press
  static const Color accentCyan = Color(0xFF4CC9F0);    // skeleton overlay cyan

  // --- Semantic colors ---
  static const Color error = Color(0xFFFF3B5C);
  static const Color success = Color(0xFF35D07F);
  static const Color warning = Color(0xFFFFB020);

  // --- Joint feedback colors ---
  static const Color jointGood = Color(0xFF35D07F);
  static const Color jointError = Color(0xFFFF3B5C);
  static const Color jointWarn = Color(0xFFFFB020);

  // --- Text ---
  static const Color textPrimary = Color(0xFFF2F4F7);
  static const Color textSecondary = Color(0xFF9BA3AF);
  static const Color textTertiary = Color(0xFF5C636E);
  static const Color textOnAccent = Color(0xFF0A0B0D); // dark text on lime bg

  // --- Rating colors ---
  static const Color ratingGreat = accentPrimary;
  static const Color ratingGood = accentCyan;
  static const Color ratingNeedsWork = warning;
}
