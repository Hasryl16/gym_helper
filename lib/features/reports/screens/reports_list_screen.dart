import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/session_model.dart';
import '../../../providers/sessions_provider.dart';
import '../../../routing/route_names.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/per_rep_bar_strip.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SessionsProvider>();

    if (provider.isLoading && provider.sessions.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.bgBase,
        body: Center(
            child: CircularProgressIndicator(
                color: AppColors.accentPrimary)),
      );
    }

    if (provider.sessions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bgBase,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bar_chart_outlined,
                      color: AppColors.textTertiary, size: 64),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'REPORTS',
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No sessions yet —\nstart your first workout',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GestureDetector(
                    onTap: () => context.go(RouteNames.workout),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary,
                        borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd),
                      ),
                      child: Text(
                        'START WORKOUT',
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textOnAccent,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Text(
                        'REPORTS',
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.bgElevated,
                          borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill),
                          border:
                              Border.all(color: AppColors.borderDefault),
                        ),
                        child: Text(
                          '${provider.sessions.length} sessions',
                          style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (provider.formScoreTrend.length >= 2)
                    _TrendChartCard(
                      trend: provider.formScoreTrend,
                      improvement: provider.scoreImprovement,
                      avgGoodRate: provider.avgGoodRepRate,
                      totalCount: provider.sessions.length,
                    )
                  else
                    _TrendPlaceholder(
                        sessionCount: provider.sessions.length),
                  const SizedBox(height: AppSpacing.xl),
                  ...provider.sessions.map((s) => _SessionCard(session: s)),
                  const SizedBox(height: AppSpacing.xl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendPlaceholder extends StatelessWidget {
  const _TrendPlaceholder({required this.sessionCount});
  final int sessionCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          const Icon(Icons.show_chart,
              color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 10),
          Text(
            'Complete ${2 - sessionCount} more session${2 - sessionCount == 1 ? '' : 's'} to see trend',
            style: GoogleFonts.dmSans(
                fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TrendChartCard extends StatelessWidget {
  const _TrendChartCard({
    required this.trend,
    required this.improvement,
    required this.avgGoodRate,
    required this.totalCount,
  });

  final List<double> trend;
  final double improvement;
  final double avgGoodRate;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FORM SCORE TREND',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Last ${trend.length}',
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < trend.length; i++)
                        FlSpot(i.toDouble(), trend[i]),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.accentPrimary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, idx) {
                        final isLast = idx == trend.length - 1;
                        return FlDotCirclePainter(
                          radius: 4,
                          color: isLast
                              ? AppColors.bgElevated
                              : AppColors.accentPrimary,
                          strokeWidth: isLast ? 2 : 0,
                          strokeColor: AppColors.accentPrimary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.accentPrimary
                              .withValues(alpha: 0.25),
                          AppColors.accentPrimary
                              .withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData:
                    const LineTouchData(handleBuiltInTouches: false),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _StatChip(
                value: improvement >= 0
                    ? '+${improvement.toStringAsFixed(0)}'
                    : improvement.toStringAsFixed(0),
                label: 'Improvement',
                valueColor: improvement > 0
                    ? AppColors.accentPrimary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatChip(
                value: '${(avgGoodRate * 100).toStringAsFixed(0)}%',
                label: 'Good reps',
                valueColor: AppColors.accentCyan,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatChip(
                value: '$totalCount',
                label: 'Sessions',
                valueColor: AppColors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.value,
      required this.label,
      required this.valueColor});
  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.bgBase,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Column(
          children: [
            Text(
                value,
                style: GoogleFonts.barlowCondensed(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 10, color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});
  final SessionModel session;

  Color _scoreColor(double s) {
    if (s >= 80) return AppColors.accentPrimary;
    if (s >= 60) return AppColors.accentCyan;
    return AppColors.warning;
  }

  String _formatDuration(Duration d) =>
      '${d.inMinutes}m ${(d.inSeconds % 60).toString().padLeft(2, '0')}s';

  @override
  Widget build(BuildContext context) {
    final scoreColor = _scoreColor(session.formScore);
    final dateStr = DateFormat('MMM d').format(session.startedAt);
    final timeStr = DateFormat('h:mm a').format(session.startedAt);
    final durationStr = _formatDuration(session.duration);

    return GestureDetector(
      onTap: () =>
          context.push(RouteNames.reportDetailFor(session.sessionId)),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(session.exerciseType.icon,
                    color: AppColors.accentPrimary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.exerciseType.shortName,
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$dateStr · $timeStr · $durationStr',
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  session.formScore.toStringAsFixed(0),
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            PerRepBarStrip(
              reps: session.reps,
              fallbackScore: session.formScore,
              maxBars: 20,
            ),
            const SizedBox(height: AppSpacing.md),
            _StatusBadge(reportStatus: session.reportStatus),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.reportStatus});
  final String reportStatus;

  @override
  Widget build(BuildContext context) {
    switch (reportStatus) {
      case 'ready':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _AnimatedLimeDot(),
            const SizedBox(width: 6),
            Text(
              'AI REPORT READY',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.accentPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      case 'failed':
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(color: AppColors.error),
          ),
          child: Text(
            'RETRY',
            style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.error,
                fontWeight: FontWeight.w600),
          ),
        );
      default: // pending
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: AppColors.textTertiary),
            ),
            const SizedBox(width: 6),
            Text(
              'Generating...',
              style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppColors.textTertiary),
            ),
          ],
        );
    }
  }
}

class _AnimatedLimeDot extends StatefulWidget {
  const _AnimatedLimeDot();

  @override
  State<_AnimatedLimeDot> createState() => _AnimatedLimeDotState();
}

class _AnimatedLimeDotState extends State<_AnimatedLimeDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.accentPrimary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
