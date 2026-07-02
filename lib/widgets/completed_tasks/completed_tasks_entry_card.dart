import 'package:ciaraos/models/enums/task_status.dart';
import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompletedTasksEntryCard extends ConsumerWidget {
  const CompletedTasksEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final tasksAsync = ref.watch(allTasksProvider);
    final completedCount = tasksAsync.maybeWhen(
      data: (tasks) =>
          tasks.where((task) => task.status == TaskStatus.done).length,
      orElse: () => null,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/tasks/completed'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.task_alt_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Execution Archive',
                        style: AppTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        completedCount == null
                            ? 'View completed tasks and accuracy history'
                            : '$completedCount completed · Weekly stats & archive',
                        style: AppTypography.labelSmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
