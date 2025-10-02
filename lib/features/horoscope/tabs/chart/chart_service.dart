import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';

class ChartService {
  final Dio _dio;
  ChartService([Dio? dio])
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: AppConfig.astroBaseUrl,
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': AppConfig.astroApiKey,
          },
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

  // Convert timezone string to hours (supports "5.5" or "Asia/Kolkata")
  double _tzHours(String tz) {
    final v = double.tryParse(tz);
    if (v != null) return v;
    if (tz.toLowerCase().contains('kolkata')) return 5.5;
    return 5.5;
  }

  Map<String, dynamic> bodyFrom({
    required DateTime birth,
    required double lat,
    required double lon,
    required String tz,
  }) {
    return {
      'year': birth.year,
      'month': birth.month,
      'date': birth.day,
      'hours': birth.hour,
      'minutes': birth.minute,
      'seconds': birth.second,
      'latitude': lat,
      'longitude': lon,
      'timezone': _tzHours(tz),
      'config': AppConfig.defaultConfig(),
    };
  }

  dynamic _unwrap(dynamic data) {
    // Accept plain JSON or { output: "<json>" } or { output: {...} }
    var raw = (data is Map<String, dynamic>) ? (data['output'] ?? data) : data;
    for (int i = 0; i < 3; i++) {
      if (raw is String) {
        try {
          raw = jsonDecode(raw);
        } catch (_) {
          break;
        }
      }
    }
    return raw;
  }

  /// Rāsi chart SVG
  Future<String> fetchRaasiSvg(Map<String, dynamic> body) async {
    final r = await _dio.post('/horoscope-chart-svg-code', data: body);
    final d = r.data;
    if (d is String) return d;
    final out = _unwrap(d);
    return out is String ? out : (out['svg']?.toString() ?? '');
  }

  /// Navāṁśa chart SVG
  Future<String> fetchNavamsaSvg(Map<String, dynamic> body) async {
    final r = await _dio.post('/navamsa-chart-svg-code', data: body);
    final d = r.data;
    if (d is String) return d;
    final out = _unwrap(d);
    return out is String ? out : (out['svg']?.toString() ?? '');
  }

  /// Planets extended (table)
  Future<List<PlanetRow>> fetchPlanetsExtended(Map<String, dynamic> body) async {
    final r = await _dio.post('/planets/extended', data: body);
    final root = (r.data['output'] ?? {}) as Map<String, dynamic>;

    // Ordered, with outer three commented out as requested.
    const order = [
      'Ascendant',
      'Sun',
      'Moon',
      'Mars',
      'Mercury',
      'Jupiter',
      'Venus',
      'Saturn',
      'Rahu',
      'Ketu',
      // 'Uranus',
      // 'Neptune',
      // 'Pluto',
    ];

    final rows = <PlanetRow>[];
    for (final key in order) {
      final raw = (root[key] ?? {}) as Map<String, dynamic>;
      final name = (raw['localized_name'] ?? key).toString();

      // Retro marker (keep Ascendant clean)
      final isRetro = (raw['isRetro']?.toString().toLowerCase() == 'true');
      final displayName = (isRetro && key != 'Ascendant') ? '$name (va)' : name;

      rows.add(
        PlanetRow(
          name: displayName,
          house: (raw['house_number'] ?? '').toString(),
          sign: (raw['zodiac_sign_name'] ?? '').toString(),
          lord: (raw['zodiac_sign_lord'] ?? '').toString(),
          deg: (raw['degrees'] ?? '').toString(),
          min: (raw['minutes'] ?? '').toString(),
          sec: _fmtSec(raw['seconds']),
          nakshatra: (raw['nakshatra_name'] ?? '').toString(),
          pada: (raw['nakshatra_pada'] ?? '').toString(),
        ),
      );
    }
    return rows;
  }

  String _fmtSec(dynamic v) {
    final d = (v is num) ? v.toDouble() : double.tryParse('$v');
    return d == null ? '' : d.toStringAsFixed(2);
  }
}

class PlanetRow {
  final String name;
  final String sign;
  final String lord;
  final String house;
  final String deg;
  final String min;
  final String sec;
  final String nakshatra;
  final String pada;
  PlanetRow({
    required this.name,
    required this.sign,
    required this.lord,
    required this.house,
    required this.deg,
    required this.min,
    required this.sec,
    required this.nakshatra,
    required this.pada,
  });
}
