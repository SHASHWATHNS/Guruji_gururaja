import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/numerology_api.dart';

/// Tabs
enum NumerologySection {
  jadagarinVivaram,
  kattangalLuckyNumbers,
  cellNumber,
  name,
  nameList,
  vehicleNumber,
  luckyColor,
  stones,
}

/// ---------------- Birth-details state (mirrors Horoscope flow) ----------------
class NumerologyInputState {
  final String name;
  final DateTime dob;

  NumerologyInputState({
    this.name = '',
    DateTime? dob,
  }) : dob = dob ?? _todayLocal();

  NumerologyInputState copyWith({String? name, DateTime? dob}) =>
      NumerologyInputState(
        name: name ?? this.name,
        dob: dob ?? this.dob,
      );

  static DateTime _todayLocal() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

class NumerologyInputNotifier extends StateNotifier<NumerologyInputState> {
  NumerologyInputNotifier() : super(NumerologyInputState());

  void setName(String v) => state = state.copyWith(name: v);
  void setDob(DateTime d) => state = state.copyWith(dob: d);
}

/// Expose input state (name + dob)
final numerologyInputProvider =
StateNotifierProvider<NumerologyInputNotifier, NumerologyInputState>(
      (ref) => NumerologyInputNotifier(),
);

/// ---------------- Local calculator (no API) for two tabs ----------------
int _reduceKeepMaster(int n) {
  if (n == 11 || n == 22 || n == 33) return n;
  n = n.abs();
  while (n > 9) {
    n = n.toString().split('').fold(0, (a, c) => a + int.parse(c));
    if (n == 11 || n == 22 || n == 33) return n;
  }
  return n;
}

int _sumDobDigits(DateTime d) {
  final s =
      '${d.day.toString().padLeft(2, '0')}${d.month.toString().padLeft(2, '0')}${d.year}';
  return s.split('').fold(0, (a, c) => a + int.parse(c));
}

const _pMap = <String, int>{
  'A': 1, 'J': 1, 'S': 1,
  'B': 2, 'K': 2, 'T': 2,
  'C': 3, 'L': 3, 'U': 3,
  'D': 4, 'M': 4, 'V': 4,
  'E': 5, 'N': 5, 'W': 5,
  'F': 6, 'O': 6, 'X': 6,
  'G': 7, 'P': 7, 'Y': 7,
  'H': 8, 'Q': 8, 'Z': 8,
  'I': 9, 'R': 9,
};
bool _isVowel(String ch) =>
    const {'A', 'E', 'I', 'O', 'U', 'Y'}.contains(ch);

int _nameTotal(String name,
    {bool vowelsOnly = false, bool consonantsOnly = false}) {
  final up = name.toUpperCase();
  int sum = 0;
  for (final rune in up.runes) {
    final ch = String.fromCharCode(rune);
    final val = _pMap[ch];
    if (val == null) continue;
    if (vowelsOnly && !_isVowel(ch)) continue;
    if (consonantsOnly && _isVowel(ch)) continue;
    sum += val;
  }
  return sum == 0 ? 0 : _reduceKeepMaster(sum);
}

Map<String, dynamic> _buildJadagarinVivaramJson(NumerologyInputState input) {
  final lifePath = _reduceKeepMaster(_sumDobDigits(input.dob));
  final destiny = _nameTotal(input.name);
  final soul = _nameTotal(input.name, vowelsOnly: true);
  final perso = _nameTotal(input.name, consonantsOnly: true);
  final maturity = _reduceKeepMaster(lifePath + destiny);
  final bday = _reduceKeepMaster(input.dob.day);

  return {
    'Name': input.name,
    'DOB':
    '${input.dob.day.toString().padLeft(2, '0')}-${input.dob.month.toString().padLeft(2, '0')}-${input.dob.year}',
    'Life Path': lifePath,
    'Destiny / Expression': destiny,
    'Soul Urge': soul,
    'Personality': perso,
    'Maturity': maturity,
    'Birth-Day Number': bday,
  };
}

Map<String, dynamic> _buildKattangalJson(NumerologyInputState input) {
  int r(int n) => _reduceKeepMaster(n);
  final now = DateTime.now();

  final personalYear = r(now.year + input.dob.month + input.dob.day);
  final personalMonth = r(personalYear + now.month);
  final personalDay = r(personalMonth + now.day);

  final d = r(input.dob.day);
  final m = r(input.dob.month);
  final y = r(
      input.dob.year.toString().split('').fold(0, (a, c) => a + int.parse(c)));

  final pinnacles = [r(d + m), r(d + y), r(r(d + m) + r(d + y)), r(m + y)];
  final challenges = [
    r((d - m).abs()),
    r((d - y).abs()),
    r(((d - m).abs() - (d - y).abs()).abs()),
    r((m - y).abs())
  ];

  return {
    'Personal Year': personalYear,
    'Personal Month': personalMonth,
    'Personal Day': personalDay,
    'Pinnacles': {
      'P1': pinnacles[0],
      'P2': pinnacles[1],
      'P3': pinnacles[2],
      'P4': pinnacles[3]
    },
    'Challenges': {
      'C1': challenges[0],
      'C2': challenges[1],
      'C3': challenges[2],
      'C4': challenges[3]
    },
  };
}

/// ---------------- Existing API config ----------------
final numerologyApiProvider = Provider<NumerologyApi>((ref) {
  const baseUrl = 'https://your-numerology-api.services.com';
  const apiKey = 'YOUR_API_KEY';
  return NumerologyApi(baseUrl: baseUrl, apiKey: apiKey);
});

/// One provider per section (family); local for two tabs, API for others
final numerologySectionProvider =
FutureProvider.family<Map<String, dynamic>, NumerologySection>(
        (ref, section) async {
      final api = ref.read(numerologyApiProvider);
      final input = ref.watch(numerologyInputProvider);

      if (section == NumerologySection.jadagarinVivaram) {
        return _buildJadagarinVivaramJson(input);
      }
      if (section == NumerologySection.kattangalLuckyNumbers) {
        return _buildKattangalJson(input);
      }

      // All other tabs go to your API
      return api.fetchSection(section);
    });
