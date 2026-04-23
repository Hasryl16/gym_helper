import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';

/// Animated fitness level selection card.
class LevelCard extends StatefulWidget {
  const LevelCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<LevelCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.accentPrimary
                  : AppColors.borderDefault,
              width: widget.isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.accentPrimary.withValues(alpha: 0.15)
                      : AppColors.bgBase,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isSelected
                      ? AppColors.accentPrimary
                      : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: widget.isSelected
                            ? AppColors.accentPrimary
                            : AppColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.description,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Selection indicator
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.isSelected ? 1.0 : 0.0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.bgBase,
                    size: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
