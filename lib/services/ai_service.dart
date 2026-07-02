import 'dart:convert';

import 'package:ciaraos/models/executive_brief.dart';
import 'package:http/http.dart' as http;

class AiService {
  AiService({String? baseUrl}) : _baseUrl = baseUrl ?? 'http://localhost:8000';

  final String _baseUrl;

  Future<ExecutiveBrief?> fetchBrief(Map<String, dynamic> payload) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/brief'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return ExecutiveBrief.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
