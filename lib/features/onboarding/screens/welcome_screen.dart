import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../routing/route_names.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  static const int _itemCount = 5;
  static const Duration _duration = Duration(milliseconds: 500);
  static const Duration _delayStep = Duration(milliseconds: 120);

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _itemCount,
      (_) => AnimationController(vsync: this, duration: _duration),
    );
    _fadeAnims = _controllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOutCubic))
        .toList();
    _slideAnims = _controllers.map((c) {
      return Tween<Offset>(
        begin: const Offset(0, 0.35),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic));
    }).toList();

    _startStaggered();
  }

  Future<void> _startStaggered() async {
    for (int i = 0; i < _itemCount; i++) {
      await Future.delayed(_delayStep);
      if (mounted) _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _animated(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnims[index],
      child: SlideTransition(
        position: _slideAnims[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Stack(
        children: [
          // Geometric background
          const Positioned.fill(child: _GeometricBackground()),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 3),

                  // 0 — App logo pill
                  _animated(
                    0,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgElevated,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusPill),
                        border: const Border.fromBorderSide(
                          BorderSide(color: AppColors.divider),
                        ),
                      ),
                      child: Text(
                        'v1.0  •  POWERED BY AI',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 1 — Big title
                  _animated(
                    1,
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'GYM\n',
                            style: GoogleFonts.barlowCondensed(
                              fontSize: 80,
                              height: 0.9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -2.0,
                            ),
                          ),
                          TextSpan(
                            text: 'HELPER',
                            style: GoogleFonts.barlowCondensed(
                              fontSize: 80,
                              height: 0.9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentPrimary,
                              letterSpacing: -2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 2 — Tagline
                  _animated(
                    2,
                    Text(
                      'Real-time form correction.\nPowered by AI.',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // 3 — Feature pills
                  _animated(
                    3,
                    Row(
                      children: const [
                        _FeaturePill('MediaPipe Pose'),
                        SizedBox(width: AppSpacing.sm),
                        _FeaturePill('AI Reports'),
                        SizedBox(width: AppSpacing.sm),
                        _FeaturePill('3 Exercises'),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // 4 — CTA
                  _animated(
                    4,
                    PrimaryButton(
                      label: 'Get Started',
                      onPressed: () => context.go(RouteNames.signIn),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.divider),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// CustomPaint background: overlapping semi-transparent circles grid.
class _GeometricBackground extends StatelessWidget {
  const _GeometricBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MeshPainter(),
    );
  }
}

class _MeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentPrimary.withValues(alpha: 0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;

    const radius = 90.0;
    const spacing = 130.0;

    // Draw a grid of overlapping circles in the upper-right quadrant
    for (double x = size.width * 0.4; x < size.width + radius; x += spacing) {
      for (double y = -radius; y < size.height * 0.6; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }

    // Additional larger accent circles
    final accentPaint = Paint()
      ..color = AppColors.accentPrimary.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.12), 160, accentPaint);
    canvas.drawCircle(Offset(size.width * 0.95, size.height * 0.28), 90, accentPaint);

    // Diagonal line grid (very subtle)
    final linePaint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    for (double i = -size.height; i < size.width + size.height; i += 60) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height * 0.5, size.height * 0.5),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MeshPainter oldDelegate) => false;
}
