import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_model.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/user_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../routing/route_names.dart';
import '../widgets/level_card.dart';

class LevelSetupScreen extends StatefulWidget {
  const LevelSetupScreen({super.key});

  @override
  State<LevelSetupScreen> createState() => _LevelSetupScreenState();
}

class _LevelSetupScreenState extends State<LevelSetupScreen> {
  FitnessLevel _selected = FitnessLevel.beginner;
  bool _isSaving = false;

  static const _levels = [
    _LevelOption(
      level: FitnessLevel.beginner,
      title: AppStrings.levelBeginner,
      description: AppStrings.levelBeginnerDesc,
      icon: Icons.spa_outlined,
    ),
    _LevelOption(
      level: FitnessLevel.intermediate,
      title: AppStrings.levelIntermediate,
      description: AppStrings.levelIntermediateDesc,
      icon: Icons.bolt_outlined,
    ),
    _LevelOption(
      level: FitnessLevel.advanced,
      title: AppStrings.levelAdvanced,
      description: AppStrings.levelAdvancedDesc,
      icon: Icons.local_fire_department_outlined,
    ),
  ];

  Future<void> _confirm() async {
    setState(() => _isSaving = true);
    try {
      await context.read<UserProvider>().setLevel(_selected);
      if (mounted) context.go(RouteNames.onboardingCamera);
    } catch (_) {
      // Continue even if Firestore update fails — can retry later
      if (mounted) context.go(RouteNames.onboardingCamera);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxxl),

              // Step indicator
              Text(
                'STEP 1 OF 2',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentPrimary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                AppStrings.levelTitle,
                style: GoogleFonts.barlowCondensed(
                  fontSize: 40,
                  height: 1.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This personalises your form thresholds and AI coaching.',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Level cards
              ..._levels.map((opt) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: LevelCard(
                      icon: opt.icon,
                      title: opt.title,
                      description: opt.description,
                      isSelected: _selected == opt.level,
                      onTap: () => setState(() => _selected = opt.level),
                    ),
                  )),

              const Spacer(),

              PrimaryButton(
                label: AppStrings.levelConfirm,
                onPressed: _isSaving ? null : _confirm,
                isLoading: _isSaving,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelOption {
  const _LevelOption({
    required this.level,
    required this.title,
    required this.description,
    required this.icon,
  });

  final FitnessLevel level;
  final String title;
  final String description;
  final IconData icon;
}
