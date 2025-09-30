// lib/features/horoscope/data/repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guruji_gururaja/features/horoscope/data/svg_tools.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_config.dart';
import '../form/horoscope_form_screen.dart' show BirthData;
import '../tabs/summary/summary_service.dart' show AstroRequest;
import 'cache.dart';

class HoroscopeRepository {
  HoroscopeRepository({Dio? dio, Cache? cache})
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: AppConfig.astroBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': AppConfig.astroApiKey,
        },
      )),
        _cache = cache ?? Cache();

  final Dio _dio;
  final Cache _cache;

  // ---------- SUMMARY ----------
  Future<Map<String, dynamic>> getSummary(AstroRequest req) async {
    final key = _k('summary', {
      't': req.birthIST.toIso8601String(),
      'la': req.lat,
      'lo': req.lon,
      'tz': req.tz,
      'pl': req.place,
    });

    return _cache.getJson(key, () async {
      // planets/extended
      final pxResp = await _dio.post('/planets/extended', data: _body(req));
      final px = (pxResp.data['output'] ?? {}) as Map;

      final asc = (px['Ascendant'] ?? {}) as Map;
      final sun = (px['Sun'] ?? {}) as Map;
      final moon = (px['Moon'] ?? {}) as Map;

      // tithi (unchanged)
      final tithi =
      await _unwrapJson(await _dio.post('/tithi-durations', data: _body(req)));
      final tithiNumber = _int(tithi, ['number', 'tithi', 'tithi_number']) ?? 0;
      final tithiName   = _str(tithi,  ['name', 'tithi_name']);

// --- YOGA (robust across Map | List | nested + weird encodings)
      final yogaResp = await _dio.post('/yoga-durations', data: _body(req));
      final yogaName = _pickDurationName(
        yogaResp.data,
        req.birthIST,
        const ['name', 'yoga', 'yoga_name'],
      );

// --- KARANA (same robustness)
      final karanaResp = await _dio.post('/karana-durations', data: _body(req));
      final karanaName = _pickDurationName(
        karanaResp.data,
        req.birthIST,
        const ['name', 'karana', 'karana_name'],
      );
      // Yogi/Avayogi
      final pair = _computeYogiAvayogi(
        (sun['fullDegree'] as num?)?.toDouble() ?? 0,
        (moon['fullDegree'] as num?)?.toDouble() ?? 0,
      );

      final out = <String, dynamic>{
        'name': req.name,
        'birthIST': req.birthIST.toIso8601String(),
        'birthplace': req.place,
        'lagnam': (asc['zodiac_sign_name'] ?? '—').toString(),
        'raasi': (moon['zodiac_sign_name'] ?? '—').toString(),
        'nakshatra': (moon['nakshatra_name'] ?? '—').toString(),
        'tithiNumber': tithiNumber,
        'tithiName': tithiName,
        'yogaName': yogaName,
        'karanaName': karanaName,
        'yogiNakshatra': pair.$1,
        'avayogiNakshatra': pair.$2,
        'tamilMonth': _tamilMonth((sun['zodiac_sign_name'] ?? '—').toString()),
        'tamilYear': _tamilYear(req.birthIST),
        'sunLongitudeDeg':
        (sun['fullDegree'] as num?)?.toDouble() ?? double.nan,
        'moonLongitudeDeg':
        (moon['fullDegree'] as num?)?.toDouble() ?? double.nan,
      };
      return out;
    });
  }

  String _pickDurationName(dynamic body, DateTime ist, List<String> nameKeys) {
    final raw = _unwrapOutput(body);

    // A) Simple map with a name
    if (raw is Map) {
      final direct = _str(raw, nameKeys);
      if (direct != '—') return direct;
      // nested maps: take first that has a name
      for (final v in raw.values) {
        if (v is Map) {
          final n2 = _str(v, nameKeys);
          if (n2 != '—') return n2;
        }
      }
      return '—';
    }

    // B) List of durations: prefer the one covering birth time
    if (raw is List) {
      DateTime? _parse(dynamic v) {
        if (v == null) return null;
        final s = v.toString();
        try {
          if (s.length == 10) return DateFormat('yyyy-MM-dd').parseUtc(s);
          return DateTime.parse(s.replaceFirst(' ', 'T'));
        } catch (_) {
          return null;
        }
      }

      for (final e in raw) {
        if (e is Map) {
          final st = _parse(e['start_time']);
          final en = _parse(e['end_time']);
          if (st != null && en != null && !ist.isBefore(st) && ist.isBefore(en)) {
            final n = _str(e, nameKeys);
            if (n != '—') return n;
          }
        }
      }
      // fallback: first with a name
      for (final e in raw) {
        if (e is Map) {
          final n = _str(e, nameKeys);
          if (n != '—') return n;
        }
      }
      return '—';
    }

    return '—';
  }

  Future<Map<String, dynamic>> getCharts(BirthData bd) async {
    final key = _k('charts', {
      'y': bd.dob.year,
      'm': bd.dob.month,
      'd': bd.dob.day,
      'h': bd.tob.hour,
      'mi': bd.tob.minute,
      'la': bd.lat,
      'lo': bd.lon,
    });

    return _cache.getJson(key, () async {
      final b = _bodyFromBirth(bd);

      // 1) Fetch vendor SVG payloads
      final raasiResp = await _dio.post('/horoscope-chart-svg-code', data: b);
      final navResp   = await _dio.post('/navamsa-chart-svg-code',   data: b);

      // 2) Rebuild clean charts from vendor text labels
      final raasiSvg = SvgTools.rebuildCleanChartSvg(raasiResp.data, title: 'Rāśi');
      final navSvg   = SvgTools.rebuildCleanChartSvg(navResp.data,   title: 'Navāṁśa');

      // 3) Planets (unchanged)
      final pxResp = await _dio.post('/planets/extended', data: b);
      final output = (pxResp.data['output'] ?? {}) as Map<String, dynamic>;

      const order = ['Ascendant','Sun','Moon','Mars','Mercury','Jupiter','Venus','Saturn','Rahu','Ketu','Uranus','Neptune','Pluto'];
      final rows = <Map<String, dynamic>>[];
      for (final key in order) {
        final raw = (output[key] ?? {}) as Map<String, dynamic>;
        final baseName = (raw['localized_name'] ?? key).toString();
        final isRetro = raw['isRetro']?.toString().toLowerCase() == 'true';
        final name = (isRetro && key != 'Ascendant') ? '$baseName (va)' : baseName;
        rows.add({
          'name': name,
          'sign': (raw['zodiac_sign_name'] ?? '').toString(),
          'lord': (raw['zodiac_sign_lord'] ?? '').toString(),
          'house': (raw['house_number'] ?? '').toString(),
          'deg': (raw['degrees'] ?? '').toString(),
          'min': (raw['minutes'] ?? '').toString(),
          'sec': _fmtSec(raw['seconds']),
          'nakshatra': (raw['nakshatra_name'] ?? '').toString(),
          'pada': (raw['nakshatra_pada'] ?? '').toString(),
        });
      }

      return {
        'raasiSvg': raasiSvg,
        'navamsaSvg': navSvg,
        'planets': rows,
      };
    });
  }


  // ---------- DASHA ----------
  Future<Map<String, dynamic>> getDasha(BirthData bd) async {
    final key = _k('dasha', {
      'y': bd.dob.year,
      'm': bd.dob.month,
      'd': bd.dob.day,
      'h': bd.tob.hour,
      'mi': bd.tob.minute,
      'la': bd.lat,
      'lo': bd.lon,
    });

    return _cache.getJson(key, () async {
      final b = _bodyFromBirth(bd);

      // Mahā dasha list
      final mahaRes = await _dio.post('/vimsottari/maha-dasas', data: b);
      final mahaData = _unwrapOutput(mahaRes.data);
      final mahaList = <Map<String, dynamic>>[];
      if (mahaData is Map) {
        final keys = mahaData.keys.map((k) => k.toString()).toList()
          ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
        for (final k in keys) {
          final node = mahaData[k];
          if (node is Map) {
            mahaList.add({
              'lord': (node['Lord'] ?? '-').toString(),
              'start': _toIso(node['start_time']),
              'end': _toIso(node['end_time']),
            });
          }
        }
      }

      // Antar for each Mahā
      final antarRes =
      await _dio.post('/vimsottari/maha-dasas-and-antar-dasas', data: b);
      final antarData = _unwrapOutput(antarRes.data);

      final Map<String, List<Map<String, dynamic>>> antarByLord = {};
      if (antarData is Map) {
        for (final m in mahaList) {
          final lord = m['lord'] as String;
          final node = antarData[lord];
          final list = <Map<String, dynamic>>[];
          if (node is Map) {
            for (final e in node.entries) {
              final v = e.value;
              if (v is Map) {
                list.add({
                  'lord': e.key.toString(),
                  'start': _toIso(v['start_time']),
                  'end': _toIso(v['end_time']),
                });
              }
            }
          }
          antarByLord[lord] = list;
        }
      }

      return {
        'maha': mahaList,
        'antarByLord': antarByLord,
      };
    });
  }

  // ---------- helpers ----------

  Map<String, dynamic> _body(AstroRequest req) => {
    'year': req.birthIST.year,
    'month': req.birthIST.month,
    'date': req.birthIST.day,
    'hours': req.birthIST.hour,
    'minutes': req.birthIST.minute,
    'seconds': req.birthIST.second,
    'latitude': req.lat,
    'longitude': req.lon,
    'timezone': _tzToHours(req.tz),
    'config': AppConfig.defaultConfig(),
  };

  Map<String, dynamic> _bodyFromBirth(BirthData bd) => {
    'year': bd.dob.year,
    'month': bd.dob.month,
    'date': bd.dob.day,
    'hours': bd.tob.hour,
    'minutes': bd.tob.minute,
    'seconds': 0,
    'latitude': bd.lat ?? 0,
    'longitude': bd.lon ?? 0,
    'timezone': _tzToHours(bd.timezone),
    'config': AppConfig.defaultConfig(),
  };

  double _tzToHours(String tz) {
    final v = double.tryParse(tz);
    if (v != null) return v;
    if (tz.toLowerCase().contains('kolkata')) return 5.5;
    return 5.5;
  }

  String _k(String kind, Map<String, Object?> parts) => '$kind:${jsonEncode(parts)}';

  Future<Map<String, dynamic>> _unwrapJson(Response res) async {
    final body = res.data;
    final data = _unwrapOutput(body);
    if (data is Map) return data.cast<String, dynamic>();
    return {};
  }

  dynamic _unwrapOutput(dynamic body) {
    // Handles {"output":"\"{...}\""} or {"output":{...}} or plain {...}
    dynamic raw =
    (body is Map && body.containsKey('output')) ? body['output'] : body;
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

  /// NEW: robustly pull an <svg ...> string out of varied API shapes.
  String _unwrapSvg(dynamic body) {
    // Handle {"output":"<svg ...>...</svg>"} or {"output":{"svg":"..."}} or plain "<svg...>"
    dynamic raw = (body is Map && body.containsKey('output')) ? body['output'] : body;
    if (raw is Map && raw['svg'] is String) raw = raw['svg'];
    var s = raw?.toString() ?? '';

    // Some responses double-encode JSON; try one safe decode pass.
    if (!s.contains('<svg')) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is String) s = decoded;
        if (decoded is Map && decoded['svg'] is String) s = decoded['svg'] as String;
      } catch (_) {/* ignore */}
    }

    // Strip things flutter_svg commonly chokes on.
    // 1) <style>…</style>
    s = s.replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), '');
    // 2) HTML/SVG comments
    s = s.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
    // (Optional) strip whitespace around it
    s = s.trim();

    // Ensure it really is an SVG
    if (!s.contains('<svg')) return '';
    return s;
  }

  (String, String) _computeYogiAvayogi(double sunLon, double moonLon) {
    double norm(double v) {
      v %= 360.0;
      if (v < 0) v += 360.0;
      return v;
    }

    final yogaPoint = norm(sunLon + moonLon);
    final yogaIdx = (yogaPoint / (360 / 27)).floor() % 27;
    final yi = (yogaIdx + 7) % 27;
    final ai = (yogaIdx + 21) % 27;
    const names = [
      'Ashwini',
      'Bharani',
      'Krittika',
      'Rohini',
      'Mrigashira',
      'Ardra',
      'Punarvasu',
      'Pushya',
      'Ashlesha',
      'Magha',
      'Purva Phalguni',
      'Uttara Phalguni',
      'Hasta',
      'Chitra',
      'Swati',
      'Vishakha',
      'Anuradha',
      'Jyeshtha',
      'Mula',
      'Purva Ashadha',
      'Uttara Ashadha',
      'Shravana',
      'Dhanishta',
      'Shatabhisha',
      'Purva Bhadrapada',
      'Uttara Bhadrapada',
      'Revati'
    ];
    return (names[yi], names[ai]);
  }

  String _tamilMonth(String sunSign) {
    const map = {
      'Aries': 'சித்திரை',
      'Taurus': 'வைகாசி',
      'Gemini': 'ஆனி',
      'Cancer': 'ஆடி',
      'Leo': 'ஆவணி',
      'Virgo': 'புரட்டாசி',
      'Libra': 'ஐப்பசி',
      'Scorpio': 'கார்த்திகை',
      'Sagittarius': 'மார்கழி',
      'Capricorn': 'தை',
      'Aquarius': 'மாசி',
      'Pisces': 'பங்குனி',
    };
    return map[sunSign] ?? '—';
  }

  String _tamilYear(DateTime ist) {
    const cycle = [
      'Prabhava',
      'Vibhava',
      'Shukla',
      'Pramoduta',
      'Prachopati',
      'Angirasa',
      'Srimukha',
      'Bhava',
      'Yuva',
      'Dhatu',
      'Ishvara',
      'Vehudanya',
      'Pramati',
      'Vikrama',
      'Vishu',
      'Chitrabhanu',
      'Subhanu',
      'Dharana',
      'Parthiba',
      'Viya',
      'Sarvajit',
      'Sarvadhari',
      'Virodhi',
      'Vikruti',
      'Kara',
      'Nandana',
      'Vijaya',
      'Jaya',
      'Manmatha',
      'Dhunmuki',
      'Hevilambi',
      'Vilambi',
      'Vikari',
      'Sarvari',
      'Plava',
      'Subhakrith',
      'Shobhakrith',
      'Krodhi',
      'Vishvavasu',
      'Parabhava',
      'Plavanga',
      'Kilaka',
      'Saumya',
      'Sadharana',
      'Virodhikruthi',
      'Paritapi',
      'Pramadeecha',
      'Ananda',
      'Rakshasa',
      'Nala',
      'Pingala',
      'Kalayukthi',
      'Siddharthi',
      'Roudri',
      'Dhunmati',
      'Dundubhi',
      'Rudhurotgari',
      'Raktakshi',
      'Krodhana',
      'Akshaya',
    ];
    final boundary = DateTime(ist.year, 4, 14);
    final greg = ist.isBefore(boundary) ? ist.year - 1 : ist.year;
    final index = (greg - 1987) % 60;
    return cycle[(index + 60) % 60];
  }

  String _fmtSec(dynamic v) {
    final d = (v is num) ? v.toDouble() : double.tryParse('$v');
    if (d == null) return '';
    return d.toStringAsFixed(2);
  }

  String? _toIso(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    try {
      if (s.length == 10) {
        return DateFormat('yyyy-MM-dd').parseUtc(s).toIso8601String();
      }
      return DateTime.parse(s.replaceFirst(' ', 'T')).toIso8601String();
    } catch (_) {
      return s;
    }
  }

  String _str(Map m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return '—';
  }

  int? _int(Map m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v is num) return v.toInt();
      if (v is String) {
        final p = int.tryParse(v);
        if (p != null) return p;
      }
    }
    return null;
  }
}
final horoscopeRepositoryProvider = Provider<HoroscopeRepository>(
      (ref) => HoroscopeRepository(),
);