import 'package:ciaraos/models/enums/opportunity_status.dart';
import 'package:ciaraos/models/enums/opportunity_type.dart';
import 'package:ciaraos/models/opportunity.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Pipeline status colors — card left bar, group header dots, and indicators.
abstract final class _OpportunityStatusColors {
  static const Color researching = Color(0xFFF59E0B);
  static const Color applying = Color(0xFF3B82F6);
  static const Color submitted = Color(0xFF8B5CF6);
  static const Color interviewing = Color(0xFF10B981);
  static const Color offer = Color(0xFF22C55E);
  static const Color rejected = Color(0xFF64748B);
  static const Color closed = Color(0xFF44474C);
}

/// Deadline urgency amber — intentionally same as researching status color.
abstract final class _OpportunityDeadlineColors {
  static const Color dueSoon = _OpportunityStatusColors.researching;
  static const Color docsComplete = Color(0xFF10B981);
}

Color opportunityStatusColor(OpportunityStatus status) {
  return switch (status) {
    OpportunityStatus.researching => _OpportunityStatusColors.researching,
    OpportunityStatus.applying => _OpportunityStatusColors.applying,
    OpportunityStatus.submitted => _OpportunityStatusColors.submitted,
    OpportunityStatus.interviewing => _OpportunityStatusColors.interviewing,
    OpportunityStatus.offer => _OpportunityStatusColors.offer,
    OpportunityStatus.rejected => _OpportunityStatusColors.rejected,
    OpportunityStatus.closed => _OpportunityStatusColors.closed,
  };
}

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.onTap,
    this.onLongPress,
  });

  final Opportunity opportunity;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  static String _typeLabel(OpportunityType type) {
    return switch (type) {
      OpportunityType.job => 'Job',
      OpportunityType.internship => 'Internship',
      OpportunityType.fellowship => 'Fellowship',
      OpportunityType.program => 'Program',
      OpportunityType.masters => 'Masters',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = opportunityStatusColor(opportunity.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: AppSpacing.taskBorderWidth,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(AppSpacing.radiusMd),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                    right: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            opportunity.title,
                            style: AppTypography.headingMedium.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _TypeTagChip(label: _typeLabel(opportunity.type)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      opportunity.organization,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (opportunity.deadline != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _DeadlineIndicator(deadline: opportunity.deadline!),
                    ],
                    if (opportunity.documentsTotal > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _DocumentsIndicator(
                        ready: opportunity.documentsReady,
                        total: opportunity.documentsTotal,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeTagChip extends StatelessWidget {
  const _TypeTagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: colorScheme.onSurfaceVariant),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

enum _DeadlineKind { future, dueSoon, dueToday, overdue }

class _DeadlineIndicator extends StatelessWidget {
  const _DeadlineIndicator({required this.deadline});

  final DateTime deadline;

  _DeadlineKind get _kind {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(deadline.year, deadline.month, deadline.day);
    final daysUntil = due.difference(today).inDays;

    if (daysUntil < 0) {
      return _DeadlineKind.overdue;
    }
    if (daysUntil == 0) {
      return _DeadlineKind.dueToday;
    }
    if (daysUntil <= 2) {
      return _DeadlineKind.dueSoon;
    }
    return _DeadlineKind.future;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final kind = _kind;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(deadline.year, deadline.month, deadline.day);
    final daysUntil = due.difference(today).inDays;

    final Color color;
    final IconData icon;
    final String label;

    switch (kind) {
      case _DeadlineKind.future:
        color = colorScheme.onSurfaceVariant;
        icon = Icons.calendar_today;
        label = DateFormat('MMM d').format(deadline).toUpperCase();
      case _DeadlineKind.dueSoon:
        color = _OpportunityDeadlineColors.dueSoon;
        icon = Icons.bolt;
        label = 'DUE IN ${daysUntil}D';
      case _DeadlineKind.dueToday:
        color = colorScheme.error;
        icon = Icons.bolt;
        label = 'DUE TODAY';
      case _DeadlineKind.overdue:
        color = colorScheme.error;
        icon = Icons.schedule;
        label = 'OVERDUE';
    }

    return Row(
      children: [
        Icon(icon, size: AppSpacing.md, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }
}

class _DocumentsIndicator extends StatelessWidget {
  const _DocumentsIndicator({
    required this.ready,
    required this.total,
  });

  final int ready;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color color;
    if (ready == total) {
      color = _OpportunityDeadlineColors.docsComplete;
    } else if (ready > 0) {
      color = _OpportunityDeadlineColors.dueSoon;
    } else {
      color = colorScheme.onSurfaceVariant;
    }

    return Row(
      children: [
        Icon(Icons.check_circle_outline, size: AppSpacing.md, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$ready / $total docs ready',
          style: AppTypography.bodyMedium.copyWith(color: color),
        ),
      ],
    );
  }
}
