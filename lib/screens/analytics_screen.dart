import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:project/theme.dart';
import 'package:project/components/responsive_layout.dart';
import 'package:project/providers/verification_provider.dart';
import 'package:project/models/verification.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  String _selectedPeriod = '7d';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Analytics Dashboard'),
        actions: [
          // Period selector
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PeriodTab(
                  label: '7D',
                  isActive: _selectedPeriod == '7d',
                  onTap: () => setState(() => _selectedPeriod = '7d'),
                ),
                _PeriodTab(
                  label: '30D',
                  isActive: _selectedPeriod == '30d',
                  onTap: () => setState(() => _selectedPeriod = '30d'),
                ),
                _PeriodTab(
                  label: '90D',
                  isActive: _selectedPeriod == '90d',
                  onTap: () => setState(() => _selectedPeriod = '90d'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<VerificationProvider>(
        builder: (context, provider, _) {
          final stats = provider.stats;
          final verifications = provider.verifications;
          final certificates = provider.certificates;

          return Stack(
            children: [
              // Animated background
              _AnimatedBackground(controller: _pulseController),

              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ContentContainer(
                  maxWidth: 1200,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header stats
                      _HeaderStats(
                        stats: stats,
                        pulseController: _pulseController,
                      ),
                      const SizedBox(height: 32),

                      // Charts row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 700;
                          return isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _VerificationTrendChart(
                                        verifications: verifications,
                                        period: _selectedPeriod,
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: _StatusDistributionChart(
                                        verifications: verifications,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _VerificationTrendChart(
                                      verifications: verifications,
                                      period: _selectedPeriod,
                                    ),
                                    const SizedBox(height: 24),
                                    _StatusDistributionChart(
                                      verifications: verifications,
                                    ),
                                  ],
                                );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Trust Score Distribution
                      _TrustScoreDistribution(),
                      const SizedBox(height: 24),

                      // Document type breakdown
                      _DocumentTypeBreakdown(),
                      const SizedBox(height: 24),

                      // Blockchain activity
                      _BlockchainActivityCard(
                        verifications: verifications,
                        certificates: certificates,
                      ),
                      const SizedBox(height: 24),

                      // Recent activity table
                      _RecentActivityTable(
                        verifications: verifications,
                        provider: provider,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.cyberPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(progress: controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double progress;

  _BackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.cyberPurple.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.9, size.height * 0.1),
          radius: 300 + 50 * progress,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.1),
      300 + 50 * progress,
      paint,
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _HeaderStats extends StatelessWidget {
  final Map<String, int> stats;
  final AnimationController pulseController;

  const _HeaderStats({required this.stats, required this.pulseController});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final items = [
          _StatData(
            icon: Icons.people_outline_rounded,
            label: 'Total Tenants',
            value: stats['totalTenants'] ?? 0,
            trend: '+12%',
            trendUp: true,
            color: AppColors.electricBlue,
          ),
          _StatData(
            icon: Icons.verified_rounded,
            label: 'Verified',
            value: stats['verified'] ?? 0,
            trend: '+8%',
            trendUp: true,
            color: AppColors.neonGreen,
          ),
          _StatData(
            icon: Icons.schedule_rounded,
            label: 'Pending',
            value: stats['pending'] ?? 0,
            trend: '-3%',
            trendUp: false,
            color: AppColors.warning,
          ),
          _StatData(
            icon: Icons.workspace_premium_rounded,
            label: 'Certificates',
            value: stats['certificates'] ?? 0,
            trend: '+15%',
            trendUp: true,
            color: AppColors.cyberPurple,
          ),
        ];

        if (isCompact) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items
                .map((item) => SizedBox(
                      width: (constraints.maxWidth - 12) / 2,
                      child: _StatCard(data: item, compact: true),
                    ))
                .toList(),
          );
        }

        return Row(
          children: items
              .map((item) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: items.indexOf(item) < items.length - 1 ? 16 : 0,
                      ),
                      child: _StatCard(data: item),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final int value;
  final String trend;
  final bool trendUp;
  final Color color;

  _StatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  final bool compact;

  const _StatCard({required this.data, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 36 : 44,
                height: compact ? 36 : 44,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child:
                    Icon(data.icon, color: data.color, size: compact ? 18 : 22),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: data.trendUp
                      ? AppColors.neonGreen.withValues(alpha: 0.15)
                      : AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      data.trendUp
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 12,
                      color: data.trendUp ? AppColors.neonGreen : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.trend,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color:
                            data.trendUp ? AppColors.neonGreen : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 12 : 16),
          Text(
            data.value.toString(),
            style: (compact ? textTheme.headlineSmall : textTheme.headlineMedium)
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _VerificationTrendChart extends StatelessWidget {
  final List<Verification> verifications;
  final String period;

  const _VerificationTrendChart({
    required this.verifications,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Generate mock trend data
    final days = period == '7d' ? 7 : period == '30d' ? 30 : 90;
    final spots = List.generate(days, (i) {
      final base = 2.0;
      final variation = math.sin(i * 0.5) * 1.5 + math.Random(i).nextDouble();
      return FlSpot(i.toDouble(), (base + variation).clamp(0, 5));
    });

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.show_chart_rounded,
                    color: AppColors.electricBlue, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                'VERIFICATION TREND',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.electricBlue,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.cardBorder,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: days / 7,
                      getTitlesWidget: (value, meta) {
                        if (value % (days / 7) != 0) return const SizedBox();
                        return Text(
                          'D${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.neonGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.neonGreen.withValues(alpha: 0.3),
                          AppColors.neonGreen.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDistributionChart extends StatelessWidget {
  final List<Verification> verifications;

  const _StatusDistributionChart({required this.verifications});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final verified =
        verifications.where((v) => v.status == VerificationStatus.verified).length;
    final pending =
        verifications.where((v) => v.status == VerificationStatus.pending).length;
    final failed =
        verifications.where((v) => v.status == VerificationStatus.failed).length;
    final total = verifications.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cyberPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.pie_chart_rounded,
                    color: AppColors.cyberPurple, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                'STATUS',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.cyberPurple,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: verified.toDouble(),
                    title: '',
                    color: AppColors.neonGreen,
                    radius: 25,
                  ),
                  PieChartSectionData(
                    value: pending.toDouble(),
                    title: '',
                    color: AppColors.warning,
                    radius: 25,
                  ),
                  PieChartSectionData(
                    value: failed.toDouble().clamp(0.5, double.infinity),
                    title: '',
                    color: AppColors.error,
                    radius: 25,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _LegendItem(
            color: AppColors.neonGreen,
            label: 'Verified',
            value: '$verified',
            percentage:
                total > 0 ? '${(verified / total * 100).toStringAsFixed(0)}%' : '0%',
          ),
          const SizedBox(height: 8),
          _LegendItem(
            color: AppColors.warning,
            label: 'Pending',
            value: '$pending',
            percentage:
                total > 0 ? '${(pending / total * 100).toStringAsFixed(0)}%' : '0%',
          ),
          const SizedBox(height: 8),
          _LegendItem(
            color: AppColors.error,
            label: 'Failed',
            value: '$failed',
            percentage:
                total > 0 ? '${(failed / total * 100).toStringAsFixed(0)}%' : '0%',
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final String percentage;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(width: 8),
        Text(percentage,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}

class _TrustScoreDistribution extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Mock trust score distribution
    final scores = [
      {'range': '90-100', 'count': 12, 'color': AppColors.neonGreen},
      {'range': '80-89', 'count': 8, 'color': AppColors.electricBlue},
      {'range': '70-79', 'count': 3, 'color': AppColors.warning},
      {'range': '60-69', 'count': 1, 'color': AppColors.error},
    ];

    final maxCount = 12;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.score_rounded,
                    color: AppColors.neonGreen, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                'TRUST SCORE DISTRIBUTION',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.neonGreen,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...scores.map((score) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            score['range'] as String,
                            style: textTheme.labelMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor:
                                    (score['count'] as int) / maxCount,
                                child: Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: score['color'] as Color,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (score['color'] as Color)
                                            .withValues(alpha: 0.4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${score['count']}',
                            style: textTheme.titleSmall?.semiBold,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _DocumentTypeBreakdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final docTypes = [
      {'type': 'Aadhaar Card', 'count': 24, 'icon': Icons.badge_outlined},
      {'type': 'PAN Card', 'count': 24, 'icon': Icons.credit_card_outlined},
      {'type': 'Employment', 'count': 18, 'icon': Icons.work_outline_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.folder_outlined,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                'DOCUMENT TYPES VERIFIED',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.warning,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: docTypes
                .map((doc) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                            right: docTypes.indexOf(doc) < docTypes.length - 1
                                ? 12
                                : 0),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Column(
                          children: [
                            Icon(doc['icon'] as IconData,
                                color: AppColors.textSecondary, size: 28),
                            const SizedBox(height: 12),
                            Text(
                              '${doc['count']}',
                              style: textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doc['type'] as String,
                              style: textTheme.labelSmall
                                  ?.copyWith(color: AppColors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _BlockchainActivityCard extends StatelessWidget {
  final List<Verification> verifications;
  final List certificates;

  const _BlockchainActivityCard({
    required this.verifications,
    required this.certificates,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonGreen.withValues(alpha: 0.1),
            AppColors.electricBlue.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.neonGreen,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.link_rounded,
                    color: AppColors.background, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                'BLOCKCHAIN ACTIVITY',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.neonGreen,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: AppColors.neonGreen),
                    SizedBox(width: 6),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neonGreen,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _BlockchainStat(
                  label: 'Total Transactions',
                  value: '${verifications.where((v) => v.transactionHash != null).length}',
                  icon: Icons.receipt_long_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _BlockchainStat(
                  label: 'Certificates Minted',
                  value: '${certificates.length}',
                  icon: Icons.workspace_premium_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _BlockchainStat(
                  label: 'Network',
                  value: 'Polygon',
                  icon: Icons.language_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlockchainStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _BlockchainStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textMuted, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityTable extends StatelessWidget {
  final List<Verification> verifications;
  final VerificationProvider provider;

  const _RecentActivityTable({
    required this.verifications,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('MMM dd, HH:mm');

    // Sort by most recent
    final sorted = List<Verification>.from(verifications)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recent = sorted.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.history_rounded,
                    color: AppColors.electricBlue, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                'RECENT ACTIVITY',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.electricBlue,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...recent.map((v) {
            final tenant = provider.getTenantById(v.tenantId);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusColor(v.status).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(v.status),
                      color: _getStatusColor(v.status),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenant?.name ?? 'Unknown',
                          style: textTheme.titleSmall?.semiBold,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateFormat.format(v.createdAt),
                          style: textTheme.labelSmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(v.status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Text(
                      v.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(v.status),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return AppColors.neonGreen;
      case VerificationStatus.pending:
        return AppColors.warning;
      case VerificationStatus.processing:
        return AppColors.electricBlue;
      case VerificationStatus.failed:
        return AppColors.error;
      case VerificationStatus.revoked:
        return AppColors.textMuted;
    }
  }

  IconData _getStatusIcon(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return Icons.verified_rounded;
      case VerificationStatus.pending:
        return Icons.schedule_rounded;
      case VerificationStatus.processing:
        return Icons.sync_rounded;
      case VerificationStatus.failed:
        return Icons.error_outline_rounded;
      case VerificationStatus.revoked:
        return Icons.block_rounded;
    }
  }
}
