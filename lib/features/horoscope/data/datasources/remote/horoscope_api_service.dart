import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';

class HoroscopeApiService {
  // ====== CONFIG ======
  static const _baseUrl = 'https://json.freeastrologyapi.com';
  // NOTE: your current test key. Move to secure storage/env for prod.
  static const _apiKey = 'Gn8Fe7i5YiOy87nmWxU19aycrUNs3Ug42u1dVC8f';

  final Dio _dio;

  HoroscopeApiService({Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 20),
          headers: const {
            'Content-Type': 'application/json',
          },
          // we'll handle errors ourselves
          validateStatus: (code) => code != null && code >= 200 && code < 600,
        ),
      ) {
    // always set latest API key header (easy to swap later)
    _dio.options.headers['x-api-key'] = _apiKey;
  }

  // ====== tiny in-memory cache + retry ======
  static final Map<String, dynamic> _cache = {};
  String _ck(String path, Map<String, dynamic> payload) =>
      '$path::${json.encode(payload)}';

  Future<Response> _postWithRetry(String path, Map<String, dynamic> payload) async {
    final key = _ck(path, payload);
    if (_cache.containsKey(key)) {
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 200,
        data: _cache[key],
      );
    }

    const maxAttempts = 3;
    var attempt = 0;
    final rnd = Random();

    while (true) {
      attempt++;
      try {
        final res = await _dio.post(path, data: payload);

        final sc = res.statusCode ?? 0;
        if (sc >= 200 && sc < 300) {
          dynamic d = res.data;
          if (d is String) {
            try { d = json.decode(d); } catch (_) {}
          }
          _cache[key] = d;
          return Response(
            requestOptions: res.requestOptions,
            statusCode: sc,
            data: d,
          );
        }

        // polite backoff on rate-limit
        if (sc == 429 && attempt < maxAttempts) {
          final retryAfter = res.headers.map['retry-after']?.first;
          final wait = retryAfter != null
              ? Duration(seconds: int.tryParse(retryAfter) ?? 1)
              : Duration(milliseconds: 600 * attempt + rnd.nextInt(200));
          await Future.delayed(wait);
          continue;
        }

        throw _mkErr(res, _readErr(res));
      } on DioException catch (e) {
        if (attempt >= maxAttempts) rethrow;
        // small exponential backoff for transient network errors
        await Future.delayed(Duration(milliseconds: 400 * attempt));
        if (e.response != null && (e.response!.statusCode ?? 0) >= 400 && (e.response!.statusCode ?? 0) != 429) {
          // non-retryable HTTP errors
          rethrow;
        }
      }
    }
  }

  DioException _mkErr(Response res, String msg) => DioException(
    requestOptions: res.requestOptions,
    response: res,
    error: msg,
    type: DioExceptionType.badResponse,
  );

  // ====== PLANETS ======
  Future<List<Map<String, dynamic>>> getPlanets(
      Map<String, dynamic> payload,
      ) async {
    final res = await _postWithRetry('/planets', payload);
    final data = res.data;

    // Common shapes the API returns
    if (data is Map && data['planets'] is List) {
      return (data['planets'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    if (data is Map && data['output'] is Map) {
      return _expandNumericMap(Map<String, dynamic>.from(data['output'] as Map));
    }
    if (data is Map && data['output'] is List) {
      final out = data['output'] as List;
      if (out.isNotEmpty && out.first is Map) {
        return _expandNumericMap(Map<String, dynamic>.from(out.first as Map));
      }
    }
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: 'Unexpected planets response shape: ${res.data}',
      type: DioExceptionType.badResponse,
    );
  }

  List<Map<String, dynamic>> _expandNumericMap(Map<String, dynamic> m) {
    final keys = m.keys.toList()
      ..sort((a, b) {
        final ai = int.tryParse(a.toString());
        final bi = int.tryParse(b.toString());
        if (ai == null && bi == null) return a.toString().compareTo(b.toString());
        if (ai == null) return 1;
        if (bi == null) return -1;
        return ai.compareTo(bi);
      });
    return keys
        .where((k) => m[k] is Map)
        .map((k) => Map<String, dynamic>.from(m[k] as Map))
        .toList();
  }

  // ====== GENERIC HELPERS ======
  Future<Map<String, dynamic>> _postAndUnwrap(
      String path,
      Map<String, dynamic> payload,
      ) async {
    final res = await _postWithRetry(path, payload);

    dynamic data = res.data;
    if (data is String) {
      try { data = json.decode(data); } catch (_) {}
    }
    if (data is! Map) return {};

    // Common wrappers: output/data/result sometimes hold the real map,
    // sometimes they’re a single-element list with a map.
    Map<String, dynamic> m = Map<String, dynamic>.from(data as Map);
    for (final k in const ['output', 'data', 'result']) {
      final v = m[k];
      if (v is Map) {
        m = Map<String, dynamic>.from(v);
      } else if (v is List && v.isNotEmpty && v.first is Map) {
        m = Map<String, dynamic>.from(v.first as Map);
      }
    }
    return m;
  }

  Future<dynamic> _postRaw(
      String path,
      Map<String, dynamic> payload,
      ) async {
    final res = await _postWithRetry(path, payload);
    return res.data;
  }

  // ====== PANCHANG ENDPOINTS ======
  // All of these expect your payload with "config": {"observation_point":"topocentric","ayanamsha":"lahiri"}

  /// Tithi information
  Future<Map<String, dynamic>> getTithi(Map<String, dynamic> payload) async =>
      _postAndUnwrap('/tithi-durations', payload);

  /// Nakshatra durations (Star)
  Future<Map<String, dynamic>> getNakshatra(Map<String, dynamic> payload) async =>
      _postAndUnwrap('/nakshatra-durations', payload);

  /// Yoga timings
  Future<Map<String, dynamic>> getYoga(Map<String, dynamic> payload) async =>
      _postAndUnwrap('/yoga-durations', payload);

  /// Karana timings
  Future<Map<String, dynamic>> getKarana(Map<String, dynamic> payload) async =>
      _postAndUnwrap('/karana-durations', payload);

  /// Lunar month information (Tamil month/year)
  Future<Map<String, dynamic>> getLunarMonth(Map<String, dynamic> payload) async =>
      _postAndUnwrap('/lunarmonthinfo', payload);

  // ====== VIMSOTTARI DASAs (NEW) ======

  /// POST https://json.freeastrologyapi.com/vimsottari/maha-dasas
  /// Returns a list (or wrapped list) of Mahadasa periods.
  Future<dynamic> getVimsottariMahaDasas(Map<String, dynamic> payload) async =>
      _postRaw('/vimsottari/maha-dasas', payload);

  /// POST https://json.freeastrologyapi.com/vimsottari/maha-dasas-and-antar-dasas
  /// Returns Mahadasa with nested Antar (Bhukti) periods.
  Future<dynamic> getVimsottariMahaAndAntarDasas(Map<String, dynamic> payload) async =>
      _postRaw('/vimsottari/maha-dasas-and-antar-dasas', payload);

  // ====== ERROR HELPER ======
  String _readErr(Response res) {
    final raw = res.data;
    try {
      final m = raw is String ? json.decode(raw) : raw;
      if (m is Map && m['message'] != null) return 'HTTP ${res.statusCode}: ${m['message']}';
      if (m is Map && m['error'] != null) return 'HTTP ${res.statusCode}: ${m['error']}';
    } catch (_) {}
    return 'HTTP ${res.statusCode}: $raw';
  }
}
