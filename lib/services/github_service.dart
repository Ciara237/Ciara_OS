import 'dart:convert';

import 'package:ciaraos/models/github_activity.dart';
import 'package:ciaraos/services/ai_service.dart';
import 'package:http/http.dart' as http;

class GitHubService {
  GitHubService({String? baseUrl})
      : _baseUrl = baseUrl ?? AiServiceConfig.baseUrl;

  final String _baseUrl;

  Future<GitHubActivity?> fetchActivity({String? username}) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/github/activity').replace(
        queryParameters:
            username != null && username.isNotEmpty ? {'username': username} : null,
      );
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return GitHubActivity.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
