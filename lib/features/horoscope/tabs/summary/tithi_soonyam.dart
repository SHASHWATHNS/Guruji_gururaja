// lib/features/horoscope/tabs/summary/tithi_soonyam.dart

class TithiSoonyamInfo {
  final List<String> rasi;     // Shoonya rāsi to display
  final List<String> planets;  // Afflicted planets (optional)
  final List<String> remedies; // Nitya Devis (optional)
  const TithiSoonyamInfo({this.rasi = const [], this.planets = const [], this.remedies = const []});
}

int _fortnightIndex(int tithiNumber) => ((tithiNumber - 1) % 15) + 1;

const Map<int, TithiSoonyamInfo> _soonyamTable = {
  1:  TithiSoonyamInfo(rasi: ['Libra','Capricorn'], planets: ['Venus','Saturn'], remedies: ['Kameshvari','Vijaya']),
  12: TithiSoonyamInfo(rasi: ['Libra','Capricorn'], planets: ['Venus','Saturn'], remedies: ['Kameshvari','Vijaya']),
  2:  TithiSoonyamInfo(rasi: ['Sagittarius','Pisces'], planets: ['Jupiter'], remedies: ['Bhagamalini','Nilapataka']),
  11: TithiSoonyamInfo(rasi: ['Sagittarius','Pisces'], planets: ['Jupiter'], remedies: ['Bhagamalini','Nilapataka']),
  3:  TithiSoonyamInfo(rasi: ['Leo','Capricorn'], planets: ['Sun','Saturn'], remedies: ['Nityaklinna']),
  4:  TithiSoonyamInfo(rasi: ['Taurus','Aquarius'], planets: ['Venus','Saturn'], remedies: ['Bherunda']),
  5:  TithiSoonyamInfo(rasi: ['Gemini','Virgo'], planets: ['Mercury'], remedies: ['Vahnivasini','Tvarita']),
  8:  TithiSoonyamInfo(rasi: ['Gemini','Virgo'], planets: ['Mercury'], remedies: ['Vahnivasini','Tvarita']),
  6:  TithiSoonyamInfo(rasi: ['Aries','Leo'], planets: ['Mars','Sun'], remedies: ['MahaVajreswari']),
  7:  TithiSoonyamInfo(rasi: ['Cancer','Sagittarius'], planets: ['Moon','Jupiter'], remedies: ['Shivaduti']),
  9:  TithiSoonyamInfo(rasi: ['Leo','Scorpio'], planets: ['Sun','Mars'], remedies: ['Kulasundari','Nitya']),
  10: TithiSoonyamInfo(rasi: ['Leo','Scorpio'], planets: ['Sun','Mars'], remedies: ['Kulasundari','Nitya']),
  13: TithiSoonyamInfo(rasi: ['Taurus','Leo'], planets: ['Venus','Sun'], remedies: ['Sarvamangala']),
  14: TithiSoonyamInfo(rasi: ['Gemini','Virgo','Sagittarius','Pisces'], planets: ['Mercury','Jupiter'], remedies: ['Jwalamalini']),
  15: TithiSoonyamInfo(rasi: [], planets: [], remedies: ['Chidroopa (Chitra)']),
};

TithiSoonyamInfo tithiSoonyamInfo(int tithiNumber) {
  return _soonyamTable[_fortnightIndex(tithiNumber)] ?? const TithiSoonyamInfo();
}

String tithiSoonyamText(int tithiNumber) {
  final r = tithiSoonyamInfo(tithiNumber).rasi;
  return r.isEmpty ? '—' : r.join(', ');
}
