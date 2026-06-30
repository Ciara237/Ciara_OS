import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class ProductivityIndexCard extends StatelessWidget {
  const ProductivityIndexCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRODUCTIVITY INDEX',
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _MetricRow(
            label: 'THROUGHPUT',
            trailing: '0%',
            child: LinearProgressIndicator(
              value: 0,
              minHeight: AppSpacing.xs,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _MetricRow(
            label: 'VELOCITY',
            trailing: '0.0 pts/d',
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.trailing,
    required this.child,
  });

  final String label;
  final String trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              trailing,
              style: AppTypography.labelLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        if (child is! SizedBox) ...[
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ],
    );
  }
}
