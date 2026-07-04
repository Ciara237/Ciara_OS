import 'dart:convert';

import 'package:ciaraos/models/notion_page.dart';
import 'package:ciaraos/services/ai_service.dart';
import 'package:http/http.dart' as http;

class NotionApiClient {
  NotionApiClient({String? baseUrl})
      : _baseUrl = baseUrl ?? AiServiceConfig.baseUrl;

  final String _baseUrl;

  Future<NotionPagesResponse?> fetchPages({bool force = false}) async {
    try {
      final params = force ? {'force': 'true'} : null;
      final uri = Uri.parse('$_baseUrl/api/notion/pages').replace(
        queryParameters: params,
      );
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        return NotionPagesResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<NotionPage?> fetchPage(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/notion/pages/$id/sync');
      final response = await http
          .post(uri)
          .timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        return NotionPage.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<NotionHealthStatus> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health/notion'))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        return NotionHealthStatus.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (_) {}

    return const NotionHealthStatus(
      configured: false,
      pagesAccessible: false,
      pageCount: 0,
    );
  }
}
