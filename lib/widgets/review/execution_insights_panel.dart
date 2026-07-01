import 'package:ciaraos/models/execution_insight.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class ExecutionInsightsPanel extends StatelessWidget {
  const ExecutionInsightsPanel({
    super.key,
    required this.insights,
  });

  final List<ExecutionInsight> insights;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXECUTION INSIGHTS',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (insights.isEmpty)
          _InsightTile(
            icon: Icons.insights_outlined,
            iconColor: colorScheme.onSurfaceVariant,
            title: 'Building your profile',
            description:
                'Complete more focused sessions this week to unlock execution insights.',
            colorScheme: colorScheme,
          )
        else
          for (final insight in insights) ...[
            _InsightTile(
              icon: insight.icon,
              iconColor: _iconColor(insight.iconColorKind, colorScheme),
              title: insight.title,
              description: insight.description,
              recommendation: insight.recommendation,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }

  Color _iconColor(InsightIconColorKind kind, ColorScheme colorScheme) {
    return switch (kind) {
      InsightIconColorKind.primary => colorScheme.primary,
      InsightIconColorKind.tertiary => colorScheme.tertiary,
      InsightIconColorKind.secondary => colorScheme.secondary,
    };
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.colorScheme,
    this.recommendation,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String? recommendation;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: AppSpacing.lg),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                if (recommendation != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    recommendation!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
