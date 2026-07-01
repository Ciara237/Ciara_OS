import 'package:ciaraos/providers/focus_session_provider.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/focus_duration_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _focusGoalSeconds = 45 * 60;

class DeepFocusBar extends ConsumerWidget {
  const DeepFocusBar({super.key});

  Future<void> _syncStartedFlag(WidgetRef ref, int taskId, bool started) async {
    final task = await ref.read(taskRepositoryProvider).getById(taskId);
    if (task == null || task.started == started) {
      return;
    }

    await ref.read(taskRepositoryProvider).update(
          task
              .copyWith(
                started: started,
                updatedAt: DateTime.now(),
              )
              .toCompanion(),
        );
    ref.invalidate(taskByIdProvider(taskId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final session = ref.watch(focusSessionProvider);
    final isNarrow = MediaQuery.sizeOf(context).width < 480;

    if (!session.isActive) {
      return const SizedBox.shrink();
    }

    final elapsed = session.totalElapsedSeconds;
    final remaining = (_focusGoalSeconds - elapsed).clamp(0, _focusGoalSeconds);
    final remainingLabel = formatFocusClock(remaining);
    final taskAsync = ref.watch(taskByIdProvider(session.taskId!));
    final nextTitle = taskAsync.value?.title;
    final statusLabel = session.isRunning
        ? 'DEEP FOCUS ACTIVE: $remainingLabel REMAINING'
        : 'DEEP FOCUS PAUSED: $remainingLabel REMAINING';

    final pauseButton = OutlinedButton(
      onPressed: () async {
        final focus = ref.read(focusSessionProvider.notifier);
        if (session.isRunning) {
          focus.pause();
          await _syncStartedFlag(ref, session.taskId!, false);
        } else {
          focus.resume();
          await _syncStartedFlag(ref, session.taskId!, true);
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onPrimary,
        side: BorderSide(
          color: colorScheme.onPrimary.withValues(alpha: 0.2),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        session.isRunning ? 'PAUSE SESSION' : 'RESUME SESSION',
        style: AppTypography.labelSmall.copyWith(
          color: colorScheme.onPrimary,
        ),
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _PulsingDot(color: colorScheme.secondary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        statusLabel,
                        style: AppTypography.labelLarge.copyWith(
                          color: colorScheme.onPrimary,
                          letterSpacing: 0.8,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                if (nextTitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Next up: $nextTitle',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Align(alignment: Alignment.centerRight, child: pauseButton),
              ],
            )
          : Row(
              children: [
                _PulsingDot(color: colorScheme.secondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    statusLabel,
                    style: AppTypography.labelLarge.copyWith(
                      color: colorScheme.onPrimary,
                      letterSpacing: 0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (nextTitle != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      'Next up: $nextTitle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: AppSpacing.sm),
                pauseButton,
              ],
            ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: Container(
        width: AppSpacing.sm,
        height: AppSpacing.sm,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
