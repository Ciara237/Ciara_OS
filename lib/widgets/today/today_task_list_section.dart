import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/task_providers.dart';
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
    final updated = task.copyWith(
      started: !task.started,
      updatedAt: DateTime.now(),
    );
    await repository.update(updated.toCompanion());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);

    return tasksAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => EmptyState(
        message: 'Could not load today tasks.',
        actionLabel: 'GO TO BACKLOG',
        onAction: () => context.go('/tasks'),
      ),
      data: (tasks) {
        if (tasks.isEmpty) {
          return EmptyState(
            message:
                "No tasks flagged for today. Add tasks and mark them 'Today' "
                'from the backlog.',
            actionLabel: 'GO TO BACKLOG',
            onAction: () => context.go('/tasks'),
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
