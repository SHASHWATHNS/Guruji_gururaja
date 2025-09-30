// lib/features/horoscope/tabs/chart/chart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../form/horoscope_form_screen.dart' show birthDataProvider;
import '../../data/repository.dart' show horoscopeRepositoryProvider;
// l10n
import '../../../../core/i18n/app_localizations.dart';

class ChartScreen extends ConsumerStatefulWidget {
  const ChartScreen({super.key});
  @override
  ConsumerState<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen> {
  final _vCtrl = ScrollController();        // vertical
  final _planetsHCtrl = ScrollController(); // horizontal for planets table

  @override
  void dispose() {
    _vCtrl.dispose();
    _planetsHCtrl.dispose();
    super.dispose();
  }

  // ---------- tiny value-localization helpers (Chart tab only) ----------
  String _norm(String v) =>
      v.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_').replaceAll('-', '_');

  // 12 Rāśi
  static const _taZodiac = {
    'aries':'மேஷம்','taurus':'ரிஷபம்','gemini':'மிதுனம்','cancer':'கடகம்',
    'leo':'சிம்மம்','virgo':'கன்னி','libra':'துலாம்','scorpio':'விருச்சிகம்',
    'sagittarius':'தனுசு','capricorn':'மகரம்','aquarius':'கும்பம்','pisces':'மீனம்'
  };

  // Planets
  static const _taPlanets = {
    'ascendant':'லக்னம்',
    'sun':'சூரியன்','moon':'சந்திரன்','mars':'செவ்வாய்','mercury':'புதன்','jupiter':'குரு',
    'venus':'சுக்கிரன்','saturn':'சனி',
    'rahu':'ராகு','ketu':'கேது',
    'uranus':'உரேனஸ்','neptune':'நெப்ட்யூன்','pluto':'ப்ளூட்டோ'
  };

  // Nakshatra (variants). Do NOT modify your “Uttara Phalguni(Uttara)” server form.
  static const _taNak = {
    'aswini': 'அசுவினி (கேது)',   'ashwini': 'அசுவினி (கேது)',
    'bharani': 'பரணி (சுக்கிரன்)',
    'krittika': 'கார்த்திகை (சூரியன்)',
    'rohini': 'ரோகிணி (சந்திரன்)',
    'mrigasira': 'மிருகசீரிஷம் (செவ்வாய்)', 'mrigashira': 'மிருகசீரிஷம் (செவ்வாய்)',
    'aardra': 'திருவாதிரை (ராகு)', 'ardra': 'திருவாதிரை (ராகு)',
    'punarvasu': 'புனர்பூசம் (குரு)',
    'pushya': 'பூசம் (சனி)', 'pushyami': 'பூசம் (சனி)',
    'aaslesha': 'ஆயில்யம் (புதன்)', 'ashlesha': 'ஆயில்யம் (புதன்)',
    'makha': 'மகம் (கேது)', 'magha': 'மகம் (கேது)',
    'poorva_phalguni(pubba)': 'பூரம் (சுக்கிரன்)', 'purva_phalguni': 'பூரம் (சுக்கிரன்)',
    'uttara_phalguni(uttara)': 'உத்திரம் (சூரியன்)', 'uttara_phalguni': 'உத்திரம் (சூரியன்)',
    'hasta': 'ஹஸ்தம் (சந்திரன்)',
    'chitta': 'சித்திரை (செவ்வாய்)', 'chitra': 'சித்திரை (செவ்வாய்)',
    'swati': 'சுவாதி (ராகு)',
    'visakha': 'விசாகம் (குரு)', 'vishakha': 'விசாகம் (குரு)',
    'anuradha': 'அனுஷம் (சனி)',
    'jyeshta': 'கேட்டை (புதன்)', 'jyeshtha': 'கேட்டை (புதன்)',
    'moola': 'மூலம் (கேது)', 'mula': 'மூலம் (கேது)',
    'poorvaashaada': 'பூராடம் (சுக்கிரன்)', 'purva_ashadha': 'பூராடம் (சுக்கிரன்)',
    'uttaraashaada': 'உத்திராடம் (சூரியன்)', 'uttara_ashadha': 'உத்திராடம் (சூரியன்)',
    'sravanam': 'திருவோணம் (சந்திரன்)', 'shravana': 'திருவோணம் (சந்திரன்)',
    'dhanishta': 'அவிட்டம் (செவ்வாய்)',
    'satabisha': 'சதயம் (ராகு)', 'shatabhisha': 'சதயம் (ராகு)',
    'poorvaabhadra': 'பூரட்டாதி (குரு)', 'purva_bhadrapada': 'பூரட்டாதி (குரு)',
    'uttaraabhadra': 'உத்திரட்டாதி (சனி)', 'uttara_bhadrapada': 'உத்திரட்டாதி (சனி)',
    'revati': 'ரேவதி (புதன்)',
  };

  String _ta(Map<String, String> dict, String v) {
    if (Localizations.localeOf(context).languageCode != 'ta') return v;
    final raw = v.trim();
    if (raw.isEmpty || raw == '—') return v;

    // Keep retrograde marker (va)
    final hasVa = RegExp(r'\(va\)', caseSensitive: false).hasMatch(raw);
    final withoutVa = raw.replaceAll(RegExp(r'\s*\(va\)\s*', caseSensitive: false), '').trim();

    // Many APIs send trailing parenthetical clarifications e.g. "Uttara Phalguni(Uttara)"
    final noParenTrail = withoutVa.replaceAll(RegExp(r'\s*\([^)]*\)\s*$'), '').trim();

    String? pick(Map<String, String> m, String s) => m[_norm(s)] ?? m[s.toLowerCase()] ?? m[s];
    final translated = pick(dict, withoutVa) ?? pick(dict, noParenTrail) ?? v;
    return hasVa ? '$translated (va)' : translated;
  }

  // ---- SVG label tweaks ----

  // Localize center titles only (Rāśi / Navāṁśa)
  String _localizeSvgTitles(String svg) {
    if (Localizations.localeOf(context).languageCode != 'ta') return svg;
    return svg.replaceAll('Rāśi', 'ராசி').replaceAll('Navāṁśa', 'நவாம்சம்');
  }

  // Localize short planet tokens inside houses (Asc, Su, Mo, …)
  String _localizeSvgCellTokens(String svg) {
    if (Localizations.localeOf(context).languageCode != 'ta') return svg;

    const tok = <String, String>{
      'Asc':'லக்னம்',
      'Su':'சூ', // Sun
      'Mo':'ச',  // Moon
      'Ma':'செ', // Mars
      'Me':'பு', // Mercury
      'Ju':'கு', // Jupiter
      'Ve':'சு', // Venus
      'Sa':'ச',  // Saturn
      'Ra':'ரா', // Rahu
      'Ke':'கே', // Ketu
      'Ur':'யு', // Uranus
      'Ne':'நெ', // Neptune
      'Pl':'ப்ளூ',// Pluto
    };

    var out = svg;
    // Replace only when the token is a separate “word” (start/space/paren … end/space/paren).
    tok.forEach((k, v) {
      final re = RegExp(r'(?:(?<=^)|(?<=[\s(>]))' + k + r'(?=(?:$)|[\s)<])');
      out = out.replaceAllMapped(re, (_) => v);
    });
    return out;
  }

  // Stack space-separated planet labels inside each house so they fit nicely
  String _stackHouseLabels(String svg) {
    final re = RegExp(r'<text[^>]*\bx="([\d.]+)"[^>]*\by="([\d.]+)"[^>]*>([^<]+)</text>');
    final isTa = Localizations.localeOf(context).languageCode == 'ta';
    final perLine = isTa ? 3 : 2;

    bool _skip(String s) {
      final t = s.trim();
      if (t.isEmpty) return true;
      if (t.contains('Rāśi') || t.contains('Navāṁśa') || t.contains('ராசி') || t.contains('நவாம்சம்')) {
        return true; // center titles
      }
      if (!t.contains(' ')) return true; // single token fits
      if (RegExp(r'^\(?[A-Za-z]{1,4}\)?$').hasMatch(t)) return true; // lone short token like "(Ur)"
      return false;
    }

    return svg.replaceAllMapped(re, (m) {
      final x = m.group(1)!;
      final y = m.group(2)!;
      final content = m.group(3)!.trim();
      if (_skip(content)) return m[0]!;

      final tokens = content.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
      final lines = <String>[];
      int i = 0;

      // Keep 'Asc' alone on first line (looks better)
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

  // Full beautifier: titles -> cell tokens -> stacking
  String _beautifySvg(String svg) =>
      _stackHouseLabels(_localizeSvgCellTokens(_localizeSvgTitles(svg)));
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
        final navSvg   = _beautifySvg((data['navamsaSvg'] ?? '').toString());
        final planets  = (data['planets'] as List?)?.cast<Map<String, dynamic>>() ?? const <Map<String, dynamic>>[];

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
                  rows: planets.map((r) {
                    // value-level localization for Tamil (table)
                    return {
                      ...r,
                      'name'     : _ta(_taPlanets, (r['name'] ?? '').toString()),
                      'sign'     : _ta(_taZodiac, (r['sign'] ?? '').toString()),
                      'lord'     : _ta(_taPlanets, (r['lord'] ?? '').toString()),
                      'nakshatra': _ta(_taNak, (r['nakshatra'] ?? '').toString()),
                    };
                  }).toList(),
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
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
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

    final headers = [
      context.l10n.t('planets.col.body'),
      context.l10n.t('planets.col.sign'),
      context.l10n.t('planets.col.lord'),
      context.l10n.t('planets.col.house'),
      context.l10n.t('planets.col.deg'),
      context.l10n.t('planets.col.min'),
      context.l10n.t('planets.col.sec'),
      context.l10n.t('planets.col.nakshatra'),
      context.l10n.t('planets.col.pada'),
    ];
    const widths  = <double>[140.0,80.0,90.0,40.0,40.0,40.0,58.0,120.0,48.0];

    return Scrollbar(
      controller: hCtrl,
      thumbVisibility: true,
      notificationPredicate: (_) => true,
      child: SingleChildScrollView(
        controller: hCtrl,
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 8,
          horizontalMargin: 8,
          columns: [for (final h in headers) DataColumn(label: Text(h))],
          rows: rows.map((r) {
            final cells = [
              (r['name'] ?? '').toString(),
              (r['sign'] ?? '').toString(),
              (r['lord'] ?? '').toString(),
              (r['house'] ?? '').toString(),
              (r['deg'] ?? '').toString(),
              (r['min'] ?? '').toString(),
              (r['sec'] ?? '').toString(),
              (r['nakshatra'] ?? '').toString(),
              (r['pada'] ?? '').toString(),
            ];
            return DataRow(
              cells: [
                for (int i = 0; i < cells.length; i++)
                  DataCell(SizedBox(
                    width: widths[i],
                    child: Text(cells[i], maxLines: 1, overflow: TextOverflow.ellipsis),
                  )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
