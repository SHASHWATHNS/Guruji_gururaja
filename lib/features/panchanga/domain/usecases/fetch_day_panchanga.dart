import 'package:flutter/foundation.dart';
import '../../data/repositories/panchanga_repository.dart';

/// Single place that calls ALL endpoints for a given day and merges the result.
/// Screen watches this once; no more “dash” rows due to out-of-sync calls.
class FetchDayPanchanga {
  FetchDayPanchanga(this.repo);
  final PanchangaRepository repo;

  Future<Map<String, dynamic>> call({
    required DateTime date,
    required double lat,
    required double lon,
    required double tz,
  }) async {
    final y = date.year;
    final m = date.month;
    final d = date.day;
    final h = date.hour;
    final min = date.minute;
    final s = date.second;

    final baseBody = <String, dynamic>{
      'year': y,
      'month': m,
      'date': d,
      'hours': h == 0 ? 1 : h, // API docs say no leading zero like 0/1/2
      'minutes': min,
      'seconds': s,
      'latitude': lat,
      'longitude': lon,
      'timezone': tz,
      'config': {
        'observation_point': 'topocentric',
        'ayanamsha': 'lahiri',
      }
    };

    // Hit all endpoints in parallel
    final results = await Future.wait<Map<String, dynamic>>([
      repo.postJson('getsunriseandset', body: baseBody),
      repo.postJson('tithi-durations', body: baseBody),
      repo.postJson('nakshatra-durations', body: baseBody),
      repo.postJson('yoga-durations', body: baseBody),
      repo.postJson('karana-durations', body: baseBody),
      repo.postJson('good-bad-times', body: baseBody),
      repo.postJson('vedicweekday', body: baseBody),
      repo.postJson('lunarmonthinfo', body: baseBody),
      repo.postJson('rituinfo', body: baseBody),
    ]).catchError((e, st) {
      if (kDebugMode) {
        debugPrint('Panchanga batch error: $e\n$st');
      }
      throw e;
    });

    // Merge into one map
    final merged = <String, dynamic>{};
    for (final r in results) {
      merged.addAll(r);
    }
    return merged;
  }
}
