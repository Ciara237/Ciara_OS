import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/database_provider.dart';
import 'package:ciaraos/repositories/task_repository.dart';
import 'package:ciaraos/utils/task_filter_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(databaseProvider));
});

final allTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAll();
});

final todayTasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchToday();
});

final taskByIdProvider = FutureProvider.family<Task?, int>((ref, id) {
  return ref.read(taskRepositoryProvider).getById(id);
});

final weekTasksProvider = FutureProvider.family<List<Task>, DateTime>(
  (ref, weekStart) async {
    final normalizedStart = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    return ref.read(taskRepositoryProvider).getTasksForWeek(normalizedStart);
  },
);

final domainFilterProvider = StateProvider<Domain?>((ref) => null);

final deadlineFilterProvider = StateProvider<String?>((ref) => null);

final statusFilterProvider = StateProvider<TaskStatus?>((ref) => null);

final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(allTasksProvider);
  final domain = ref.watch(domainFilterProvider);
  final deadline = ref.watch(deadlineFilterProvider);
  final status = ref.watch(statusFilterProvider);

  return tasksAsync.whenData(
    (tasks) => applyTaskFilters(
      tasks: tasks,
      domain: domain,
      deadline: deadline,
      status: status,
    ),
  );
});
