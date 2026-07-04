import 'package:ciaraos/providers/calendar_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showCalendarSetupSheet(
  BuildContext context,
  WidgetRef ref,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
    ),
    builder: (context) => CalendarSetupSheet(parentRef: ref),
  );
}

class CalendarSetupSheet extends ConsumerStatefulWidget {
  const CalendarSetupSheet({super.key, required this.parentRef});

  final WidgetRef parentRef;

  @override
  ConsumerState<CalendarSetupSheet> createState() =>
      _CalendarSetupSheetState();
}

class _CalendarSetupSheetState extends ConsumerState<CalendarSetupSheet> {
  bool _connecting = false;
  bool _awaitingBrowser = false;
  bool _disconnecting = false;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Calendar connection is not available right now. Try again later.',
          ),
        ),
      );
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
    widget.parentRef.invalidate(calendarAuthProvider);
    final status = await widget.parentRef.read(calendarAuthProvider.future);
    if (!mounted) {
      return;
    }

    if (status.authorized) {
      widget.parentRef.read(calendarEventsProvider.notifier).refresh();
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not connected yet. Complete authorization in browser.'),
      ),
    );
  }

  Future<void> _disconnect() async {
    setState(() => _disconnecting = true);
    final ok = await ref.read(calendarServiceProvider).disconnect();
    widget.parentRef.invalidate(calendarAuthProvider);
    widget.parentRef.read(calendarEventsProvider.notifier).loadDays(1);
    if (!mounted) {
      return;
    }
    setState(() => _disconnecting = false);
    if (ok) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authAsync = ref.watch(calendarAuthProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: authAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _buildConnectFlow(colorScheme),
          data: (status) {
            if (status.authorized) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Google Calendar',
                    style: AppTypography.headingLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    status.email ?? 'Connected',
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Connected',
                        style: AppTypography.labelSmall.copyWith(
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextButton(
                    onPressed: _disconnecting ? null : _disconnect,
                    child: Text(
                      'Disconnect',
                      style: AppTypography.labelLarge.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              );
            }

            return _buildConnectFlow(colorScheme);
          },
        ),
      ),
    );
  }

  Widget _buildConnectFlow(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect Google Calendar',
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Ciara OS reads your calendar and creates focus blocks tagged '
          '[FOCUS] — it never modifies your other events.',
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_awaitingBrowser) ...[
          Text(
            'Complete authorization in your browser, then tap Done.',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: _confirmConnected,
            child: const Text('Done'),
          ),
        ] else ...[
          FilledButton(
            onPressed: _connecting ? null : _connect,
            child: _connecting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Connect →'),
          ),
        ],
      ],
    );
  }
}
