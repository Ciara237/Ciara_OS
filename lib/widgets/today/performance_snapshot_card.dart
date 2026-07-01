import 'package:ciaraos/providers/today_providers.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: snapshotAsync.when(
        loading: () => _SnapshotBody(
          completedLabel: '— / —',
          focusLabel: '—',
          streakLabel: '—',
        ),
        error: (_, _) => _SnapshotBody(
          completedLabel: '0 / 0',
          focusLabel: '0h',
          streakLabel: '0 days',
        ),
        data: (snapshot) => _SnapshotBody(
          completedLabel:
              '${snapshot.completedToday} / ${snapshot.totalToday}',
          focusLabel: formatFocusUptime(snapshot.focusSeconds),
          streakLabel:
              '${snapshot.dailyStreak} ${snapshot.dailyStreak == 1 ? 'day' : 'days'}',
        ),
      ),
    );
  }
}

class _SnapshotBody extends StatelessWidget {
  const _SnapshotBody({
    required this.completedLabel,
    required this.focusLabel,
    required this.streakLabel,
  });

  final String completedLabel;
  final String focusLabel;
  final String streakLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERFORMANCE SNAPSHOT',
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SnapshotRow(label: 'Completed today', value: completedLabel),
        const SizedBox(height: AppSpacing.md),
        _SnapshotRow(label: 'Focus uptime', value: focusLabel),
        const SizedBox(height: AppSpacing.md),
        _SnapshotRow(label: 'Daily Streaks', value: streakLabel),
      ],
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
