// lib/features/horoscope/data/cache.dart
import 'dart:convert';
import 'local_store.dart';

/// Very small JSON cache on top of LocalStore (SharedPreferences).
/// Stores {"_ts": "...", "data": {...}} and returns the inner map.
class Cache {
  Cache({this.ttl = const Duration(days: 7), this.prefix = 'astro:'});

  final Duration ttl;
  final String prefix;

  String _k(String key) => '$prefix$key';

  Future<Map<String, dynamic>> getJson(
      String key,
      Future<Map<String, dynamic>> Function() fetch,
      ) async {
    final fullKey = _k(key);
    final cached = await LocalStore.read(fullKey);

    if (cached != null && cached.isNotEmpty) {
      try {
        final obj = jsonDecode(cached);
        if (obj is Map<String, dynamic>) {
          // Wrapper with timestamp
          if (obj.containsKey('_ts') && obj.containsKey('data')) {
            final ts = DateTime.tryParse(obj['_ts'] as String? ?? '');
            if (ts != null && DateTime.now().difference(ts) <= ttl) {
              final data = obj['data'];
              if (data is Map<String, dynamic>) return data;
            }
          } else {
            // Old format: directly the map
            return obj.cast<String, dynamic>();
          }
        }
      } catch (_) {
        // fall through to fetch fresh
      }
    }

    final fresh = await fetch();
    try {
      final wrapper = jsonEncode({
        '_ts': DateTime.now().toIso8601String(),
        'data': fresh,
      });
      await LocalStore.write(fullKey, wrapper);
    } catch (_) {
      await LocalStore.write(fullKey, jsonEncode(fresh));
    }
    return fresh;
  }

  Future<void> putJson(String key, Map<String, dynamic> value) async {
    await LocalStore.write(
      _k(key),
      jsonEncode({'_ts': DateTime.now().toIso8601String(), 'data': value}),
    );
  }

  Future<void> invalidate(String key) => LocalStore.remove(_k(key));
}
