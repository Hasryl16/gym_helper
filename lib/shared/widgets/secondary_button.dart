import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Outlined lime button — transparent background with 1.5px lime border.
class SecondaryButton extends StatefulWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : _onTapDown,
      onTapUp: isDisabled ? null : _onTapUp,
      onTapCancel: isDisabled ? null : _onTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isDisabled ? 0.4 : 1.0,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: AppColors.accentPrimary,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.accentPrimary),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        widget.icon!,
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        widget.label.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentPrimary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
