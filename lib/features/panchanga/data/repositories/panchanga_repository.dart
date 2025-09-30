import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../response_normalizer.dart';

class PanchangaRepository {
  PanchangaRepository({http.Client? client})
      : client = client ?? http.Client();

  final http.Client client;

  Future<Map<String, dynamic>> postJson(
      String endpoint, {
        required Map<String, dynamic> body,
      }) async {
    final uri = Uri.parse('${AppConfig.astroBaseUrl}/$endpoint');

    final res = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': AppConfig.astroApiKey,
      },
      body: jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        'API $endpoint failed (${res.statusCode}): ${res.body}',
      );
    }

    final raw = jsonDecode(res.body) as Map<String, dynamic>;
    final normalized = normalizeAstroResponse(endpoint, raw);

    if (kDebugMode) {
      debugPrint('[ASTRO:$endpoint] $normalized');
    }
    return normalized;
  }
}
