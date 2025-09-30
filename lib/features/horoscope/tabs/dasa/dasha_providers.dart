// lib/features/horoscope/tabs/dasa/dasha_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../form/horoscope_form_screen.dart' show BirthData;
import 'dasha_service.dart';

final dashaServiceProvider = Provider<DashaService>((_) => DashaService());

/// 1) Mahā list (API)
final mahaProvider =
FutureProvider.autoDispose.family<List<Map<String, dynamic>>, BirthData>((ref, bd) async {
  final service = ref.read(dashaServiceProvider);
  return service.fetchMaha(bd);
});

/// Key for Bhukti (Antar)
class AntarKey {
  final BirthData bd;
  final String lord;
  const AntarKey(this.bd, this.lord);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AntarKey && other.bd == bd && other.lord == lord);
  @override
  int get hashCode => Object.hash(bd, lord);
}

/// 2) Bhukti list for selected Mahā (API)
final antarProvider =
FutureProvider.autoDispose.family<List<Map<String, dynamic>>, AntarKey>((ref, key) async {
  final service = ref.read(dashaServiceProvider);
  return service.fetchAntarForLord(key.bd, key.lord);
});

/// Keys for computed levels
class PratyKey {
  final Map<String, dynamic> antar;
  const PratyKey(this.antar);
  @override
  bool operator ==(Object o) => o is PratyKey && o.antar == antar;
  @override
  int get hashCode => antar.hashCode;
}

class SookKey {
  final Map<String, dynamic> praty;
  const SookKey(this.praty);
  @override
  bool operator ==(Object o) => o is SookKey && o.praty == praty;
  @override
  int get hashCode => praty.hashCode;
}

class PranaKey {
  final Map<String, dynamic> sook;
  const PranaKey(this.sook);
  @override
  bool operator ==(Object o) => o is PranaKey && o.sook == sook;
  @override
  int get hashCode => sook.hashCode;
}

/// 3) Pratyantar (computed)
final pratyantarProvider =
FutureProvider.autoDispose.family<List<Map<String, dynamic>>, PratyKey>((ref, key) async {
  final service = ref.read(dashaServiceProvider);
  return service.computePratyantar(key.antar);
});

/// 4) Sūkṣma (computed)
final sookshmaProvider =
FutureProvider.autoDispose.family<List<Map<String, dynamic>>, SookKey>((ref, key) async {
  final service = ref.read(dashaServiceProvider);
  return service.computeSookshma(key.praty);
});

/// 5) Prāṇa (computed)
final pranaProvider =
FutureProvider.autoDispose.family<List<Map<String, dynamic>>, PranaKey>((ref, key) async {
  final service = ref.read(dashaServiceProvider);
  return service.computePrana(key.sook);
});
