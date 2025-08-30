import '../entities/planet_entity.dart';

abstract class HoroscopeRepository {
  Future<List<PlanetEntity>> fetchPlanets({
    required String name,
    required DateTime dobLocal,
    String? tob24h, // null if unknown
    required bool unknownTime,
    required String placeLabel,
    required double lat,
    required double lng,
    required String tzid,
  });
}
