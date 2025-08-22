import 'dart:math';
import '../domain/entities/panchanga.dart';
import '../domain/repositories/panchanga_repository.dart';

class MockPanchangaRepository implements PanchangaRepository {
  const MockPanchangaRepository();

  @override
  Future<PanchangaData> getPanchanga({
    required DateTime date,
    String place = 'Chennai, India',
    int tzHour = 5,
    int tzMinute = 30,
  }) async {
    // Simulate a tiny delay (remove if not needed)
    await Future<void>.delayed(const Duration(milliseconds: 150));

    // --- Fake but stable-ish values for demo ---
    final weekdayNames = [
      'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
    ];
    final wd = weekdayNames[date.weekday % 7];

    // Rotate through some values so different days look different
    final pick = (List<String> xs) => xs[date.day % xs.length];

    final nak = pick(['Ashwini','Bharani','Krittika','Rohini','Mrigashira','Pushya','Hasta','Anuradha','Shravana']);
    final thithi = pick(['Shukla Pratipad','Shukla Dwitiya','Krishna Tryodashi','Poornima','Amavasya']);
    final yoga = pick(['Vyatipata','Harshana','Shoola','Siddha','Brahma']);
    final karna = pick(['Bava','Balava','Kaulava','Taitila','Vanija','Vishti']);
    final bird = pick(['Peacock','Cock','Eagle','Swan','Parrot']);
    final activity = pick(['Move','Fix','Benefit','Neutral']);
    final swara = pick(['a, e','u, oo','hu, he, ho, Da','ka, ki']);
    final tamilMonth = pick(['Aadi','Aavani','Purattasi','Aippasi','Margazhi','Thai','Maasi','Panguni','Chithirai','Vaikasi','Aani','Shravana']);

    final sunrise = DateTime(date.year, date.month, date.day, 6, 7, 51);
    final sunset  = DateTime(date.year, date.month, date.day, 18, 37, 31);

    String hhmmss(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

    // Random-ish but stable ranges
    DateTime rangeStart(int h, int m, int s) => DateTime(date.year, date.month, date.day, h, m, s);
    final rahuStart = rangeStart(13, 56, 23);
    final rahuEnd   = rangeStart(15, 30, 06);
    final yamaStart = rangeStart(6, 7, 51);
    final yamaEnd   = rangeStart(7, 41, 34);
    final guliStart = rangeStart(9, 15, 16);
    final guliEnd   = rangeStart(10, 48, 58);
    final brahStart = rangeStart(4, 35, 48);
    final brahEnd   = rangeStart(5, 21, 50);

    final samv = pick(['Visvāvasu','Shobhakritu','Plava','Shubhakritu','Nala','Pingala']);
    final lunarMonth = pick(['Shravana','Bhadrapada','Ashwin','Karthika']);
    final solarMonth = pick(['Leo','Cancer','Virgo','Libra']);
    final ruthu = pick(['Varsha','Sharad','Hemanta','Vasanta']);
    final horaLord = pick(['Jupiter','Venus','Saturn','Mars','Mercury','Moon','Sun']);
    final tatvaChar = pick(['Sathvika','Rajasika','Tamasika']);
    final panchaTatva = pick(['Arohana-Ether[M]','Arohana-Air[M]','Arohana-Fire[M]']);
    final subPanchaTatva = pick(['Arohana-Ether[M]','Arohana-Earth[M]']);

    final janmaGhati = '00:00:0${(date.day % 9)}';
    final deg = 24, min = 12, sec = 54;
    final ayanamsa = "$deg° ${min.toString().padLeft(2, '0')}' ${sec.toString().padLeft(2, '0')}\"";

    final nvy1 = pick(['Amrita-Siddhi','Sarvartha-Siddhi','Mitra']);
    final nvy2 = pick(['Sarvartha-Siddi','Tripushkara','Dwipushkara']);

    final nLord = pick(['Saturn','Jupiter','Mars','Moon']);
    final nDeity = pick(['Brihaspati','Rudra','Indra','Vishnu']);
    final tLord = pick(['Jupiter','Venus','Rahu','Ketu']);
    final tDeity = pick(['Kama','Lakshmi','Durga','Ganesha']);
    final tDagdha = pick(['Taurus and Leo','Gemini and Virgo','Cancer and Aquarius']);
    final yLord = pick(['Rahu','Ketu','Jupiter','Saturn']);
    final yDeity = pick(['Rudra','Brahma','Vishnu','Shiva']);
    final kLord = pick(['Sun','Moon','Mars','Mercury']);
    final kDeity = pick(['Nandikeshwara','Skanda','Agni','Vayu']);

    final sections = <PanchangaSection>[
      PanchangaSection(
        items: [
          PanchangaItem(label: 'Vedic Day', value: wd),
          PanchangaItem(label: 'Star/Nakshatra', value: nak, timeText: '${date.add(const Duration(days: 1)).toString().substring(0,10)} 00:08:33'),
          PanchangaItem(label: 'Thithi', value: thithi, timeText: '${date.toString().substring(0,10)} 12:45:49'),
          PanchangaItem(label: 'Yoga', value: yoga, timeText: '${date.toString().substring(0,10)} 16:13:12'),
          PanchangaItem(label: 'Karna', value: karna, timeText: '${date.toString().substring(0,10)} 12:45:49'),
          PanchangaItem(label: 'Bird', value: bird),
          PanchangaItem(label: 'Activity', value: activity),
          PanchangaItem(label: 'Swara', value: swara),
          PanchangaItem(label: 'Tamil Month', value: tamilMonth),
        ],
      ),
      PanchangaSection(
        thickDividerBefore: true,
        items: [
          PanchangaItem(label: 'Rahu Kaala', value: '${hhmmss(rahuStart)} to ${hhmmss(rahuEnd)}'),
          PanchangaItem(label: 'Yamaganda Kaala', value: '${hhmmss(yamaStart)} to ${hhmmss(yamaEnd)}'),
          PanchangaItem(label: 'Gulika Kaala', value: '${hhmmss(guliStart)} to ${hhmmss(guliEnd)}'),
          PanchangaItem(label: 'Brahmi Muhurtha', value: '${hhmmss(brahStart)} to ${hhmmss(brahEnd)}'),
        ],
      ),
      PanchangaSection(
        thickDividerBefore: true,
        items: [
          PanchangaItem(label: 'Samvathsara', value: samv),
          PanchangaItem(label: 'Lunar Month', value: lunarMonth),
          PanchangaItem(label: 'Solar Month', value: solarMonth),
          PanchangaItem(label: 'Ruthu', value: ruthu),
          PanchangaItem(label: 'Hora Lord', value: horaLord),
          PanchangaItem(label: 'Tatva Character', value: tatvaChar),
          PanchangaItem(label: 'Pancha Tatva', value: panchaTatva),
          PanchangaItem(label: 'Sub Pancha Tatva', value: subPanchaTatva),
          PanchangaItem(label: 'Sunrise', value: hhmmss(sunrise)),
          PanchangaItem(label: 'Sunset', value: hhmmss(sunset)),
          PanchangaItem(label: 'Janma Ghati', value: janmaGhati),
          PanchangaItem(label: 'Ayanamsa', value: ayanamsa),
          PanchangaItem(
            label: 'Note',
            value: '“+” very benefic, “-” very malefic, others mildly benefic/malefic',
          ),
          PanchangaItem(label: 'Chandra Kala', value: '15 :- Destruction'),
        ],
      ),
      PanchangaSection(
        thickDividerBefore: true,
        items: [
          PanchangaItem(label: 'Nakshatra Vaara Yoga', value: nvy1, timeText: '${date.add(const Duration(days: 1)).toString().substring(0,10)} 00:08:33'),
          PanchangaItem(label: '', value: nvy2, timeText: '${date.add(const Duration(days: 2)).toString().substring(0,10)} 00:16:34'),
        ],
      ),
      PanchangaSection(
        thickDividerBefore: true,
        items: [
          PanchangaItem(label: 'Nakshatra Lord', value: nLord),
          PanchangaItem(label: 'Nakshatra Deity', value: nDeity),
          PanchangaItem(label: 'Thithi Lord', value: tLord),
          PanchangaItem(label: 'Thithi Deity', value: tDeity),
          PanchangaItem(label: 'Thithi dagdha rashi', value: tDagdha),
          PanchangaItem(label: 'Yoga Lord', value: yLord),
          PanchangaItem(label: 'Yoga Deity', value: yDeity),
          PanchangaItem(label: 'Karna Lord', value: kLord),
          PanchangaItem(label: 'Karna Deity', value: kDeity),
        ],
      ),
    ];

    return PanchangaData(date: date, sections: sections);
  }
}
