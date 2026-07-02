import 'package:ciaraos/models/completed_tasks_data.dart';
import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/services/completed_tasks_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final completedTasksFilterProvider =
    StateProvider<CompletedTasksFilter>((ref) => CompletedTasksFilter.all);

final completedTasksDomainFilterProvider = StateProvider<Domain?>((ref) => null);

final completedTasksPriorityFilterProvider =
    StateProvider<Priority?>((ref) => null);

final completedTasksProjectFilterProvider = StateProvider<int?>((ref) => null);

final completedTasksArchiveLimitProvider = StateProvider<int>((ref) => 0);

final completedTasksProvider = Provider<AsyncValue<CompletedTasksData>>((ref) {
  final tasksAsync = ref.watch(allTasksProvider);
  final projectsAsync = ref.watch(allProjectsProvider);
  final filter = ref.watch(completedTasksFilterProvider);
  final domainFilter = ref.watch(completedTasksDomainFilterProvider);
  final priorityFilter = ref.watch(completedTasksPriorityFilterProvider);
  final projectFilter = ref.watch(completedTasksProjectFilterProvider);
  final archiveLimit = ref.watch(completedTasksArchiveLimitProvider);

  if (tasksAsync.isLoading || projectsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (tasksAsync.hasError) {
    return AsyncValue.error(
      tasksAsync.error!,
      tasksAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (projectsAsync.hasError) {
    return AsyncValue.error(
      projectsAsync.error!,
      projectsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final projectNames = Map<int, String>.from({
    for (final project in projectsAsync.value ?? []) project.id: project.name,
  });

  return AsyncValue.data(
    CompletedTasksService().compute(
      allTasks: tasksAsync.value ?? [],
      projectNames: projectNames,
      filter: filter,
      domainFilter: domainFilter,
      priorityFilter: priorityFilter,
      projectFilter: projectFilter,
      archiveLimit: archiveLimit,
    ),
  );
});

void resetCompletedTasksFilters(WidgetRef ref) {
  ref.read(completedTasksFilterProvider.notifier).state =
      CompletedTasksFilter.all;
  ref.read(completedTasksDomainFilterProvider.notifier).state = null;
  ref.read(completedTasksPriorityFilterProvider.notifier).state = null;
  ref.read(completedTasksProjectFilterProvider.notifier).state = null;
}

void loadMoreCompletedArchive(WidgetRef ref) {
  final current = ref.read(completedTasksArchiveLimitProvider);
  ref.read(completedTasksArchiveLimitProvider.notifier).state = current == 0
      ? CompletedTasksService.archiveBatchSize
      : current + CompletedTasksService.archiveBatchSize;
}
