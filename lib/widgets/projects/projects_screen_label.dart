import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class ProjectsScreenLabel extends StatelessWidget {
  const ProjectsScreenLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CENTRAL DIRECTORY',
          style: AppTypography.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Projects Glance',
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'High-level strategic oversight of active domains.',
          style: AppTypography.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
