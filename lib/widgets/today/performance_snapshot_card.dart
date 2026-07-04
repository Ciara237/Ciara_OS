import 'package:ciaraos/models/performance_metric_trend.dart';
import 'package:ciaraos/providers/today_providers.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _trendPositive = Color(0xFFA3E635);
const _trendNegative = Color(0xFFF97316);
const _trendNeutral = Color(0xFF64748B);

class PerformanceSnapshotCard extends ConsumerWidget {
  const PerformanceSnapshotCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final snapshotAsync = ref.watch(todayPerformanceProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: snapshotAsync.when(
        loading: () => const _SnapshotGrid.loading(),
        error: (_, _) => const _SnapshotGrid.empty(),
        data: (snapshot) => _SnapshotGrid(snapshot: snapshot),
      ),
    );
  }
}

class _SnapshotGrid extends StatelessWidget {
  const _SnapshotGrid({required this.snapshot}) : loading = false, empty = false;

  const _SnapshotGrid.loading()
      : snapshot = null,
        loading = true,
        empty = false;

  const _SnapshotGrid.empty()
      : snapshot = null,
        loading = false,
        empty = true;

  final TodayPerformanceSnapshot? snapshot;
  final bool loading;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final s = snapshot;
    final mutedIcon = colorScheme.onSurfaceVariant.withValues(alpha: 0.75);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERFORMANCE SNAPSHOT',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.6,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.65,
          children: [
            _MetricTile(
              icon: Icons.check_circle_outline,
              iconColor: mutedIcon,
              label: 'COMPLETED',
              value: loading
                  ? '—'
                  : '${s?.completedToday ?? 0}/${s?.totalToday ?? 0}',
              trend: loading ? null : s?.completedTrend,
            ),
            _MetricTile(
              icon: Icons.timer_outlined,
              iconColor: mutedIcon,
              label: 'UPTIME',
              value: loading
                  ? '—'
                  : formatFocusUptime(s?.focusSeconds ?? 0),
              trend: loading ? null : s?.focusTrend,
            ),
            _MetricTile(
              icon: Icons.bolt_outlined,
              iconColor: mutedIcon,
              label: 'SESSIONS',
              value: loading ? '—' : '${s?.sessionCountToday ?? 0}',
              trend: loading ? null : s?.sessionsTrend,
            ),
            _MetricTile(
              icon: Icons.psychology_outlined,
              iconColor: mutedIcon,
              label: 'QUALITY',
              value: loading
                  ? '—'
                  : formatAverageQuality(s?.averageQualityScore),
              trend: loading ? null : s?.qualityTrend,
            ),
            _MetricTile(
              icon: Icons.gps_fixed_outlined,
              iconColor: mutedIcon,
              label: 'ACCURACY',
              value: loading
                  ? '—'
                  : formatPlanningAccuracy(s?.planningAccuracy),
              trend: loading ? null : s?.accuracyTrend,
            ),
            _MetricTile(
              icon: Icons.local_fire_department_outlined,
              iconColor: mutedIcon,
              label: 'STREAK',
              value: loading ? '—' : '${s?.dailyStreak ?? 0}d',
              trend: loading ? null : s?.streakTrend,
              highlightTrendOnlyWhenPositive: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.trend,
    this.highlightTrendOnlyWhenPositive = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final PerformanceMetricTrend? trend;
  final bool highlightTrendOnlyWhenPositive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trendLabel = trend?.compactLabel() ?? '';
    final showTrend = trendLabel.isNotEmpty;

    Color trendColor = _trendNeutral;
    if (trend != null) {
      if (highlightTrendOnlyWhenPositive) {
        trendColor = trend!.isPositive ? _trendPositive : _trendNeutral;
      } else if (trend!.isPositive) {
        trendColor = _trendPositive;
      } else if (trend!.isNegative) {
        trendColor = _trendNegative;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTypography.headingMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    height: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (showTrend) ...[
                const SizedBox(width: AppSpacing.xs),
                Text(
                  trendLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: trendColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
