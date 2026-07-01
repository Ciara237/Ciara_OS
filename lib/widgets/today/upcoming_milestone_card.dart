import 'package:ciaraos/models/enums/project_status.dart';
import 'package:ciaraos/models/project.dart';
import 'package:ciaraos/providers/project_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/project_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpcomingMilestoneCard extends ConsumerWidget {
  const UpcomingMilestoneCard({super.key});

  static Project? nearestActiveProject(List<Project> projects) {
    final active = projects
        .where((project) => project.status == ProjectStatus.active)
        .toList();
    if (active.isEmpty) {
      return null;
    }

    active.sort((a, b) {
      return projectRemainingDays(a).compareTo(projectRemainingDays(b));
    });
    return active.first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final projectsAsync = ref.watch(allProjectsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UPCOMING MILESTONE',
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          projectsAsync.when(
            loading: () => Text(
              'Loading milestones…',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            error: (_, _) => Text(
              'No active milestones',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            data: (projects) {
              final project = nearestActiveProject(projects);
              if (project == null) {
                return Text(
                  'No active milestones',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              }

              final remaining = projectRemainingDays(project);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: AppTypography.headingMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$remaining days remaining',
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
