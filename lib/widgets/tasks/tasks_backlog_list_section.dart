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
      task
          .copyWith(
            status: TaskStatus.done,
            updatedAt: DateTime.now(),
          )
          .toCompanion(),
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
        final totalCount = allTasks.value?.length ?? 0;

        if (totalCount == 0) {
          return EmptyState(
            message: 'Your backlog is empty. Add your first task.',
            actionLabel: 'ADD TASK',
            onAction: () => context.push('/tasks/new'),
          );
        }

        if (tasks.isEmpty) {
          return EmptyState(
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
