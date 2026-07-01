import 'package:ciaraos/providers/today_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/today/today_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TodayActionRow extends ConsumerWidget {
  const TodayActionRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasFilters = hasActiveTodayFilters(
      domain: ref.watch(todayDomainFilterProvider),
      deadline: ref.watch(todayDeadlineFilterProvider),
      status: ref.watch(todayStatusFilterProvider),
    );

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => showTodayFilterSheet(context, ref),
            icon: Icon(
              Icons.filter_list,
              size: AppSpacing.md,
              color: hasFilters ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
            label: Text(
              hasFilters ? 'Filter ·' : 'Filter',
              style: AppTypography.bodyMedium.copyWith(
                color: hasFilters ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              backgroundColor: hasFilters
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              side: BorderSide(
                color: hasFilters
                    ? colorScheme.primary
                    : colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => context.push('/tasks/new'),
            icon: Icon(
              Icons.add,
              size: AppSpacing.md,
              color: colorScheme.onPrimary,
            ),
            label: Text(
              ' New Task',
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
