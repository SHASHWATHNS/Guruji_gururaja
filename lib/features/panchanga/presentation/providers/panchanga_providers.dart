import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/panchanga_api.dart';

// -------- Date selection --------
final selectedDateProvider =
StateProvider<DateTime>((_) => DateTime.now());

// Month view anchor (first day of month)
final monthAnchorProvider =
StateProvider<DateTime>((ref) {
  final d = ref.watch(selectedDateProvider);
  return DateTime(d.year, d.month, 1);
});

// -------- Location / TZ (replace with real user settings if you have them) --------
final latitudeProvider  = Provider<double>((_) => 11.0168);  // Coimbatore EX
final longitudeProvider = Provider<double>((_) => 76.9558);
final timezoneProvider  = Provider<double>((_) => 5.5);

// -------- API client --------
final panchangaApiProvider = Provider<PanchangaAPI>((_) => PanchangaAPI());

// -------- Helpers --------
DateTime _at00(DateTime d) => DateTime(d.year, d.month, d.day);

// -------- Endpoint providers (ALL use PanchangaAPI) --------
final sunriseSunsetProvider =
FutureProvider.family<Map<String, dynamic>, DateTime>((ref, date) async {
  final api = ref.read(panchangaApiProvider);
  final lat = ref.read(latitudeProvider);
  final lon = ref.read(longitudeProvider);
  final tz  = ref.read(timezoneProvider);
  return api.getSunriseSunset(_at00(date), lat: lat, lon: lon, tz: tz);
});

final tithiProvider =
FutureProvider.family<Map<String, dynamic>, DateTime>((ref, date) async {
  final api = ref.read(panchangaApiProvider);
  final lat = ref.read(latitudeProvider);
  final lon = ref.read(longitudeProvider);
  final tz  = ref.read(timezoneProvider);
  return api.getTithi(_at00(date), lat: lat, lon: lon, tz: tz);
});

final nakshatraProvider =
FutureProvider.family<Map<String, dynamic>, DateTime>((ref, date) async {
  final api = ref.read(panchangaApiProvider);
  final lat = ref.read(latitudeProvider);
  final lon = ref.read(longitudeProvider);
  final tz  = ref.read(timezoneProvider);
  return api.getNakshatra(_at00(date), lat: lat, lon: lon, tz: tz);
});

final yogaProvider =
FutureProvider.family<Map<String, dynamic>, DateTime>((ref, date) async {
  final api = ref.read(panchangaApiProvider);
  final lat = ref.read(latitudeProvider);
  final lon = ref.read(longitudeProvider);
  final tz  = ref.read(timezoneProvider);
  return api.getYoga(_at00(date), lat: lat, lon: lon, tz: tz);
});

final karanaProvider =
FutureProvider.family<Map<String, dynamic>, DateTime>((ref, date) async {
  final api = ref.read(panchangaApiProvider);
  final lat = ref.read(latitudeProvider);
  final lon = ref.read(longitudeProvider);
  final tz  = ref.read(timezoneProvider);
  return api.getKarana(_at00(date), lat: lat, lon: lon, tz: tz);
});

final goodBadTimesProvider =
FutureProvider.family<Map<String, dynamic>, DateTime>((ref, date) async {
  final api = ref.read(panchangaApiProvider);
  final lat = ref.read(latitudeProvider);
  final lon = ref.read(longitudeProvider);
  final tz  = ref.read(timezoneProvider);
  return api.getGoodBadTimes(_at00(date), lat: lat, lon: lon, tz: tz);
});

final vedicWeekdayProvider =
FutureProvider.family<Map<String, dynamic>, DateTime>((ref, date) async {
  final api = ref.read(panchangaApiProvider);
  final lat = ref.read(latitudeProvider);
  final lon = ref.read(longitudeProvider);
  final tz  = ref.read(timezoneProvider);
  return api.getVedicWeekday(_at00(date), lat: lat, lon: lon, tz: tz);
});

final lunarMonthProvider =
FutureProvider.family<Map<String, dynamic>, DateTime>((ref, date) async {
  final api = ref.read(panchangaApiProvider);
  final lat = ref.read(latitudeProvider);
  final lon = ref.read(longitudeProvider);
  final tz  = ref.read(timezoneProvider);
  return api.getLunarMonth(_at00(date), lat: lat, lon: lon, tz: tz);
});

final rituProvider =
FutureProvider.family<Map<String, dynamic>, DateTime>((ref, date) async {
  final api = ref.read(panchangaApiProvider);
  final lat = ref.read(latitudeProvider);
  final lon = ref.read(longitudeProvider);
  final tz  = ref.read(timezoneProvider);
  return api.getRitu(_at00(date), lat: lat, lon: lon, tz: tz);
});

final samvatProvider =
FutureProvider.family<Map<String, dynamic>, DateTime>((ref, date) async {
  final api = ref.read(panchangaApiProvider);
  final lat = ref.read(latitudeProvider);
  final lon = ref.read(longitudeProvider);
  final tz  = ref.read(timezoneProvider);
  return api.getSamvat(_at00(date), lat: lat, lon: lon, tz: tz);
});

final aayanamProvider =
FutureProvider.family<Map<String, dynamic>, DateTime>((ref, date) async {
  final api = ref.read(panchangaApiProvider);
  final lat = ref.read(latitudeProvider);
  final lon = ref.read(longitudeProvider);
  final tz  = ref.read(timezoneProvider);
  return api.getAayanam(_at00(date), lat: lat, lon: lon, tz: tz);
});

// -------- Month grid for the calendar --------
class MonthCell {
  MonthCell(this.date, this.inCurrentMonth, this.isToday);
  final DateTime date;
  final bool inCurrentMonth;
  final bool isToday;
}

final monthGridProvider = Provider<List<MonthCell>>((ref) {
  final anchor = ref.watch(monthAnchorProvider);
  final first = DateTime(anchor.year, anchor.month, 1);
  final firstWeekday = first.weekday % 7; // make Monday=1..Sunday=0 -> 0..6
  final start = first.subtract(Duration(days: firstWeekday));

  final nextMonth = DateTime(anchor.year, anchor.month + 1, 1);
  final daysInMonth = nextMonth.difference(first).inDays;

  final cells = <MonthCell>[];
  for (var i = 0; i < 42; i++) {
    final d = start.add(Duration(days: i));
    final inMonth = d.month == anchor.month;
    final today = _at00(d) == _at00(DateTime.now());
    cells.add(MonthCell(d, inMonth, today));
  }

  // Ensure full 6 rows, ignore daysInMonth; grid already 42 cells.
  return cells;
});
