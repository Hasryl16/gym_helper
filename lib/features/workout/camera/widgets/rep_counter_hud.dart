import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_colors.dart';

/// Top-center rep counter HUD overlay.
/// Displays the current rep count in large lime BarlowCondensed with
/// an AnimatedScale pulse on increment.
class RepCounterHud extends StatefulWidget {
  const RepCounterHud({
    super.key,
    required this.count,
    required this.target,
  });

  final int count;
  final int target;

  @override
  State<RepCounterHud> createState() => _RepCounterHudState();
}

class _RepCounterHudState extends State<RepCounterHud>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pulseScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.18),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.18, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(RepCounterHud oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count && widget.count > 0) {
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulseScale,
            child: Text(
              '${widget.count}',
              style: GoogleFonts.barlowCondensed(
                fontSize: 72,
                fontWeight: FontWeight.w700,
                color: AppColors.accentPrimary,
                height: 0.95,
                letterSpacing: -1.0,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'REPS / ${widget.target}',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
