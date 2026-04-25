import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/exercise_type.dart';
import '../../../providers/sessions_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/workout_session_provider.dart';
import '../../../routing/route_names.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/per_rep_bar_strip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Color _scoreColor(double s) {
    if (s >= 80) return AppColors.accentPrimary;
    if (s >= 60) return AppColors.accentCyan;
    return AppColors.warning;
  }

  String _formatDuration(Duration d) =>
      '${d.inMinutes}m ${(d.inSeconds % 60).toString().padLeft(2, '0')}s';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final sessions = context.watch<SessionsProvider>();
    final lastSession = sessions.lastSession;
    final rawName = user?.displayName.trim() ?? '';
    final firstName = rawName.isEmpty ? 'Athlete' : rawName.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                _greeting(),
                style: GoogleFonts.dmSans(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              Text(
                '${firstName.toUpperCase()} 👋',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Streak hero
              _StreakCard(streak: user?.currentStreak ?? 0),
              const SizedBox(height: AppSpacing.lg),

              // Quick-start
              _QuickStartCard(
                lastExercise: lastSession?.exerciseType,
                lastReps: lastSession?.totalReps ?? 0,
                onTap: () {
                  if (lastSession != null) {
                    context
                        .read<WorkoutSessionProvider>()
                        .selectExercise(lastSession.exerciseType);
                    context.go(RouteNames.workoutPositionGuide);
                  } else {
                    context.go(RouteNames.workout);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Last session
              if (lastSession != null) ...[
                Text(
                  'LAST SESSION',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: () => context
                      .push(RouteNames.reportDetailFor(lastSession.sessionId)),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.borderDefault),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.bgBase,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(lastSession.exerciseType.icon,
                                  color: AppColors.accentPrimary, size: 20),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(lastSession.exerciseType.shortName,
                                      style: GoogleFonts.barlowCondensed(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary)),
                                  Text(
                                    '${DateFormat('MMM d').format(lastSession.startedAt)} · ${_formatDuration(lastSession.duration)}',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              lastSession.formScore.toStringAsFixed(0),
                              style: GoogleFonts.barlowCondensed(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: _scoreColor(lastSession.formScore),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PerRepBarStrip(
                          reps: lastSession.reps,
                          fallbackScore: lastSession.formScore,
                          maxBars: 10,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            _MiniChip(
                                value: '${lastSession.totalReps}',
                                label: 'reps'),
                            const SizedBox(width: AppSpacing.sm),
                            _MiniChip(
                                value: '${lastSession.goodReps}',
                                label: 'good'),
                            const SizedBox(width: AppSpacing.sm),
                            _MiniChip(
                              value: lastSession.formScore
                                  .toStringAsFixed(0),
                              label: 'score',
                              valueColor:
                                  _scoreColor(lastSession.formScore),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: streak == 0
          ? Center(
              child: Text(
                'Start your streak today! 🔥',
                style: GoogleFonts.dmSans(
                    fontSize: 15, color: AppColors.textSecondary),
              ),
            )
          : Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 32)),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$streak',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentPrimary,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'DAY STREAK',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _WeeklyDots(currentStreak: streak),
              ],
            ),
    );
  }
}

class _WeeklyDots extends StatelessWidget {
  const _WeeklyDots({required this.currentStreak});
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday; // 1=Mon, 7=Sun
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < 7; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Column(
                children: [
                  _Dot(
                    isToday: (i + 1) == today,
                    isFuture: (i + 1) > today,
                    isCompleted: (i + 1) <= today &&
                        currentStreak >= (today - i),
                  ),
                  const SizedBox(height: 4),
                  Text(labels[i],
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.textTertiary)),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(
      {required this.isToday,
      required this.isFuture,
      required this.isCompleted});
  final bool isToday;
  final bool isFuture;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    if (isToday) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.accentPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: AppColors.accentPrimary.withValues(alpha: 0.5),
                blurRadius: 6)
          ],
        ),
      );
    }
    if (isCompleted) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.accentPrimary.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
      );
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderDefault),
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  const _QuickStartCard({
    required this.lastExercise,
    required this.lastReps,
    required this.onTap,
  });
  final ExerciseType? lastExercise;
  final int lastReps;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasLast = lastExercise != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.accentPrimary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          children: [
            Icon(
              hasLast ? lastExercise!.icon : Icons.fitness_center,
              color: AppColors.textOnAccent,
              size: 28,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasLast ? 'QUICK START' : 'START FIRST WORKOUT',
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 11,
                      color: AppColors.textOnAccent,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    hasLast
                        ? '${lastExercise!.displayName} · $lastReps reps'
                        : 'Begin your fitness journey',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textOnAccent,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: AppColors.textOnAccent, size: 16),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip(
      {required this.value, required this.label, this.valueColor});
  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.barlowCondensed(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.textPrimary)),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 10, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
