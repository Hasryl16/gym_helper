import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../routing/route_names.dart';

class CameraPermissionScreen extends StatefulWidget {
  const CameraPermissionScreen({super.key});

  @override
  State<CameraPermissionScreen> createState() => _CameraPermissionScreenState();
}

class _CameraPermissionScreenState extends State<CameraPermissionScreen> {
  bool _isRequesting = false;

  Future<void> _requestPermission() async {
    setState(() => _isRequesting = true);
    try {
      final status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.cameraPermissionDenied),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
        await _complete();
      }
    }
  }

  Future<void> _skipPermission() async {
    debugPrint('[GymHelper] Camera permission skipped by user.');
    await _complete();
  }

  Future<void> _complete() async {
    await context.read<OnboardingProvider>().markCompleted();
    if (mounted) context.go(RouteNames.home);
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
                'STEP 2 OF 2',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentPrimary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Camera icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: const Border.fromBorderSide(
                    BorderSide(color: AppColors.divider),
                  ),
                ),
                child: const Icon(
                  Icons.videocam_outlined,
                  color: AppColors.accentPrimary,
                  size: 40,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Title
              Text(
                AppStrings.cameraTitle,
                style: GoogleFonts.barlowCondensed(
                  fontSize: 36,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Explanation
              Text(
                AppStrings.cameraExplanation,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Privacy bullet points
              ..._bulletPoints.map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: AppColors.accentPrimary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            point,
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

              // Allow button
              PrimaryButton(
                label: AppStrings.cameraAllow,
                onPressed: _isRequesting ? null : _requestPermission,
                isLoading: _isRequesting,
              ),

              const SizedBox(height: AppSpacing.md),

              // Not Now link
              Center(
                child: TextButton(
                  onPressed: _isRequesting ? null : _skipPermission,
                  child: Text(
                    AppStrings.cameraNotNow,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  static const _bulletPoints = [
    'Video is processed entirely on-device in real time.',
    'No footage is ever uploaded or stored remotely.',
    'Camera is only active during an active workout session.',
  ];
}
