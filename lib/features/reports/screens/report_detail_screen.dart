import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/report_model.dart';
import '../../../core/models/session_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/gemini_report_service.dart';
import '../../../providers/user_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key, required this.sessionId});
  final String sessionId;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final _firestore = FirestoreService();
  StreamSubscription<SessionModel?>? _sessionSub;
  StreamSubscription<ReportModel?>? _reportSub;
  SessionModel? _session;
  ReportModel? _report;
  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    _sessionSub = _firestore.watchSession(widget.sessionId).listen((s) {
      if (mounted) setState(() => _session = s);
    });
    _reportSub = _firestore.watchReport(widget.sessionId).listen((r) {
      if (mounted) setState(() => _report = r);
    });
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _reportSub?.cancel();
    super.dispose();
  }

  Color _scoreColor(double s) {
    if (s >= 80) return AppColors.accentPrimary;
    if (s >= 60) return AppColors.accentCyan;
    return AppColors.warning;
  }

  Color _barColor(double s) {
    if (s >= 80) return AppColors.accentPrimary;
    if (s >= 60) return AppColors.accentCyan;
    if (s >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String _ratingLabel(double s) {
    if (s >= 80) return 'GREAT';
    if (s >= 60) return 'GOOD';
    return 'NEEDS WORK';
  }

  String _formatDuration(Duration d) =>
      '${d.inMinutes}m ${(d.inSeconds % 60).toString().padLeft(2, '0')}s';

  Future<void> _retry() async {
    final session = _session;
    if (session == null) return;
    setState(() => _retrying = true);
    try {
      final level = context.read<UserProvider>().user?.fitnessLevel
          ?? FitnessLevel.beginner;
      await GeminiReportService().generateReport(session, level);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Retry failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'SESSION REPORT',
          style: GoogleFonts.barlowCondensed(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: _session == null
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.accentPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScoreHero(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildAiSection(),
                  if (_session!.reps.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _buildRepChart(),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }

  Widget _buildScoreHero() {
    final s = _session!;
    final scoreColor = _scoreColor(s.formScore);
    final ratingLabel = _ratingLabel(s.formScore);
    final goodPct =
        s.totalReps > 0 ? (s.goodReps / s.totalReps * 100).round() : 0;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.bgBase,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(s.exerciseType.icon,
                    color: AppColors.accentPrimary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.exerciseType.shortName,
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${DateFormat('MMM d, h:mm a').format(s.startedAt)} · ${_formatDuration(s.duration)}',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                s.formScore.toStringAsFixed(0),
                style: GoogleFonts.barlowCondensed(
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  color: scoreColor,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: scoreColor),
            ),
            child: Text(
              ratingLabel,
              style: GoogleFonts.barlowCondensed(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: scoreColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _HeroChip(value: '${s.totalReps}', label: 'Reps'),
              const SizedBox(width: AppSpacing.sm),
              _HeroChip(value: '${s.goodReps}', label: 'Good'),
              const SizedBox(width: AppSpacing.sm),
              _HeroChip(value: '$goodPct%', label: 'Rate'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiSection() {
    switch (_session!.reportStatus) {
      case 'ready':
        if (_report == null) {
          return const _ShimmerPlaceholder();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_report!.summary.isNotEmpty) ...[
              Text(
                _report!.summary,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (_report!.strengths.isNotEmpty)
              _AiCard(
                emoji: '✨',
                title: "WHAT YOU'RE DOING WELL",
                titleColor: AppColors.accentPrimary,
                items: _report!.strengths,
                itemIcon: Icons.check_circle_outline,
                itemColor: AppColors.accentPrimary,
              ),
            if (_report!.improvements.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _AiCard(
                emoji: '🎯',
                title: 'WHAT TO IMPROVE',
                titleColor: AppColors.accentCyan,
                items: _report!.improvements,
                itemIcon: Icons.radio_button_unchecked,
                itemColor: AppColors.accentCyan,
              ),
            ],
            if (_report!.nextSessionGoal.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusLg),
                  border: const Border(
                    left: BorderSide(
                        color: AppColors.accentPrimary, width: 3),
                    top: BorderSide(color: AppColors.borderDefault),
                    right: BorderSide(color: AppColors.borderDefault),
                    bottom: BorderSide(color: AppColors.borderDefault),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🚀 NEXT SESSION GOAL',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.accentPrimary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _report!.nextSessionGoal,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );

      case 'failed':
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.error),
          ),
          child: Column(
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 36),
              const SizedBox(height: AppSpacing.md),
              Text('Report Unavailable',
                  style: GoogleFonts.barlowCondensed(
                      fontSize: 20,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.sm),
              Text('AI report generation failed',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.lg),
              GestureDetector(
                onTap: _retrying ? null : _retry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: _retrying
                        ? AppColors.bgBase
                        : AppColors.accentPrimary,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Text(
                    _retrying ? 'Retrying...' : 'RETRY',
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _retrying
                          ? AppColors.textSecondary
                          : AppColors.textOnAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      default: // pending
        return const _ShimmerPlaceholder();
    }
  }

  Widget _buildRepChart() {
    final reps = _session!.reps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PER-REP FORM',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: AppColors.textTertiary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceBetween,
                    maxY: 100,
                    minY: 0,
                    barGroups: [
                      for (int i = 0; i < reps.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: reps[i].formScore,
                              color: _barColor(reps[i].formScore),
                              width: 8,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ],
                        ),
                    ],
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 20,
                          getTitlesWidget: (val, meta) {
                            final idx = val.toInt();
                            if (idx % 5 != 0 &&
                                idx != reps.length - 1) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textTertiary),
                            );
                          },
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(enabled: false),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const _LegendDot(color: AppColors.accentPrimary),
                  const SizedBox(width: 4),
                  Text('Great',
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                  const SizedBox(width: 16),
                  const _LegendDot(color: AppColors.accentCyan),
                  const SizedBox(width: 4),
                  Text('Good',
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                  const SizedBox(width: 16),
                  const _LegendDot(color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text('Needs work',
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.value, required this.label});
  final String value;
  final String label;

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
            Text(value,
                style: GoogleFonts.barlowCondensed(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 10, color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}

class _AiCard extends StatelessWidget {
  const _AiCard({
    required this.emoji,
    required this.title,
    required this.titleColor,
    required this.items,
    required this.itemIcon,
    required this.itemColor,
  });
  final String emoji;
  final String title;
  final Color titleColor;
  final List<String> items;
  final IconData itemIcon;
  final Color itemColor;

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
          Text(
            '$emoji $title',
            style: GoogleFonts.dmSans(
                fontSize: 11, color: titleColor, letterSpacing: 1.0),
          ),
          const SizedBox(height: AppSpacing.md),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(itemIcon, color: itemColor, size: 16),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(item,
                          style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              height: 1.4)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  const _ShimmerPlaceholder();

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _fade = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generating your AI report...',
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (int i = 0; i < 3; i++) ...[
              Container(
                height: 16,
                width: i == 2 ? 160 : double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.bgBase,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
