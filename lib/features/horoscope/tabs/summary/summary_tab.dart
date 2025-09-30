// lib/features/horoscope/tabs/summary/summary_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../form/horoscope_form_screen.dart' show birthDataProvider, BirthData;
import '../../data/repository.dart' show horoscopeRepositoryProvider;
import 'summary_service.dart' show AstroRequest;
import 'tithi_soonyam.dart';
import '../../../../core/i18n/app_localizations.dart';

// ── helpers ─────────────────────────────────────────────────────────
class _Age { final int y, m, d; const _Age(this.y, this.m, this.d); }
_Age _ageFrom(DateTime birth, DateTime now) {
  var y = now.year - birth.year;
  var m = now.month - birth.month;
  var d = now.day - birth.day;
  if (d < 0) { d += DateTime(now.year, now.month, 0).day; m -= 1; }
  if (m < 0) { m += 12; y -= 1; }
  return _Age(y, m, d);
}
String _fmtDob(DateTime d) => DateFormat.yMMMMd().format(d);
String _fmtTob(BuildContext c, TimeOfDay t) => t.format(c);
String _norm(String v) => v.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_').replaceAll('-', '_');

// ── dictionaries ────────────────────────────────────────────────────
const _taZodiac = {
  'aries':'மேஷம்','taurus':'ரிஷபம்','gemini':'மிதுனம்','cancer':'கடகம்',
  'leo':'சிம்மம்','virgo':'கன்னி','libra':'துலாம்','scorpio':'விருச்சிகம்',
  'sagittarius':'தனுசு','capricorn':'மகரம்','aquarius':'கும்பம்','pisces':'மீனம்',
};

const _taNak = {
  'aswini':'அசுவினி (கேது)','ashwini':'அசுவினி (கேது)',
  'bharani':'பரணி (சுக்கிரன்)','krittika':'கார்த்திகை (சூரியன்)',
  'rohini':'ரோகிணி (சந்திரன்)',
  'mrigasira':'மிருகசீரிஷம் (செவ்வாய்)','mrigashira':'மிருகசீரிஷம் (செவ்வாய்)',
  'aardra':'திருவாதிரை (ராகு)','ardra':'திருவாதிரை (ராகு)',
  'punarvasu':'புனர்பூசம் (குரு)',
  'pushya':'பூசம் (சனி)','pushyami':'பூசம் (சனி)',
  'aaslesha':'ஆயில்யம் (புதன்)','ashlesha':'ஆயில்யம் (புதன்)',
  'makha':'மகம் (கேது)','magha':'மகம் (கேது)',
  'poorva_phalguni(pubba)':'பூரம் (சுக்கிரன்)','purva_phalguni':'பூரம் (சுக்கிரன்)',
  'uttara_phalguni(uttara)':'உத்திரம் (சூரியன்)','uttara_phalguni':'உத்திரம் (சூரியன்)',
  'hasta':'ஹஸ்தம் (சந்திரன்)',
  'chitta':'சித்திரை (செவ்வாய்)','chitra':'சித்திரை (செவ்வாய்)',
  'swati':'சுவாதி (ராகு)',
  'visakha':'விசாகம் (குரு)','vishakha':'விசாகம் (குரு)',
  'anuradha':'அனுஷம் (சனி)',
  'jyeshta':'கேட்டை (புதன்)','jyeshtha':'கேட்டை (புதன்)',
  'moola':'மூலம் (கேது)','mula':'மூலம் (கேது)',
  'poorvaashaada':'பூராடம் (சுக்கிரன்)','purva_ashadha':'பூராடம் (சுக்கிரன்)',
  'uttaraashaada':'உத்திராடம் (சூரியன்)','uttara_ashadha':'உத்திராடம் (சூரியன்)',
  'sravanam':'திருவோணம் (சந்திரன்)','shravana':'திருவோணம் (சந்திரன்)',
  'dhanishta':'அவிட்டம் (செவ்வாய்)',
  'satabisha':'சதயம் (ராகு)','shatabhisha':'சதயம் (ராகு)',
  'poorvaabhadra':'பூரட்டாதி (குரு)','purva_bhadrapada':'பூரட்டாதி (குரு)',
  'uttaraabhadra':'உத்திரட்டாதி (சனி)','uttara_bhadrapada':'உத்திரட்டாதி (சனி)',
  'revati':'ரேவதி (புதன்)',
};

const _taTithiName = {
  'pratipat':'பிரதமை','dwitiya':'துவிதியை','tritiya':'திருதியை','chaturthi':'சதுர்த்தி',
  'panchami':'பஞ்சமி','shahshthi':'ஷஷ்டி','saptami':'சப்தமி','ashtami':'அஷ்டமி',
  'navami':'நவமி','dashami':'தசமி','ekadashi':'ஏகாதசி','dwadashi':'த்வாதசி',
  'trayodashi':'திரயோதசி','chaturdashi':'சதுர்தசி','poornima':'பௌர்ணமி','amawasya':'அமாவாசை',
};

const _taPaksha = {'valarpirai':'வளர்பிறை','theypirai':'தேய்பிறை'};
const _taTamilYears = {
  'Prabhava':'பிரபவ','Vibhava':'விபவ','Shukla':'சுக்ல','Pramoduta':'ப்ரமோதை','Prachopati':'ப்ரசோபதி','Angirasa':'அங்கீரச',
  'Srimukha':'ஸ்ரீமுக','Bhava':'பாவ','Yuva':'யுவ','Dhatu':'தாது','Ishvara':'ஈஸ்வர','Vehudanya':'வேஹுதான்ய',
  'Pramati':'ப்ரமதி','Vikrama':'விக்ரம','Vishu':'விஷு','Chitrabhanu':'சித்திரபானு','Subhanu':'சுபானு','Dharana':'தாரண',
  'Parthiba':'பர்திபா','Viya':'வியா','Sarvajit':'சர்வஜித்','Sarvadhari':'சர்வாதாரி','Virodhi':'விரோதி','Vikruti':'விக்ருதி',
  'Kara':'கர','Nandana':'நந்தன','Vijaya':'விஜய','Jaya':'ஜய','Manmatha':'மன்மத','Dhunmuki':'துன்முகி',
  'Hevilambi':'ஹேவிலம்பி','Vilambi':'விலம்பி','Vikari':'விகாரி','Sarvari':'சர்வரி','Plava':'ப்லவ','Subhakrith':'சுபகிருது',
  'Shobhakrith':'சோபகிருது','Krodhi':'க்ரோதீ','Vishvavasu':'விஷ்வவாசு','Parabhava':'பரபவ','Plavanga':'ப்லவங்க','Kilaka':'கீலக',
  'Saumya':'சௌம்ய','Sadharana':'சாதாரண','Virodhikruthi':'விரோதிகிருதி','Paritapi':'பரிதாபி','Pramadeecha':'ப்ரமதீச',
  'Ananda':'ஆனந்த','Rakshasa':'ராக்ஷச','Nala':'நள','Pingala':'பிங்கல','Kalayukthi':'காலயுக்தி','Siddharthi':'சித்தார்த்தி',
  'Roudri':'ரௌத்ரி','Dhunmati':'துன்மதி','Dundubhi':'துண்டுபி','Rudhurotgari':'ருதுரோத்கரி','Raktakshi':'ராக்தாக்ஷி',
  'Krodhana':'க்ரோதனா','Akshaya':'அக்ஷய',
};
const _taKarana = {
  'bava':'பவம்  (செவ்வாய்)  (சிங்கம்)','balava':'பாலவம்  (ராகு)  (புலி)',
  'kaulava':'கௌலவம்  (சனி)  (பன்றி)','taitula':'தைதுலம்  (சுக்கிரன்)  (கழுதை)',
  'garija':'கரசை  (சந்திரன்)  (யானை)','vanija':'வணிசை  (சூரியன்)  (எருது)',
  'vishti':'பத்திரை  (கேது)  (கோழி)','bhadra':'பத்திரை  (கேது)  (கோழி)',
  'sakuna':'சகுனி  (சனி)  (காக்கை)','chatushapada':'சதுஷ்பாதம்  (குரு)  (நாய்)',
  'naga':'நாகவம்  (ராகு)  (பாம்பு)','kimstughna':'கிம்ஸ்துக்னம்  (புதன்)  (புழு)',
};
const _taYoga = {
  'vishkambha':'விஷ்கம்பம்','preeti':'பிரீதி','aayushmaan':'ஆயுஷ்மான்','soubhaagya':'சௌபாக்கியம்',
  'sobhana':'சோபனம்','atiganda':'அதிகண்டம்','sukarman':'சுகர்மம்','dhriti':'திருதி','shoola':'சூலம்','ganda':'கண்டம்','vriddhi':'விருத்தி','dhruva':'துருவம்',
  'vyaaghaata':'வியாகாதம்','harshana':'ஹர்ஷணம்','vajra':'வஜ்ரம்','siddhi':'சித்தி','vyatipaata':'வியாதிபாதம்','variyaan':'வரியான்',
  'variyan':'வரியான்','parigha':'பரீகம்','shiva':'சிவம்','siddha':'சித்தம்','saadhya':'சாத்தியம்','subha':'சுபம்','sukla':'சுப்பிரம்','brahma':'பிராமியம்','indra':'ஐந்திரம்','vaidhriti':'வைதிருதி',
};

// ── translation helpers ────────────────────────────────────────────
String _taYear(String v) => _taTamilYears[v] ?? _ta(_taTamilYears, v);
String _ta(Map<String, String> m, String v) {
  if (v.trim().isEmpty || v == '—') return v;
  return m[_norm(v)] ?? m[v] ?? v;
}
String _taList(String csv, Map<String,String> dict) {
  if (csv.trim().isEmpty || csv == '—') return csv;
  final items = csv.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
  return items.map((e) => _ta(dict, e)).join(', ');
}
String _taTithi(int number, String name) {
  final s = name.trim();
  if (s.isEmpty || s == '—') return s;
  final parts = s.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  String? paksha;
  String base = parts.last;
  if (parts.length > 1) {
    final f = parts.first.toLowerCase();
    if (f.startsWith('valar') || f.startsWith('shukla') || f.startsWith('sukla') || f.startsWith('wax')) {
      paksha = 'valarpirai';
    } else if (f.startsWith('they') || f.startsWith('krishna') || f.startsWith('wan')) {
      paksha = 'theypirai';
    }
  }
  final tName = _ta(_taTithiName, base);
  final withPaksha = paksha != null ? '${_ta(_taPaksha, paksha!)} $tName' : tName;
  if (number > 0) return '$number $withPaksha';
  return withPaksha;
}

// ── widget ─────────────────────────────────────────────────────────
class SummaryTab extends ConsumerStatefulWidget {
  const SummaryTab({super.key});
  @override
  ConsumerState<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends ConsumerState<SummaryTab> {
  final _vCtrl = ScrollController();

  @override
  void dispose() { _vCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bd = ref.watch(birthDataProvider);
    if (bd == null) {
      return Center(child: Text(context.l10n.t('form.fillFirst')));
    }

    final isTa = Localizations.localeOf(context).languageCode == 'ta';
    String tr(Map<String,String> dict, String v) => isTa ? _ta(dict, v) : v;
    String trYear(String v) => isTa ? _taYear(v) : v;
    String trList(String csv, Map<String,String> dict) => isTa ? _taList(csv, dict) : csv;
    String trTithi(int n, String name) => isTa ? _taTithi(n, name) : (n > 0 ? '$n $name' : name);

    final ist = DateTime(bd.dob.year, bd.dob.month, bd.dob.day, bd.tob.hour, bd.tob.minute);
    final req = AstroRequest(
      name: bd.name,
      birthIST: ist,
      place: '${bd.district}, ${bd.state}, ${bd.country}',
      lat: bd.lat ?? 0,
      lon: bd.lon ?? 0,
      tz: bd.timezone,
    );

    final repo = ref.read(horoscopeRepositoryProvider);

    return Scrollbar(
      controller: _vCtrl,
      thumbVisibility: true,
      child: FutureBuilder<Map<String, dynamic>>(
        future: repo.getSummary(req),
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
          }
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text('${context.l10n.t('summary.error')}: ${snap.error}', style: const TextStyle(color: Colors.red)),
            );
          }

          final m = snap.data ?? const {};
          final age = _ageFrom(ist, DateTime.now());

          String fmtDeg(num? v) {
            final d = v == null ? null : (v as num).toDouble();
            if (d == null || d.isNaN) return '—';
            return d.toStringAsFixed(2);
          }

          final tithiNum  = (m['tithiNumber'] ?? 0) as int;
          final rawTithi  = (m['tithiName'] ?? '—').toString();
          final soonyam   = tithiSoonyamText(tithiNum);

          // Strip any leading number/paksha words from API tithi name → base only
          final baseTithi = rawTithi
              .replaceAll(RegExp(r'^\d+\s*'), '')
              .replaceAll(RegExp(r'^(Valarpirai|Theypirai|Shukla|Sukla|Krishna|Waxing|Waning)\s+', caseSensitive: false), '')
              .trim();

          // Tithi row should be number + base tithi ONLY (no paksha inside)
          final tithiDisplayName = baseTithi;

          // Standalone paksha row: compute from tithi number (1–15 / 16–30)
          final pakshaKey = (tithiNum <= 15) ? 'valarpirai' : 'theypirai';
          final pakshaDisplay = isTa
              ? context.l10n.t(pakshaKey == 'valarpirai' ? 'paksha.valarpirai' : 'paksha.theypirai')
              : (pakshaKey == 'valarpirai' ? 'Valarpirai' : 'Theypirai');

          final items = <(String,String)>[
            (context.l10n.t('label.name'), m['name']?.toString() ?? bd.name),
            (context.l10n.t('label.birthplace'), m['birthplace']?.toString() ?? '${bd.district}, ${bd.state}, ${bd.country}'),

            // Local info
            (context.l10n.t('label.dob'), _fmtDob(bd.dob)),
            (context.l10n.t('label.tob'), _fmtTob(context, bd.tob)),
            (context.l10n.t('label.english.weekday'), DateFormat.EEEE().format(ist)),
            (context.l10n.t('label.tamil.day'), DateFormat.EEEE('ta_IN').format(ist)),
            (context.l10n.t('label.age'), '${age.y}y ${age.m}m ${age.d}d'),

            // Astro summary
            (context.l10n.t('label.lagnam'), tr(_taZodiac, m['lagnam']?.toString() ?? '—')),
            (context.l10n.t('label.raasi'), tr(_taZodiac, m['raasi']?.toString() ?? '—')),
            (context.l10n.t('label.nakshatra'), tr(_taNak, m['nakshatra']?.toString() ?? '—')),

            // Tithi: number + translated base name (no paksha embedded)
            (context.l10n.t('label.tithi'), trTithi(tithiNum, tithiDisplayName)),

            // NEW: standalone Paksha / Pirai row
            (context.l10n.t('label.paksha'), pakshaDisplay),

            (context.l10n.t('label.tithi_soonyam'), trList(soonyam, _taZodiac)),
            (context.l10n.t('label.yoga'), tr(_taYoga, m['yogaName']?.toString() ?? '—')),
            (context.l10n.t('label.karana'), tr(_taKarana, m['karanaName']?.toString() ?? '—')),

            // Yogi/Avayogi
            (context.l10n.t('label.yogi_nakshatra'), tr(_taNak, m['yogiNakshatra']?.toString() ?? '—')),
            (context.l10n.t('label.avayogi_nakshatra'), tr(_taNak, m['avayogiNakshatra']?.toString() ?? '—')),

            // Tamil month / year
            (context.l10n.t('label.tamil.month'), m['tamilMonth']?.toString() ?? '—'),
            (context.l10n.t('label.tamil.year'), trYear(m['tamilYear']?.toString() ?? '—')),
            //
            // // Degrees
            // (context.l10n.t('label.sun.deg'), fmtDeg(m['sunLongitudeDeg'] as num?)),
            // (context.l10n.t('label.moon.deg'), fmtDeg(m['moonLongitudeDeg'] as num?)),
          ];

          return ListView.builder(
            controller: _vCtrl,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: items.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) return const SizedBox(height: 4);
              final kv = items[i - 1];
              return _KVRow(k: kv.$1, v: kv.$2);
            },
          );
        },
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  const _KVRow({required this.k, required this.v});
  final String k, v;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(width: 12),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }
}
