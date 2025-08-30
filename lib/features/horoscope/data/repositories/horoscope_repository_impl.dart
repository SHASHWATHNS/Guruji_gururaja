import '../../domain/repositories/horoscope_repository.dart';
import '../../domain/entities/planet_entity.dart';
import '../datasources/remote/horoscope_api_service.dart';
import '../models/planet_model.dart';

import '../../../horoscope/domain/entities/birth_summary.dart';
import '../../presentation/utils/tamil_maps.dart';

class HoroscopeRepositoryImpl implements HoroscopeRepository {
  final HoroscopeApiService api;
  HoroscopeRepositoryImpl(this.api);

  @override
  Future<List<PlanetEntity>> fetchPlanets({
    required String name,
    required DateTime dobLocal,
    String? tob24h,
    required bool unknownTime,
    required String placeLabel,
    required double lat,
    required double lng,
    required String tzid,
  }) async {
    int hh = 12, mm = 0;
    if (!unknownTime && tob24h != null && tob24h.contains(':')) {
      final parts = tob24h.split(':');
      hh = int.tryParse(parts[0]) ?? 12;
      mm = int.tryParse(parts[1]) ?? 0;
    }

    final payload = {
      "year": dobLocal.year,
      "month": dobLocal.month,
      "date": dobLocal.day,
      "hours": hh,
      "minutes": mm,
      "seconds": 0,
      "latitude": lat,
      "longitude": lng,
      "timezone": 5.5,
      "ayanamsha": "lahiri"
    };

    final raw = await api.getPlanets(payload);
    return raw.map((e) => PlanetModel.fromJson(e).toEntity()).toList();
  }

  // ---------- Build the Jadagarin Vivaram summary ----------
  Future<BirthSummary> buildBirthSummary({
    required String name,
    required DateTime dobLocal,
    String? tob24h,
    required bool unknownTime,
    required String placeLabel,
    required double lat,
    required double lng,
    required String tzid,
  }) async {
    // 1) Planets → Lagnam / Rāsi
    final planets = await fetchPlanets(
      name: name,
      dobLocal: dobLocal,
      tob24h: tob24h,
      unknownTime: unknownTime,
      placeLabel: placeLabel,
      lat: lat,
      lng: lng,
      tzid: tzid,
    );

    final asc = planets.firstWhere(
          (p) => p.name.toLowerCase().contains('asc'),
      orElse: () => planets.first,
    );
    final moon = planets.firstWhere(
          (p) => p.name == 'Moon',
      orElse: () => planets.first,
    );

    final lagnaTa = asTamilSign(asc.sign.isEmpty ? '-' : asc.sign);
    final raasiTa = asTamilSign(moon.sign.isEmpty ? '-' : moon.sign);

    // 2) Common payload for Panchang endpoints
    final hhmm = (!unknownTime && tob24h != null && tob24h.contains(':'))
        ? tob24h.split(':')
        : ['12', '00'];
    final payload = {
      "year": dobLocal.year,
      "month": dobLocal.month,
      "date": dobLocal.day,
      "hours": int.tryParse(hhmm[0]) ?? 12,
      "minutes": int.tryParse(hhmm[1]) ?? 0,
      "seconds": 0,
      "latitude": lat,
      "longitude": lng,
      "timezone": 5.5,
      "config": {
        "observation_point": "topocentric",
        "ayanamsha": "lahiri"
      }
    };

    // 3) Call Panchang endpoints in parallel
    Map<String, dynamic> tithi = {},
        nak = {},
        yoga = {},
        karana = {},
        lunar = {};
    try {
      final results = await Future.wait([
        api.getTithi(payload),
        api.getNakshatra(payload),
        api.getYoga(payload),
        api.getKarana(payload),
        api.getLunarMonth(payload),
      ]);
      tithi = results[0];
      nak = results[1];
      yoga = results[2];
      karana = results[3];
      lunar = results[4];
    } catch (_) {
      // keep empty; UI will show —
    }

    // --- Deep scanners ---
    String _deepFindString(dynamic node, List<String> needles) {
      if (node == null) return '—';
      if (node is String && node.trim().isNotEmpty) return node;

      if (node is Map) {
        final m = Map<String, dynamic>.from(node);
        for (final e in m.entries) {
          final k = e.key.toString().toLowerCase();
          for (final n in needles) {
            if (k.contains(n)) {
              final v = e.value;
              if (v is String && v.trim().isNotEmpty) return v;
              if (v is Map) {
                final n2 = _deepFindString(v, ['name', ...needles]);
                if (n2 != '—') return n2;
              }
            }
          }
        }
        for (final v in m.values) {
          final got = _deepFindString(v, needles);
          if (got != '—') return got;
        }
        return '—';
      }

      if (node is List) {
        for (final it in node) {
          final got = _deepFindString(it, needles);
          if (got != '—') return got;
        }
        return '—';
      }

      return '—';
    }

    String _deepFindBoolAsTa(dynamic node, List<String> needles) {
      bool? _boolish(dynamic v) {
        if (v is bool) return v;
        final s = v.toString().toLowerCase();
        if (s == 'true' || s == 'yes' || s == '1') return true;
        if (s == 'false' || s == 'no' || s == '0') return false;
        return null;
      }

      if (node == null) return '—';
      if (node is Map) {
        final m = Map<String, dynamic>.from(node);
        for (final e in m.entries) {
          final k = e.key.toString().toLowerCase();
          for (final n in needles) {
            if (k.contains(n)) {
              final b = _boolish(e.value);
              if (b != null) return b ? 'ஆம்' : 'இல்லை';
            }
          }
        }
        for (final v in m.values) {
          final got = _deepFindBoolAsTa(v, needles);
          if (got != '—') return got;
        }
        return '—';
      }
      if (node is List) {
        for (final it in node) {
          final got = _deepFindBoolAsTa(it, needles);
          if (got != '—') return got;
        }
        return '—';
      }
      final b = (node is bool) ? node : null;
      if (b != null) return b ? 'ஆம்' : 'இல்லை';
      return '—';
    }

    // --- helper: prefer root 'name' first ---
    String _rootName(Map src, List<String> altKeys) {
      if (src['name'] is String &&
          (src['name'] as String).trim().isNotEmpty) {
        return src['name'] as String;
      }
      for (final k in altKeys) {
        final v = src[k];
        if (v is String && v.trim().isNotEmpty) return v;
      }
      return _deepFindString(src, ['name', ...altKeys]);
    }

    // 4) Pull values
    final starEn = _rootName(nak, ['nakshatra', 'nakshatra_name', 'star']);
    final starTa = asTamilNak(starEn == '—' ? '' : starEn);

    final tithiName = _rootName(tithi, ['tithi', 'tithi_name']);
    final yogaName = _rootName(yoga, ['yoga', 'yoga_name']);
    final karanaName =
    _rootName(karana, ['karana', 'karanam', 'karana_name']);

    final tithiSoon = _deepFindBoolAsTa(tithi, ['soonyam', 'shunya']);

    final tamilMonth = _rootName(lunar,
        ['tamil_month', 'tamil_maadham', 'month_tamil', 'tamilMonth']);
    final tamilYear = _rootName(
        lunar, ['tamil_year', 'tamil_varudam', 'year_tamil', 'tamilYear']);

    // 5) Local fields
    final dobStr = _fmtDate(dobLocal);
    final tobStr = unknownTime ? 'தெரியாது' : (tob24h ?? 'தெரியாது');
    final city = placeLabel;
    final dayTa = weekdayTa(dobLocal);
    final ageStr = _ageString(dobLocal);

    return BirthSummary(
      name: name,
      dob: dobStr,
      tob: tobStr,
      city: city,
      weekdayTa: dayTa,
      hinduDayTa: dayTa,
      age: ageStr,
      lagnam: lagnaTa,
      raasi: raasiTa,
      star: starTa == '' ? '—' : starTa,
      thithi: tithiName,
      thithiSoonyam: tithiSoon,
      yogam: yogaName,
      yogiAvaYogi: '—',
      karanam: karanaName,
      tamilMaadham: tamilMonth,
      tamilVarudam: tamilYear,
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  String _ageString(DateTime dob) {
    final now = DateTime.now();
    int y = now.year - dob.year;
    int m = now.month - dob.month;
    int d = now.day - dob.day;
    if (d < 0) {
      m -= 1;
      d += _daysInMonth(DateTime(now.year, now.month, 0));
    }
    if (m < 0) {
      y -= 1;
      m += 12;
    }
    return '$y வருடம் $m மாதம் $d நாள்';
  }

  int _daysInMonth(DateTime when) {
    final firstNext = (when.month == 12)
        ? DateTime(when.year + 1, 1, 1)
        : DateTime(when.year, when.month + 1, 1);
    return firstNext.subtract(const Duration(days: 1)).day;
  }
}
