import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/utils/task_filter_utils.dart';
import 'package:ciaraos/widgets/common/empty_state.dart';
import 'package:ciaraos/widgets/tasks/task_list_tile.dart';
import 'package:ciaraos/widgets/tasks/task_quick_actions_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TasksBacklogListSection extends ConsumerWidget {
  const TasksBacklogListSection({super.key});

  Future<void> _markDone(WidgetRef ref, Task task) async {
    final repository = ref.read(taskRepositoryProvider);
    await repository.update(
      task.markedDone().toCompanion(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTasks = ref.watch(filteredTasksProvider);
    final allTasks = ref.watch(allTasksProvider);
    final domain = ref.watch(domainFilterProvider);
    final deadline = ref.watch(deadlineFilterProvider);
    final status = ref.watch(statusFilterProvider);
    final filtersActive = hasActiveTaskFilters(
      domain: domain,
      deadline: deadline,
      status: status,
    );

    return filteredTasks.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => EmptyState(
        message: 'Could not load tasks.',
        actionLabel: 'RETRY',
        onAction: () => ref.invalidate(allTasksProvider),
      ),
      data: (tasks) {
        final all = allTasks.value ?? const <Task>[];
        final activeCount =
            all.where((task) => task.status != TaskStatus.done).length;
        final totalCount = all.length;

        if (totalCount == 0) {
          return EmptyState(
            style: EmptyStateStyle.tasks,
            title: 'The Backlog is Clear',
            message:
                'A blank slate. Begin capturing actionable items to '
                'structure your upcoming focus cycles.',
            actionLabel: 'INITIALIZE TASK',
            actionIcon: Icons.add,
            onAction: () => context.push('/tasks/new'),
            footer: const TasksEmptyStateFooter(),
          );
        }

        if (activeCount == 0 && !filtersActive) {
          return EmptyState(
            title: 'Backlog Complete',
            message:
                'All tasks are done. View completed work in the Execution Archive.',
            actionLabel: 'OPEN ARCHIVE',
            onAction: () => context.push('/tasks/completed'),
          );
        }

        if (tasks.isEmpty) {
          return EmptyState(
            title: 'No Matching Tasks',
            message:
                'No tasks match the current filters. Clear filters to see all tasks.',
            actionLabel: 'CLEAR FILTERS',
            onAction: filtersActive ? () => clearAllFilters(ref) : null,
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskListTile(
              task: task,
              showDomainChip: true,
              showDeadline: true,
              showCheckbox: true,
              showStartedButton: false,
              onTap: () => context.push('/tasks/${task.id}'),
              onLongPress: () => showTaskQuickActionsSheet(
                context: context,
                ref: ref,
                task: task,
              ),
              onCheckboxTap: () => _markDone(ref, task),
            );
          },
        );
      },
    );
  }
}
