import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/widgets/tasks/task_list_tile.dart';
import 'package:flutter/material.dart';

class DomainTaskGroup extends StatelessWidget {
  const DomainTaskGroup({
    super.key,
    required this.domain,
    required this.tasks,
    required this.onTaskTap,
    required this.onStartedToggle,
  });

  final Domain domain;
  final List<Task> tasks;
  final ValueChanged<Task> onTaskTap;
  final ValueChanged<Task> onStartedToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(domain);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              domainIcon(domain),
              size: AppSpacing.md,
              color: domainColor,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                domainLabel(domain),
                style: AppTypography.labelLarge.copyWith(
                  color: domainColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Text(
              '${tasks.length} ITEMS',
              style: AppTypography.labelLarge.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Divider(
          color: domainColor.withValues(alpha: 0.3),
          thickness: 1,
          height: 1,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...tasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: TaskListTile(
              task: task,
              onTap: () => onTaskTap(task),
              onStartedToggle: () => onStartedToggle(task),
            ),
          ),
        ),
      ],
    );
  }
}
