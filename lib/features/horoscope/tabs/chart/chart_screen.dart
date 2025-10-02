// lib/features/horoscope/tabs/chart/chart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../form/horoscope_form_screen.dart' show birthDataProvider;
import '../../data/repository.dart' show horoscopeRepositoryProvider;
import '../../../../core/i18n/app_localizations.dart';

class ChartScreen extends ConsumerStatefulWidget {
  const ChartScreen({super.key});
  @override
  ConsumerState<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen> {
  final _vCtrl = ScrollController();
  final _planetsHCtrl = ScrollController();

  @override
  void dispose() {
    _vCtrl.dispose();
    _planetsHCtrl.dispose();
    super.dispose();
  }

  // ---- strip Ur/Ne/Pl from SVG cell labels ----
  String _stripOuterPlanetsFromSvg(String svg) {
    var out = svg;
    for (final p in const [
      r'(?:(?<=^)|(?<=[\s(>]))Ur(?=(?:$)|[\s)<])',
      r'(?:(?<=^)|(?<=[\s(>]))Ne(?=(?:$)|[\s)<])',
      r'(?:(?<=^)|(?<=[\s(>]))Pl(?=(?:$)|[\s)<])',
    ]) {
      out = out.replaceAll(RegExp(p), '');
    }
    out = out.replaceAll(RegExp(r'\(\s*\)'), '');
    out = out.replaceAll(RegExp(r'\s{2,}'), ' ');
    out = out.replaceAllMapped(RegExp(r'>([^<]*?)<\/text>'),
            (m) => '>${m.group(1)!.trim()}</text>');
    return out;
  }

  // ---------- tiny value-localization helpers (Chart tab only) ----------
  String _norm(String v) =>
      v.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_').replaceAll('-', '_');

  static const _taZodiac = {
    'aries': 'மேஷம்',
    'taurus': 'ரிஷபம்',
    'gemini': 'மிதுனம்',
    'cancer': 'கடகம்',
    'leo': 'சிம்மம்',
    'virgo': 'கன்னி',
    'libra': 'துலாம்',
    'scorpio': 'விருச்சிகம்',
    'sagittarius': 'தனுசு',
    'capricorn': 'மகரம்',
    'aquarius': 'கும்பம்',
    'pisces': 'மீனம்'
  };

  static const _taPlanets = {
    'ascendant': 'லக்னம்',
    'sun': 'சூரியன்',
    'moon': 'சந்திரன்',
    'mars': 'செவ்வாய்',
    'mercury': 'புதன்',
    'jupiter': 'குரு',
    'venus': 'சுக்கிரன்',
    'saturn': 'சனி',
    'rahu': 'ராகு',
    'ketu': 'கேது',
    'uranus': 'உரேனஸ்',
    'neptune': 'நெப்ட்யூன்',
    'pluto': 'ப்ளூட்டோ'
  };

  static const _taNak = {
    'aswini': 'அசுவினி (கேது)',
    'ashwini': 'அசுவினி (கேது)',
    'bharani': 'பரணி (சுக்கிரன்)',
    'krittika': 'கார்த்திகை (சூரியன்)',
    'rohini': 'ரோகிணி (சந்திரன்)',
    'mrigasira': 'மிருகசீரிஷம் (செவ்வாய்)',
    'mrigashira': 'மிருகசீரிஷம் (செவ்வாய்)',
    'aardra': 'திருவாதிரை (ராகு)',
    'ardra': 'திருவாதிரை (ராகு)',
    'punarvasu': 'புனர்பூசம் (குரு)',
    'pushya': 'பூசம் (சனி)',
    'pushyami': 'பூசம் (சனி)',
    'aaslesha': 'ஆயில்யம் (புதன்)',
    'ashlesha': 'ஆயில்யம் (புதன்)',
    'makha': 'மகம் (கேது)',
    'magha': 'மகம் (கேது)',
    'poorva_phalguni(pubba)': 'பூரம் (சுக்கிரன்)',
    'purva_phalguni': 'பூரம் (சுக்கிரன்)',
    'uttara_phalguni(uttara)': 'உத்திரம் (சூரியன்)',
    'uttara_phalguni': 'உத்திரம் (சூரியன்)',
    'hasta': 'ஹஸ்தம் (சந்திரன்)',
    'chitta': 'சித்திரை (செவ்வாய்)',
    'chitra': 'சித்திரை (செவ்வாய்)',
    'swati': 'சுவாதி (ராகு)',
    'visakha': 'விசாகம் (குரு)',
    'vishakha': 'விசாகம் (குரு)',
    'anuradha': 'அனுஷம் (சனி)',
    'jyeshta': 'கேட்டை (புதன்)',
    'jyeshtha': 'கேட்டை (புதன்)',
    'moola': 'மூலம் (கேது)',
    'mula': 'மூலம் (கேது)',
    'poorvaashaada': 'பூராடம் (சுக்கிரன்)',
    'purva_ashadha': 'பூராடம் (சுக்கிரன்)',
    'uttaraashaada': 'உத்திராடம் (சூரியன்)',
    'uttara_ashadha': 'உத்திராடம் (சூரியன்)',
    'sravanam': 'திருவோணம் (சந்திரன்)',
    'shravana': 'திருவோணம் (சந்திரன்)',
    'dhanishta': 'அவிட்டம் (செவ்வாய்)',
    'satabisha': 'சதயம் (ராகு)',
    'shatabhisha': 'சதயம் (ராகு)',
    'poorvaabhadra': 'பூரட்டாதி (குரு)',
    'purva_bhadrapada': 'பூரட்டாதி (குரு)',
    'uttaraabhadra': 'உத்திரட்டாதி (சனி)',
    'uttara_bhadrapada': 'உத்திரட்டாதி (சனி)',
    'revati': 'ரேவதி (புதன்)',
  };

  String _ta(Map<String, String> dict, String v) {
    if (Localizations.localeOf(context).languageCode != 'ta') return v;
    final raw = v.trim();
    if (raw.isEmpty || raw == '—') return v;
    final hasVa = RegExp(r'\(va\)', caseSensitive: false).hasMatch(raw);
    final withoutVa =
    raw.replaceAll(RegExp(r'\s*\(va\)\s*', caseSensitive: false), '').trim();
    final noParenTrail =
    withoutVa.replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), '').trim();
    String? pick(Map<String, String> m, String s) =>
        m[_norm(s)] ?? m[s.toLowerCase()] ?? m[s];
    final translated = pick(dict, withoutVa) ?? pick(dict, noParenTrail) ?? v;
    return hasVa ? '$translated (va)' : translated;
  }

  // ---- SVG tweaks ----
  String _localizeSvgTitles(String svg) {
    if (Localizations.localeOf(context).languageCode != 'ta') return svg;
    return svg
        .replaceAll('Rāśi', 'ராசி')
        .replaceAll('Rasi', 'ராசி')
        .replaceAll('Navāṁśa', 'நவாம்சம்')
        .replaceAll('Navamsa', 'நவாம்சம்');
  }

  String _localizeSvgCellTokens(String svg) {
    if (Localizations.localeOf(context).languageCode != 'ta') return svg;
    const tok = <String, String>{
      'Asc': 'லக்னம்',
      'Su': 'சூ',
      'Mo': 'ச',
      'Ma': 'செ',
      'Me': 'பு',
      'Ju': 'கு',
      'Ve': 'சு',
      'Sa': 'ச',
      'Ra': 'ரா',
      'Ke': 'கே',
      'Ur': 'யு',
      'Ne': 'நெ',
      'Pl': 'ப்ளூ',
    };
    var out = svg;
    tok.forEach((k, v) {
      final re = RegExp(r'(?:(?<=^)|(?<=[\s(>]))' + k + r'(?=(?:$)|[\s)<])');
      out = out.replaceAllMapped(re, (_) => v);
    });
    return out;
  }

  String _stackHouseLabels(String svg) {
    final re = RegExp(
        r'<text[^>]*\bx="([\d.]+)"[^>]*\by="([\d.]+)"[^>]*>([^<]+)</text>');
    final isTa = Localizations.localeOf(context).languageCode == 'ta';
    final perLine = isTa ? 3 : 2;

    bool _skip(String s) {
      final t = s.trim();
      if (t.isEmpty) return true;
      if (t.contains('Rāśi') ||
          t.contains('Navāṁśa') ||
          t.contains('ராசி') ||
          t.contains('நவாம்சம்')) return true;
      if (!t.contains(' ')) return true;
      if (RegExp(r'^\(?[A-Za-z]{1,4}\)?$').hasMatch(t)) return true;
      return false;
    }

    return svg.replaceAllMapped(re, (m) {
      final x = m.group(1)!;
      final y = m.group(2)!;
      final content = m.group(3)!.trim();
      if (_skip(content)) return m[0]!;

      final tokens =
      content.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
      final lines = <String>[];
      int i = 0;
      if (tokens.isNotEmpty && tokens.first.toLowerCase() == 'asc') {
        lines.add(tokens.first);
        i = 1;
      }
      while (i < tokens.length) {
        final end = (i + perLine <= tokens.length) ? i + perLine : tokens.length;
        lines.add(tokens.sublist(i, end).join(' '));
        i = end;
      }
      final inner = [
        for (int j = 0; j < lines.length; j++)
          '<tspan x="$x" dy="${j == 0 ? '0' : '1.05em'}">${lines[j]}</tspan>'
      ].join();

      return '<text x="$x" y="$y" text-anchor="middle" style="white-space:pre-line">$inner</text>';
    });
  }

  String _beautifySvg(String svg) =>
      _stackHouseLabels(
        _localizeSvgCellTokens(
          _localizeSvgTitles(
            _stripOuterPlanetsFromSvg(svg),
          ),
        ),
      );

  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bd = ref.watch(birthDataProvider);
    if (bd == null) {
      return Center(child: Text(context.l10n.t('form.fillFirst')));
    }

    final repo = ref.read(horoscopeRepositoryProvider);

    return FutureBuilder<Map<String, dynamic>>(
      future: repo.getCharts(bd),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${context.l10n.t('chart.error')}: ${snap.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        final data = snap.data ?? const {};
        final raasiSvg = _beautifySvg((data['raasiSvg'] ?? '').toString());
        final navSvg = _beautifySvg((data['navamsaSvg'] ?? '').toString());

        // IMPORTANT: filter OUTER planets BEFORE translating -> hides in TA too
        final rawPlanets =
            (data['planets'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
        final filtered = rawPlanets.where((r) {
          final n = (r['name'] ?? '').toString().toLowerCase();
          return !(n.contains('uranus') || n.contains('neptune') || n.contains('pluto'));
        }).toList();

        return Scrollbar(
          controller: _vCtrl,
          thumbVisibility: true,
          child: ListView(
            controller: _vCtrl,
            padding: const EdgeInsets.all(12),
            children: [
              _CardSection(
                title: context.l10n.t('chart.raasi.title'),
                child: _SvgPanel(svgText: raasiSvg),
              ),
              const SizedBox(height: 12),
              _CardSection(
                title: context.l10n.t('chart.navamsa.title'),
                child: _SvgPanel(svgText: navSvg),
              ),
              const SizedBox(height: 12),
              _CardSection(
                title: context.l10n.t('chart.planets.extended'),
                child: _PlanetsTable(
                  rows: filtered
                      .map((r) => {
                    ...r,
                    'name': _ta(_taPlanets, (r['name'] ?? '').toString()),
                    'sign': _ta(_taZodiac, (r['sign'] ?? '').toString()),
                    'lord': _ta(_taPlanets, (r['lord'] ?? '').toString()),
                    'nakshatra':
                    _ta(_taNak, (r['nakshatra'] ?? '').toString()),
                  })
                      .toList(),
                  hCtrl: _planetsHCtrl,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.35),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child:
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}

class _SvgPanel extends StatelessWidget {
  const _SvgPanel({required this.svgText});
  final String svgText;

  @override
  Widget build(BuildContext context) {
    if (svgText.trim().isEmpty) {
      return SizedBox(
        height: 280,
        child: Center(child: Text(context.l10n.t('api.noSvg'))),
      );
    }
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        child: ClipRect(
          child: SvgPicture.string(
            svgText,
            fit: BoxFit.contain,
            allowDrawingOutsideViewBox: true,
            key: ValueKey(svgText.hashCode),
          ),
        ),
      ),
    );
  }
}

class _PlanetsTable extends StatelessWidget {
  const _PlanetsTable({required this.rows, required this.hCtrl});
  final List<Map<String, dynamic>> rows;
  final ScrollController hCtrl;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return Text(context.l10n.t('data.noPlanetRows'));

    final view = rows.map((r) {
      final deg = (r['deg'] ?? '').toString();
      final min = (r['min'] ?? '').toString();
      final sec = (r['sec'] ?? '').toString();
      return _RowView(
        body: (r['name'] ?? '').toString(),
        house: (r['house'] ?? '').toString(),
        nakshatra: (r['nakshatra'] ?? '').toString(),
        pada: (r['pada'] ?? '').toString(),
        degree: _composeDegree(deg, min, sec),
        rasi: (r['sign'] ?? '').toString(),
        lord: (r['lord'] ?? '').toString(),
      );
    }).toList();

    const bodyW = 120.0; // << narrower
    const colW = <double>[80, 140, 60, 120, 120, 120];

    // left (frozen) column – header also constrained so width sticks
    final leftTable = DataTable(
      columnSpacing: 8,
      horizontalMargin: 8,
      columns: [
        DataColumn(
          label: SizedBox(
            width: bodyW,
            child: Text(context.l10n.t('planets.col.body')),
          ),
        ),
      ],
      rows: [
        for (final r in view)
          DataRow(
            cells: [
              DataCell(
                SizedBox(
                  width: bodyW,
                  child: Text(
                    r.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
      ],
    );

    // right (scrollable) columns – NO scrollbar widget
    final rightTable = DataTable(
      columnSpacing: 8,
      horizontalMargin: 8,
      columns: [
        DataColumn(label: Text(context.l10n.t('planets.col.house'))),
        DataColumn(label: Text(context.l10n.t('planets.col.nakshatra'))),
        DataColumn(label: Text(context.l10n.t('planets.col.pada'))),
        DataColumn(label: Text(context.l10n.t('planets.col.deg'))),
        DataColumn(label: Text(context.l10n.t('planets.col.sign'))),
        DataColumn(label: Text(context.l10n.t('planets.col.lord'))),
        // kept for future:
        // DataColumn(label: Text(context.l10n.t('planets.col.min'))),
        // DataColumn(label: Text(context.l10n.t('planets.col.sec'))),
      ],
      rows: [
        for (final r in view)
          DataRow(
            cells: [
              _cell(colW[0], r.house),
              _cell(colW[1], r.nakshatra),
              _cell(colW[2], r.pada),
              _cell(colW[3], r.degree),
              _cell(colW[4], r.rasi),
              _cell(colW[5], r.lord),
            ],
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leftTable,
          Expanded(
            child: SingleChildScrollView(
              controller: hCtrl,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 4),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth:
                  colW.reduce((a, b) => a + b) + (8 * (colW.length - 1)) + 24,
                ),
                child: rightTable,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static DataCell _cell(double w, String text) => DataCell(
    SizedBox(
      width: w,
      child:
      Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
    ),
  );

  static String _composeDegree(String deg, String min, String sec) {
    String d = deg.trim().replaceAll(RegExp(r'[^0-9.\-]'), '');
    String m = min.trim().replaceAll(RegExp(r'[^0-9.\-]'), '');
    String s = sec.trim().replaceAll(RegExp(r'[^0-9.\-]'), '');
    final parts = <String>[];
    if (d.isNotEmpty) parts.add('$d°');
    if (m.isNotEmpty) parts.add("${m}'");
    if (s.isNotEmpty) parts.add('$s"');
    return parts.isEmpty ? '—' : parts.join(' ');
  }
}

class _RowView {
  final String body;
  final String house;
  final String nakshatra;
  final String pada;
  final String degree;
  final String rasi;
  final String lord;
  _RowView({
    required this.body,
    required this.house,
    required this.nakshatra,
    required this.pada,
    required this.degree,
    required this.rasi,
    required this.lord,
  });
}
