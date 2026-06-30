import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/task.dart';

/// Fixed display order for domain-grouped task lists.
const List<Domain> kDomainDisplayOrder = [
  Domain.engineering,
  Domain.security,
  Domain.opportunities,
  Domain.builder,
  Domain.other,
];

/// Groups [tasks] by domain, preserving [kDomainDisplayOrder].
/// Domains with zero tasks are omitted.
Map<Domain, List<Task>> groupTodayTasksByDomain(List<Task> tasks) {
  final grouped = <Domain, List<Task>>{};

  for (final domain in kDomainDisplayOrder) {
    final domainTasks =
        tasks.where((task) => task.domain == domain).toList();
    if (domainTasks.isNotEmpty) {
      grouped[domain] = domainTasks;
    }
  }

  return grouped;
}
