import 'package:ciaraos/models/task.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_theme.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';

class TodayTaskRow extends StatelessWidget {
  const TodayTaskRow({
    super.key,
    required this.task,
    required this.onTap,
    required this.onStartedToggle,
  });

  final Task task;
  final VoidCallback onTap;
  final VoidCallback onStartedToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domainColor = context.domainColor(task.domain);
    final started = task.started;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: AppSpacing.xs,
                height: AppSpacing.xl,
                decoration: BoxDecoration(
                  color: domainColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _StartedToggle(
                started: started,
                domainColor: domainColor,
                onPressed: onStartedToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartedToggle extends StatelessWidget {
  const _StartedToggle({
    required this.started,
    required this.domainColor,
    required this.onPressed,
  });

  final bool started;
  final Color domainColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (started) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(
          Icons.check_circle,
          size: AppSpacing.md,
          color: colorScheme.onPrimary,
        ),
        label: Text(
          'STARTED',
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: domainColor,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        Icons.play_arrow,
        size: AppSpacing.md,
        color: colorScheme.onSurfaceVariant,
      ),
      label: Text(
        'STARTED',
        style: AppTypography.labelLarge.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: colorScheme.outlineVariant),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),
    );
  }
}
