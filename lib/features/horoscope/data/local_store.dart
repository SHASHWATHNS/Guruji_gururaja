// lib/features/horoscope/data/local_store.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight key–value store backed by SharedPreferences.
/// - Generic string cache: read/write/remove
/// - Birth data persistence: saveBirth/loadLastBirth
/// - History list: addBirthToHistory/loadHistoryRaw
class LocalStore {
  // ------- generic cache (used by Cache class) -------
  static Future<String?> read(String key) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(key);
    // caller handles JSON decode if needed
  }

  static Future<void> write(String key, String value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, value);
  }

  static Future<void> remove(String key) async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(key);
  }

  // ------- birth persistence & history -------
  static const _kLastBirth = 'astro:last_birth';
  static const _kHistory = 'astro:birth_history';
  static const _kHistoryMax = 50; // keep latest N

  /// Save current birth entry and automatically push to history.
  /// [data] is a JSON-serializable map (your BirthData.toJson()).
  static Future<void> saveBirth(Map<String, dynamic> data) async {
    final sp = await SharedPreferences.getInstance();

    // Save "last used"
    await sp.setString(_kLastBirth, jsonEncode(data));

    // Also push to history
    await addBirthToHistory(data);
  }

  /// Load the last used birth entry (or null).
  static Future<Map<String, dynamic>?> loadLastBirth() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kLastBirth);
    if (raw == null || raw.isEmpty) return null;
    try {
      final obj = jsonDecode(raw);
      return (obj is Map<String, dynamic>) ? obj : null;
    } catch (_) {
      return null;
    }
  }

  /// Push an entry into history (dedup & capped).
  /// We consider two entries equal if their JSON (without metadata) matches.
  static Future<void> addBirthToHistory(Map<String, dynamic> data) async {
    final sp = await SharedPreferences.getInstance();

    // load current list
    final list = await _loadHistoryList(sp);

    // prepare an item with metadata
    final nowIso = DateTime.now().toIso8601String();
    final item = Map<String, dynamic>.from(data)
      ..putIfAbsent('_savedAt', () => nowIso);

    // basic dedup by comparing serialized content (excluding _savedAt)
    String _fingerprint(Map<String, dynamic> m) {
      final clone = Map<String, dynamic>.from(m)..remove('_savedAt');
      return jsonEncode(clone);
    }

    final fpNew = _fingerprint(item);
    // remove any existing with same fingerprint
    list.removeWhere((e) {
      try {
        return _fingerprint(e as Map<String, dynamic>) == fpNew;
      } catch (_) {
        return false;
      }
    });

    // insert at top
    list.insert(0, item);

    // cap size
    if (list.length > _kHistoryMax) {
      list.removeRange(_kHistoryMax, list.length);
    }

    await sp.setString(_kHistory, jsonEncode(list));
  }

  /// Return raw history (newest first). You can pass [limit] for the first N.
  static Future<List<Map<String, dynamic>>> loadHistoryRaw({int? limit}) async {
    final sp = await SharedPreferences.getInstance();
    final list = await _loadHistoryList(sp);
    final trimmed = (limit != null && limit > 0 && limit < list.length)
        ? list.sublist(0, limit)
        : list;
    return trimmed
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
  }
  static Future<void> deleteBirthFromHistory(Map<String, dynamic> item) async {
    final sp = await SharedPreferences.getInstance();
    final list = await _loadHistoryList(sp);

    String _fingerprint(Map<String, dynamic> m) {
      final clone = Map<String, dynamic>.from(m)..remove('_savedAt');
      return jsonEncode(clone);
    }

    final savedAt = item['_savedAt']?.toString();
    final fpItem = _fingerprint(item);

    list.removeWhere((e) {
      if (e is! Map) return false;
      final m = e.cast<String, dynamic>();
      // 1) exact timestamp match
      if (savedAt != null && savedAt.isNotEmpty && m['_savedAt'] == savedAt) {
        return true;
      }
      // 2) fallback to content fingerprint
      try {
        return _fingerprint(m) == fpItem;
      } catch (_) {
        return false;
      }
    });

    await sp.setString(_kHistory, jsonEncode(list));
  }

  /// Delete all saved history.
  static Future<void> clearHistory() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kHistory);
  }
  // ------- internals -------
  static Future<List<dynamic>> _loadHistoryList(SharedPreferences sp) async {
    final raw = sp.getString(_kHistory);
    if (raw == null || raw.isEmpty) return <dynamic>[];
    try {
      final decoded = jsonDecode(raw);
      return (decoded is List) ? decoded : <dynamic>[];
    } catch (_) {
      return <dynamic>[];
    }
  }
}
