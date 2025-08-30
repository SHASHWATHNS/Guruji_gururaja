class PlanetEntity {
  final String name;          // Sun, Moon, ...
  final String sign;          // Aries..Pisces
  final double degInSign;     // 0..30
  final int house;            // 1..12 (0 if missing)
  final String nakshatra;     // may be empty
  final int pada;             // 0..4
  final bool retro;

  const PlanetEntity({
    required this.name,
    required this.sign,
    required this.degInSign,
    required this.house,
    required this.nakshatra,
    required this.pada,
    required this.retro,
  });
}
