import 'package:ciaraos/providers/focus_session_repository_provider.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/providers/weekly_review_providers.dart';
import 'package:ciaraos/services/weekly_review_service.dart';
import 'package:ciaraos/utils/review_stats_utils.dart';
import 'package:ciaraos/models/weekly_debrief.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final weeklyReviewServiceProvider = Provider<WeeklyReviewService>((ref) {
  return WeeklyReviewService(
    taskRepository: ref.watch(taskRepositoryProvider),
    focusSessionRepository: ref.watch(focusSessionRepositoryProvider),
    projectRepository: ref.watch(projectRepositoryProvider),
  );
});

final weeklyDebriefProvider = FutureProvider<WeeklyDebrief>((ref) async {
  final weekOf = mondayOfWeek(DateTime.now());
  return ref.watch(weeklyReviewServiceProvider).buildDebrief(weekOf);
});

final currentWeekReviewProvider = FutureProvider((ref) async {
  final weekOf = mondayOfWeek(DateTime.now());
  return ref.watch(weeklyReviewRepositoryProvider).getByWeek(weekOf);
});
