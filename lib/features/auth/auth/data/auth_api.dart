// lib/features/auth/data/auth_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

const String kBaseUrl = 'https://gurujigururaja.in/api';
const String kRegisterEndpoint = '$kBaseUrl/register.php';
const String kLoginEndpoint    = '$kBaseUrl/login.php';

class AuthApiResponse {
  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? userRaw;
  const AuthApiResponse({required this.success, required this.message, this.token, this.userRaw});
}

class AuthApi {
  const AuthApi();

  Future<AuthApiResponse> register({
    required String name,
    required String phone,
    required String password,
    required String email, // <-- make email required to match your PHP
  }) async {
    final payload = {
      'name': name,
      'phone': phone,
      'password': password,
      'email': email,
    };

    final r = await http.post(
      Uri.parse(kRegisterEndpoint),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    // Debug
    // (Check these in your run console)
    // ignore: avoid_print
    print('[REGISTER] status=${r.statusCode}');
    // ignore: avoid_print
    print('[REGISTER] headers=${r.headers}');
    // ignore: avoid_print
    print('[REGISTER] body=${r.body}');

    return _parse(r);
  }

  Future<AuthApiResponse> login({
    required String phone,
    required String password,
  }) async {
    final payload = {
      'phone': phone,
      'password': password,
    };

    final r = await http.post(
      Uri.parse(kLoginEndpoint),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    // Debug
    // ignore: avoid_print
    print('[LOGIN] status=${r.statusCode}');
    // ignore: avoid_print
    print('[LOGIN] headers=${r.headers}');
    // ignore: avoid_print
    print('[LOGIN] body=${r.body}');

    return _parse(r);
  }

  AuthApiResponse _parse(http.Response r) {
    final raw = r.body.trim();

    // Try JSON
    try {
      if (raw.isNotEmpty &&
          (r.headers['content-type']?.contains('application/json') == true ||
              raw.startsWith('{') || raw.startsWith('['))) {
        final body = jsonDecode(raw);

        // ✅ Only treat explicit success as success.
        // Do NOT use http 2xx to auto-pass.
        final bool success =
            body['success'] == true ||
                (body['status'] is String && (body['status'] as String).toLowerCase() == 'success') ||
                body['error'] == false;

        final String message =
            body['message']?.toString() ??
                body['msg']?.toString() ??
                (success ? 'OK' : 'Failed');

        String? token;
        for (final k in ['token','access_token','jwt','auth_token']) {
          if (body[k] is String && (body[k] as String).isNotEmpty) { token = body[k]; break; }
        }

        Map<String, dynamic>? user;
        for (final k in ['user','data','profile']) {
          final v = body[k];
          if (v is Map<String, dynamic>) { user = Map<String, dynamic>.from(v); break; }
        }

        return AuthApiResponse(success: success, message: message, token: token, userRaw: user);
      }
    } catch (_) {
      // fall through to non-JSON handling
    }

    // Non-JSON: treat as failure unless it clearly spells success keywords
    final firstLine = raw.split('\n').first.trim().toLowerCase();
    final bool successFallback = firstLine == 'success' || firstLine == 'ok' || firstLine == '1';
    final msgOut = (raw.isEmpty ? 'Invalid server response' : raw.split('\n').first.trim());
    return AuthApiResponse(success: successFallback, message: msgOut, userRaw: null);
  }
}
