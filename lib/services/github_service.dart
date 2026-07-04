import 'dart:convert';

import 'package:ciaraos/models/github_activity.dart';
import 'package:ciaraos/services/ai_service.dart';
import 'package:http/http.dart' as http;

class GitHubService {
  GitHubService({String? baseUrl})
      : _baseUrl = baseUrl ?? AiServiceConfig.baseUrl;

  final String _baseUrl;

  Future<GitHubActivity?> fetchActivity({
    String? username,
    bool force = false,
  }) async {
    try {
      final params = <String, String>{};
      if (username != null && username.isNotEmpty) {
        params['username'] = username;
      }
      if (force) {
        params['force'] = 'true';
      }
      final uri = Uri.parse('$_baseUrl/api/github/activity').replace(
        queryParameters: params.isEmpty ? null : params,
      );
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 25));

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
    } catch (_) {
      return null;
    }
  }
}

class GitHubRateLimitException implements Exception {
  @override
  String toString() => 'GitHub API rate limit exceeded';
}
