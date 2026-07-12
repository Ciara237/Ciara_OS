import 'dart:convert';

import 'package:ciaraos/models/notion_page.dart';
import 'package:ciaraos/services/ai_service.dart';
import 'package:http/http.dart' as http;

void _logNetworkRequest(String method, String url, {int? statusCode, String? error}) {
  // ignore: avoid_print
  print('📡 [NETWORK] $method $url${statusCode != null ? " → $statusCode" : ""}${error != null ? " ERROR: $error" : ""}');
}

class NotionApiClient {
  NotionApiClient({String? baseUrl})
      : _baseUrl = baseUrl ?? AiServiceConfig.baseUrl;

  final String _baseUrl;

  Future<NotionPagesResponse?> fetchPages({bool force = false}) async {
    final url = '$_baseUrl/api/notion/pages';
    try {
      final params = force ? {'force': 'true'} : null;
      final uri = Uri.parse(url).replace(
        queryParameters: params,
      );
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 45));

      _logNetworkRequest('GET', url, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return NotionPagesResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      _logNetworkRequest('GET', url, error: e.toString());
      return null;
    }
  }

  Future<NotionPage?> fetchPage(String id) async {
    final url = '$_baseUrl/api/notion/pages/$id/sync';
    try {
      final uri = Uri.parse(url);
      final response = await http
          .post(uri)
          .timeout(const Duration(seconds: 45));

      _logNetworkRequest('POST', url, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return NotionPage.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      _logNetworkRequest('POST', url, error: e.toString());
      return null;
    }
  }

  Future<NotionHealthStatus> checkHealth() async {
    final url = '$_baseUrl/health/notion';
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));

      _logNetworkRequest('GET', url, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return NotionHealthStatus.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      _logNetworkRequest('GET', url, error: e.toString());
    }

    return const NotionHealthStatus(
      configured: false,
      pagesAccessible: false,
      pageCount: 0,
    );
  }
}
