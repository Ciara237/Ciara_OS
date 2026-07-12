import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/utils/task_filter_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Task row for Today / Backlog lists.
class TaskListTile extends StatelessWidget {
  const TaskListTile({
    super.key,
    required this.task,
    this.onTap,
    this.onLongPress,
    this.onStartedToggle,
    this.showDomainChip = false,
    this.showDeadline = false,
    this.showCheckbox = false,
    this.showStartedButton = true,
    this.onCheckboxTap,
  });

  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onStartedToggle;
  final bool showDomainChip;
  final bool showDeadline;
  final bool showCheckbox;
  final bool showStartedButton;
  final VoidCallback? onCheckboxTap;

  /// Demo task shown on onboarding step 3.
  static Task demoTask() {
    final now = DateTime.now();
    return Task(
      id: 0,
      title: 'System Architecture',
      domain: Domain.engineering,
      status: TaskStatus.inProgress,
      priority: Priority.medium,
      started: true,
      today: false,
      notes: 'Design token integration',
      postponeCount: 0,
      totalFocusedSeconds: 0,
      focusSessionCount: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  String? get _subtitle {
    if (showDomainChip) {
      return null;
    }
    final notes = task.notes?.trim();
    if (notes == null || notes.isEmpty) {
      return null;
    }
    return notes.split('\n').first;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(task.domain);
    final isDone = task.status == TaskStatus.done;
    final minTouchHeight = AppSpacing.minListTileHeight(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.1),
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minTouchHeight),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showCheckbox)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: AppSpacing.md,
                        height: AppSpacing.md,
                        child: Checkbox(
                          value: isDone,
                          onChanged: onCheckboxTap == null
                              ? null
                              : (_) => onCheckboxTap!(),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                      ),
                    ),
                  ),
                Container(
                  width: AppSpacing.taskBorderWidth,
                  decoration: BoxDecoration(
                    color: domainColor,
                    borderRadius: showCheckbox
                        ? BorderRadius.zero
                        : const BorderRadius.horizontal(
                            left: Radius.circular(AppSpacing.radiusMd),
                          ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showDomainChip) ...[
                                Row(
                                  children: [
                                    _DomainChip(
                                      label: domainShortLabel(task.domain),
                                      color: domainColor,
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            AppTypography.bodyLargeResponsive(
                                          context,
                                        ).copyWith(
                                          color: colorScheme.onSurface,
                                          decoration: isDone
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                Text(
                                  task.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      AppTypography.bodyLargeResponsive(
                                        context,
                                      ).copyWith(
                                        color: colorScheme.onSurface,
                                        decoration: isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                ),
                              ],
                              if (_subtitle != null) ...[
                                SizedBox(height: AppSpacing.xs),
                                Text(
                                  _subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      AppTypography.bodyMediumResponsive(
                                        context,
                                      ).copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (showDeadline) ...[
                          SizedBox(width: AppSpacing.sm),
                          _DeadlineBadge(task: task),
                        ],
                        if (showStartedButton) ...[
                          SizedBox(width: AppSpacing.sm),
                          StartedToggleButton(
                            started: task.started,
                            domainColor: domainColor,
                            onPressed: onStartedToggle,
                          ),
                        ],
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
  const _DomainChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmallResponsive(context).copyWith(color: color),
      ),
    );
  }
}

class _DeadlineBadge extends StatelessWidget {
  const _DeadlineBadge({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final display = deadlineDisplayFor(task);

    if (display == TaskDeadlineDisplay.none) {
      return const SizedBox.shrink();
    }

    final text = switch (display) {
      TaskDeadlineDisplay.today => 'TODAY',
      TaskDeadlineDisplay.overdue => 'OVERDUE',
      TaskDeadlineDisplay.date =>
        DateFormat('MMM d').format(task.deadline!).toUpperCase(),
      TaskDeadlineDisplay.none => '',
    };

    final color = display == TaskDeadlineDisplay.overdue
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;

    return Text(
      text,
      style: AppTypography.labelLargeResponsive(context).copyWith(color: color),
    );
  }
}

class StartedToggleButton extends StatelessWidget {
  const StartedToggleButton({
    super.key,
    required this.started,
    required this.domainColor,
    this.onPressed,
  });

  final bool started;
  final Color domainColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonHeight = AppSpacing.buttonHeight(context);
    final iconSize = AppSpacing.iconSize(context);

    if (started) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(
          Icons.play_arrow,
          size: iconSize,
          color: colorScheme.onPrimary,
        ),
        label: Text(
          '▶ STARTED',
          style: AppTypography.labelLargeResponsive(context).copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: domainColor,
          foregroundColor: colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          minimumSize: Size(0, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        Icons.play_arrow,
        size: iconSize,
        color: colorScheme.onSurfaceVariant,
      ),
      label: Text(
        '▶ STARTED',
        style: AppTypography.labelLargeResponsive(context).copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: colorScheme.onSurfaceVariant),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        minimumSize: Size(0, buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),
    );
  }
}