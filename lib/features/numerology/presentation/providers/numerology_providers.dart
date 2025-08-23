import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/numerology_api.dart';

/// Add/update sections here (order matches tabs)
enum NumerologySection {
  jadagarinVivaram,
  kattangalLuckyNumbers,
  cellNumber,
  name,
  vehicleNumber,
  luckyColor,
  stones,
}

/// Configure your API once here
final numerologyApiProvider = Provider<NumerologyApi>((ref) {
  // TODO: put your real base URL and API key
  const baseUrl = 'https://your-numerology-api.example.com';
  const apiKey  = 'YOUR_API_KEY';
  return NumerologyApi(baseUrl: baseUrl, apiKey: apiKey);
});

/// One provider per section (family); auto-caches & refreshes on invalidate()
final numerologySectionProvider =
FutureProvider.family<Map<String, dynamic>, NumerologySection>((ref, section) async {
  final api = ref.read(numerologyApiProvider);

  // You can pass query/user inputs here if needed
  // e.g., name, dob, mobile, vehicleNo, etc.
  // For now, we call per-section endpoints.
  return api.fetchSection(section);
});
