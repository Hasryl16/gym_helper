import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/models/exercise_type.dart';
import '../../../providers/workout_session_provider.dart';
import '../../../routing/route_names.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';

class PositionGuideScreen extends StatelessWidget {
  const PositionGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionProv = context.watch<WorkoutSessionProvider>();
    final exercise = sessionProv.exerciseType;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgElevated,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.go(RouteNames.workout),
        ),
        title: Text(
          'SETUP',
          style: GoogleFonts.barlowCondensed(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // Exercise badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  border: const Border.fromBorderSide(
                    BorderSide(color: AppColors.accentPrimary),
                  ),
                ),
                child: Text(
                  exercise.shortName,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentPrimary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                'PHONE\nPLACEMENT',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 36,
                  height: 1.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Phone placement illustration
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: const Border.fromBorderSide(
                    BorderSide(color: AppColors.divider),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.stay_current_portrait,
                        color: AppColors.accentPrimary,
                        size: 40,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Side view — full body visible',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Instructions
              Text(
                exercise.cameraPlacement,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Checklist
              ..._checklistFor(exercise).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: AppColors.accentPrimary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            item,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

              const Spacer(),

              PrimaryButton(
                label: "I'm Ready",
                onPressed: () async {
                  final cameras = await availableCameras();
                  if (!context.mounted) return;
                  await context
                      .read<WorkoutSessionProvider>()
                      .initCamera(cameras);
                  if (!context.mounted) return;
                  context.go('/workout/position-guide/live');
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _checklistFor(ExerciseType exercise) {
    return [
      'Ensure the room has adequate lighting.',
      'Your full body must be in frame at all times.',
      'Wear form-fitting clothing for accurate tracking.',
    ];
  }
}
