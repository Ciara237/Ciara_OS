import 'package:ciaraos/models/calendar_event.dart';
import 'package:ciaraos/providers/calendar_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/navigation/minimal_back_header.dart';
import 'package:ciaraos/widgets/today/focus_block_scheduler_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  bool _awaitingBrowser = false;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoLoad());
  }

  Future<void> _maybeAutoLoad() async {
    final auth = await ref.read(calendarAuthProvider.future);
    if (!auth.authorized || !mounted) {
      return;
    }
    final notifier = ref.read(calendarEventsProvider.notifier);
    if (notifier.shouldAutoLoad) {
      await notifier.loadDays(7);
    }
  }

  Future<void> _connect() async {
    setState(() {
      _connecting = true;
      _awaitingBrowser = false;
    });
    final authUrl = await ref.read(calendarServiceProvider).getAuthUrl();
    if (!mounted) {
      return;
    }
    if (authUrl == null) {
      setState(() => _connecting = false);
      return;
    }
    final uri = Uri.tryParse(authUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    setState(() {
      _connecting = false;
      _awaitingBrowser = true;
    });
  }

  Future<void> _confirmConnected() async {
    ref.invalidate(calendarAuthProvider);
    await ref.read(calendarAuthProvider.future);
    if (!mounted) {
      return;
    }
    setState(() => _awaitingBrowser = false);
    await ref.read(calendarEventsProvider.notifier).loadDays(7);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authAsync = ref.watch(calendarAuthProvider);

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        children: [
          const MinimalBackHeader(),
          Expanded(
            child: authAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => _UnauthorizedBody(
                connecting: _connecting,
                awaitingBrowser: _awaitingBrowser,
                onConnect: _connect,
                onDone: _confirmConnected,
              ),
              data: (status) {
                if (!status.authorized) {
                  return _UnauthorizedBody(
                    connecting: _connecting,
                    awaitingBrowser: _awaitingBrowser,
                    onConnect: _connect,
                    onDone: _confirmConnected,
                  );
                }
                return const _AuthorizedCalendarBody();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UnauthorizedBody extends StatelessWidget {
  const _UnauthorizedBody({
    required this.connecting,
    required this.awaitingBrowser,
    required this.onConnect,
    required this.onDone,
  });

  final bool connecting;
  final bool awaitingBrowser;
  final VoidCallback onConnect;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Google Calendar not connected',
                style: AppTypography.headingMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Connect to see your schedule, find free windows, and '
                'schedule [FOCUS] blocks without leaving Ciara OS.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (awaitingBrowser) ...[
                Text(
                  'Complete authorization in your browser, then tap Done.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: onDone,
                  child: const Text('Done'),
                ),
              ] else
                FilledButton(
                  onPressed: connecting ? null : onConnect,
                  child: connecting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Connect Google Calendar →'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthorizedCalendarBody extends ConsumerWidget {
  const _AuthorizedCalendarBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(calendarSelectedDayProvider);
    final eventsAsync = ref.watch(calendarEventsProvider);
    final events = eventsAsync.value ?? const <CalendarEvent>[];
    final dayEvents = events
        .where((event) => isSameCalendarDay(event.start, selectedDay))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        _WeekStrip(
          selectedDay: selectedDay,
          events: events,
          onSelectDay: (day) =>
              ref.read(calendarSelectedDayProvider.notifier).state = day,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('EEEE, MMM d').format(selectedDay).toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  fontFamily: 'monospace',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            TextButton(
              onPressed: () => showFocusBlockSchedulerSheet(
                context,
                ref,
                preselectedDate: selectedDay,
              ),
              child: const Text('+ Focus Block'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (eventsAsync.isLoading && dayEvents.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (dayEvents.isEmpty)
          Text(
            'No events. Schedule a focus block?',
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
        else
          ...dayEvents.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _CalendarEventCard(event: event),
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'UPCOMING',
          style: AppTypography.labelSmall.copyWith(
            fontFamily: 'monospace',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _UpcomingSection(events: events, selectedDay: selectedDay),
      ],
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.selectedDay,
    required this.events,
    required this.onSelectDay,
  });

  final DateTime selectedDay;
  final List<CalendarEvent> events;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final weekStart =
        selectedDay.subtract(Duration(days: selectedDay.weekday - 1));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (index) {
          final day = DateTime(
            weekStart.year,
            weekStart.month,
            weekStart.day + index,
          );
          final selected = isSameCalendarDay(day, selectedDay);
          final isToday = isSameCalendarDay(day, today);
          final hasEvents =
              events.any((event) => isSameCalendarDay(event.start, day));

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: InkWell(
              onTap: () => onSelectDay(day),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: Container(
                width: 44,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: !selected && isToday
                      ? Border.all(color: colorScheme.primary)
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E').format(day)[0],
                      style: AppTypography.labelSmall.copyWith(
                        color: selected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${day.day}',
                      style: AppTypography.labelLarge.copyWith(
                        color: selected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (hasEvents)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: selected
                              ? colorScheme.onPrimary
                              : colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CalendarEventCard extends ConsumerWidget {
  const _CalendarEventCard({required this.event});

  final CalendarEvent event;

  Future<void> _reschedule(BuildContext context, WidgetRef ref) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(event.start),
    );
    if (picked == null) {
      return;
    }

    final newStart = DateTime(
      event.start.year,
      event.start.month,
      event.start.day,
      picked.hour,
      picked.minute,
    );

    final updated = await ref.read(calendarServiceProvider).rescheduleFocusBlock(
          eventId: event.id,
          newStart: newStart,
          durationMinutes: event.durationMinutes,
        );
    if (updated != null) {
      ref.read(calendarEventsProvider.notifier).upsertEvent(updated);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete focus block?'),
        content: Text('Remove "${event.displayTitle}" from your calendar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    ref.read(calendarEventsProvider.notifier).removeFocusBlock(event.id);
    final ok = await ref.read(calendarServiceProvider).deleteFocusBlock(
          event.id,
        );
    if (!ok) {
      ref.read(calendarEventsProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final domain = event.focusDomain;
    final accentColor = event.isFocusBlock
        ? (domain != null
            ? AppColors.domainColors[domain]!
            : colorScheme.primary)
        : colorScheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: AppSpacing.taskBorderWidth,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(AppSpacing.radiusMd),
                ),
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                  right: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.isFocusBlock
                              ? event.displayTitle
                              : event.title,
                          style: AppTypography.bodyMedium.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (event.isFocusBlock)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            'FOCUS BLOCK',
                            style: AppTypography.labelSmall.copyWith(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              color: accentColor,
                            ),
                          ),
                        ),
                      if (event.isFocusBlock) ...[
                        IconButton(
                          onPressed: () => _reschedule(context, ref),
                          icon: const Icon(Icons.schedule, size: 18),
                          tooltip: 'Reschedule',
                        ),
                        IconButton(
                          onPressed: () => _delete(context, ref),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          tooltip: 'Delete',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    formatEventTimeRange(event),
                    style: AppTypography.labelSmall.copyWith(
                      fontFamily: 'monospace',
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (event.durationMinutes > 0 && !event.isAllDay) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${event.durationMinutes} min',
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                  if (event.location != null &&
                      event.location!.isNotEmpty &&
                      !event.isFocusBlock) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      event.location!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection({
    required this.events,
    required this.selectedDay,
  });

  final List<CalendarEvent> events;
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final end = today.add(const Duration(days: 7));

    final upcoming = events
        .where(
          (event) =>
              !event.start.isBefore(today) &&
              event.start.isBefore(end) &&
              !isSameCalendarDay(event.start, selectedDay),
        )
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    if (upcoming.isEmpty) {
      return Text(
        'Nothing else scheduled this week.',
        style: AppTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    final grouped = <DateTime, List<CalendarEvent>>{};
    for (final event in upcoming) {
      final key = DateTime(
        event.start.year,
        event.start.month,
        event.start.day,
      );
      grouped.putIfAbsent(key, () => []).add(event);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                DateFormat('EEE, MMM d').format(entry.key).toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ),
            ...entry.value.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _UpcomingRow(event: event),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        );
      }).toList(),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final domain = event.focusDomain;
    final accentColor = event.isFocusBlock && domain != null
        ? AppColors.domainColors[domain]!
        : colorScheme.outlineVariant;

    return Row(
      children: [
        Container(
          width: 3,
          height: 28,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 64,
          child: Text(
            event.isAllDay
                ? 'All day'
                : DateFormat('h:mm a').format(event.start),
            style: AppTypography.labelSmall.copyWith(
              fontFamily: 'monospace',
              fontSize: 10,
              color: colorScheme.onSurfaceVariant,
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
      ],
    );
  }
}
