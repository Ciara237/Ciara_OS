import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/daily_stats_providers.dart';
import 'package:ciaraos/providers/focus_session_provider.dart';
import 'package:ciaraos/services/task_completion_service.dart';
import 'package:ciaraos/services/daily_activity_stats.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/widgets/deep_work/deep_work_section.dart';
import 'package:ciaraos/widgets/deep_work/end_session_dialog.dart';
import 'package:ciaraos/widgets/navigation/minimal_back_header.dart';
import 'package:ciaraos/utils/opportunity_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

const _cardMaxWidth = 672.0;
const _wideBreakpoint = 768.0;
const _cardRadius = 12.0;

/// Tight icon control — avoids default 48px [IconButton] min width overflow.
class _DetailCompactIconButton extends StatelessWidget {
  const _DetailCompactIconButton({
    required this.onPressed,
    required this.icon,
    required this.color,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(
        minWidth: AppSpacing.xl,
        minHeight: AppSpacing.xl,
      ),
      icon: Icon(icon, size: AppSpacing.lg, color: color),
    );
  }
}

class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  bool _isEditingNotes = false;
  bool _isUpdating = false;
  bool? _optimisticStarted;
  late final TextEditingController _notesController;

  int get _id => int.parse(widget.taskId);

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _persistTask(Task task) async {
    await ref.read(taskRepositoryProvider).update(
          task.copyWith(updatedAt: DateTime.now()).toCompanion(),
        );
    ref.invalidate(taskByIdProvider(_id));
  }

  bool _displayStarted(Task task) => _optimisticStarted ?? task.started;

  Future<void> _setStarted(Task task, bool started) async {
    if (_isUpdating || _displayStarted(task) == started) {
      return;
    }

    final focus = ref.read(focusSessionProvider.notifier);
    if (started) {
      await focus.startForTask(task.id);
    } else if (ref.read(focusSessionProvider).isTrackingTask(task.id)) {
      await focus.pause();
    }

    setState(() {
      _optimisticStarted = started;
      _isUpdating = true;
    });

    try {
      await _persistTask(task.copyWith(started: started));
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
          _optimisticStarted = null;
        });
      }
    }
  }

  Future<void> _pauseTask(Task task) async {
    await _setStarted(task, false);
  }

  Future<void> _toggleFocusTimer(Task task) async {
    final session = ref.read(focusSessionProvider);
    if (session.isTrackingTask(task.id) && session.isRunning) {
      await _setStarted(task, false);
      return;
    }
    if (session.isTrackingTask(task.id) && !session.isRunning) {
      await _setStarted(task, true);
      return;
    }
    await _setStarted(task, true);
  }

  Future<void> _markComplete(Task task) async {
    if (_isUpdating || task.status == TaskStatus.done) {
      return;
    }

    final engine = ref.read(focusSessionProvider.notifier);
    if (ref.read(focusSessionProvider).isTrackingTask(task.id)) {
      final quality = await showEndSessionDialog(
        context,
        durationSeconds:
            ref.read(focusSessionProvider).totalElapsedSeconds,
      );
      if (quality == null || !mounted) {
        return;
      }
      await engine.endSession(quality);
    }

    setState(() => _isUpdating = true);
    try {
      await markTaskDone(ref, task);
      await DailyActivityStats.recordActiveDay();
      ref.read(dailyStatsRevisionProvider.notifier).state++;
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _toggleToday(Task task) async {
    await _persistTask(task.copyWith(today: !task.today));
  }

  Future<void> _postponeTask(Task task) async {
    final repository = ref.read(taskRepositoryProvider);
    await repository.incrementPostponeCount(task.id);
    final latest = await repository.getById(task.id) ?? task;
    await _persistTask(
      latest.copyWith(
        today: false,
        updatedAt: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task postponed (${latest.postponeCount}x)'),
      ),
    );
  }

  Future<void> _pickDeadline(Task task) async {
    final now = DateTime.now();
    final initial = task.deadline ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) {
      return;
    }
    await _persistTask(task.copyWith(deadline: picked));
  }

  Future<void> _saveNotes(Task task) async {
    final text = _notesController.text.trim();
    await _persistTask(
      task.copyWith(
        notes: text.isEmpty ? null : text,
        clearNotes: text.isEmpty,
      ),
    );
    if (mounted) {
      setState(() => _isEditingNotes = false);
    }
  }

  Future<void> _deleteTask(Task task) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete task?',
            style: AppTypography.headingMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'This will permanently remove "${task.title}".',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await ref.read(taskRepositoryProvider).delete(task.id);
    if (!mounted) {
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final taskAsync = ref.watch(taskByIdProvider(_id));
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
    final cardPadding = isWide ? AppSpacing.xl : AppSpacing.lg;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          const MinimalBackHeader(),
          Expanded(
            child: Stack(
              children: [
                const Positioned.fill(child: _TaskDetailDotBackground()),
                taskAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'Could not load task.',
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            data: (task) {
              if (task == null) {
                return Center(
                  child: Text(
                    'Task not found.',
                    style: AppTypography.bodyLarge.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              if (!_isEditingNotes &&
                  _notesController.text.isEmpty &&
                  task.notes != null) {
                _notesController.text = task.notes!;
              }

              final started = _displayStarted(task);
              final projectAsync = task.projectId != null
                  ? ref.watch(projectByIdProvider(task.projectId!))
                  : null;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xl,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
                    child: TaskDetailCard(
                      task: task,
                      project: projectAsync?.value,
                      cardPadding: cardPadding,
                      isWide: isWide,
                      started: started,
                      isUpdating: _isUpdating,
                      isEditingNotes: _isEditingNotes,
                      notesController: _notesController,
                      onEdit: () => context.push('/tasks/${task.id}/edit'),
                      onStart: () => _toggleFocusTimer(task),
                      onEditDeadline: () => _pickDeadline(task),
                      onOpenProject: task.projectId != null
                          ? () => context.push('/projects/${task.projectId}')
                          : null,
                      onEditNotes: () => setState(() => _isEditingNotes = true),
                      onSaveNotes: () => _saveNotes(task),
                      onPause: () => _pauseTask(task),
                      onMarkComplete: () => _markComplete(task),
                      onToggleToday: () => _toggleToday(task),
                      onPostpone: () => _postponeTask(task),
                      onDelete: () => _deleteTask(task),
                    ),
                  ),
                ),
              );
            },
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskDetailDotBackground extends StatelessWidget {
  const _TaskDetailDotBackground();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomPaint(
      painter: _DotGridPainter(
        dotColor: colorScheme.onSurface.withValues(alpha: 0.03),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter({required this.dotColor});

  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    const spacing = 24.0;
    const radius = 1.0;

    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) {
    return oldDelegate.dotColor != dotColor;
  }
}

class TaskDetailCard extends StatelessWidget {
  const TaskDetailCard({
    super.key,
    required this.task,
    required this.project,
    required this.cardPadding,
    required this.isWide,
    required this.started,
    required this.isUpdating,
    required this.isEditingNotes,
    required this.notesController,
    required this.onEdit,
    required this.onStart,
    required this.onEditDeadline,
    required this.onOpenProject,
    required this.onEditNotes,
    required this.onSaveNotes,
    required this.onPause,
    required this.onMarkComplete,
    required this.onToggleToday,
    required this.onPostpone,
    required this.onDelete,
  });

  final Task task;
  final Project? project;
  final double cardPadding;
  final bool isWide;
  final bool started;
  final bool isUpdating;
  final bool isEditingNotes;
  final TextEditingController notesController;
  final VoidCallback onEdit;
  final VoidCallback onStart;
  final VoidCallback onEditDeadline;
  final VoidCallback? onOpenProject;
  final VoidCallback onEditNotes;
  final VoidCallback onSaveNotes;
  final VoidCallback onPause;
  final VoidCallback onMarkComplete;
  final VoidCallback onToggleToday;
  final VoidCallback onPostpone;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(task.domain);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 4, color: domainColor),
            Padding(
              padding: EdgeInsets.all(cardPadding),
              child: TaskDetailCardHeader(
                task: task,
                onEdit: onEdit,
              ),
            ),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
            Container(
              color: colorScheme.surface.withValues(alpha: 0.5),
              padding: EdgeInsets.all(cardPadding),
              child: TaskDetailBodyGrid(
                task: task,
                project: project,
                isWide: isWide,
                started: started,
                isUpdating: isUpdating,
                onStart: onStart,
                onEditDeadline: onEditDeadline,
                onOpenProject: onOpenProject,
              ),
            ),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
            TaskExecutionNotesSection(
              padding: cardPadding,
              isEditing: isEditingNotes,
              notes: task.notes,
              controller: notesController,
              onEdit: onEditNotes,
              onSave: onSaveNotes,
            ),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
            Padding(
              padding: EdgeInsets.all(cardPadding),
              child: TaskDetailMetadataStrip(
                task: task,
                onToggleToday: onToggleToday,
                onPostpone: onPostpone,
                onDelete: onDelete,
              ),
            ),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.1),
            ),
            TaskDetailFooter(
              padding: cardPadding,
              started: started,
              isDone: task.status == TaskStatus.done,
              isUpdating: isUpdating,
              domainColor: domainColor,
              onPause: onPause,
              onMarkComplete: onMarkComplete,
            ),
          ],
        ),
      ),
    );
  }
}

class TaskDetailCardHeader extends StatelessWidget {
  const TaskDetailCardHeader({
    super.key,
    required this.task,
    required this.onEdit,
  });

  final Task task;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(task.domain);
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _DomainContextChip(
                    label: domainLabel(task.domain),
                    color: domainColor,
                    icon: domainIcon(task.domain),
                  ),
                  if (task.projectId != null)
                    _ProjectRefChip(
                      label: 'PRJ-${task.projectId!.toString().padLeft(3, '0')}',
                    ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DetailCompactIconButton(
                  onPressed: onEdit,
                  icon: Icons.edit,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          task.title,
          style: (isWide
                  ? AppTypography.headingLarge
                  : AppTypography.headingMedium)
              .copyWith(color: colorScheme.onSurface),
          softWrap: true,
        ),
      ],
    );
  }
}

class _DomainContextChip extends StatelessWidget {
  const _DomainContextChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final maxChipWidth = MediaQuery.sizeOf(context).width - AppSpacing.xl * 4;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxChipWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                style: AppTypography.labelLarge.copyWith(color: color),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectRefChip extends StatelessWidget {
  const _ProjectRefChip({required this.label});

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
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelLarge.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class TaskDetailBodyGrid extends StatelessWidget {
  const TaskDetailBodyGrid({
    super.key,
    required this.task,
    required this.project,
    required this.isWide,
    required this.started,
    required this.isUpdating,
    required this.onStart,
    required this.onEditDeadline,
    required this.onOpenProject,
  });

  final Task task;
  final Project? project;
  final bool isWide;
  final bool started;
  final bool isUpdating;
  final VoidCallback onStart;
  final VoidCallback onEditDeadline;
  final VoidCallback? onOpenProject;

  @override
  Widget build(BuildContext context) {
    final leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TaskStatusField(status: task.status),
        const SizedBox(height: AppSpacing.lg),
        DeepWorkSection(
          task: task,
          isUpdating: isUpdating,
          onStartPause: onStart,
        ),
      ],
    );

    final rightChildren = <Widget>[];
    if (task.deadline != null) {
      rightChildren.add(
        _DeadlineField(
          deadline: task.deadline!,
          onEditDeadline: onEditDeadline,
        ),
      );
    }
    if (task.projectId != null) {
      if (rightChildren.isNotEmpty) {
        rightChildren.add(const SizedBox(height: AppSpacing.lg));
      }
      rightChildren.add(
        _ParentProjectField(
          projectName: project?.name,
          onTap: onOpenProject,
        ),
      );
    }

    final rightColumn = rightChildren.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rightChildren,
          );

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leftColumn,
          if (rightChildren.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            rightColumn,
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: leftColumn),
        const SizedBox(width: AppSpacing.xl),
        Expanded(child: rightColumn),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _TaskStatusField extends StatelessWidget {
  const _TaskStatusField({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dotColor = switch (status) {
      TaskStatus.inProgress => colorScheme.tertiaryFixedDim,
      TaskStatus.done => colorScheme.primary,
      TaskStatus.stuck => colorScheme.error,
      TaskStatus.notStarted => colorScheme.outline,
    };

    return _LabeledField(
      label: 'CURRENT STATUS',
      child: Row(
        children: [
          _PulsingStatusDot(color: dotColor, animate: status == TaskStatus.inProgress),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              taskStatusDisplayLabel(status),
              style: AppTypography.bodyLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingStatusDot extends StatefulWidget {
  const _PulsingStatusDot({
    required this.color,
    required this.animate,
  });

  final Color color;
  final bool animate;

  @override
  State<_PulsingStatusDot> createState() => _PulsingStatusDotState();
}

class _PulsingStatusDotState extends State<_PulsingStatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _PulsingStatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate) {
      _controller.stop();
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = widget.animate ? 0.45 + (_controller.value * 0.55) : 1.0;
        return Opacity(
          opacity: opacity,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
        );
      },
    );
  }
}

class _DeadlineField extends StatelessWidget {
  const _DeadlineField({
    required this.deadline,
    required this.onEditDeadline,
  });

  final DateTime deadline;
  final VoidCallback onEditDeadline;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final display = _deadlineDisplay(context, deadline);

    return _LabeledField(
      label: 'DEADLINE',
      child: Row(
        children: [
          Icon(display.icon, size: AppSpacing.md, color: display.color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              display.label,
              style: AppTypography.bodyLarge.copyWith(color: display.color),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          _DetailCompactIconButton(
            onPressed: onEditDeadline,
            icon: Icons.edit,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _DeadlineDisplay {
  const _DeadlineDisplay({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}

_DeadlineDisplay _deadlineDisplay(BuildContext context, DateTime deadline) {
  final colorScheme = Theme.of(context).colorScheme;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(deadline.year, deadline.month, deadline.day);
  final daysUntil = due.difference(today).inDays;

  if (daysUntil < 0) {
    return _DeadlineDisplay(
      icon: Icons.schedule,
      label: 'OVERDUE',
      color: colorScheme.error,
    );
  }
  if (daysUntil == 0) {
    return _DeadlineDisplay(
      icon: Icons.flag,
      label: 'Today, ${DateFormat('HH:mm').format(deadline)}',
      color: colorScheme.error,
    );
  }
  if (daysUntil <= 3) {
    return _DeadlineDisplay(
      icon: Icons.bolt,
      label: 'Due in $daysUntil ${daysUntil == 1 ? 'day' : 'days'}',
      color: AppColors.priorityHigh,
    );
  }

  return _DeadlineDisplay(
    icon: Icons.calendar_today,
    label: DateFormat('MMM d, yyyy').format(deadline),
    color: colorScheme.onSurfaceVariant,
  );
}

class _ParentProjectField extends StatelessWidget {
  const _ParentProjectField({
    required this.projectName,
    required this.onTap,
  });

  final String? projectName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _LabeledField(
      label: 'PARENT PROJECT',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Ink(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_special_outlined,
                  color: colorScheme.primaryFixedDim,
                  size: AppSpacing.lg,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    projectName ?? 'Loading project...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TaskExecutionNotesSection extends StatelessWidget {
  const TaskExecutionNotesSection({
    super.key,
    required this.padding,
    required this.isEditing,
    required this.notes,
    required this.controller,
    required this.onEdit,
    required this.onSave,
  });

  final double padding;
  final bool isEditing;
  final String? notes;
  final TextEditingController controller;
  final VoidCallback onEdit;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasNotes = notes != null && notes!.trim().isNotEmpty;

    return Container(
      color: colorScheme.surfaceContainerLow,
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'EXECUTION NOTES',
                  style: AppTypography.labelLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              _DetailCompactIconButton(
                onPressed: isEditing ? onSave : onEdit,
                icon: isEditing ? Icons.check : Icons.edit,
                color: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (isEditing)
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: null,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface,
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: 'Add execution notes...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            )
          else
            Text(
              hasNotes ? notes! : 'No execution notes added.',
              style: AppTypography.bodyMedium.copyWith(
                color: hasNotes
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurfaceVariant,
                fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }
}

class TaskDetailMetadataStrip extends StatelessWidget {
  const TaskDetailMetadataStrip({
    super.key,
    required this.task,
    required this.onToggleToday,
    required this.onPostpone,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onToggleToday;
  final VoidCallback onPostpone;
  final VoidCallback onDelete;

  static const _postponeWarningColor = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final procrastinationSignal = task.postponeCount > 3;
    final showPostpone = task.status != TaskStatus.done;
    final postponeAccent =
        task.postponeCount > 3 ? _postponeWarningColor : colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetadataRow(
          label: 'PRIORITY',
          value: priorityLabelFor(task.priority),
          valueColor: priorityColorFor(task.priority),
        ),
        const SizedBox(height: AppSpacing.sm),
        _MetadataRow(
          label: 'CREATED',
          value: DateFormat('MMM d, yyyy').format(task.createdAt),
        ),
        const SizedBox(height: AppSpacing.sm),
        _MetadataRow(
          label: 'LAST MODIFIED',
          value: relativeTimeLabel(task.updatedAt),
        ),
        const SizedBox(height: AppSpacing.sm),
        _MetadataRow(
          label: 'POSTPONED',
          value:
              '${task.postponeCount} ${task.postponeCount == 1 ? 'time' : 'times'}',
          valueColor: procrastinationSignal
              ? AppColors.priorityHigh
              : colorScheme.onSurface,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton(
              onPressed: onToggleToday,
              child: Text(
                task.today ? "Remove from Today's Queue" : 'Add to Today',
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            if (showPostpone)
              OutlinedButton.icon(
                onPressed: onPostpone,
                icon: Icon(Icons.schedule, size: 18, color: postponeAccent),
                label: Text(
                  'POSTPONE',
                  style: AppTypography.labelLarge.copyWith(
                    color: postponeAccent,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: postponeAccent,
                  side: BorderSide(color: postponeAccent),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
          ],
        ),
        Center(
          child: TextButton(
            onPressed: onDelete,
            child: Text(
              'DELETE',
              style: AppTypography.labelLarge.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            style: AppTypography.labelSmall.copyWith(
              color: valueColor ?? colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}

class TaskDetailFooter extends StatelessWidget {
  const TaskDetailFooter({
    super.key,
    required this.padding,
    required this.started,
    required this.isDone,
    required this.isUpdating,
    required this.domainColor,
    required this.onPause,
    required this.onMarkComplete,
  });

  final double padding;
  final bool started;
  final bool isDone;
  final bool isUpdating;
  final Color domainColor;
  final VoidCallback onPause;
  final VoidCallback onMarkComplete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainerLowest,
      padding: EdgeInsets.all(padding),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: [
          if (started)
            OutlinedButton(
              onPressed: isUpdating ? null : onPause,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
                side: BorderSide(color: colorScheme.outlineVariant),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: Text(
                'Pause Task',
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          FilledButton(
            onPressed: isDone || isUpdating ? null : onMarkComplete,
            style: FilledButton.styleFrom(
              backgroundColor: domainColor,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              elevation: 0,
              shadowColor: domainColor.withValues(alpha: 0.1),
            ),
            child: Text(
              'Mark Complete',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color priorityColorFor(Priority priority) {
  return switch (priority) {
    Priority.low => AppColors.priorityLow,
    Priority.medium => AppColors.priorityMedium,
    Priority.high => AppColors.priorityHigh,
    Priority.critical => AppColors.priorityCritical,
  };
}

String priorityLabelFor(Priority priority) {
  return switch (priority) {
    Priority.low => 'LOW',
    Priority.medium => 'MEDIUM',
    Priority.high => 'HIGH',
    Priority.critical => 'CRITICAL',
  };
}

String taskStatusDisplayLabel(TaskStatus status) {
  return switch (status) {
    TaskStatus.notStarted => 'Not Started',
    TaskStatus.inProgress => 'In Progress',
    TaskStatus.done => 'Done',
    TaskStatus.stuck => 'Stuck',
  };
}
