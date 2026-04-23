import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../routing/route_names.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            children: [
              const Spacer(),
              const Icon(
                Icons.person_outline,
                color: AppColors.textTertiary,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                user?.displayName ?? 'ATHLETE',
                style: GoogleFonts.barlowCondensed(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                user?.email ?? '',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Profile — Coming in Phase 5',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              SecondaryButton(
                label: 'Sign Out',
                onPressed: () async {
                  await auth.signOut();
                  if (context.mounted) context.go(RouteNames.welcome);
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
