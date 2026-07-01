import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/providers/today_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/utils/task_filter_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showTodayFilterSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Consumer(
          builder: (context, ref, _) {
            final colorScheme = Theme.of(context).colorScheme;
            final domain = ref.watch(todayDomainFilterProvider);
            final deadline = ref.watch(todayDeadlineFilterProvider);
            final status = ref.watch(todayStatusFilterProvider);

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'FILTER TODAY',
                            style: AppTypography.labelLarge.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (hasActiveTodayFilters(
                          domain: domain,
                          deadline: deadline,
                          status: status,
                        ))
                          TextButton(
                            onPressed: () {
                              clearTodayFilters(ref);
                              Navigator.pop(context);
                            },
                            child: const Text('Clear all'),
                          ),
                      ],
                    ),
                  ),
                  _FilterSectionTitle(title: 'Domain'),
                  ListTile(
                    title: const Text('All domains'),
                    trailing: domain == null
                        ? Icon(Icons.check, color: colorScheme.primary)
                        : null,
                    onTap: () {
                      ref.read(todayDomainFilterProvider.notifier).state = null;
                    },
                  ),
                  for (final value in Domain.values)
                    ListTile(
                      leading: Icon(domainIcon(value), color: colorScheme.primary),
                      title: Text(domainLabel(value)),
                      trailing: domain == value
                          ? Icon(Icons.check, color: colorScheme.primary)
                          : null,
                      onTap: () {
                        ref.read(todayDomainFilterProvider.notifier).state =
                            value;
                      },
                    ),
                  const Divider(height: 1),
                  _FilterSectionTitle(title: 'Deadline'),
                  ListTile(
                    title: const Text('Any deadline'),
                    trailing: deadline == null
                        ? Icon(Icons.check, color: colorScheme.primary)
                        : null,
                    onTap: () {
                      ref.read(todayDeadlineFilterProvider.notifier).state =
                          null;
                    },
                  ),
                  ListTile(
                    title: const Text('Due today'),
                    trailing: deadline == TaskDeadlineFilter.today
                        ? Icon(Icons.check, color: colorScheme.primary)
                        : null,
                    onTap: () {
                      ref.read(todayDeadlineFilterProvider.notifier).state =
                          TaskDeadlineFilter.today;
                    },
                  ),
                  ListTile(
                    title: const Text('Due this week'),
                    trailing: deadline == TaskDeadlineFilter.week
                        ? Icon(Icons.check, color: colorScheme.primary)
                        : null,
                    onTap: () {
                      ref.read(todayDeadlineFilterProvider.notifier).state =
                          TaskDeadlineFilter.week;
                    },
                  ),
                  ListTile(
                    title: const Text('Due this month'),
                    trailing: deadline == TaskDeadlineFilter.month
                        ? Icon(Icons.check, color: colorScheme.primary)
                        : null,
                    onTap: () {
                      ref.read(todayDeadlineFilterProvider.notifier).state =
                          TaskDeadlineFilter.month;
                    },
                  ),
                  const Divider(height: 1),
                  _FilterSectionTitle(title: 'Status'),
                  ListTile(
                    title: const Text('Any status'),
                    trailing: status == null
                        ? Icon(Icons.check, color: colorScheme.primary)
                        : null,
                    onTap: () {
                      ref.read(todayStatusFilterProvider.notifier).state = null;
                    },
                  ),
                  for (final option in const <({TaskStatus value, String label})>[
                    (value: TaskStatus.notStarted, label: 'Not started'),
                    (value: TaskStatus.inProgress, label: 'In progress'),
                    (value: TaskStatus.done, label: 'Done'),
                    (value: TaskStatus.stuck, label: 'Stuck'),
                  ])
                    ListTile(
                      title: Text(option.label),
                      trailing: status == option.value
                          ? Icon(Icons.check, color: colorScheme.primary)
                          : null,
                      onTap: () {
                        ref.read(todayStatusFilterProvider.notifier).state =
                            option.value;
                      },
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

class _FilterSectionTitle extends StatelessWidget {
  const _FilterSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
