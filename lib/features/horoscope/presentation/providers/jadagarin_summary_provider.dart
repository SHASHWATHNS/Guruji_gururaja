// lib/features/horoscope/presentation/providers/jadagarin_summary_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../horoscope/data/datasources/remote/horoscope_api_service.dart';
import '../../../horoscope/data/repositories/horoscope_repository_impl.dart';
import '../../../horoscope/domain/entities/birth_summary.dart';
import '../../domain/entities/birth_input.dart';

sealed class JSummaryState { const JSummaryState(); }
class JIdle extends JSummaryState { const JIdle(); }
class JLoading extends JSummaryState { const JLoading(); }
class JReady extends JSummaryState { final BirthSummary summary; const JReady(this.summary); }
class JError extends JSummaryState { final String message; const JError(this.message); }

final _apiProvider  = Provider((ref) => HoroscopeApiService());
final _repoProvider = Provider((ref) => HoroscopeRepositoryImpl(ref.read(_apiProvider)));

final jSummaryProvider =
StateNotifierProvider<JSummaryNotifier, JSummaryState>((ref) {
  return JSummaryNotifier(ref.read(_repoProvider));
});

class JSummaryNotifier extends StateNotifier<JSummaryState> {
  final HoroscopeRepositoryImpl repo;
  JSummaryNotifier(this.repo) : super(const JIdle());

  Future<void> load(BirthInput input) async {
    state = const JLoading();
    try {
      final raw = await repo.buildBirthSummary(
        name: input.name,
        dobLocal: input.dobLocal,
        tob24h: input.tob24h,
        unknownTime: input.unknownTime,
        placeLabel: input.placeLabel,
        lat: input.lat,
        lng: input.lng,
        tzid: input.tzid,
      );
      state = JReady(_formatSummary(raw));
    } catch (e) {
      state = JError(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Decoders (robust)
  // ──────────────────────────────────────────────────────────────

  /// Try to coerce a `{key: value, ...}` string (not valid JSON) into a Map.
  Map<String, dynamic>? _coerceMapLikeToMap(String s) {
    final trimmed = s.trim();
    if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) return null;
    // Very simple key:value parser; values end at comma or closing brace.
    final body = trimmed.substring(1, trimmed.length - 1);
    final map = <String, dynamic>{};
    final pairRe = RegExp(r'(\w+)\s*:\s*([^,}]+)');
    for (final m in pairRe.allMatches(body)) {
      final k = m.group(1)!;
      final vRaw = m.group(2)!.trim();
      // strip surrounding quotes if present
      final v = vRaw.startsWith('"') && vRaw.endsWith('"')
          ? vRaw.substring(1, vRaw.length - 1)
          : vRaw;
      // try number
      final n = num.tryParse(v);
      map[k] = n ?? v;
    }
    return map.isEmpty ? null : map;
  }

  /// Safely decode: JSON, double-encoded JSON, or map-like strings.
  dynamic _decodeLoose(dynamic v) {
    if (v is! String) return v;
    var s = v.trim();

    // 1) Try regular JSON (and one level of double-encoding).
    for (var i = 0; i < 2; i++) {
      if (!(s.startsWith('{') || s.startsWith('[') || s.startsWith('"'))) break;
      try {
        final x = json.decode(s);
        if (x is String) { s = x.trim(); continue; }
        return x;
      } catch (_) {
        break;
      }
    }

    // 2) Try to coerce non-JSON map strings like {a: 1, b: foo}
    final coerced = _coerceMapLikeToMap(s);
    if (coerced != null) return coerced;

    // 3) Otherwise return original string
    return v;
  }

  String _nameOf(dynamic v) {
    v = _decodeLoose(v);
    if (v is Map) {
      if (v['name'] is String) return v['name'] as String;
      if (v['star'] is String) return v['star'] as String;
      if (v.values.any((e) => e is Map && e['name'] != null)) {
        final keys = v.keys.map((k) => int.tryParse('$k') ?? 1 << 30).toList()
          ..sort();
        return keys
            .map((i) => v['$i'])
            .where((e) => e != null)
            .map((e) => _nameOf(e))
            .where((e) => e.isNotEmpty)
            .join(', ');
      }
    }
    if (v is List) return v.map(_nameOf).where((e) => e.isNotEmpty).join(', ');
    return (v ?? '').toString();
  }

  String _fmtTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    return iso.replaceFirst('T', ' ').split('.').first;
  }

  // ──────────────────────────────────────────────────────────────
  // Pretty formatters for each field
  // ──────────────────────────────────────────────────────────────

  String _fmtNakshatra(dynamic v) {
    final d = _decodeLoose(v);
    if (d is Map) {
      final name = _nameOf(d);
      final rem  = d['remaining_percentage_at_given_time'];
      if (rem is num) return '$name (மீதமுள்ளது ${rem.toStringAsFixed(1)}%)';
      final s = d['starts_at'] as String?;
      final e = d['ends_at'] as String?;
      if (s != null && e != null) return '$name (${_fmtTime(s)} → ${_fmtTime(e)})';
      return name;
    }
    return _nameOf(d);
  }

  String _fmtPaksha(String? p) {
    if (p == null) return '';
    final t = p.toLowerCase();
    if (t.startsWith('shukla'))  return 'சுக்லபக்ஷம்';
    if (t.startsWith('krishna')) return 'கிருஷ்ணபக்ஷம்';
    return p;
  }

  String _fmtTithi(dynamic v) {
    final d = _decodeLoose(v);
    if (d is Map) {
      final name = _nameOf(d);
      final pk   = _fmtPaksha(d['paksha'] as String?);
      final left = d['left_precentage'] ?? d['left_percentage'];
      final comp = d['completes_at'] as String?;
      final bits = <String>[];
      if (pk.isNotEmpty) bits.add(pk);
      if (left is num)  bits.add('மீதம் ${left.toStringAsFixed(1)}%');
      if (comp != null && comp.isNotEmpty) bits.add('முடிவு ${_fmtTime(comp)}');
      return bits.isEmpty ? name : '$name (${bits.join(' • ')})';
    }
    return _nameOf(d);
  }

  String _fmtYoga(dynamic v) {
    final d = _decodeLoose(v);
    if (d is Map) {
      final keys = d.keys.map((k) => int.tryParse('$k') ?? 1 << 30).toList()
        ..sort();
      final out = <String>[];
      for (final i in keys) {
        final it = d['$i'];
        final name = _nameOf(it);
        String extra = '';
        if (it is Map) {
          final comp = it['completion'] as String?;
          final left = it['yoga_left_percentage'];
          if (comp is String && comp.isNotEmpty) {
            extra = ' (${_fmtTime(comp)})';
          } else if (left is num) {
            extra = ' (மீதம் ${left.toStringAsFixed(1)}%)';
          }
        }
        if (name.isNotEmpty) out.add('$name$extra');
        if (out.length == 2) break;
      }
      return out.join(', ');
    }
    if (d is List) return d.map(_nameOf).take(2).join(', ');
    return _nameOf(d);
  }

  String _fmtKarana(dynamic v) {
    final d = _decodeLoose(v);
    if (d is Map) {
      final keys = d.keys.map((k) => int.tryParse('$k') ?? 1 << 30).toList()
        ..sort();
      final out = <String>[];
      for (final i in keys) {
        final it = d['$i'];
        final name = _nameOf(it);
        String extra = '';
        if (it is Map) {
          final comp = it['completion'] as String?;
          final left = it['karana_left_percentage'];
          if (comp is String && comp.isNotEmpty) {
            extra = ' (${_fmtTime(comp)})';
          } else if (left is num) {
            extra = ' (மீதம் ${left.toStringAsFixed(1)}%)';
          }
        }
        if (name.isNotEmpty) out.add('$name$extra');
        if (out.length == 2) break;
      }
      return out.join(', ');
    }
    if (d is List) return d.map(_nameOf).take(2).join(', ');
    return _nameOf(d);
  }

  String _fmtYogiAvaYogi(dynamic v) {
    final d = _decodeLoose(v);
    if (d is Map) {
      String yogi   = _nameOf(d['yogi']);
      String avyogi = _nameOf(d['avyogi'] ?? d['ava_yogi']);
      if (yogi.isEmpty && d.values.isNotEmpty) {
        final names = d.values.map(_nameOf).where((e) => e.isNotEmpty).toList();
        if (names.isNotEmpty) yogi = names.first;
        if (names.length > 1) avyogi = names[1];
      }
      final bits = <String>[];
      if (yogi.isNotEmpty)   bits.add('யோகி: $yogi');
      if (avyogi.isNotEmpty) bits.add('அவயோகி: $avyogi');
      return bits.isEmpty ? '' : bits.join(', ');
    }
    if (d is List) {
      final names = d.map(_nameOf).where((e) => e.isNotEmpty).toList();
      if (names.isEmpty) return '';
      if (names.length == 1) return 'யோகி: ${names[0]}';
      return 'யோகி: ${names[0]}, அவயோகி: ${names[1]}';
    }
    final s = _nameOf(d);
    return s.isEmpty ? '' : 'யோகி: $s';
  }

  // Tamil month / year
  String _fmtTamilMonth(dynamic v) {
    final d = _decodeLoose(v);
    if (d is! Map) return _nameOf(d);

    final name = (d['lunar_month_full_name'] ??
        d['month_full_name'] ??
        d['lunar_month_name'] ??
        d['month_name'])?.toString();

    bool isTrue(x) => x == 1 || x == true || x == '1' || x == 'true';

    final flags = <String>[];
    if (isTrue(d['adhika'])) flags.add('அதிக');
    if (isTrue(d['kshaya'])) flags.add('க்ஷய');
    if (isTrue(d['nija']))   flags.add('நிஜ');

    if (name == null || name.isEmpty) return '';
    return flags.isEmpty ? name : '$name (${flags.join(", ")})';
  }

  String _fmtTamilYear(dynamic v) {
    final d = _decodeLoose(v);
    if (d is! Map) return _nameOf(d);

    final year = (d['lunar_year_full_name'] ??
        d['year_full_name'] ??
        d['lunar_year_name'] ??
        d['year_name'])?.toString();

    if (year != null && year.isNotEmpty) {
      return year; // proper year
    }

    // API sometimes repeats month map here; show a clean month-like label instead of JSON.
    return _fmtTamilMonth(d);
  }

  // ──────────────────────────────────────────────────────────────
  // final rebuilder
  // ──────────────────────────────────────────────────────────────
  BirthSummary _formatSummary(BirthSummary s) {
    return BirthSummary(
      name: s.name,
      dob: s.dob,
      tob: s.tob,
      city: s.city,
      weekdayTa: s.weekdayTa,
      hinduDayTa: s.hinduDayTa,
      age: s.age,
      lagnam: s.lagnam,
      raasi: s.raasi,
      star: _fmtNakshatra(s.star),
      thithi: _fmtTithi(s.thithi),
      thithiSoonyam: s.thithiSoonyam,
      yogam: _fmtYoga(s.yogam),
      yogiAvaYogi: _fmtYogiAvaYogi(s.yogiAvaYogi),
      karanam: _fmtKarana(s.karanam),
      tamilMaadham: _fmtTamilMonth(s.tamilMaadham),
      tamilVarudam: _fmtTamilYear(s.tamilVarudam), // <-- now always human readable
    );
  }
}
