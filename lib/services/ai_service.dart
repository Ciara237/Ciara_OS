import 'dart:convert';

import 'package:ciaraos/models/executive_brief.dart';
import 'package:http/http.dart' as http;

/// Override at run time:
/// `flutter run --dart-define=CIARA_AI_BACKEND_URL=http://localhost:8001`
abstract final class AiServiceConfig {
  static const String baseUrl = String.fromEnvironment(
    'CIARA_AI_BACKEND_URL',
    defaultValue: 'http://localhost:8001',
  );
}

class AiFetchResult {
  const AiFetchResult._({
    this.brief,
    this.errorMessage,
    this.reachedBackend = false,
  });

  final ExecutiveBrief? brief;
  final String? errorMessage;
  final bool reachedBackend;

  bool get isSuccess => brief != null;

  factory AiFetchResult.success(ExecutiveBrief brief) {
    return AiFetchResult._(brief: brief, reachedBackend: true);
  }

  factory AiFetchResult.connectionFailure(String message) {
    return AiFetchResult._(errorMessage: message);
  }

  factory AiFetchResult.httpFailure({
    required int statusCode,
    required String body,
  }) {
    final lowerBody = body.toLowerCase();
    String message;

    if (statusCode == 500 && lowerBody.contains('groq_api_key')) {
      message = 'AI features are not available right now. Try again later.';
    } else if (lowerBody.contains('invalid api key') ||
        lowerBody.contains('invalid_api_key')) {
      message = 'AI features could not authenticate. Try again later.';
    } else if (statusCode == 502 &&
        lowerBody.contains('invalid_ai_response')) {
      message = 'The AI response was invalid. Try again.';
    } else if (statusCode == 502) {
      message = 'AI features are temporarily unavailable. Try again later.';
    } else {
      message = 'Something went wrong. Try again later.';
    }

    return AiFetchResult._(
      errorMessage: message,
      reachedBackend: true,
    );
  }

  factory AiFetchResult.parseFailure() {
    return const AiFetchResult._(
      errorMessage: 'The brief could not be loaded. Try again.',
      reachedBackend: true,
    );
  }
}

class AiService {
  AiService({String? baseUrl}) : _baseUrl = baseUrl ?? AiServiceConfig.baseUrl;

  final String _baseUrl;

  Future<AiFetchResult> fetchBrief(Map<String, dynamic> payload) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/brief'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        try {
          final brief = ExecutiveBrief.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>,
          );
          return AiFetchResult.success(brief);
        } catch (_) {
          return AiFetchResult.parseFailure();
        }
      }

      return AiFetchResult.httpFailure(
        statusCode: response.statusCode,
        body: response.body,
      );
    } on Exception catch (_) {
      return AiFetchResult.connectionFailure(
        'Could not generate your brief. Check your connection and try again.',
      );
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
