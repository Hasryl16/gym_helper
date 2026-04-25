import 'package:flutter/material.dart';
import '../../core/models/rep_data.dart';
import '../theme/app_colors.dart';

class PerRepBarStrip extends StatelessWidget {
  const PerRepBarStrip({
    super.key,
    required this.reps,
    required this.fallbackScore,
    this.maxBars = 20,
    this.maxHeight = 28.0,
  });

  final List<RepData> reps;
  final double fallbackScore;
  final int maxBars;
  final double maxHeight;

  Color _barColor(double score) {
    if (score >= 80) return AppColors.accentPrimary;
    if (score >= 60) return AppColors.accentCyan;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    if (reps.isEmpty) {
      return Container(
        height: maxHeight,
        decoration: BoxDecoration(
          color: _barColor(fallbackScore),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    final displayReps = reps.take(maxBars).toList();
    final overflow = reps.length - maxBars;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < displayReps.length; i++) ...[
                if (i > 0) const SizedBox(width: 2),
                Expanded(
                  child: Container(
                    height: (displayReps[i].formScore / 100 * maxHeight)
                        .clamp(4.0, maxHeight),
                    decoration: BoxDecoration(
                      color: _barColor(displayReps[i].formScore),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (overflow > 0) ...[
          const SizedBox(width: 6),
          Text(
            '+$overflow',
            style: const TextStyle(
                fontSize: 10, color: AppColors.textTertiary),
          ),
        ],
      ],
    );
  }
}
