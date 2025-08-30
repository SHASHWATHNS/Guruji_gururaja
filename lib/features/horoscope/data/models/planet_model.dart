import '../../domain/entities/planet_entity.dart';

class PlanetModel {
  final String name;
  final String sign;      // normalized
  final double degInSign;
  final int house;
  final String nakshatra;
  final int pada;
  final bool retro;

  const PlanetModel({
    required this.name,
    required this.sign,
    required this.degInSign,
    required this.house,
    required this.nakshatra,
    required this.pada,
    required this.retro,
  });

  factory PlanetModel.fromJson(Map<String, dynamic> j) {
    // Keys seen in your screenshot: name, normDegree, current_sign, house_number, isRetro
    final name = (j['name'] ?? '').toString();
    final degInSign = _toDouble(j['degree_in_sign'] ?? j['normDegree'] ?? j['deg'] ?? j['degree'] ?? 0);
    final signIdx = int.tryParse('${j['sign_index'] ?? j['current_sign'] ?? 0}') ?? 0;
    final sign = _signNameFromIndex(signIdx);
    final house = int.tryParse('${j['house'] ?? j['house_number'] ?? 0}') ?? 0;
    final retro = (j['retro'] ?? j['isRetro'] ?? false) == true;

    // not present here—keep blank/0
    final nak = (j['nakshatra'] ?? '').toString();
    final pada = int.tryParse('${j['pada'] ?? 0}') ?? 0;

    return PlanetModel(
      name: name,
      sign: sign,
      degInSign: degInSign,
      house: house,
      nakshatra: nak,
      pada: pada,
      retro: retro,
    );
  }

  PlanetEntity toEntity() => PlanetEntity(
    name: name,
    sign: sign,
    degInSign: degInSign,
    house: house,
    nakshatra: nakshatra,
    pada: pada,
    retro: retro,
  );
}

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

// Vendor uses 1..12
String _signNameFromIndex(int i) {
  const signs = [
    '', 'Aries','Taurus','Gemini','Cancer','Leo','Virgo','Libra','Scorpio','Sagittarius','Capricorn','Aquarius','Pisces'
  ];
  if (i < 1 || i > 12) return '';
  return signs[i];
}
