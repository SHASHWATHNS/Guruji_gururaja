import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../form/horoscope_form_screen.dart' show birthDataProvider;
import 'chart_service.dart';

/// Construct a single request-body from the saved form data.
/// All downstream calls reuse this; avoids ProviderFamily misuse.
final chartBodyProvider = Provider<Map<String, dynamic>>((ref) {
  final bd = ref.watch(birthDataProvider);
  if (bd == null) {
    throw StateError('No birth data. Open Horoscope form first.');
  }
  final birthIst = DateTime(bd.dob.year, bd.dob.month, bd.dob.day, bd.tob.hour, bd.tob.minute);
  return ref.read(chartServiceProvider).bodyFrom(
    birth: birthIst,
    lat: bd.lat ?? 0,
    lon: bd.lon ?? 0,
    tz: bd.timezone,
  );
});

final chartServiceProvider = Provider<ChartService>((_) => ChartService());

final raasiSvgProvider = FutureProvider.autoDispose<String>((ref) async {
  final body = ref.watch(chartBodyProvider);
  final svc = ref.read(chartServiceProvider);
  return svc.fetchRaasiSvg(body);
});

final navamsaSvgProvider = FutureProvider.autoDispose<String>((ref) async {
  final body = ref.watch(chartBodyProvider);
  final svc = ref.read(chartServiceProvider);
  return svc.fetchNavamsaSvg(body);
});

final planetsProvider = FutureProvider.autoDispose((ref) async {
  final body = ref.watch(chartBodyProvider);
  final svc = ref.read(chartServiceProvider);
  return svc.fetchPlanetsExtended(body);
});
