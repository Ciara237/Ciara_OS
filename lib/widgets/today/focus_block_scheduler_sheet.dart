import 'package:ciaraos/models/calendar_event.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/calendar_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

void showFocusBlockSchedulerSheet(
  BuildContext context,
  WidgetRef ref, {
  DateTime? preselectedDate,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
    ),
    builder: (context) => FocusBlockSchedulerSheet(
      parentRef: ref,
      preselectedDate: preselectedDate,
    ),
  );
}

class FocusBlockSchedulerSheet extends ConsumerStatefulWidget {
  const FocusBlockSchedulerSheet({
    super.key,
    required this.parentRef,
    this.preselectedDate,
  });

  final WidgetRef parentRef;
  final DateTime? preselectedDate;

  @override
  ConsumerState<FocusBlockSchedulerSheet> createState() =>
      _FocusBlockSchedulerSheetState();
}

class _FocusBlockSchedulerSheetState
    extends ConsumerState<FocusBlockSchedulerSheet> {
  static const _durationOptions = [25, 45, 60, 90];

  Task? _selectedTask;
  int _tabIndex = 0;
  FreeSlot? _selectedSlot;
  DateTime? _pickedTime;
  int _durationMinutes = 45;
  bool _creating = false;
  CalendarEvent? _createdEvent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    if (_createdEvent != null) {
      return _SuccessView(event: _createdEvent!);
    }

    final tasksAsync = ref.watch(todayTasksProvider);
    final activeTasks = tasksAsync.value
            ?.where((task) => task.status != TaskStatus.done)
            .toList() ??
        const <Task>[];
    final freeSlotsAsync = ref.watch(freeSlotsProvider(_durationMinutes));

    final canSchedule = _selectedTask != null &&
        !_creating &&
        ((_tabIndex == 0 && _selectedSlot != null) ||
            (_tabIndex == 1 && _pickedTime != null));

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'SCHEDULE FOCUS BLOCK',
                        style: AppTypography.labelLarge.copyWith(
                          fontFamily: 'monospace',
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    Text(
                      'TASK',
                      style: AppTypography.labelSmall.copyWith(
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (activeTasks.isEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No tasks flagged for today',
                            style: AppTypography.bodyMedium.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context.push('/tasks');
                            },
                            child: const Text('Go to Backlog →'),
                          ),
                        ],
                      )
                    else
                      InputDecorator(
                        decoration: const InputDecoration(isDense: true),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Task>(
                            value: _selectedTask,
                            isExpanded: true,
                            hint: const Text('Select a task'),
                            items: activeTasks
                                .map(
                                  (task) => DropdownMenuItem(
                                    value: task,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: AppColors
                                                .domainColors[task.domain],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Text(
                                            task.title,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (task) =>
                                setState(() => _selectedTask = task),
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        _WhenTab(
                          label: 'Find Free Time',
                          selected: _tabIndex == 0,
                          onTap: () => setState(() => _tabIndex = 0),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _WhenTab(
                          label: 'Pick Time',
                          selected: _tabIndex == 1,
                          onTap: () => setState(() => _tabIndex = 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_tabIndex == 0)
                      freeSlotsAsync.when(
                        loading: () => Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Finding free windows...',
                              style: AppTypography.bodyMedium.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        error: (_, _) => Text(
                          'Could not load free slots.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        data: (slots) {
                          if (slots.isEmpty) {
                            return Text(
                              'No free windows found today.',
                              style: AppTypography.bodyMedium.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            );
                          }
                          return Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: slots.map((slot) {
                              final selected = _selectedSlot == slot;
                              return FilterChip(
                                label: Text(
                                  '${slot.displayTime} · ${slot.displayDuration}',
                                ),
                                selected: selected,
                                onSelected: (_) => setState(
                                  () => _selectedSlot = slot,
                                ),
                                selectedColor:
                                    colorScheme.primary.withValues(alpha: 0.15),
                                checkmarkColor: colorScheme.primary,
                                labelStyle: AppTypography.labelSmall.copyWith(
                                  color: selected
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                                side: BorderSide(
                                  color: selected
                                      ? colorScheme.primary
                                      : colorScheme.outlineVariant,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      )
                    else ...[
                      InkWell(
                        onTap: _pickCustomTime,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.4),
                            ),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            _pickedTime == null
                                ? 'Select time...'
                                : DateFormat('h:mm a').format(_pickedTime!),
                            style: AppTypography.bodyMedium.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: _durationOptions.map((minutes) {
                          final selected = _durationMinutes == minutes;
                          return FilterChip(
                            label: Text('$minutes min'),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _durationMinutes = minutes;
                                _selectedSlot = null;
                              });
                              ref.invalidate(freeSlotsProvider(minutes));
                            },
                            selectedColor:
                                colorScheme.primary.withValues(alpha: 0.15),
                            labelStyle: AppTypography.labelSmall.copyWith(
                              color: selected
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: FilledButton(
                  onPressed: canSchedule ? _schedule : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: _creating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Schedule Focus Block →'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickCustomTime() async {
    final now = DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_pickedTime ?? now),
    );
    if (picked == null) {
      return;
    }
    final base = widget.preselectedDate ?? now;
    setState(() {
      _pickedTime = DateTime(
        base.year,
        base.month,
        base.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _schedule() async {
    final task = _selectedTask;
    if (task == null) {
      return;
    }

    final startTime = _tabIndex == 0 ? _selectedSlot!.start : _pickedTime!;
    setState(() => _creating = true);

    final created = await ref.read(calendarServiceProvider).createFocusBlock(
          taskTitle: task.title,
          taskId: task.id,
          domain: task.domain.name,
          startTime: startTime,
          durationMinutes: _durationMinutes,
        );

    if (!mounted) {
      return;
    }

    if (created == null) {
      setState(() => _creating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not schedule focus block. Check that the backend is running.',
          ),
        ),
      );
      return;
    }

    widget.parentRef.read(calendarEventsProvider.notifier).upsertEvent(created);
    setState(() {
      _creating = false;
      _createdEvent = created;
    });
  }
}

class _WhenTab extends StatelessWidget {
  const _WhenTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? colorScheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatefulWidget {
  const _SuccessView({required this.event});

  final CalendarEvent event;

  @override
  State<_SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<_SuccessView> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = isSameCalendarDay(widget.event.start, DateTime.now())
        ? 'Today ${formatEventTimeRange(widget.event)}'
        : '${DateFormat('EEE, MMM d').format(widget.event.start)} ${formatEventTimeRange(widget.event)}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 56,
              color: Color(0xFF10B981),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Focus block scheduled',
              style: AppTypography.headingMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/calendar');
              },
              child: const Text('View in Calendar →'),
            ),
          ],
        ),
      ),
    );
  }
}
