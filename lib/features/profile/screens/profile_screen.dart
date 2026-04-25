import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/sessions_provider.dart';
import '../../../routing/route_names.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _levelEmoji(FitnessLevel l) => switch (l) {
        FitnessLevel.beginner => '🌱',
        FitnessLevel.intermediate => '⚡',
        FitnessLevel.advanced => '🔥',
      };

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.all(0),
              title: Text('Notifications',
                  style: GoogleFonts.dmSans(
                      fontSize: 15, color: AppColors.textPrimary)),
              value: false,
              onChanged: null,
              activeThumbColor: AppColors.accentPrimary,
            ),
            const Divider(color: AppColors.borderDefault),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('About',
                  style: GoogleFonts.dmSans(
                      fontSize: 15, color: AppColors.textPrimary)),
              trailing: Text('v1.0.0',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final auth = context.read<AppAuthProvider>();
    final sessions = context.watch<SessionsProvider>();

    final initial = (user?.displayName.isNotEmpty == true)
        ? user!.displayName.trim()[0].toUpperCase()
        : 'A';

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'PROFILE',
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: AppColors.textSecondary),
                    onPressed: () => _showSettings(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Avatar
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.accentPrimary, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Name + email
              Center(
                child: Text(
                  user?.displayName ?? '',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  user?.email ?? '',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 3-stat row
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      _StatItem(
                          value:
                              '${user?.totalSessions ?? sessions.sessions.length}',
                          label: 'Sessions'),
                      const VerticalDivider(
                          color: AppColors.borderDefault,
                          thickness: 1,
                          width: 1),
                      _StatItem(
                          value: '${user?.totalReps ?? 0}',
                          label: 'Total reps'),
                      const VerticalDivider(
                          color: AppColors.borderDefault,
                          thickness: 1,
                          width: 1),
                      _StatItem(
                          value: '${user?.currentStreak ?? 0}',
                          label: 'Day streak',
                          suffix: '🔥'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Fitness level
              Text(
                'FITNESS LEVEL',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Row(
                  children: FitnessLevel.values.map((level) {
                    final isActive = user?.fitnessLevel == level;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          try {
                            await context
                                .read<UserProvider>()
                                .setLevel(level);
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content:
                                    Text('Failed to save — try again'),
                                backgroundColor: AppColors.error,
                              ));
                            }
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.all(3),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.accentPrimary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${_levelEmoji(level)} ${level.displayName}',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? AppColors.textOnAccent
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Sign out
              GestureDetector(
                onTap: () async {
                  await auth.signOut();
                  if (context.mounted) context.go(RouteNames.welcome);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bgBase,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    border:
                        Border.all(color: AppColors.error, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      'SIGN OUT',
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem(
      {required this.value, required this.label, this.suffix});
  final String value;
  final String label;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: GoogleFonts.barlowCondensed(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentPrimary)),
              if (suffix != null) ...[
                const SizedBox(width: 3),
                Text(suffix!, style: const TextStyle(fontSize: 16)),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
