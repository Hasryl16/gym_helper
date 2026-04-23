import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/models/exercise_type.dart';
import '../../../providers/workout_session_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';

class ExerciseSelectScreen extends StatefulWidget {
  const ExerciseSelectScreen({super.key});

  @override
  State<ExerciseSelectScreen> createState() => _ExerciseSelectScreenState();
}

class _ExerciseSelectScreenState extends State<ExerciseSelectScreen> {
  ExerciseType _selectedExercise = ExerciseType.pushup;
  double _targetReps = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.xl,
                AppSpacing.pagePadding,
                0,
              ),
              child: Text(
                'CHOOSE\nEXERCISE',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 40,
                  height: 1.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Exercise cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                ),
                children: ExerciseType.values.map((exercise) {
                  final isSelected = exercise == _selectedExercise;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _ExerciseCard(
                      exercise: exercise,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedExercise = exercise),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Rep target slider
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TARGET REPS',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        _targetReps.toInt().toString(),
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentPrimary,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.accentPrimary,
                      inactiveTrackColor: AppColors.bgElevated,
                      thumbColor: AppColors.accentPrimary,
                      overlayColor: AppColors.accentPrimary.withValues(alpha: 0.15),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _targetReps,
                      min: 5,
                      max: 50,
                      divisions: 9,
                      onChanged: (v) => setState(() => _targetReps = v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('5', style: _sliderLabel),
                      Text('50', style: _sliderLabel),
                    ],
                  ),
                ],
              ),
            ),

            // Start button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: PrimaryButton(
                label: 'Start Workout',
                onPressed: () {
                  context.read<WorkoutSessionProvider>().configureExercise(
                        _selectedExercise,
                        targetReps: _targetReps.toInt(),
                      );
                  context.go('/workout/position-guide');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _sliderLabel => GoogleFonts.dmSans(
        fontSize: 11,
        color: AppColors.textTertiary,
        fontWeight: FontWeight.w500,
      );
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.isSelected,
    required this.onTap,
  });

  final ExerciseType exercise;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.accentPrimary : AppColors.borderDefault,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentPrimary.withValues(alpha: 0.15)
                    : AppColors.bgBase,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(
                exercise.icon,
                color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.displayName,
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.accentPrimary : AppColors.textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    exercise.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.accentPrimary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
