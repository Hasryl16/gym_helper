import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Builds the global [ThemeData] for GymHelper.
abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgBase,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentPrimary,
        onPrimary: AppColors.bgBase,
        secondary: AppColors.accentCyan,
        onSecondary: AppColors.bgBase,
        surface: AppColors.bgElevated,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textPrimary,
        outline: AppColors.divider,
      ),

      // Text theme using DM Sans as base
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgElevated,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.barlowCondensed(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actionsIconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // Bottom navigation bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgElevated,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accentPrimary, size: 24);
          }
          return const IconThemeData(color: AppColors.textTertiary, size: 24);
        }),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: AppColors.borderDefault, width: 1),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.accentPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(
          color: AppColors.textTertiary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.dmSans(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        errorStyle: GoogleFonts.dmSans(
          color: AppColors.error,
          fontSize: 12,
        ),
      ),

      // Elevated button (used for primary actions)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: AppColors.bgBase,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          elevation: 0,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgElevated,
        contentTextStyle: GoogleFonts.dmSans(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
