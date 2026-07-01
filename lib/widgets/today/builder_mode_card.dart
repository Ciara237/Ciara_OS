import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/providers/today_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BuilderModeCard extends ConsumerWidget {
  const BuilderModeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final builderColor = context.domainColor(Domain.builder);
    final tasksAsync = ref.watch(filteredTodayTasksProvider);

    final builderTasks = tasksAsync.maybeWhen(
      data: (tasks) =>
          tasks.where((task) => task.domain == Domain.builder).toList(),
      orElse: () => <Task>[],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: builderColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.architecture, color: builderColor, size: AppSpacing.lg),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'BUILDER MODE',
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (builderTasks.isEmpty)
            Text(
              'No tasks currently flagged for Builder. Consider tagging items '
              'to trigger focus UI.',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < builderTasks.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  _BuilderTaskLink(task: builderTasks[i]),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _BuilderTaskLink extends StatelessWidget {
  const _BuilderTaskLink({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => context.push('/tasks/${task.id}'),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
