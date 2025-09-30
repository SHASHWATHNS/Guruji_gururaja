// Centralized, normalized Panchanga API client.
// Handles weird endpoints that return JSON-encoded strings.

import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';

class PanchangaAPI {
  PanchangaAPI({Dio? dio})
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: AppConfig.astroBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': AppConfig.astroApiKey,
        },
      ));

  final Dio _dio;

  Map<String, dynamic> _normalize(dynamic data) {
    if (data is String) {
      try {
        final decoded = json.decode(data);
        return decoded is Map<String, dynamic> ? decoded : {'value': decoded};
      } catch (_) {
        return {'value': data};
      }
    }
    if (data is Map<String, dynamic>) return data;
    if (data is List) return {'list': data};
    return {'value': data};
  }

  Map<String, dynamic> _payload(
      DateTime dt, {
        required double lat,
        required double lon,
        required double tz,
      }) {
    return {
      'year': dt.year,
      'month': dt.month,
      'date': dt.day,
      'hours': dt.hour,
      'minutes': dt.minute,
      'seconds': dt.second,
      'latitude': lat,
      'longitude': lon,
      'timezone': tz,
      'config': AppConfig.defaultConfig(),
    };
  }

  Future<Map<String, dynamic>> _post(
      String path,
      Map<String, dynamic> body,
      ) async {
    try {
      final res = await _dio.post(path, data: body);
      if (res.statusCode == 200) {
        final data = res.data;
        if (data is Map && data.containsKey('output')) {
          return _normalize(data['output']);
        }
        return _normalize(data);
      }
      throw Exception('HTTP ${res.statusCode} ${res.statusMessage}');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? jsonEncode(e.response!.data)
          : e.message ?? 'Unknown network error';
      throw Exception('API $path failed (${e.response?.statusCode}): $msg');
    }
  }

  // ---------- Endpoints ----------
  Future<Map<String, dynamic>> getSunriseSunset(
      DateTime dt, {
        required double lat,
        required double lon,
        required double tz,
      }) =>
      _post('/getsunriseandset', _payload(dt, lat: lat, lon: lon, tz: tz));

  Future<Map<String, dynamic>> getTithi(
      DateTime dt, {
        required double lat,
        required double lon,
        required double tz,
      }) =>
      _post('/tithi-durations', _payload(dt, lat: lat, lon: lon, tz: tz));

  Future<Map<String, dynamic>> getNakshatra(
      DateTime dt, {
        required double lat,
        required double lon,
        required double tz,
      }) =>
      _post('/nakshatra-durations', _payload(dt, lat: lat, lon: lon, tz: tz));

  Future<Map<String, dynamic>> getYoga(
      DateTime dt, {
        required double lat,
        required double lon,
        required double tz,
      }) =>
      _post('/yoga-durations', _payload(dt, lat: lat, lon: lon, tz: tz));

  Future<Map<String, dynamic>> getKarana(
      DateTime dt, {
        required double lat,
        required double lon,
        required double tz,
      }) =>
      _post('/karana-durations', _payload(dt, lat: lat, lon: lon, tz: tz));

  Future<Map<String, dynamic>> getGoodBadTimes(
      DateTime dt, {
        required double lat,
        required double lon,
        required double tz,
      }) =>
      _post('/good-bad-times', _payload(dt, lat: lat, lon: lon, tz: tz));

  Future<Map<String, dynamic>> getVedicWeekday(
      DateTime dt, {
        required double lat,
        required double lon,
        required double tz,
      }) =>
      _post('/vedicweekday', _payload(dt, lat: lat, lon: lon, tz: tz));

  Future<Map<String, dynamic>> getLunarMonth(
      DateTime dt, {
        required double lat,
        required double lon,
        required double tz,
      }) =>
      _post('/lunarmonthinfo', _payload(dt, lat: lat, lon: lon, tz: tz));

  Future<Map<String, dynamic>> getRitu(
      DateTime dt, {
        required double lat,
        required double lon,
        required double tz,
      }) =>
      _post('/rituinfo', _payload(dt, lat: lat, lon: lon, tz: tz));

  Future<Map<String, dynamic>> getSamvat(
      DateTime dt, {
        required double lat,
        required double lon,
        required double tz,
      }) =>
      _post('/samvatinfo', _payload(dt, lat: lat, lon: lon, tz: tz));

  Future<Map<String, dynamic>> getAayanam(
      DateTime dt, {
        required double lat,
        required double lon,
        required double tz,
      }) =>
      _post('/aayanam', _payload(dt, lat: lat, lon: lon, tz: tz));
}
