// lib/features/horoscope/tabs/dasa/dasha_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../form/horoscope_form_screen.dart' show BirthData;

/// Service to fetch Mahā & Bhukti from API and compute deeper levels client-side.
class DashaService {
  final Dio _dio;
  DashaService([Dio? dio])
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: AppConfig.astroBaseUrl,
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': AppConfig.astroApiKey,
          },
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

  Map<String, dynamic> _body(BirthData bd) => {
    'year': bd.dob.year,
    'month': bd.dob.month,
    'date': bd.dob.day,
    'hours': bd.tob.hour,
    'minutes': bd.tob.minute,
    'seconds': 0,
    'latitude': bd.lat ?? 0,
    'longitude': bd.lon ?? 0,
    'timezone': double.tryParse(bd.timezone) ?? 5.5,
    'config': AppConfig.defaultConfig(),
  };

  /// Some endpoints return: { statusCode, output: "<json-string>" }
  dynamic _unwrap(dynamic body) {
    dynamic raw = (body is Map && body.containsKey('output')) ? body['output'] : body;
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

  // ---------- Remote fetch (Mahā + Bhukti) ----------

  Future<List<Map<String, dynamic>>> fetchMaha(BirthData bd) async {
    final res = await _dio.post('/vimsottari/maha-dasas', data: _body(bd));
    final data = _unwrap(res.data);

    final list = <Map<String, dynamic>>[];
    if (data is Map) {
      final keys = data.keys.map((k) => k.toString()).toList()
        ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      for (final k in keys) {
        final node = data[k];
        if (node is Map) {
          list.add({
            'lord': (node['Lord'] ?? '-').toString(),
            'start': node['start_time']?.toString(),
            'end': node['end_time']?.toString(),
          });
        }
      }
    }
    return list;
  }

  Future<List<Map<String, dynamic>>> fetchAntarForLord(BirthData bd, String mahaLord) async {
    final res = await _dio.post('/vimsottari/maha-dasas-and-antar-dasas', data: _body(bd));
    final data = _unwrap(res.data);

    final list = <Map<String, dynamic>>[];
    if (data is Map && data.containsKey(mahaLord)) {
      final inner = data[mahaLord];
      if (inner is Map) {
        for (final e in inner.entries) {
          final v = e.value;
          if (v is Map) {
            list.add({
              'lord': e.key.toString(),
              'start': v['start_time']?.toString(),
              'end': v['end_time']?.toString(),
            });
          }
        }
      }
    }
    return list;
  }

  // ---------- Client-side compute (Pratyantar, Sūkṣma, Prāṇa) ----------

  static const List<String> _order = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'
  ];
  static const Map<String, int> _years = {
    'Ketu': 7, 'Venus': 20, 'Sun': 6, 'Moon': 10, 'Mars': 7,
    'Rahu': 18, 'Jupiter': 16, 'Saturn': 19, 'Mercury': 17,
  };

  DateTime? parse(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      if (s.length == 10) return DateTime.parse(s);
      return DateTime.parse(s.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  List<String> _rotatedOrderFrom(String startLord) {
    final idx = _order.indexWhere((e) => e.toLowerCase() == startLord.toLowerCase());
    if (idx < 0) return List<String>.from(_order);
    return [..._order.sublist(idx), ..._order.sublist(0, idx)];
  }

  /// Split parent [start,end] into 9 children, starting at [startLord]
  List<Map<String, dynamic>> splitChildren({
    required String startLord,
    required DateTime start,
    required DateTime end,
  }) {
    final rot = _rotatedOrderFrom(startLord);
    final parentMs = end.difference(start).inMilliseconds;
    if (parentMs <= 0) return [];
    const total = 120.0;

    final parts = <int>[];
    var acc = 0;
    for (int i = 0; i < 9; i++) {
      if (i == 8) {
        parts.add(parentMs - acc); // last one seals boundary
      } else {
        final w = (_years[rot[i]] ?? 0) / total;
        final ms = (parentMs * w).round();
        parts.add(ms);
        acc += ms;
      }
    }

    final out = <Map<String, dynamic>>[];
    var cursor = start;
    for (int i = 0; i < 9; i++) {
      final s = cursor;
      final e = s.add(Duration(milliseconds: parts[i]));
      out.add({
        'lord': rot[i],
        'start': s.toIso8601String().replaceFirst('T', ' '),
        'end': e.toIso8601String().replaceFirst('T', ' '),
      });
      cursor = e;
    }
    return out;
  }

  List<Map<String, dynamic>> computePratyantar(Map<String, dynamic> antar) {
    final start = parse(antar['start']);
    final end = parse(antar['end']);
    final lord = (antar['lord'] ?? '').toString();
    if (start == null || end == null || lord.isEmpty) return [];
    return splitChildren(startLord: lord, start: start, end: end);
  }

  List<Map<String, dynamic>> computeSookshma(Map<String, dynamic> praty) {
    final start = parse(praty['start']);
    final end = parse(praty['end']);
    final lord = (praty['lord'] ?? '').toString();
    if (start == null || end == null || lord.isEmpty) return [];
    return splitChildren(startLord: lord, start: start, end: end);
  }

  List<Map<String, dynamic>> computePrana(Map<String, dynamic> sook) {
    final start = parse(sook['start']);
    final end = parse(sook['end']);
    final lord = (sook['lord'] ?? '').toString();
    if (start == null || end == null || lord.isEmpty) return [];
    return splitChildren(startLord: lord, start: start, end: end);
  }

  /// Find active index by time
  int activeIndex(List<Map<String, dynamic>> items, DateTime now) {
    for (int i = 0; i < items.length; i++) {
      final s = parse(items[i]['start'] as String?);
      final e = parse(items[i]['end'] as String?);
      if (s != null && e != null && !now.isBefore(s) && !now.isAfter(e)) return i;
    }
    return -1;
  }
}
