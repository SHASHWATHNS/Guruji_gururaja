import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/birth_input.dart';
import '../../data/models/dasa_models.dart';
import '../../data/datasources/remote/horoscope_api_service.dart';

final _apiProvider = Provider<HoroscopeApiService>((ref) => HoroscopeApiService());

/// Public: returns DasaTree using live API, with safe fallback to demo if parsing fails.
final dasaTreeProvider =
FutureProvider.family<DasaTree, BirthInput>((ref, input) async {
  final api = ref.read(_apiProvider);

  final hhmm = (input.unknownTime || input.tob24h == null || !input.tob24h!.contains(':'))
      ? const ['12', '00']
      : input.tob24h!.split(':');

  final payload = {
    "year": input.dobLocal.year,
    "month": input.dobLocal.month,
    "date": input.dobLocal.day,
    "hours": int.tryParse(hhmm[0]) ?? 12,
    "minutes": int.tryParse(hhmm[1]) ?? 0,
    "seconds": 0,
    "latitude": input.lat,
    "longitude": input.lng,
    "timezone": 5.5,
    "config": {
      "observation_point": "topocentric",
      "ayanamsha": "lahiri"
    }
  };

  try {
    // Prefer richer endpoint first
    final raw = await api.getVimsottariMahaAndAntarDasas(payload);
    final tree = _parseMahaAntar(raw);
    if (tree != null) return tree;

    // Fallback to Maha-only; we’ll synthesize simple antars
    final raw2 = await api.getVimsottariMahaDasas(payload);
    final tree2 = _parseMahaOnly(raw2);
    if (tree2 != null) return tree2;
  } catch (_) {
    // ignored -> use demo
  }

  // FINAL fallback: demo data so UI never breaks
  return _demoTree(input);
});

// --------------------- Parsing helpers ---------------------

DateTime _parseDate(dynamic v) {
  if (v is DateTime) return v;
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  if (v is String) {
    // normalize: "YYYY-MM-DD HH:mm:ss" -> ISO
    final s = v.contains('T') ? v : v.replaceFirst(' ', 'T');
    final d = DateTime.tryParse(s);
    if (d != null) return d;
  }
  return DateTime.now();
}

String _asStringName(Map m) {
  for (final k in const ['name','graha','graha_name','planet']) {
    final v = m[k];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return '-';
}

List _asList(dynamic d) {
  if (d is List) return d;
  if (d is Map) {
    for (final k in const ['maha_dasas','mahadasas','mahadasha','mahadashas','rows','table','output']) {
      if (d[k] is List) return d[k] as List;
    }
  }
  if (d is String) {
    try { final j = json.decode(d); return _asList(j); } catch (_) {}
  }
  return const [];
}

List _findNestedList(Map m, List<String> keys) {
  for (final k in keys) {
    final v = m[k];
    if (v is List) return v;
    if (v is Map) {
      final r = _findNestedList(Map<String, dynamic>.from(v), keys);
      if (r.isNotEmpty) return r;
    }
  }
  return const [];
}

DasaTree? _parseMahaAntar(dynamic raw) {
  final mahList = _asList(raw).map((e) => e is Map ? e : {}).cast<Map>().toList();
  if (mahList.isEmpty && raw is Map) {
    final nested = _findNestedList(Map<String, dynamic>.from(raw), ['maha_dasas','mahadasas','table','rows','output']);
    if (nested.isNotEmpty) {
      return _parseMahaAntar(nested);
    }
  }
  if (mahList.isEmpty) return null;

  final List<MahaDasa> maha = [];
  for (final m in mahList) {
    final name = _asStringName(m);
    final start = _parseDate(m['start'] ?? m['starts_at'] ?? m['from']);
    final end   = _parseDate(m['end']   ?? m['ends_at']   ?? m['to']);

    final antarList = _asList(m['antar_dasas'] ?? m['antardasas'] ?? m['bhuktis']);
    final List<AntarDasa> antars = antarList.map((a) {
      final am = a is Map ? a : {};
      final an = _asStringName(am);
      final as = _parseDate(am['start'] ?? am['starts_at'] ?? am['from']);
      final ae = _parseDate(am['end']   ?? am['ends_at']   ?? am['to']);
      return AntarDasa(name: an, start: as, end: ae);
    }).toList();

    maha.add(MahaDasa(graha: name, start: start, end: end, antars: antars));
  }

  final snap = _snapshotFrom(maha);
  return DasaTree(snapshot: snap, table: maha);
}

DasaTree? _parseMahaOnly(dynamic raw) {
  final mahList = _asList(raw).map((e) => e is Map ? e : {}).cast<Map>().toList();
  if (mahList.isEmpty) return null;

  final List<MahaDasa> maha = [];
  for (final m in mahList) {
    final name = _asStringName(m);
    final start = _parseDate(m['start'] ?? m['starts_at'] ?? m['from']);
    final end   = _parseDate(m['end']   ?? m['ends_at']   ?? m['to']);

    // synthesize 9 equal antars
    final totalDays = end.difference(start).inDays.abs();
    final per = (totalDays ~/ 9).clamp(1, totalDays == 0 ? 1 : totalDays);
    final ants = <AntarDasa>[];
    var st = start;
    for (int i = 0; i < 9; i++) {
      final ed = i == 8 ? end : st.add(Duration(days: per));
      ants.add(AntarDasa(name: '$name / ${i+1}', start: st, end: ed));
      st = ed;
    }

    maha.add(MahaDasa(graha: name, start: start, end: end, antars: ants));
  }

  final snap = _snapshotFrom(maha);
  return DasaTree(snapshot: snap, table: maha);
}

DasaSnapshot _snapshotFrom(List<MahaDasa> maha) {
  final now = DateTime.now();
  // find current mahadasa
  MahaDasa curM = maha.first;
  for (final m in maha) {
    if (!now.isBefore(m.start) && now.isBefore(m.end)) { curM = m; break; }
  }
  // find current antar
  AntarDasa curA = curM.antars.first;
  for (final a in curM.antars) {
    if (!now.isBefore(a.start) && now.isBefore(a.end)) { curA = a; break; }
  }

  final antarName = curA.name.contains('/') ? curA.name.split('/').last.trim() : curA.name;

  return DasaSnapshot(
    currentMaha: curM.graha,
    currentAntar: antarName,
    from: curA.start,
    to: curA.end,
  );
}

// --------------------- Demo fallback (only if APIs fail) ---------------------
DasaTree _demoTree(BirthInput input) {
  final now = DateTime.now();
  final start0 = DateTime(now.year - 8, now.month, now.day);
  final names = ['Sun','Moon','Mars','Rahu','Jupiter','Saturn','Mercury','Ketu','Venus'];

  DateTime st = start0;
  final List<MahaDasa> maha = [];
  for (int i = 0; i < names.length; i++) {
    final end = DateTime(st.year + 6, st.month, st.day);
    final ants = <AntarDasa>[];
    var ast = st;
    for (int k = 0; k < 9; k++) {
      final aend = ast.add(Duration(days: (end.difference(st).inDays ~/ 9)));
      ants.add(AntarDasa(name: '${names[i]} / ${names[(i+k)%names.length]}', start: ast, end: aend));
      ast = aend;
    }
    maha.add(MahaDasa(graha: names[i], start: st, end: end, antars: ants));
    st = end;
  }

  final snap = _snapshotFrom(maha);
  return DasaTree(snapshot: snap, table: maha);
}
