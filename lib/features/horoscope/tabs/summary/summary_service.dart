// lib/features/horoscope/tabs/summary/summary_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';

/// ───────────────────────── Models ─────────────────────────

class AstroRequest {
  final String name, place, tz;
  final DateTime birthIST;
  final double lat, lon;
  AstroRequest({
    required this.name,
    required this.birthIST,
    required this.place,
    required this.lat,
    required this.lon,
    required this.tz,
  });
}

class SummaryResult {
  final String name;
  final DateTime birthIST;
  final String birthplace;
  final String lagnam;
  final String raasi;
  final String nakshatra;
  final int tithiNumber;
  final String tithiName;
  final String yogaName;
  final String karanaName;
  final String yogiNakshatra;
  final String avayogiNakshatra;
  final String tamilMonth;
  final String tamilYear;
  final double sunLongitudeDeg;
  final double moonLongitudeDeg;
  /// Display-ready: "Valarpirai" / "Theypirai"
  final String paksha;

  SummaryResult({
    required this.name,
    required this.birthIST,
    required this.birthplace,
    required this.lagnam,
    required this.raasi,
    required this.nakshatra,
    required this.tithiNumber,
    required this.tithiName,
    required this.yogaName,
    required this.karanaName,
    required this.yogiNakshatra,
    required this.avayogiNakshatra,
    required this.tamilMonth,
    required this.tamilYear,
    required this.sunLongitudeDeg,
    required this.moonLongitudeDeg,
    required this.paksha,
  });
}

class SummaryService {
  final Dio _dio;
  SummaryService([Dio? dio])
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

  Map<String, dynamic> _body(AstroRequest req) {
    final tzVal = double.tryParse(req.tz) ??
        (req.tz.toLowerCase().contains('kolkata') ? 5.5 : 5.5);
    return {
      'year': req.birthIST.year,
      'month': req.birthIST.month,
      'date': req.birthIST.day,
      'hours': req.birthIST.hour,
      'minutes': req.birthIST.minute,
      'seconds': req.birthIST.second,
      'latitude': req.lat,
      'longitude': req.lon,
      'timezone': tzVal,
      'config': AppConfig.defaultConfig(),
    };
  }

  dynamic _unwrap(dynamic body) {
    var raw = (body is Map<String, dynamic>) ? (body['output'] ?? body) : body;
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

  /// Normalize any API paksha text to our internal keys (lowercase).
  /// Returns 'valarpirai' / 'theypirai' / ''.
  String _mapPakshaText(dynamic raw) {
    final s = raw?.toString().toLowerCase().trim() ?? '';
    if (s.isEmpty) return '';
    if (s.contains('shukla') || s.contains('sukla') || s.contains('wax')) {
      return 'valarpirai';
    }
    if (s.contains('krishna') || s.contains('wan')) {
      return 'theypirai';
    }
    return '';
  }

  /// Decide paksha using API-provided field first, then name edge-cases,
  /// finally fallback by tithi number (1–15 Shukla, 16–30 Krishna).
  String _derivePakshaKey(Map tithiData, int tithiNumber, String tithiName) {
    // 1) Prefer explicit API field (various common keys seen across providers)
    final fromField = _mapPakshaText(
      tithiData['paksha'] ??
          tithiData['paksha_name'] ??
          tithiData['pakshaName'] ??
          tithiData['fortnight'],
    );
    if (fromField.isNotEmpty) return fromField;

    // 2) Edge-cases by name (Purnima/Amavasya)
    final name = tithiName.toLowerCase();
    if (name.contains('poornima') || name.contains('purnima')) {
      return 'valarpirai';
    }
    if (name.contains('amavasya') || name.contains('amavasai')) {
      return 'theypirai';
    }

    // 3) Fallback by number
    return (tithiNumber <= 15) ? 'valarpirai' : 'theypirai';
  }

  Future<SummaryResult> fetchSummary(AstroRequest req) async {
    // planets/extended
    final pxResp = await _dio.post('/planets/extended', data: _body(req));
    final px = (pxResp.data['output'] ?? {}) as Map<String, dynamic>;
    final asc = (px['Ascendant'] ?? {}) as Map<String, dynamic>;
    final sun = (px['Sun'] ?? {}) as Map<String, dynamic>;
    final moon = (px['Moon'] ?? {}) as Map<String, dynamic>;

    // tithi
    final tithiResp = await _dio.post('/tithi-durations', data: _body(req));
    final tithiData = _unwrap(tithiResp.data) as Map;
    final tithiNumber =
    (tithiData['number'] ?? tithiData['tithi_number'] ?? 0) is num
        ? (tithiData['number'] ?? tithiData['tithi_number'] ?? 0) as int
        : int.tryParse(
        (tithiData['number'] ??
            tithiData['tithi_number'] ??
            '0')
            .toString()) ??
        0;
    final tithiName =
    (tithiData['name'] ?? tithiData['tithi_name'] ?? '—').toString();

    // paksha (key)
    final pakshaKey = _derivePakshaKey(tithiData, tithiNumber, tithiName);

    // yoga
    final yogaResp = await _dio.post('/yoga-durations', data: _body(req));
    final yogaData = _unwrap(yogaResp.data);
    String yogaName = '—';
    if (yogaData is Map) {
      yogaName = (yogaData['name'] ??
          yogaData['yoga'] ??
          yogaData['yoga_name'] ??
          '—')
          .toString();
      if (yogaName == '—') {
        for (final v in yogaData.values) {
          if (v is Map) {
            yogaName =
                (v['name'] ?? v['yoga'] ?? v['yoga_name'] ?? '—').toString();
            if (yogaName != '—') break;
          }
        }
      }
    }

    // karana
    final karanaResp =
    await _dio.post('/karana-durations', data: _body(req));
    final karanaData = _unwrap(karanaResp.data);
    String karanaName = '—';
    if (karanaData is Map) {
      karanaName = (karanaData['name'] ??
          karanaData['karana'] ??
          karanaData['karana_name'] ??
          '—')
          .toString();
      if (karanaName == '—') {
        for (final v in karanaData.values) {
          if (v is Map) {
            karanaName =
                (v['name'] ?? v['karana'] ?? v['karana_name'] ?? '—')
                    .toString();
            if (karanaName != '—') break;
          }
        }
      }
    }

    // yogi / avayogi — return canonical keys matching UI map
    final pair = _computeYogiAvayogiCanonical(
      (sun['fullDegree'] as num?)?.toDouble() ?? 0,
      (moon['fullDegree'] as num?)?.toDouble() ?? 0,
    );

    return SummaryResult(
      name: req.name,
      birthIST: req.birthIST,
      birthplace: req.place,
      lagnam: (asc['zodiac_sign_name'] ?? '—').toString(),
      raasi: (moon['zodiac_sign_name'] ?? '—').toString(),
      nakshatra: (moon['nakshatra_name'] ?? '—').toString(),
      tithiNumber: tithiNumber,
      tithiName: tithiName,
      yogaName: yogaName,
      karanaName: karanaName,
      yogiNakshatra: pair.$1, // canonical key (e.g., 'satabisha')
      avayogiNakshatra: pair.$2,
      tamilMonth: _tamilMonth((sun['zodiac_sign_name'] ?? '—').toString()),
      tamilYear: _tamilYear(req.birthIST),
      sunLongitudeDeg:
      (sun['fullDegree'] as num?)?.toDouble() ?? double.nan,
      moonLongitudeDeg:
      (moon['fullDegree'] as num?)?.toDouble() ?? double.nan,
      // Store display-ready form for the UI (English token; Tamil is handled in UI)
      paksha: pakshaKey == 'valarpirai' ? 'Valarpirai' : 'Theypirai',
    );
  }

  /// Canonical list (order matters): Aswini → Revati
  static const List<String> _nakKeys = [
    'aswini',
    'bharani',
    'krittika',
    'rohini',
    'mrigasira',
    'aardra',
    'punarvasu',
    'pushya',
    'aaslesha',
    'makha',
    'poorva_phalguni(pubba)',
    'uttara_phalguni(uttara)',
    'hasta',
    'chitta',
    'swati',
    'visakha',
    'anuradha',
    'jyeshta',
    'moola',
    'poorvaashaada',
    'uttaraashaada',
    'sravanam',
    'dhanishta',
    'satabisha',
    'poorvaabhadra',
    'uttaraabhadra',
    'revati',
  ];

  (String, String) _computeYogiAvayogiCanonical(
      double sunLon, double moonLon) {
    double norm(double v) {
      v %= 360;
      if (v < 0) v += 360;
      return v;
    }

    // Yoga point = Sun + Moon
    final yogaPoint = norm(sunLon + moonLon);
    // Map 360° → 27 equal parts
    final yogaIdx = (yogaPoint / (360 / 27)).floor() % 27;

    // Per logic:
    //   Yogi star     = (Yoga index + 7) % 27
    //   Avayogi star  = (Yoga index + 21) % 27
    final yi = (yogaIdx + 7) % 27;
    final ai = (yogaIdx + 21) % 27;

    return (_nakKeys[yi], _nakKeys[ai]);
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
}
