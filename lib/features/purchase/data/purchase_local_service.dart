import 'package:shared_preferences/shared_preferences.dart';

class PurchaseLocalService {
  static const _kUsesKey = 'purchase.free_uses';
  static const int freeLimit = 5;

  Future<int> getUses() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kUsesKey) ?? 0;
  }

  Future<void> incrementUse() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_kUsesKey) ?? 0;
    await prefs.setInt(_kUsesKey, current + 1);
  }

  Future<void> resetUses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUsesKey);
  }

  /// Convenient helpers
  Future<int> remainingFreeUses() async {
    final used = await getUses();
    final left = freeLimit - used;
    return left > 0 ? left : 0;
  }

  Future<bool> isLocked() async {
    final used = await getUses();
    return used >= freeLimit;
  }
}
