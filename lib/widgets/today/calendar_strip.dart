import 'package:ciaraos/models/calendar_event.dart';
import 'package:ciaraos/providers/calendar_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/today/focus_block_scheduler_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CalendarStrip extends ConsumerStatefulWidget {
  const CalendarStrip({super.key});

  @override
  ConsumerState<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends ConsumerState<CalendarStrip> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoad());
  }

  Future<void> _maybeLoad() async {
    final auth = await ref.read(calendarAuthProvider.future);
    if (!auth.authorized || !mounted) {
      return;
    }
    final notifier = ref.read(calendarEventsProvider.notifier);
    if (notifier.shouldAutoLoad) {
      await notifier.loadDays(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(calendarAuthProvider);
    final authorized = authAsync.value?.authorized ?? false;
    if (!authorized) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final eventsAsync = ref.watch(calendarEventsProvider);
    final today = DateTime.now();
    final todayEvents = eventsAsync.value
            ?.where((event) => isSameCalendarDay(event.start, today))
            .toList() ??
        const <CalendarEvent>[];
    todayEvents.sort((a, b) => a.start.compareTo(b.start));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'TODAY',
                style: AppTypography.labelSmall.copyWith(
                  fontFamily: 'monospace',
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('EEE, MMM d').format(today).toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  fontFamily: 'monospace',
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: () => showFocusBlockSchedulerSheet(context, ref),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '+ Schedule',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (eventsAsync.isLoading && todayEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: LinearProgressIndicator(minHeight: 2),
            )
          else if (todayEvents.isEmpty)
            Row(
              children: [
                Text(
                  'No events today. ',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: () => showFocusBlockSchedulerSheet(context, ref),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '+ Schedule Focus Block',
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            )
          else ...[
            for (final event in todayEvents.take(3))
              _StripEventRow(event: event),
            if (todayEvents.length > 3)
              TextButton(
                onPressed: () => context.push('/calendar'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '+ ${todayEvents.length - 3} more',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StripEventRow extends StatelessWidget {
  const _StripEventRow({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domain = event.focusDomain;
    final accentColor = domain != null
        ? AppColors.domainColors[domain]!
        : colorScheme.onSurfaceVariant;
    final timeLabel = event.isAllDay
        ? 'All day'
        : DateFormat('h:mm a').format(event.start);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              timeLabel,
              style: AppTypography.labelSmall.copyWith(
                fontFamily: 'monospace',
                color: event.isFocusBlock
                    ? accentColor
                    : colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              event.isFocusBlock ? event.displayTitle : event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (event.durationMinutes > 0 && !event.isAllDay) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                '${event.durationMinutes}m',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
