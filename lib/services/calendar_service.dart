import 'dart:convert';

import 'package:ciaraos/models/calendar_event.dart';
import 'package:ciaraos/services/ai_service.dart';
import 'package:http/http.dart' as http;

class CalendarService {
  CalendarService({String? baseUrl})
      : _baseUrl = baseUrl ?? AiServiceConfig.baseUrl;

  final String _baseUrl;

  Future<CalendarAuthStatus> checkStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/auth/google/status'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return CalendarAuthStatus.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (_) {}
    return const CalendarAuthStatus(
      authorized: false,
      calendarId: 'primary',
    );
  }

  Future<String?> getAuthUrl() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/auth/google'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['auth_url'] as String?;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> disconnect() async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/auth/google/disconnect'))
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<CalendarEvent>> getEvents({
    int days = 1,
    DateTime? start,
  }) async {
    try {
      final params = <String, String>{'days': days.toString()};
      if (start != null) {
        params['start'] =
            '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
      }
      final uri = Uri.parse('$_baseUrl/api/calendar/events')
          .replace(queryParameters: params);
      final response =
          await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final events = json['events'] as List<dynamic>? ?? const [];
        return events
            .map(
              (item) => CalendarEvent.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<CalendarEvent?> createFocusBlock({
    required String taskTitle,
    required int taskId,
    required String domain,
    required DateTime startTime,
    int durationMinutes = 45,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/calendar/focus-block'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'task_title': taskTitle,
              'task_id': taskId,
              'domain': domain,
              'start_time': startTime.toUtc().toIso8601String(),
              'duration_minutes': durationMinutes,
            }),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        return CalendarEvent.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (_) {}
    return null;
  }

  Future<bool> deleteFocusBlock(String eventId) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/api/calendar/events/$eventId'))
          .timeout(const Duration(seconds: 20));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<CalendarEvent?> rescheduleFocusBlock({
    required String eventId,
    required DateTime newStart,
    int? durationMinutes,
  }) async {
    try {
      final body = <String, dynamic>{
        'start_time': newStart.toUtc().toIso8601String(),
        'duration_minutes': durationMinutes ?? 45,
      };
      final response = await http
          .patch(
            Uri.parse('$_baseUrl/api/calendar/events/$eventId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        return CalendarEvent.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (_) {}
    return null;
  }

  Future<List<FreeSlot>> getFreeSlots({
    DateTime? date,
    int durationMinutes = 45,
  }) async {
    try {
      final params = <String, String>{
        'duration_minutes': durationMinutes.toString(),
      };
      if (date != null) {
        params['date'] =
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      final uri = Uri.parse('$_baseUrl/api/calendar/free-slots')
          .replace(queryParameters: params);
      final response =
          await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final slots = json['free_slots'] as List<dynamic>? ?? const [];
        return slots
            .map((item) => FreeSlot.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return const [];
  }
}
