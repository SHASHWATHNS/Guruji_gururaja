// lib/features/matchmaking/presentation/screens/match_making_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/i18n/app_localizations.dart';

class MatchMakingScreen extends ConsumerStatefulWidget {
  const MatchMakingScreen({super.key});

  @override
  ConsumerState<MatchMakingScreen> createState() => _MatchingStarScreenState();
}

class _MatchingStarScreenState extends ConsumerState<MatchMakingScreen> {
  // ===== form state =====
  final _bName = TextEditingController();
  _Option? _bStar;
  _Option? _bRasi;
  _BirthDetails? _bBirth;

  final _gName = TextEditingController();
  _Option? _gStar;
  _Option? _gRasi;
  _BirthDetails? _gBirth;

  bool _calculating = false;
  _MatchResult? _result;

  // >>>>>>> IMPORTANT: put your API key here <<<<<<<
  static const String _apiKey = 'Gn8Fe7i5YiOy87nmWxU19aycrUNs3Ug42u1dVC8f';
  static const String _endpoint =
      'https://json.freeastrologyapi.com/match-making/ashtakoot-score';

  @override
  void dispose() {
    _bName.dispose();
    _gName.dispose();
    super.dispose();
  }

  List<_Option> get _stars => _localeIsTa ? _Data.nakshatraTa : _Data.nakshatraEn;
  List<_Option> get _rasi => _localeIsTa ? _Data.rasiTa : _Data.rasiEn;

  bool get _localeIsTa =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ta';

  Future<void> _onCalculate() async {
    final t = context.l10n.t;
    FocusScope.of(context).unfocus();

    // basic validation
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
    // Birth details needed by API
    if (_bBirth == null || _gBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('match.error.birthRequired'))),
      );
      return;
    }

    setState(() {
      _calculating = true;
      _result = null;
    });

    try {
      final lang = _localeIsTa ? 'en' : // API supports en/hi/te only
      (Localizations.localeOf(context).languageCode.toLowerCase());
      final safeLang = (lang == 'hi' || lang == 'te') ? lang : 'en';

      final body = jsonEncode({
        "female": _gBirth!.toApiJson(), // treating Girl as "female"
        "male": _bBirth!.toApiJson(),   // and Boy as "male"
        "config": {
          "observation_point": "topocentric",
          "language": safeLang,
          "ayanamsha": "lahiri",
        }
      });

      final res = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
        },
        body: body,
      );

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      if (map['statusCode'] != 200 || map['output'] == null) {
        throw Exception('Bad response: ${res.body}');
      }

      final out = map['output'] as Map<String, dynamic>;
      final total = (out['total_score'] as num?)?.toDouble() ?? 0.0;
      final outOf = (out['out_of'] as num?)?.toDouble() ?? 36.0;

      // Collect kootam scores safely
      List<_PoruthamScore> items = [];
      void addK(String apiKey, String uiName, num defaultOutOf) {
        final k = (out[apiKey] as Map?)?.cast<String, dynamic>();
        final sc = (k?['score'] as num?)?.toDouble() ?? 0.0;
        final of = (k?['out_of'] as num?)?.toDouble() ?? defaultOutOf.toDouble();
        items.add(_PoruthamScore(uiName, sc, of));
      }

      addK('varna_kootam', _localeIsTa ? 'வர்ண' : 'Varna', 1);
      addK('vasya_kootam', _localeIsTa ? 'வசிய' : 'Vashya', 2);
      addK('tara_kootam', _localeIsTa ? 'தாரா' : 'Tara', 3);
      addK('yoni_kootam', _localeIsTa ? 'யோனி' : 'Yoni', 4);
      addK('graha_maitri_kootam', _localeIsTa ? 'கிரக மைத்\u200cரீ' : 'Graha Maitri', 5);
      addK('gana_kootam', _localeIsTa ? 'கணம்' : 'Gana', 6);
      addK('rasi_kootam', _localeIsTa ? 'ராசி' : 'Rasi (Bhakut)', 7);
      addK('nadi_kootam', _localeIsTa ? 'நாடி' : 'Nadi', 8);

      setState(() {
        _result = _MatchResult(items, total: total, max: outOf);
        _calculating = false;
      });
    } catch (e) {
      setState(() => _calculating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t('common.error')}: $e')),
      );
    }
  }

  Future<void> _pickBirthDetails({
    required bool forBride,
  }) async {
    final res = await showModalBottomSheet<_BirthDetails>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _BirthFormSheet(initial: forBride ? _bBirth : _gBirth),
    );
    if (res != null) {
      setState(() {
        if (forBride) {
          _bBirth = res;
        } else {
          _gBirth = res;
        }
      });
    }
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
              t('Guruji Gururaja'),
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
            extra: _BirthInline(
              details: _bBirth,
              onTap: () => _pickBirthDetails(forBride: true),
              title: t('Birth Details'),
            ),
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
            extra: _BirthInline(
              details: _gBirth,
              onTap: () => _pickBirthDetails(forBride: false),
              title: t('Birth Details'),
            ),
          ),
          const SizedBox(height: 16),

          // Calculate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: _calculating
                  ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
  final Widget? extra;

  const _PersonCard({
    required this.nameController,
    required this.nameLabel,
    required this.starLabel,
    required this.rasiLabel,
    required this.starItems,
    required this.rasiItems,
    required this.onStarChanged,
    required this.onRasiChanged,
    this.extra,
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
            if (extra != null) ...[
              const SizedBox(height: 10),
              extra!,
            ],
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
    final pct = (result.total / result.max).clamp(0.0, 1.0);
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
            const SizedBox(height: 10),
            // Breakdown grid
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: result.items
                  .map((s) => Chip(
                label: Text('${s.name}: ${_fmt(s.points)} / ${_fmt(s.outOf)}'),
                backgroundColor: Colors.pink.shade50,
              ))
                  .toList(),
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 8),
            Text(
              '${t('match.result.total')}: ${_fmt(result.total)} / ${_fmt(result.max)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              pct >= 0.66
                  ? (t('Match Result Good')) // high-level verdict via i18n key
                  : pct >= 0.44
                  ? (t('Match Result Ok'))
                  : (t('Match Result Poor')),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(num n) => (n % 1 == 0) ? n.toStringAsFixed(0) : n.toStringAsFixed(1);
}

class _Option {
  final String label;
  const _Option(this.label);
}

/// ===== Static data for EN / TA =====
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
  final double points;
  final double outOf;
  _PoruthamScore(this.name, num points, num outOf)
      : points = points.toDouble(),
        outOf = outOf.toDouble();
}

class _MatchResult {
  final List<_PoruthamScore> items;
  final double total;
  final double max;
  _MatchResult(this.items, {required num total, required num max})
      : total = total.toDouble(),
        max = max.toDouble();
}

/// ===== Birth details (for API) =====
class _BirthDetails {
  final DateTime date; // local date
  final TimeOfDay time; // local time
  final double latitude;
  final double longitude;
  final double timezone; // e.g., 5.5

  const _BirthDetails({
    required this.date,
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  Map<String, dynamic> toApiJson() => {
    "year": date.year,
    "month": date.month,
    "date": date.day,
    "hours": time.hour,
    "minutes": time.minute,
    "seconds": 0,
    "latitude": latitude,
    "longitude": longitude,
    "timezone": timezone,
  };
}

/// ===== Inline “Birth details” chip + summary =====
class _BirthInline extends StatelessWidget {
  final _BirthDetails? details;
  final VoidCallback onTap;
  final String title;
  const _BirthInline({required this.details, required this.onTap, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.cake_outlined),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(details == null
          ? '—'
          : '${_two(details!.date.day)}/${_two(details!.date.month)}/${details!.date.year} '
          '${_two(details!.time.hour)}:${_two(details!.time.minute)}  '
          '(${details!.latitude.toStringAsFixed(4)}, ${details!.longitude.toStringAsFixed(4)} | GMT${details!.timezone >= 0 ? '+' : ''}${details!.timezone})'),
      trailing: TextButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.edit_outlined),
        label: Text(details == null ? 'Add' : 'Edit'),
      ),
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}

/// ===== Bottom sheet to enter birth details =====
class _BirthFormSheet extends StatefulWidget {
  final _BirthDetails? initial;
  const _BirthFormSheet({this.initial});

  @override
  State<_BirthFormSheet> createState() => _BirthFormSheetState();
}

class _BirthFormSheetState extends State<_BirthFormSheet> {
  late DateTime _date;
  late TimeOfDay _time;
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  final _tz = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = widget.initial?.date ?? DateTime(now.year - 25, 1, 1);
    _time = widget.initial?.time ?? const TimeOfDay(hour: 6, minute: 0);
    _lat.text = (widget.initial?.latitude ?? 11.0168).toString();   // default: Coimbatore
    _lng.text = (widget.initial?.longitude ?? 76.9558).toString();
    _tz.text = (widget.initial?.timezone ?? 5.5).toString();
  }

  @override
  void dispose() {
    _lat.dispose();
    _lng.dispose();
    _tz.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final br = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    return Padding(
      padding: EdgeInsets.only(
          left: 16, right: 16, bottom: 16 + MediaQuery.of(context).viewInsets.bottom, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 4, width: 48, decoration: BoxDecoration(
              color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 12),
          Text('Birth details', style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _DenseTileButton(
                  icon: Icons.event_outlined,
                  label: '${_two(_date.day)}/${_two(_date.month)}/${_date.year}',
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DenseTileButton(
                  icon: Icons.schedule_outlined,
                  label: '${_two(_time.hour)}:${_two(_time.minute)}',
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: _time);
                    if (picked != null) setState(() => _time = picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _lat,
                  keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(labelText: 'Latitude', border: br, enabledBorder: br, focusedBorder: br),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _lng,
                  keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(labelText: 'Longitude', border: br, enabledBorder: br, focusedBorder: br),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _tz,
            keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: InputDecoration(labelText: 'Timezone (e.g., 5.5)', border: br, enabledBorder: br, focusedBorder: br),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Save'),
              onPressed: () {
                final lat = double.tryParse(_lat.text.trim());
                final lng = double.tryParse(_lng.text.trim());
                final tz = double.tryParse(_tz.text.trim());
                if (lat == null || lng == null || tz == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter valid lat/lng/timezone')),
                  );
                  return;
                }
                Navigator.of(context).pop(_BirthDetails(
                  date: _date,
                  time: _time,
                  latitude: lat,
                  longitude: lng,
                  timezone: tz,
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}

class _DenseTileButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DenseTileButton({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
