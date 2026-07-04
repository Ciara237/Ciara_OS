import 'package:ciaraos/models/calendar_event.dart';
import 'package:ciaraos/providers/calendar_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:ciaraos/widgets/today/focus_block_scheduler_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final today = DateTime.now();
    final isCompact = MediaQuery.sizeOf(context).width < 400;
    final headerDate = isCompact
        ? DateFormat('EEE, MMM d, y').format(today)
        : DateFormat('EEEE, MMMM d, y').format(today);

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        children: [
          authAsync.when(
            loading: () => _CalendarHeader(
              headerDate: headerDate,
              onBack: () => context.pop(),
            ),
            error: (_, _) => _CalendarHeader(
              headerDate: headerDate,
              onBack: () => context.pop(),
            ),
            data: (status) => _CalendarHeader(
              headerDate: headerDate,
              onBack: () => context.pop(),
              showSearch: status.authorized,
            ),
          ),
          Expanded(
            child: authAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
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

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.headerDate,
    required this.onBack,
    this.showSearch = false,
  });

  final String headerDate;
  final VoidCallback onBack;
  final bool showSearch;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: onBack,
                  icon: Icon(
                    Icons.arrow_back,
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SCHEDULE',
                      style: AppTypography.labelSmall.copyWith(
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Calendar',
                      style: AppTypography.headingLarge.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 112,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      headerDate,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: AppTypography.labelSmall.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        height: 1.3,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (showSearch)
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.search,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

    return Material(
      color: colorScheme.surface,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 56,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Google Calendar not connected',
                  textAlign: TextAlign.center,
                  style: AppTypography.headingMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Connect your calendar to view events and schedule focus blocks.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (awaitingBrowser) ...[
                  Text(
                    'Complete in your browser, then tap Done below',
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
        ),
      ),
    );
  }
}

class _AuthorizedCalendarBody extends ConsumerWidget {
  const _AuthorizedCalendarBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedDay = ref.watch(calendarSelectedDayProvider);
    final eventsAsync = ref.watch(calendarEventsProvider);
    final events = eventsAsync.value ?? const <CalendarEvent>[];
    final dayEvents = (events
            .where((event) => isSameCalendarDay(event.start, selectedDay)))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    return Material(
      color: colorScheme.surface,
      child: ListView(
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
                  DateFormat('EEEE, MMMM d')
                      .format(selectedDay)
                      .toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    fontFamily: 'monospace',
                    color: colorScheme.onSurfaceVariant,
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
                child: Text(
                  '+ SCHEDULE FOCUS BLOCK',
                  style: AppTypography.labelSmall.copyWith(
                    fontFamily: 'monospace',
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (eventsAsync.isLoading && dayEvents.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (dayEvents.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No events scheduled.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: () => showFocusBlockSchedulerSheet(
                    context,
                    ref,
                    preselectedDate: selectedDay,
                  ),
                  child: const Text('+ Schedule Focus Block'),
                ),
              ],
            )
          else
            ...dayEvents.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _CalendarEventCard(event: event),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Text(
                'UPCOMING',
                style: AppTypography.labelSmall.copyWith(
                  fontFamily: 'monospace',
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Next 7 days',
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _UpcomingSection(events: events, selectedDay: selectedDay),
        ],
      ),
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
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

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
          final hasEvents =
              events.any((event) => isSameCalendarDay(event.start, day));

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Material(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: InkWell(
                onTap: () => onSelectDay(day),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: !selected
                        ? Border.all(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.25),
                          )
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('EEE').format(day).toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          color: selected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        day.day.toString().padLeft(2, '0'),
                        style: AppTypography.headingLarge.copyWith(
                          fontSize: 22,
                          color: selected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: hasEvents
                              ? (selected
                                  ? colorScheme.onPrimary
                                  : colorScheme.primary)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
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

    final updated =
        await ref.read(calendarServiceProvider).rescheduleFocusBlock(
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
    final ok = await ref
        .read(calendarServiceProvider)
        .deleteFocusBlock(event.id);
    if (!ok) {
      ref.read(calendarEventsProvider.notifier).refresh();
    }
  }

  String _formatStartTime(DateTime time) {
    if (event.isAllDay) {
      return 'All day';
    }
    return DateFormat('h:mm a').format(time);
  }

  String _formatEndTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
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

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: event.isFocusBlock
            ? Border(left: BorderSide(color: accentColor, width: 4))
            : Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatStartTime(event.start),
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (!event.isAllDay)
                    Text(
                      _formatEndTime(event.end),
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.isFocusBlock
                              ? event.displayTitle
                              : event.title,
                          style: AppTypography.headingMedium.copyWith(
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (event.isFocusBlock)
                        Text(
                          'FOCUS BLOCK',
                          style: AppTypography.labelSmall.copyWith(
                            fontFamily: 'monospace',
                            fontSize: 9,
                            color: accentColor,
                          ),
                        )
                      else if (event.durationMinutes > 0 && !event.isAllDay)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            '${event.durationMinutes}M',
                            style: AppTypography.labelSmall.copyWith(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (event.isFocusBlock && domain != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.5),
                        ),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        '${domainLabel(domain)} · ${event.durationMinutes} min',
                        style: AppTypography.labelSmall.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                  if (event.location != null &&
                      event.location!.isNotEmpty &&
                      !event.isFocusBlock) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (event.isFocusBlock) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _reschedule(context, ref),
                          icon: Icon(
                            Icons.access_time,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          tooltip: 'Reschedule',
                        ),
                        IconButton(
                          onPressed: () => _delete(context, ref),
                          icon: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: colorScheme.error,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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

    final upcoming = (events
            .where(
              (event) =>
                  !event.start.isBefore(today) &&
                  event.start.isBefore(end) &&
                  !isSameCalendarDay(event.start, selectedDay),
            ))
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

    return Column(
      children: upcoming
          .map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _UpcomingRow(event: event),
            ),
          )
          .toList(),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            DateFormat('EEE dd').format(event.start).toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              fontFamily: 'monospace',
              fontSize: 10,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(
          width: 72,
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
            style: AppTypography.bodyLarge.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        if (event.durationMinutes > 0 && !event.isAllDay)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              '${event.durationMinutes}M',
              style: AppTypography.labelSmall.copyWith(
                fontFamily: 'monospace',
                fontSize: 9,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
