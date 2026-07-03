import 'dart:convert';

import 'package:ciaraos/models/security_activity.dart';
import 'package:ciaraos/services/ai_service.dart';
import 'package:ciaraos/services/security_cache.dart';
import 'package:http/http.dart' as http;

enum SecurityEndpointAvailability {
  available,
  notConfigured,
  backendUnreachable,
  error,
}

class SecurityApiProbe {
  const SecurityApiProbe({
    required this.backendHealthy,
    required this.htb,
    required this.h1,
  });

  final bool backendHealthy;
  final SecurityEndpointAvailability htb;
  final SecurityEndpointAvailability h1;
}

class SecurityService {
  SecurityService({String? baseUrl})
      : _baseUrl = baseUrl ?? AiServiceConfig.baseUrl;

  final String _baseUrl;

  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<SecurityEndpointAvailability> _probeEndpoint(String path) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl$path'))
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        return SecurityEndpointAvailability.available;
      }
      if (response.statusCode == 503) {
        return SecurityEndpointAvailability.notConfigured;
      }
      return SecurityEndpointAvailability.error;
    } catch (_) {
      return SecurityEndpointAvailability.backendUnreachable;
    }
  }

  Future<SecurityApiProbe> probeEndpoints() async {
    final backendHealthy = await checkHealth();
    if (!backendHealthy) {
      return const SecurityApiProbe(
        backendHealthy: false,
        htb: SecurityEndpointAvailability.backendUnreachable,
        h1: SecurityEndpointAvailability.backendUnreachable,
      );
    }

    final results = await Future.wait([
      _probeEndpoint('/api/security/hackthebox'),
      _probeEndpoint('/api/security/hackerone'),
    ]);

    return SecurityApiProbe(
      backendHealthy: true,
      htb: results[0],
      h1: results[1],
    );
  }

  Future<HackTheBoxProfile?> fetchHackTheBox() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/security/hackthebox'))
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final profile = HackTheBoxProfile.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        await SecurityCache.saveHackTheBox(profile);
        return profile;
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
        final profile = HackerOneProfile.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        await SecurityCache.saveHackerOne(profile);
        return profile;
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
