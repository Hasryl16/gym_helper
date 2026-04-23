import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bar_chart_outlined,
                color: AppColors.textTertiary,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'REPORTS',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'AI Reports — Coming in Phase 5',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
