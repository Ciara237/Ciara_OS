import 'package:ciaraos/models/calendar_event.dart';
import 'package:ciaraos/services/calendar_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final calendarServiceProvider = Provider<CalendarService>(
  (ref) => CalendarService(),
);

final calendarAuthProvider = FutureProvider<CalendarAuthStatus>((ref) {
  return ref.read(calendarServiceProvider).checkStatus();
});

final calendarSelectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final calendarEventsProvider = StateNotifierProvider<
    CalendarEventsNotifier, AsyncValue<List<CalendarEvent>>>((ref) {
  return CalendarEventsNotifier(ref.read(calendarServiceProvider));
});

class CalendarEventsNotifier
    extends StateNotifier<AsyncValue<List<CalendarEvent>>> {
  CalendarEventsNotifier(this._service)
      : super(const AsyncValue.data([]));

  final CalendarService _service;
  DateTime? _lastLoaded;
  int _loadedDays = 1;

  int get loadedDays => _loadedDays;

  bool get shouldAutoLoad {
    if (_lastLoaded == null) {
      return true;
    }
    return DateTime.now().difference(_lastLoaded!).inMinutes > 30;
  }

  Future<void> loadDays(int days) async {
    state = const AsyncValue.loading();
    final events = await _service.getEvents(days: days);
    _loadedDays = days;
    _lastLoaded = DateTime.now();
    state = AsyncValue.data(events);
  }

  Future<void> refresh() => loadDays(_loadedDays);

  void removeFocusBlock(String eventId) {
    state.whenData((events) {
      state = AsyncValue.data(
        events.where((event) => event.id != eventId).toList(),
      );
    });
  }

  void upsertEvent(CalendarEvent event) {
    state.whenData((events) {
      final updated = [
        for (final existing in events)
          if (existing.id != event.id) existing,
        event,
      ]..sort((a, b) => a.start.compareTo(b.start));
      state = AsyncValue.data(updated);
    });
  }
}

final freeSlotsProvider =
    FutureProvider.family<List<FreeSlot>, int>((ref, duration) {
  return ref.read(calendarServiceProvider).getFreeSlots(
        durationMinutes: duration,
      );
});
