import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';

class MatchMakingScreen extends ConsumerStatefulWidget {
  const MatchMakingScreen({super.key});

  @override
  ConsumerState<MatchMakingScreen> createState() => _MatchingStarScreenState();
}

class _MatchingStarScreenState extends ConsumerState<MatchMakingScreen> {
  // form state
  final _bName = TextEditingController();
  _Option? _bStar;
  _Option? _bRasi;

  final _gName = TextEditingController();
  _Option? _gStar;
  _Option? _gRasi;

  bool _calculating = false;
  _MatchResult? _result;

  @override
  void dispose() {
    _bName.dispose();
    _gName.dispose();
    super.dispose();
  }

  List<_Option> get _stars => _localeIsTa
      ? _Data.nakshatraTa
      : _Data.nakshatraEn;

  List<_Option> get _rasi => _localeIsTa
      ? _Data.rasiTa
      : _Data.rasiEn;

  bool get _localeIsTa =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ta';

  Future<void> _onCalculate() async {
    final t = context.l10n.t;
    FocusScope.of(context).unfocus();

    if (_bName.text.trim().isEmpty ||
        _gName.text.trim().isEmpty ||
        _bStar == null ||
        _bRasi == null ||
        _gStar == null ||
        _gRasi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('match.error.requiredAll'))),
      );
      return;
    }

    setState(() {
      _calculating = true;
      _result = null;
    });

    // TODO: plug your real Porutham logic here
    await Future.delayed(const Duration(milliseconds: 700));

    // mock 10 porutham scores
    final items = <_PoruthamScore>[
      _PoruthamScore(_localeIsTa ? 'தின' : 'Dina', 8),
      _PoruthamScore(_localeIsTa ? 'கணம்' : 'Gana', 7),
      _PoruthamScore(_localeIsTa ? 'மகேந்திர' : 'Mahendra', 9),
      _PoruthamScore(_localeIsTa ? 'ஸ்திரீ தீர்க' : 'Stree Deergha', 8),
      _PoruthamScore(_localeIsTa ? 'யோனி' : 'Yoni', 6),
      _PoruthamScore(_localeIsTa ? 'ராசி' : 'Rasi', 7),
      _PoruthamScore(_localeIsTa ? 'ராச்யாதிபதி' : 'Rasyadhipati', 9),
      _PoruthamScore(_localeIsTa ? 'வசிய' : 'Vasya', 6),
      _PoruthamScore(_localeIsTa ? 'ரஜ்ஜு' : 'Rajju', 8),
      _PoruthamScore(_localeIsTa ? 'வேத' : 'Vedha', 7),
    ];
    final total = items.fold<int>(0, (a, b) => a + b.points);

    setState(() {
      _result = _MatchResult(items, total: total, max: 100);
      _calculating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n.t;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.headerBar,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t('app.title'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                t('match.chip'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _SectionTitle(text: t('match.section.bride')),
          _PersonCard(
            nameController: _bName,
            nameLabel: t('match.name'),
            starLabel: t('match.nakshatra'),
            rasiLabel: t('match.rasi'),
            starItems: _stars,
            rasiItems: _rasi,
            onStarChanged: (v) => setState(() => _bStar = v),
            onRasiChanged: (v) => setState(() => _bRasi = v),
          ),
          const SizedBox(height: 12),
          _SectionTitle(text: t('match.section.groom')),
          _PersonCard(
            nameController: _gName,
            nameLabel: t('match.name'),
            starLabel: t('match.nakshatra'),
            rasiLabel: t('match.rasi'),
            starItems: _stars,
            rasiItems: _rasi,
            onStarChanged: (v) => setState(() => _gStar = v),
            onRasiChanged: (v) => setState(() => _gRasi = v),
          ),
          const SizedBox(height: 16),

          // Calculate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: _calculating
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.favorite),
              label: Text(t('match.calculate')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: _calculating ? null : _onCalculate,
            ),
          ),

          const SizedBox(height: 16),

          if (_result != null) _ResultCard(result: _result!, t: t),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final TextEditingController nameController;
  final String nameLabel;
  final String starLabel;
  final String rasiLabel;
  final List<_Option> starItems;
  final List<_Option> rasiItems;
  final ValueChanged<_Option?> onStarChanged;
  final ValueChanged<_Option?> onRasiChanged;

  const _PersonCard({
    required this.nameController,
    required this.nameLabel,
    required this.starLabel,
    required this.rasiLabel,
    required this.starItems,
    required this.rasiItems,
    required this.onStarChanged,
    required this.onRasiChanged,
  });

  @override
  Widget build(BuildContext context) {
    final br = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: nameLabel,
                border: br, enabledBorder: br, focusedBorder: br,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            _DropdownField(
              label: starLabel,
              items: starItems,
              onChanged: onStarChanged,
            ),
            const SizedBox(height: 10),
            _DropdownField(
              label: rasiLabel,
              items: rasiItems,
              onChanged: onRasiChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatefulWidget {
  final String label;
  final List<_Option> items;
  final ValueChanged<_Option?> onChanged;
  const _DropdownField({required this.label, required this.items, required this.onChanged});

  @override
  State<_DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<_DropdownField> {
  _Option? _value;

  @override
  Widget build(BuildContext context) {
    final br = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.label,
        border: br, enabledBorder: br, focusedBorder: br,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_Option>(
          isExpanded: true,
          value: _value,
          hint: Text(widget.label),
          items: widget.items
              .map((o) => DropdownMenuItem<_Option>(
            value: o,
            child: Text(o.label),
          ))
              .toList(),
          onChanged: (v) {
            setState(() => _value = v);
            widget.onChanged(v);
          },
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final _MatchResult result;
  final String Function(String) t;
  const _ResultCard({required this.result, required this.t});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('match.result.title'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.items
                  .map((s) => Chip(
                label: Text('${s.name}: ${s.points}'),
                backgroundColor: Colors.pink.shade50,
              ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: result.total / result.max,
              minHeight: 10,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 8),
            Text(
              '${t('match.result.total')}: ${result.total}/${result.max}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _Option {
  final String label;
  const _Option(this.label);
}

/// Static data for EN / TA
class _Data {
  // 27 stars
  static const nakshatraEn = [
    _Option('Ashwini'), _Option('Bharani'), _Option('Krittika'), _Option('Rohini'),
    _Option('Mrigashira'), _Option('Ardra'), _Option('Punarvasu'), _Option('Pushya'),
    _Option('Ashlesha'), _Option('Magha'), _Option('Purva Phalguni'), _Option('Uttara Phalguni'),
    _Option('Hasta'), _Option('Chitra'), _Option('Swati'), _Option('Vishakha'),
    _Option('Anuradha'), _Option('Jyeshtha'), _Option('Mula'), _Option('Purva Ashadha'),
    _Option('Uttara Ashadha'), _Option('Shravana'), _Option('Dhanishta'), _Option('Shatabhisha'),
    _Option('Purva Bhadrapada'), _Option('Uttara Bhadrapada'), _Option('Revati'),
  ];
  static const nakshatraTa = [
    _Option('அஸ்வினி'), _Option('பரணி'), _Option('கார்த்திகை'), _Option('ரோகிணி'),
    _Option('மிருகசீரிடம்'), _Option('திருவாதிரை'), _Option('புனர்பூசம்'), _Option('பூசம்'),
    _Option('ஆயில்யம்'), _Option('மகம்'), _Option('பூரம்'), _Option('உத்திரம்'),
    _Option('ஹஸ்தம்'), _Option('சித்திரை'), _Option('சுவாதி'), _Option('விசாகம்'),
    _Option('அனுஷம்'), _Option('கேட்டை'), _Option('மூலம்'), _Option('பூராடம்'),
    _Option('உத்திராடம்'), _Option('திருவோணம்'), _Option('அவிட்டம்'), _Option('சதயம்'),
    _Option('பூரட்டாதி'), _Option('உத்திரட்டாதி'), _Option('ரேவதி'),
  ];

  // 12 rasi
  static const rasiEn = [
    _Option('Aries'), _Option('Taurus'), _Option('Gemini'), _Option('Cancer'),
    _Option('Leo'), _Option('Virgo'), _Option('Libra'), _Option('Scorpio'),
    _Option('Sagittarius'), _Option('Capricorn'), _Option('Aquarius'), _Option('Pisces'),
  ];
  static const rasiTa = [
    _Option('மேஷம்'), _Option('ரிஷபம்'), _Option('மிதுனம்'), _Option('கடகம்'),
    _Option('சிம்மம்'), _Option('கன்னி'), _Option('துலாம்'), _Option('விருச்சிகம்'),
    _Option('தனுசு'), _Option('மகரம்'), _Option('கும்பம்'), _Option('மீனம்'),
  ];
}

class _PoruthamScore {
  final String name;
  final int points;
  _PoruthamScore(this.name, this.points);
}

class _MatchResult {
  final List<_PoruthamScore> items;
  final int total;
  final int max;
  _MatchResult(this.items, {required this.total, required this.max});
}
