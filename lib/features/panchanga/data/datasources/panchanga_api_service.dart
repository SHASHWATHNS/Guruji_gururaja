import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';

/// Low-level HTTP client for json.freeastrologyapi.com
/// All endpoints accept POST with body:
/// { year, month, date, hours, minutes, seconds, latitude, longitude, timezone, config:{observation_point, ayanamsha} }
class PanchangaApiService {
  PanchangaApiService({http.Client? client})
      : _client = client ?? http.Client(),
        base = AppConfig.astroBaseUrl;

  final http.Client _client;
  final String base;

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    // Project-wide API key
    'x-api-key': AppConfig.astroApiKey,
  };

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$base/$path');
    final res = await _client.post(uri, headers: _headers(), body: jsonEncode(body));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('API $path failed (${res.statusCode}): ${res.body}');
    }
    final text = (res.body).trim();
    if (text.isEmpty) return {};
    final decoded = jsonDecode(text);
    return decoded is Map<String, dynamic> ? decoded : {'output': decoded};
  }

  // ---- Endpoints ----

  // Sunrise/Sunset (this one worked in your tests)
  Future<Map<String, dynamic>> getSunriseAndSet(Map<String, dynamic> req) =>
      _post('getsunriseandset', req);

  Future<Map<String, dynamic>> tithiDurations(Map<String, dynamic> req) =>
      _post('tithi-durations', req);

  Future<Map<String, dynamic>> nakshatraDurations(Map<String, dynamic> req) =>
      _post('nakshatra-durations', req);

  Future<Map<String, dynamic>> yogaDurations(Map<String, dynamic> req) =>
      _post('yoga-durations', req);

  Future<Map<String, dynamic>> karanaDurations(Map<String, dynamic> req) =>
      _post('karana-durations', req);

  Future<Map<String, dynamic>> goodBadTimes(Map<String, dynamic> req) =>
      _post('good-bad-times', req);

  Future<Map<String, dynamic>> vedicweekday(Map<String, dynamic> req) =>
      _post('vedicweekday', req);

  Future<Map<String, dynamic>> lunarMonthInfo(Map<String, dynamic> req) =>
      _post('lunarmonthinfo', req);

  Future<Map<String, dynamic>> rituInfo(Map<String, dynamic> req) =>
      _post('rituinfo', req);

  Future<Map<String, dynamic>> samvatInfo(Map<String, dynamic> req) =>
      _post('samvatinfo', req);

  Future<Map<String, dynamic>> aayanam(Map<String, dynamic> req) =>
      _post('aayanam', req);

  // ---- Helpers for weird inline maps (good-bad-times returns strings) ----

  /// Parse "{starts_at: 2023-03-20 11:59:57, ends_at: 2023-03-20 12:48:17}"
  static Map<String, String> parseInlineMap(String? input) {
    if (input == null || input.trim().isEmpty) return {};
    final trimmed = input.trim();
    final content = trimmed.startsWith('{') && trimmed.endsWith('}')
        ? trimmed.substring(1, trimmed.length - 1)
        : trimmed;
    final entries = content.split(RegExp(r',(?![^{}]*\})'));
    final map = <String, String>{};
    for (final e in entries) {
      final idx = e.indexOf(':');
      if (idx <= 0) continue;
      final k = e.substring(0, idx).trim();
      final v = e.substring(idx + 1).trim();
      map[k] = v;
    }
    return map;
  }

  /// Parse "{1: {..}, 2: {..}}" into list of maps
  static List<Map<String, String>> parseIndexedInlineMap(String? input) {
    if (input == null || input.trim().isEmpty) return [];
    final outer = input.trim();
    final content = outer.startsWith('{') && outer.endsWith('}')
        ? outer.substring(1, outer.length - 1)
        : outer;

    final parts = <String>[];
    var depth = 0;
    var start = 0;
    for (var i = 0; i < content.length; i++) {
      final ch = content[i];
      if (ch == '{') depth++;
      if (ch == '}') depth--;
      if (ch == ',' && depth == 0) {
        parts.add(content.substring(start, i));
        start = i + 1;
      }
    }
    parts.add(content.substring(start));

    return parts.map((p) {
      final colon = p.indexOf(':');
      final inner = colon == -1 ? p : p.substring(colon + 1).trim();
      return parseInlineMap(inner);
    }).toList();
  }
}
