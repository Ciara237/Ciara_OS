import 'package:ciaraos/providers/focus_session_repository_provider.dart';
import 'package:ciaraos/providers/opportunity_providers.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/providers/weekly_review_providers.dart';
import 'package:ciaraos/repositories/focus_session_repository.dart';
import 'package:ciaraos/repositories/opportunity_repository.dart';
import 'package:ciaraos/repositories/project_repository.dart';
import 'package:ciaraos/repositories/task_repository.dart';
import 'package:ciaraos/repositories/weekly_review_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dataManagementServiceProvider = Provider<DataManagementService>((ref) {
  return DataManagementService(
    focusSessions: ref.watch(focusSessionRepositoryProvider),
    tasks: ref.watch(taskRepositoryProvider),
    projects: ref.watch(projectRepositoryProvider),
    opportunities: ref.watch(opportunityRepositoryProvider),
    weeklyReviews: ref.watch(weeklyReviewRepositoryProvider),
  );
});

class DataManagementService {
  const DataManagementService({
    required FocusSessionRepository focusSessions,
    required TaskRepository tasks,
    required ProjectRepository projects,
    required OpportunityRepository opportunities,
    required WeeklyReviewRepository weeklyReviews,
  })  : _focusSessions = focusSessions,
        _tasks = tasks,
        _projects = projects,
        _opportunities = opportunities,
        _weeklyReviews = weeklyReviews;

  final FocusSessionRepository _focusSessions;
  final TaskRepository _tasks;
  final ProjectRepository _projects;
  final OpportunityRepository _opportunities;
  final WeeklyReviewRepository _weeklyReviews;

  Future<void> clearAllData() async {
    await _focusSessions.deleteAll();
    await _tasks.deleteAll();
    await _projects.deleteAll();
    await _opportunities.deleteAll();
    await _weeklyReviews.deleteAll();
  }
}
