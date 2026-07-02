import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/priority.dart';
import 'package:ciaraos/models/task.dart';

enum CompletedTasksFilter {
  all,
  today,
  project,
  domain,
  priority,
}

class CompletedTasksStats {
  const CompletedTasksStats({
    required this.totalCompleted,
    required this.completedThisWeek,
    required this.weekOverWeekChangePercent,
    required this.deepWorkHoursThisWeek,
    required this.avgDeepWorkHoursPerDay,
    required this.avgAccuracy,
    required this.weeklySharePercent,
  });

  final int totalCompleted;
  final int completedThisWeek;
  final double? weekOverWeekChangePercent;
  final double deepWorkHoursThisWeek;
  final double avgDeepWorkHoursPerDay;
  final double? avgAccuracy;
  final double weeklySharePercent;
}

class WeeklyDistributionPoint {
  const WeeklyDistributionPoint({
    required this.day,
    required this.label,
    required this.count,
  });

  final DateTime day;
  final String label;
  final int count;
}

class CompletedTaskSection {
  const CompletedTaskSection({
    required this.label,
    required this.tasks,
  });

  final String label;
  final List<Task> tasks;

  int get count => tasks.length;
}

class CompletedTasksData {
  const CompletedTasksData({
    required this.stats,
    required this.weeklyDistribution,
    required this.sections,
    required this.filteredTasks,
    required this.hasArchive,
    required this.archiveTaskCount,
    required this.availableProjects,
    required this.availableDomains,
    required this.availablePriorities,
  });

  final CompletedTasksStats stats;
  final List<WeeklyDistributionPoint> weeklyDistribution;
  final List<CompletedTaskSection> sections;
  final List<Task> filteredTasks;
  final bool hasArchive;
  final int archiveTaskCount;
  final List<CompletedProjectOption> availableProjects;
  final List<Domain> availableDomains;
  final List<Priority> availablePriorities;
}

class CompletedProjectOption {
  const CompletedProjectOption({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}
