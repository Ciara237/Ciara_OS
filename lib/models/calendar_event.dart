import 'package:ciaraos/models/enums/domain.dart';

class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.durationMinutes,
    required this.isAllDay,
    this.color,
    this.location,
    required this.isFocusBlock,
  });

  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final int durationMinutes;
  final bool isAllDay;
  final String? color;
  final String? location;
  final bool isFocusBlock;

  String get displayTitle => title.replaceFirst('[FOCUS] ', '');

  Domain? get focusDomain => domainFromCalendarColor(color);

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      start: _parseDateTime(json['start'] as String? ?? ''),
      end: _parseDateTime(json['end'] as String? ?? ''),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      isAllDay: json['is_all_day'] as bool? ?? false,
      color: json['color'] as String?,
      location: json['location'] as String?,
      isFocusBlock: json['is_focus_block'] as bool? ?? false,
    );
  }
}

class FreeSlot {
  const FreeSlot({
    required this.start,
    required this.end,
    required this.durationMinutes,
  });

  final DateTime start;
  final DateTime end;
  final int durationMinutes;

  factory FreeSlot.fromJson(Map<String, dynamic> json) {
    return FreeSlot(
      start: _parseDateTime(json['start'] as String? ?? ''),
      end: _parseDateTime(json['end'] as String? ?? ''),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
    );
  }

  String get displayTime {
    final hour = start.hour % 12 == 0 ? 12 : start.hour % 12;
    final minute = start.minute.toString().padLeft(2, '0');
    final period = start.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String get displayDuration => '$durationMinutes min';
}

class CalendarAuthStatus {
  const CalendarAuthStatus({
    required this.authorized,
    this.email,
    required this.calendarId,
  });

  final bool authorized;
  final String? email;
  final String calendarId;

  factory CalendarAuthStatus.fromJson(Map<String, dynamic> json) {
    return CalendarAuthStatus(
      authorized: json['authorized'] as bool? ?? false,
      email: json['email'] as String?,
      calendarId: json['calendar_id'] as String? ?? 'primary',
    );
  }
}

Domain? domainFromCalendarColor(String? colorId) {
  return switch (colorId) {
    '9' => Domain.engineering,
    '11' => Domain.security,
    '2' => Domain.opportunities,
    '3' => Domain.builder,
    '8' => Domain.other,
    _ => null,
  };
}

DateTime _parseDateTime(String value) {
  if (value.length == 10) {
    return DateTime.parse(value);
  }
  return DateTime.parse(value.replaceFirst('Z', '')).toLocal();
}

bool isSameCalendarDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatEventTimeRange(CalendarEvent event) {
  if (event.isAllDay) {
    return 'All day';
  }
  final startHour = event.start.hour % 12 == 0 ? 12 : event.start.hour % 12;
  final startMinute = event.start.minute.toString().padLeft(2, '0');
  final startPeriod = event.start.hour >= 12 ? 'PM' : 'AM';
  final endHour = event.end.hour % 12 == 0 ? 12 : event.end.hour % 12;
  final endMinute = event.end.minute.toString().padLeft(2, '0');
  final endPeriod = event.end.hour >= 12 ? 'PM' : 'AM';
  return '$startHour:$startMinute $startPeriod – $endHour:$endMinute $endPeriod';
}
