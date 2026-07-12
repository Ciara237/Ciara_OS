import 'dart:convert';

import 'package:ciaraos/models/calendar_event.dart';
import 'package:ciaraos/services/ai_service.dart';
import 'package:http/http.dart' as http;

void _logNetworkRequest(String method, String url, {int? statusCode, String? error}) {
  // ignore: avoid_print
  print('📡 [NETWORK] $method $url${statusCode != null ? " → $statusCode" : ""}${error != null ? " ERROR: $error" : ""}');
}

class CalendarService {
  CalendarService({String? baseUrl})
      : _baseUrl = baseUrl ?? AiServiceConfig.baseUrl;

  final String _baseUrl;

  Future<CalendarAuthStatus> checkStatus() async {
    final url = '$_baseUrl/auth/google/status';
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      _logNetworkRequest('GET', url, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        return CalendarAuthStatus.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      _logNetworkRequest('GET', url, error: e.toString());
    }
    return const CalendarAuthStatus(
      authorized: false,
      calendarId: 'primary',
    );
  }

  Future<String?> getAuthUrl() async {
    final url = '$_baseUrl/auth/google';
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      _logNetworkRequest('GET', url, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['auth_url'] as String?;
      }
    } catch (e) {
      _logNetworkRequest('GET', url, error: e.toString());
    }
    return null;
  }

  Future<bool> disconnect() async {
    final url = '$_baseUrl/auth/google/disconnect';
    try {
      final response = await http
          .delete(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      _logNetworkRequest('DELETE', url, statusCode: response.statusCode);
      return response.statusCode == 200;
    } catch (e) {
      _logNetworkRequest('DELETE', url, error: e.toString());
      return false;
    }
  }

  Future<List<CalendarEvent>> getEvents({
    int days = 1,
    DateTime? start,
  }) async {
    final url = '$_baseUrl/api/calendar/events';
    try {
      final params = <String, String>{'days': days.toString()};
      if (start != null) {
        params['start'] =
            '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
      }
      final uri = Uri.parse(url).replace(queryParameters: params);
      final response =
          await http.get(uri).timeout(const Duration(seconds: 20));
      _logNetworkRequest('GET', '$url?days=$days', statusCode: response.statusCode);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final events = json['events'] as List<dynamic>? ?? const [];
        return events
            .map(
              (item) => CalendarEvent.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
    } catch (e) {
      _logNetworkRequest('GET', url, error: e.toString());
    }
    return const [];
  }

  Future<CalendarEvent?> createFocusBlock({
    required String taskTitle,
    required int taskId,
    required String domain,
    required DateTime startTime,
    int durationMinutes = 45,
  }) async {
    final url = '$_baseUrl/api/calendar/focus-block';
    try {
      final response = await http
          .post(
            Uri.parse(url),
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
      _logNetworkRequest('POST', url, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        return CalendarEvent.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      _logNetworkRequest('POST', url, error: e.toString());
    }
    return null;
  }

  Future<bool> deleteFocusBlock(String eventId) async {
    final url = '$_baseUrl/api/calendar/events/$eventId';
    try {
      final response = await http
          .delete(Uri.parse(url))
          .timeout(const Duration(seconds: 20));
      _logNetworkRequest('DELETE', url, statusCode: response.statusCode);
      return response.statusCode == 200;
    } catch (e) {
      _logNetworkRequest('DELETE', url, error: e.toString());
      return false;
    }
  }

  Future<CalendarEvent?> rescheduleFocusBlock({
    required String eventId,
    required DateTime newStart,
    int? durationMinutes,
  }) async {
    final url = '$_baseUrl/api/calendar/events/$eventId';
    try {
      final body = <String, dynamic>{
        'start_time': newStart.toUtc().toIso8601String(),
        'duration_minutes': durationMinutes ?? 45,
      };
      final response = await http
          .patch(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
      _logNetworkRequest('PATCH', url, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        return CalendarEvent.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      _logNetworkRequest('PATCH', url, error: e.toString());
    }
    return null;
  }

  Future<List<FreeSlot>> getFreeSlots({
    DateTime? date,
    int durationMinutes = 45,
  }) async {
    final url = '$_baseUrl/api/calendar/free-slots';
    try {
      final params = <String, String>{
        'duration_minutes': durationMinutes.toString(),
      };
      if (date != null) {
        params['date'] =
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      final uri = Uri.parse(url).replace(queryParameters: params);
      final response =
          await http.get(uri).timeout(const Duration(seconds: 20));
      _logNetworkRequest('GET', url, statusCode: response.statusCode);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final slots = json['free_slots'] as List<dynamic>? ?? const [];
        return slots
            .map((item) => FreeSlot.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _logNetworkRequest('GET', url, error: e.toString());
    }
    return const [];
  }
}
