import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Inline empty state for a single analytics/skills section — keeps the
/// section header visible and explains what populates the data.
class InlineSectionEmptyState extends StatelessWidget {
  const InlineSectionEmptyState({
    super.key,
    required this.message,
    this.title,
    this.actionHint,
    this.progressCurrent,
    this.progressMax,
    this.progressUnit,
    this.icon = Icons.lock_outline,
    this.compact = false,
  });

  final String? title;
  final String message;
  final String? actionHint;
  final int? progressCurrent;
  final int? progressMax;
  final String? progressUnit;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final showProgress =
        progressCurrent != null && progressMax != null && progressMax! > 0;
    final progress = showProgress
        ? (progressCurrent! / progressMax!).clamp(0.0, 1.0)
        : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: compact ? 28 : 36,
            color: colorScheme.outline,
          ),
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: AppTypography.labelLargeResponsive(context).copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMediumResponsive(context).copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          if (actionHint != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              actionHint!,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmallResponsive(context).copyWith(
                color: colorScheme.primary,
              ),
            ),
          ],
          if (showProgress) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: AppTypography.labelSmallResponsive(context).copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  progressUnit == null
                      ? '$progressCurrent / $progressMax'
                      : '$progressCurrent / $progressMax $progressUnit',
                  style: AppTypography.labelSmallResponsive(context).copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Flat dashed chart placeholder used when a section has no trend data yet.
class ChartPlaceholder extends StatelessWidget {
  const ChartPlaceholder({
    super.key,
    this.overlayLabel = 'Awaiting execution data…',
    this.height = 160,
  });

  final String overlayLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _FlatLinePainter(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          Text(
            overlayLabel.toUpperCase(),
            style: AppTypography.labelSmallResponsive(context).copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FlatLinePainter extends CustomPainter {
  const _FlatLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final baseline = Paint()
      ..color = color
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      baseline,
    );

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    var x = 0.0;
    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height * 0.5),
        Offset(x + dashWidth, size.height * 0.5),
        dashPaint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _FlatLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Subtle note shown below charts while building toward the data threshold.
class TrendBuildingNote extends StatelessWidget {
  const TrendBuildingNote({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        message,
        style: AppTypography.labelSmallResponsive(context).copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}