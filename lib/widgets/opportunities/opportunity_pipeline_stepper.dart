import 'package:ciaraos/models/enums/opportunity_status.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/opportunity_utils.dart';
import 'package:flutter/material.dart';

class OpportunityPipelineStepper extends StatelessWidget {
  const OpportunityPipelineStepper({
    super.key,
    required this.currentStatus,
    this.onStageSelected,
    this.showHeader = true,
  });

  final OpportunityStatus currentStatus;
  final ValueChanged<OpportunityStatus>? onStageSelected;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = opportunityStatusColor(currentStatus);
    final currentIndex = activeOpportunityPipeline.indexOf(currentStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Text(
              'PIPELINE STATUS',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Row(
            children: [
              for (var i = 0; i < activeOpportunityPipeline.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _segmentColor(
                        index: i - 1,
                        currentIndex: currentIndex,
                        statusColor: statusColor,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ),
                _StageDot(
                  label: opportunityStatusStepLabel(activeOpportunityPipeline[i]),
                  isPast: currentIndex != -1 && i < currentIndex,
                  isCurrent: i == currentIndex,
                  isFuture: currentIndex == -1 || i > currentIndex,
                  statusColor: statusColor,
                  onTap: onStageSelected == null
                      ? null
                      : () => onStageSelected!(activeOpportunityPipeline[i]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _segmentColor({
    required int index,
    required int currentIndex,
    required Color statusColor,
    required ColorScheme colorScheme,
  }) {
    if (currentIndex == -1) {
      return colorScheme.outlineVariant;
    }
    return index < currentIndex ? statusColor : colorScheme.outlineVariant;
  }
}

class _StageDot extends StatelessWidget {
  const _StageDot({
    required this.label,
    required this.isPast,
    required this.isCurrent,
    required this.isFuture,
    required this.statusColor,
    this.onTap,
  });

  final String label;
  final bool isPast;
  final bool isCurrent;
  final bool isFuture;
  final Color statusColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dotSize = isCurrent ? 14.0 : 10.0;
    final dotColor = isCurrent || isPast
        ? statusColor.withValues(alpha: isPast ? 0.55 : 1)
        : Colors.transparent;

    return SizedBox(
      width: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Column(
            children: [
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: isFuture ? Colors.transparent : dotColor,
                  shape: BoxShape.circle,
                  border: isFuture
                      ? Border.all(
                          color: colorScheme.onSurfaceVariant,
                          width: 1.5,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTypography.labelSmall.copyWith(
                  color: isCurrent
                      ? statusColor
                      : colorScheme.onSurfaceVariant.withValues(
                          alpha: isPast ? 0.7 : 1,
                        ),
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
