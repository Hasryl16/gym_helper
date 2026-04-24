import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/workout_session_provider.dart';
import '../../../routing/route_names.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../core/constants/form_error_codes.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _scoreColor(double score) {
    if (score >= 85) return AppColors.accentPrimary;
    if (score >= 60) return AppColors.accentCyan;
    return const Color(0xFFFFB020);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<WorkoutSessionProvider>();
    final summary = session.lastSession;

    if (summary == null) {
      return const Scaffold(
        backgroundColor: AppColors.bgBase,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentPrimary),
        ),
      );
    }

    final scoreColor = _scoreColor(summary.formScore);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // Header
              Text(
                'SESSION\nCOMPLETE',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 44,
                  height: 0.95,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                summary.exerciseType.displayName,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppColors.accentPrimary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Stats row
              Row(
                children: [
                  _StatCard(
                    label: 'REPS',
                    value: '${summary.totalReps}',
                    valueColor: AppColors.textPrimary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _StatCard(
                    label: 'FORM',
                    value: '${summary.formScore.round()}',
                    valueColor: scoreColor,
                    unit: '%',
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _StatCard(
                    label: 'DURATION',
                    value: _formatDuration(summary.duration),
                    valueColor: AppColors.accentCyan,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Good reps
              _InfoRow(
                label: 'Good reps',
                value: '${summary.goodReps} / ${summary.totalReps}',
                valueColor: AppColors.jointGood,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Common errors section
              if (summary.commonErrors.isNotEmpty) ...[
                Text(
                  'COMMON ERRORS',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...summary.commonErrors.map((error) {
                  final message =
                      FormErrorCodes.cueMessages[error] ?? error;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.jointError,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          message,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.xl),
              ],

              const SizedBox(height: AppSpacing.md),

              // Save button
              PrimaryButton(
                label: 'Save & View Report',
                onPressed: () async {
                  await session.saveSession();
                  if (context.mounted) {
                    context.go(RouteNames.reports);
                    session.resetSession();
                  }
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Discard button
              SecondaryButton(
                label: 'Discard',
                onPressed: () {
                  session.resetSession();
                  context.go(RouteNames.workout);
                },
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
    this.unit,
  });

  final String label;
  final String value;
  final Color valueColor;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                      height: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (unit != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 3),
                    child: Text(
                      unit!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: valueColor.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.barlowCondensed(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
