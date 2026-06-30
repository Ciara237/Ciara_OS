import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/utils/task_filter_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showDomainFilterSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final selected = ref.watch(domainFilterProvider);

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'All Domains',
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              trailing: selected == null
                  ? Icon(Icons.check, color: colorScheme.primary)
                  : null,
              onTap: () {
                ref.read(domainFilterProvider.notifier).state = null;
                Navigator.pop(context);
              },
            ),
            for (final domain in Domain.values)
              ListTile(
                leading: Icon(domainIcon(domain), color: colorScheme.primary),
                title: Text(
                  domainLabel(domain),
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: selected == domain
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(domainFilterProvider.notifier).state = domain;
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      );
    },
  );
}

Future<void> showDeadlineFilterSheet(BuildContext context, WidgetRef ref) {
  const options = <({String? value, String label})>[
    (value: null, label: 'All'),
    (value: TaskDeadlineFilter.today, label: 'Today'),
    (value: TaskDeadlineFilter.week, label: 'This Week'),
    (value: TaskDeadlineFilter.month, label: 'This Month'),
  ];

  return showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final selected = ref.watch(deadlineFilterProvider);

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              ListTile(
                title: Text(
                  option.label,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: selected == option.value
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(deadlineFilterProvider.notifier).state =
                      option.value;
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      );
    },
  );
}

Future<void> showStatusFilterSheet(BuildContext context, WidgetRef ref) {
  const options = <({TaskStatus? value, String label})>[
    (value: null, label: 'All'),
    (value: TaskStatus.notStarted, label: 'Not Started'),
    (value: TaskStatus.inProgress, label: 'In Progress'),
    (value: TaskStatus.done, label: 'Done'),
    (value: TaskStatus.stuck, label: 'Stuck'),
  ];

  return showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      final selected = ref.watch(statusFilterProvider);

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              ListTile(
                title: Text(
                  option.label,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: selected == option.value
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(statusFilterProvider.notifier).state = option.value;
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      );
    },
  );
}
