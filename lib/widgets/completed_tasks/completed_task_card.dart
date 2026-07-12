import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompletedTaskCard extends StatelessWidget {
  const CompletedTaskCard({
    super.key,
    required this.task,
    this.projectName,
    this.onTap,
  });

  final Task task;
  final String? projectName;
  final VoidCallback? onTap;

  static const _lowAccuracyThreshold = 85.0;

  String get _contextLine {
    if (projectName != null && projectName!.isNotEmpty) {
      return '$projectName / ${domainShortLabel(task.domain)}';
    }
    return domainLabel(task.domain);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(task.domain);
    final accuracy = task.planningAccuracy;
    final accuracyText = formatPlanningAccuracy(accuracy);
    final lowAccuracy =
        accuracy != null && accuracy < _lowAccuracyThreshold;
    final actual = formatDurationMinutes(task.totalFocusedSeconds);
    final estimated = formatEstimatedMinutes(task.estimatedDurationMinutes);
    final completedAt = DateFormat('HH:mm').format(task.updatedAt);
    final cardPadding = AppSpacing.cardPadding(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.12),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: domainColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: domainColor.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Icon(
                                Icons.check,
                                size: 16,
                                color: domainColor,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: AppTypography.bodyMediumResponsive(context).copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _contextLine,
                                          style: AppTypography.labelSmallResponsive(context)
                                              .copyWith(
                                            color:
                                                colorScheme.onSurfaceVariant,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      _DomainChip(domain: task.domain),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$actual / $estimated',
                                style: AppTypography.monospaceResponsive(context).copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Text(
                              accuracyText,
                              style: AppTypography.monospaceResponsive(context).copyWith(
                                color: lowAccuracy
                                    ? colorScheme.error
                                    : colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${task.focusSessionCount}',
                              style: AppTypography.labelSmallResponsive(context).copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'COMPLETED $completedAt',
                            style: AppTypography.labelSmallResponsive(context).copyWith(
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ],
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
}

class _DomainChip extends StatelessWidget {
  const _DomainChip({required this.domain});

  final Domain domain;

  @override
  Widget build(BuildContext context) {
    final domainColor = context.domainColor(domain);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: domainColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: domainColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        domainLabel(domain),
        style: AppTypography.labelSmall.copyWith(
          color: domainColor,
          fontSize: 9,
        ),
      ),
    );
  }
}
