import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/widgets/today/today_task_row.dart';
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
            Container(
              width: AppSpacing.domainBarWidth,
              height: AppSpacing.domainBarWidth,
              decoration: BoxDecoration(
                color: domainColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              domainLabel(domain),
              style: AppTypography.labelLarge.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...tasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.executionGap),
            child: TodayTaskRow(
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
