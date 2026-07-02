import 'dart:convert';

import 'package:ciaraos/models/completed_tasks_data.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/services/ai_service.dart';
import 'package:http/http.dart' as http;

class CompletedTasksSummaryResponse {
  const CompletedTasksSummaryResponse({
    required this.totalCompleted,
    required this.completedThisWeek,
    required this.weekOverWeekChangePercent,
    required this.deepWorkHoursThisWeek,
    required this.avgDeepWorkHoursPerDay,
    required this.avgAccuracy,
    required this.weeklyDistribution,
  });

  factory CompletedTasksSummaryResponse.fromJson(Map<String, dynamic> json) {
    return CompletedTasksSummaryResponse(
      totalCompleted: json['total_completed'] as int,
      completedThisWeek: json['completed_this_week'] as int,
      weekOverWeekChangePercent:
          (json['week_over_week_change_percent'] as num?)?.toDouble(),
      deepWorkHoursThisWeek:
          (json['deep_work_hours_this_week'] as num).toDouble(),
      avgDeepWorkHoursPerDay:
          (json['avg_deep_work_hours_per_day'] as num).toDouble(),
      avgAccuracy: (json['avg_accuracy'] as num?)?.toDouble(),
      weeklyDistribution: (json['weekly_distribution'] as List<dynamic>)
          .map((value) => (value as num).toInt())
          .toList(),
    );
  }

  final int totalCompleted;
  final int completedThisWeek;
  final double? weekOverWeekChangePercent;
  final double deepWorkHoursThisWeek;
  final double avgDeepWorkHoursPerDay;
  final double? avgAccuracy;
  final List<int> weeklyDistribution;
}

class CompletedTasksApiService {
  CompletedTasksApiService({String? baseUrl})
      : _baseUrl = baseUrl ?? AiServiceConfig.baseUrl;

  final String _baseUrl;

  Future<CompletedTasksSummaryResponse?> fetchSummary({
    required List<Task> completedTasks,
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now();
    final payload = {
      'reference_date': clock.toIso8601String(),
      'tasks': completedTasks
          .where((task) => task.status == TaskStatus.done)
          .map(
            (task) => {
              'id': task.id.toString(),
              'completed_at': task.updatedAt.toIso8601String(),
              'focused_seconds': task.totalFocusedSeconds,
              'estimated_minutes': task.estimatedDurationMinutes,
              'planning_accuracy': task.planningAccuracy,
              'domain': task.domain.name,
              'priority': task.priority.name,
            },
          )
          .toList(),
    };

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/analytics/completed-tasks/summary'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      return CompletedTasksSummaryResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}

Map<String, dynamic> completedTasksSummaryPayload({
  required CompletedTasksData data,
  required List<Task> completedTasks,
  DateTime? now,
}) {
  return {
    'reference_date': (now ?? DateTime.now()).toIso8601String(),
    'stats': {
      'total_completed': data.stats.totalCompleted,
      'completed_this_week': data.stats.completedThisWeek,
      'week_over_week_change_percent': data.stats.weekOverWeekChangePercent,
      'deep_work_hours_this_week': data.stats.deepWorkHoursThisWeek,
      'avg_deep_work_hours_per_day': data.stats.avgDeepWorkHoursPerDay,
      'avg_accuracy': data.stats.avgAccuracy,
    },
    'weekly_distribution':
        data.weeklyDistribution.map((point) => point.count).toList(),
    'tasks': completedTasks
        .where((task) => task.status == TaskStatus.done)
        .map(
          (task) => {
            'id': task.id.toString(),
            'completed_at': task.updatedAt.toIso8601String(),
            'focused_seconds': task.totalFocusedSeconds,
            'estimated_minutes': task.estimatedDurationMinutes,
            'planning_accuracy': task.planningAccuracy,
            'domain': task.domain.name,
            'priority': task.priority.name,
          },
        )
        .toList(),
  };
}
