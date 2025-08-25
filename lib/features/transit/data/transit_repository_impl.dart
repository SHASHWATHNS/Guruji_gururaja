import 'dart:math';
import '../domain/entities/transit_models.dart';
import '../domain/repositories/transit_repository.dart';

class TransitRepositoryMock implements TransitRepository {
  static const _planets = <String>[
    'Sun','Moon','Mars','Mercury','Jupiter','Venus','Saturn','Rahu','Ketu'
  ];
  static const _signs = <String>[
    'Aries','Taurus','Gemini','Cancer','Leo','Virgo',
    'Libra','Scorpio','Sagittarius','Capricorn','Aquarius','Pisces'
  ];
  static const _nakshatras = <String>[
    'Ashwini','Bharani','Krittika','Rohini','Mrigashira','Ardra',
    'Punarvasu','Pushya','Ashlesha','Magha','Purva Phalguni','Uttara Phalguni',
    'Hasta','Chitra','Swati','Vishakha','Anuradha','Jyeshtha',
    'Mula','Purva Ashadha','Uttara Ashadha','Shravana','Dhanishta','Shatabhisha',
    'Purva Bhadrapada','Uttara Bhadrapada','Revati'
  ];

  final _rng = Random();

  @override
  Future<TransitDay> getTransitForDay({
    required DateTime date,
    required String timezone,
    required double lat,
    required double lng,
  }) async {
    // simulate network
    await Future.delayed(const Duration(milliseconds: 350));

    final now = DateTime.now();
    final planets = _planets.map((p) {
      final degree = _rng.nextDouble() * 30.0; // 0..30 within a sign
      final sign = _signs[_rng.nextInt(_signs.length)];
      final nak = _nakshatras[_rng.nextInt(_nakshatras.length)];
      final pada = 1 + _rng.nextInt(4);
      final retro = p == 'Mercury' || p == 'Saturn' ? _rng.nextBool() : false;
      final speed = (0.1 + _rng.nextDouble() * 1.2); // dummy
      return PlanetTransit(
        planet: p,
        sign: sign,
        degree: double.parse(degree.toStringAsFixed(2)),
        nakshatra: nak,
        pada: pada,
        retrograde: retro,
        speed: double.parse(speed.toStringAsFixed(3)),
        computedAt: now,
      );
    }).toList();

    return TransitDay(
      date: DateTime(date.year, date.month, date.day),
      timezone: timezone,
      latitude: lat,
      longitude: lng,
      planets: planets,
    );
  }
}
