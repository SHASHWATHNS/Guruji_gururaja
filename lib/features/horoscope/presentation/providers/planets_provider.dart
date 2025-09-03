import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../horoscope/domain/entities/planet_entity.dart';
import '../../../horoscope/domain/repositories/horoscope_repository.dart';
import '../../../horoscope/data/datasources/remote/horoscope_api_service.dart';
import '../../../horoscope/data/repositories/horoscope_repository_impl.dart';
import '../../domain/entities/birth_input.dart';

sealed class PlanetsState {
  const PlanetsState();
}
class PlanetsIdle extends PlanetsState { const PlanetsIdle(); }
class PlanetsLoading extends PlanetsState { const PlanetsLoading(); }
class PlanetsReady extends PlanetsState {
  final List<PlanetEntity> planets;
  const PlanetsReady(this.planets);
}
class PlanetsError extends PlanetsState {
  final String message;
  const PlanetsError(this.message);
}

final _apiProvider = Provider((ref) => HoroscopeApiService());
final horoscopeRepositoryProvider = Provider<HoroscopeRepository>((ref) {
  final api = ref.read(_apiProvider);
  return HoroscopeRepositoryImpl(api);
});

class PlanetsNotifier extends StateNotifier<PlanetsState> {
  final HoroscopeRepository repo;
  PlanetsNotifier(this.repo) : super(const PlanetsIdle());

  Future<void> load(BirthInput input) async {
    state = const PlanetsLoading();
    try {
      final items = await repo.fetchPlanets(
        name: input.name,
        dobLocal: input.dobLocal,
        tob24h: input.tob24h,
        unknownTime: input.unknownTime,
        placeLabel: input.placeLabel,
        lat: input.lat,
        lng: input.lng,
        tzid: input.tzid,
      );

      // Keep Asc + 7 grahas + Rahu/Ketu (ignore outer planets if any)
      const desired = ['Ascendant','Sun','Moon','Mars','Mercury','Jupiter','Venus','Saturn','Rahu','Ketu'];
      final filtered = items.where((p) => desired.contains(p.name)).toList();
      filtered.sort((a,b)=> desired.indexOf(a.name).compareTo(desired.indexOf(b.name)));

      state = PlanetsReady(filtered.isEmpty ? items : filtered);
    } catch (e) {
      state = PlanetsError(e.toString());
    }
  }
}

final planetsProvider =
StateNotifierProvider<PlanetsNotifier, PlanetsState>((ref) {
  final repo = ref.read(horoscopeRepositoryProvider);
  return PlanetsNotifier(repo);
});