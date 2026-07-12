import 'dart:convert';

import 'package:ciaraos/models/github_activity.dart';
import 'package:ciaraos/services/ai_service.dart';
import 'package:http/http.dart' as http;

void _logNetworkRequest(String method, String url, {int? statusCode, String? error}) {
  // ignore: avoid_print
  print('📡 [NETWORK] $method $url${statusCode != null ? " → $statusCode" : ""}${error != null ? " ERROR: $error" : ""}');
}

class GitHubService {
  GitHubService({String? baseUrl})
      : _baseUrl = baseUrl ?? AiServiceConfig.baseUrl;

  final String _baseUrl;

  Future<GitHubActivity?> fetchActivity({
    String? username,
    bool force = false,
  }) async {
    final url = '$_baseUrl/api/github/activity';
    try {
      final params = <String, String>{};
      if (username != null && username.isNotEmpty) {
        params['username'] = username;
      }
      if (force) {
        params['force'] = 'true';
      }
      final uri = Uri.parse(url).replace(
        queryParameters: params.isEmpty ? null : params,
      );
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 25));

      _logNetworkRequest('GET', url, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return GitHubActivity.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      if (response.statusCode == 429) {
        throw GitHubRateLimitException();
      }
      return null;
    } on GitHubRateLimitException {
      rethrow;
    } catch (e) {
      _logNetworkRequest('GET', url, error: e.toString());
      return null;
    }
  }
}

class GitHubRateLimitException implements Exception {
  @override
  String toString() => 'GitHub API rate limit exceeded';
}
