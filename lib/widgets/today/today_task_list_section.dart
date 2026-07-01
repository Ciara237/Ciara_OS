import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/focus_session_provider.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/providers/today_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/utils/today_task_grouper.dart';
import 'package:ciaraos/widgets/common/empty_state.dart';
import 'package:ciaraos/widgets/today/domain_task_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TodayTaskListSection extends ConsumerWidget {
  const TodayTaskListSection({super.key});

  Future<void> _toggleStarted(WidgetRef ref, Task task) async {
    final repository = ref.read(taskRepositoryProvider);
    final focus = ref.read(focusSessionProvider.notifier);
    final session = ref.read(focusSessionProvider);
    final willStart = !task.started;

    if (willStart) {
      focus.startForTask(task.id);
    } else if (session.isTrackingTask(task.id)) {
      focus.pause();
    }

    final updated = task.copyWith(
      started: willStart,
      updatedAt: DateTime.now(),
    );
    await repository.update(updated.toCompanion());
    ref.invalidate(taskByIdProvider(task.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(filteredTodayTasksProvider);
    final allTodayAsync = ref.watch(todayTasksProvider);
    final hasFilters = hasActiveTodayFilters(
      domain: ref.watch(todayDomainFilterProvider),
      deadline: ref.watch(todayDeadlineFilterProvider),
      status: ref.watch(todayStatusFilterProvider),
    );

    return tasksAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => EmptyState(
        message: 'Could not load today tasks.',
        actionLabel: 'REVIEW BACKLOG',
        onAction: () => context.go('/tasks'),
      ),
      data: (tasks) {
        final allTodayCount = allTodayAsync.maybeWhen(
          data: (all) => all.length,
          orElse: () => 0,
        );

        if (allTodayCount == 0) {
          return EmptyState(
            title: 'Your day is clear.',
            message:
                'Focus on what matters. Deep work or a peaceful reflection '
                'session awaits you.',
            actionLabel: 'REVIEW BACKLOG',
            onAction: () => context.go('/tasks'),
          );
        }

        if (tasks.isEmpty && hasFilters) {
          return EmptyState(
            message: 'No today tasks match the current filters.',
            actionLabel: 'CLEAR FILTERS',
            onAction: () => clearTodayFilters(ref),
          );
        }

        final grouped = groupTodayTasksByDomain(tasks);

        return Column(
          children: [
            for (final entry in grouped.entries) ...[
              DomainTaskGroup(
                domain: entry.key,
                tasks: entry.value,
                onTaskTap: (task) => context.push('/tasks/${task.id}'),
                onStartedToggle: (task) => _toggleStarted(ref, task),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ],
        );
      },
    );
  }
}
