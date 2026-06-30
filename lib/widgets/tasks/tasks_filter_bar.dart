import 'package:ciaraos/providers/task_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/tasks/task_filter_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasksFilterBar extends ConsumerWidget {
  const TasksFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domain = ref.watch(domainFilterProvider);
    final deadline = ref.watch(deadlineFilterProvider);
    final status = ref.watch(statusFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChipButton(
            label: 'DOMAIN',
            icon: Icons.filter_list,
            isActive: domain != null,
            onTap: () => showDomainFilterSheet(context, ref),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChipButton(
            label: 'DEADLINE',
            icon: Icons.calendar_today,
            isActive: deadline != null,
            onTap: () => showDeadlineFilterSheet(context, ref),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChipButton(
            label: 'STATUS',
            icon: Icons.check,
            isActive: status != null,
            onTap: () => showStatusFilterSheet(context, ref),
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final labelStyle = AppTypography.labelLarge.copyWith(
      color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
    );

    if (isActive) {
      return FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: AppSpacing.md, color: colorScheme.onPrimary),
        label: Text(label, style: labelStyle),
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
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
      onPressed: onTap,
      icon: Icon(icon, size: AppSpacing.md, color: colorScheme.onSurfaceVariant),
      label: Text(label, style: labelStyle),
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
