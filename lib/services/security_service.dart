import 'dart:convert';

import 'package:ciaraos/models/security_activity.dart';
import 'package:ciaraos/services/ai_service.dart';
import 'package:ciaraos/services/security_cache.dart';
import 'package:http/http.dart' as http;

void _logNetworkRequest(String method, String url, {int? statusCode, String? error}) {
  // ignore: avoid_print
  print('📡 [NETWORK] $method $url${statusCode != null ? " → $statusCode" : ""}${error != null ? " ERROR: $error" : ""}');
}

enum SecurityEndpointAvailability {
  available,
  notConfigured,
  invalidCredentials,
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
    final url = '$_baseUrl/health';
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));
      _logNetworkRequest('GET', url, statusCode: response.statusCode);
      return response.statusCode == 200;
    } catch (e) {
      _logNetworkRequest('GET', url, error: e.toString());
      return false;
    }
  }

  Future<SecurityEndpointAvailability> _probeEndpoint(String path) async {
    final url = '$_baseUrl$path';
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));

      _logNetworkRequest('GET', url, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        return SecurityEndpointAvailability.available;
      }
      if (response.statusCode == 401) {
        return SecurityEndpointAvailability.invalidCredentials;
      }
      if (response.statusCode == 503) {
        return SecurityEndpointAvailability.notConfigured;
      }
      return SecurityEndpointAvailability.error;
    } catch (e) {
      _logNetworkRequest('GET', url, error: e.toString());
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

  Future<HackTheBoxProfile?> fetchHackTheBox({bool force = false}) async {
    final url = '$_baseUrl/api/security/hackthebox';
    try {
      final uri = Uri.parse(url).replace(
        queryParameters: force ? {'force': 'true'} : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 25));

      _logNetworkRequest('GET', url, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        final profile = HackTheBoxProfile.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        await SecurityCache.saveHackTheBox(profile);
        return profile;
      }
      return null;
    } catch (e) {
      _logNetworkRequest('GET', url, error: e.toString());
      return null;
    }
  }

  Future<HackerOneProfile?> fetchHackerOne({bool force = false}) async {
    final url = '$_baseUrl/api/security/hackerone';
    try {
      final uri = Uri.parse(url).replace(
        queryParameters: force ? {'force': 'true'} : null,
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 25));

      _logNetworkRequest('GET', url, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        final profile = HackerOneProfile.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        await SecurityCache.saveHackerOne(profile);
        return profile;
      }
      return null;
    } catch (e) {
      _logNetworkRequest('GET', url, error: e.toString());
      return null;
    }
  }

  Future<bool> logManualActivity(SecurityManualLog log) async {
    final url = '$_baseUrl/api/security/log';
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(log.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      _logNetworkRequest('POST', url, statusCode: response.statusCode);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['logged'] == true;
      }
      return false;
    } catch (e) {
      _logNetworkRequest('POST', url, error: e.toString());
      return false;
    }
  }
}
