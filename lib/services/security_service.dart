import 'dart:convert';

import 'package:ciaraos/models/security_activity.dart';
import 'package:ciaraos/services/ai_service.dart';
import 'package:http/http.dart' as http;

class SecurityService {
  SecurityService({String? baseUrl})
      : _baseUrl = baseUrl ?? AiServiceConfig.baseUrl;

  final String _baseUrl;

  Future<HackTheBoxProfile?> fetchHackTheBox() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/security/hackthebox'))
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        return HackTheBoxProfile.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<HackerOneProfile?> fetchHackerOne() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/security/hackerone'))
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        return HackerOneProfile.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> logManualActivity(SecurityManualLog log) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/security/log'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(log.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['logged'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
