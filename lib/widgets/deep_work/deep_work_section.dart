import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/focus_session_provider.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/deep_work_utils.dart';
import 'package:ciaraos/utils/focus_duration_utils.dart';
import 'package:ciaraos/widgets/deep_work/end_session_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DeepWorkSection extends ConsumerWidget {
  const DeepWorkSection({
    super.key,
    required this.task,
    required this.isUpdating,
    required this.onStartPause,
  });

  final Task task;
  final bool isUpdating;
  final VoidCallback onStartPause;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final engineState = ref.watch(focusSessionProvider);
    final isTracking = engineState.isTrackingTask(task.id);
    final liveElapsed =
        isTracking ? engineState.totalElapsedSeconds : 0;
    final isRunning = isTracking && engineState.isRunning;
    final progress = isTracking
        ? engineState.goalProgress
        : (task.totalFocusedSeconds / deepWorkGoalSeconds).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DEEP WORK',
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isUpdating ? null : onStartPause,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Ink(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isRunning
                      ? colorScheme.primary.withValues(alpha: 0.4)
                      : colorScheme.outlineVariant.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        isRunning ? Icons.bolt : Icons.bolt_outlined,
                        color: isRunning
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          isTracking
                              ? (isRunning
                                  ? 'Session active · ${formatFocusClock(liveElapsed)}'
                                  : 'Paused · ${formatFocusClock(liveElapsed)}')
                              : 'Tap to begin deep work',
                          style: AppTypography.bodyMedium.copyWith(
                            color: colorScheme.onSurface,
                            fontFeatures: isTracking
                                ? const [FontFeature.tabularFigures()]
                                : null,
                            decoration: TextDecoration.none,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (isTracking)
                        TextButton(
                          onPressed: isUpdating
                              ? null
                              : () async {
                                  final quality = await showEndSessionDialog(
                                    context,
                                    durationSeconds: liveElapsed,
                                  );
                                  if (quality == null) {
                                    return;
                                  }
                                  await ref
                                      .read(focusSessionProvider.notifier)
                                      .endSession(quality);
                                },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('End'),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: AppSpacing.xs,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _StatRow(
                    label: 'Estimated duration',
                    value: formatEstimatedMinutes(task.estimatedDurationMinutes),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _StatRow(
                    label: 'Total focused time',
                    value: formatDurationMinutes(
                      task.totalFocusedSeconds +
                          (isTracking ? liveElapsed : 0),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _StatRow(
                    label: 'Focus sessions',
                    value: '${task.focusSessionCount}'
                        '${isTracking ? ' (+1 active)' : ''}',
                  ),
                  if (task.lastFocusSessionAt != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _StatRow(
                      label: 'Last session',
                      value: DateFormat('MMM d, HH:mm')
                          .format(task.lastFocusSessionAt!),
                    ),
                  ],
                  if (task.status.name == 'done' &&
                      task.planningAccuracy != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _StatRow(
                      label: 'Planning accuracy',
                      value: formatPlanningAccuracy(task.planningAccuracy),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Flexible(
          flex: 2,
          fit: FlexFit.loose,
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          flex: 1,
          child: Text(
            value,
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
