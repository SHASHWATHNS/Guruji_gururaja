import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JamakkolHome extends StatefulWidget {
  const JamakkolHome({super.key});
  @override
  State<JamakkolHome> createState() => _JamakkolHomeState();
}

class _JamakkolHomeState extends State<JamakkolHome> {
  final _apiKeyCtrl = TextEditingController();

  // Defaults from your sample request
  int year = 2025, month = 4, day = 22, hour = 6, minute = 30, second = 0;
  double timeOffset = 5.5, lat = 12.9716, lon = 77.5946;
  int ayanamsha = 1, maandiMethod = 1;

  bool _busy = false;
  bool useJamakkolLayout = true;
  Map<String, dynamic>? _data;

  void _applyNow({bool andRender = false}) async {
    final now = DateTime.now();
    setState(() {
      year = now.year;
      month = now.month;
      day = now.day;
      hour = now.hour;
      minute = now.minute;
      second = now.second;
      timeOffset = now.timeZoneOffset.inMinutes / 60.0;
    });
    if (andRender) await _fetchAndRender();
  }

  Future<void> _fetchAndRender() async {
    setState(() => _busy = true);
    try {
      final uri = Uri.parse(
        'https://api.vedicastrochart.com/v1/public/astro/horary/jamakkol',
      ).replace(queryParameters: {
        'year': '$year',
        'month': '$month',
        'day': '$day',
        'hour': '$hour',
        'minute': '$minute',
        'second': '$second',
        'timeOffset': '$timeOffset',
        'latitude': '$lat',
        'longitude': '$lon',
        'ayanamsha': '$ayanamsha',
        'maandiCalculationMethod': '$maandiMethod',
      });

      final res = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'x-api-key': _apiKeyCtrl.text.trim(),
        },
      );
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
      final body = json.decode(res.body) as Map<String, dynamic>;
      setState(() => _data = (body['data'] as Map<String, dynamic>));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Request failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // chart target width (big but padded):  min( deviceWidth - 32, 720 )
    final chartW = (w - 32).clamp(320.0, 720.0);
    final chartH = chartW * (8 / 11); // same aspect ratio as painters

    return Scaffold(
      appBar: AppBar(title: const Text('Jamakkol Chart')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API key + layout + fetch
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _apiKeyCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'x-api-key',
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _busy ? null : _fetchAndRender,
                icon: _busy
                    ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                label: const Text('Fetch & Render'),
              ),
            ]),
            const SizedBox(height: 8),
            DropdownButtonFormField<bool>(
              value: useJamakkolLayout,
              decoration: const InputDecoration(labelText: 'Layout'),
              onChanged: (v) => setState(() => useJamakkolLayout = v ?? true),
              items: const [
                DropdownMenuItem(
                  value: true,
                  child: Text('Jamakkol layout (Pis top-left)'),
                ),
                DropdownMenuItem(
                  value: false,
                  child: Text('Standard layout (Ari top-left)'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Inputs
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _numField('Year', year, (v) => setState(() => year = v)),
                _numField('Month', month, (v) => setState(() => month = v)),
                _numField('Day', day, (v) => setState(() => day = v)),
                _numField('Hour', hour, (v) => setState(() => hour = v)),
                _numField('Min', minute, (v) => setState(() => minute = v)),
                _numField('Sec', second, (v) => setState(() => second = v)),
                _doubleField('UTC Offset', timeOffset,
                        (v) => setState(() => timeOffset = v)),
                _doubleField('Lat', lat, (v) => setState(() => lat = v)),
                _doubleField('Lon', lon, (v) => setState(() => lon = v)),
                _numField('Ayanamsha', ayanamsha,
                        (v) => setState(() => ayanamsha = v)),
                _numField('Maandi Method', maandiMethod,
                        (v) => setState(() => maandiMethod = v)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 10, children: [
              OutlinedButton(
                onPressed: _busy ? null : () => _applyNow(andRender: false),
                child: const Text('Now (fill time)'),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _applyNow(andRender: true),
                icon: const Icon(Icons.flash_on),
                label: const Text('Now & Render'),
              ),
              OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => setState(() {
                  year = 2025;
                  month = 4;
                  day = 22;
                  hour = 6;
                  minute = 30;
                  second = 0;
                  timeOffset = 5.5;
                  lat = 12.9716;
                  lon = 77.5946;
                  ayanamsha = 1;
                  maandiMethod = 1;
                }),
                child: const Text('Use sample inputs'),
              ),
            ]),
            const SizedBox(height: 16),

            // CHART
            if (_data == null)
              const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Text('Fetch to render the chart…'),
                  ))
            else
              Center(
                child: SizedBox(
                  width: chartW,
                  height: chartH,
                  child: _ChartFrame(
                    data: _data!,
                    useJamakkolLayout: useJamakkolLayout,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // helpers
  Widget _numField(String label, int value, void Function(int) onChanged) {
    return SizedBox(
      width: 120,
      child: TextFormField(
        initialValue: '$value',
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        onChanged: (s) => onChanged(int.tryParse(s) ?? value),
      ),
    );
  }

  Widget _doubleField(
      String label, double value, void Function(double) onChanged) {
    return SizedBox(
      width: 150,
      child: TextFormField(
        initialValue: '$value',
        keyboardType:
        const TextInputType.numberWithOptions(decimal: true, signed: true),
        decoration: InputDecoration(labelText: label),
        onChanged: (s) => onChanged(double.tryParse(s) ?? value),
      ),
    );
  }
}

/// Paints the outer yellow band and places the inner grid with padding.
class _ChartFrame extends StatelessWidget {
  const _ChartFrame({required this.data, required this.useJamakkolLayout});
  final Map<String, dynamic> data;
  final bool useJamakkolLayout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8), // outer padding to look good
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _OuterBoxPainter(
                (data['jamakkolOuterPlanets'] as List<dynamic>?)
                    ?.cast<Map<String, dynamic>>() ??
                    const <Map<String, dynamic>>[],
              ),
            ),
          ),
          // leave a margin inside the band so grid doesn't touch border
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: JamakkolChart(
              data: data,
              useJamakkolLayout: useJamakkolLayout,
            ),
          ),
        ],
      ),
    );
  }
}

// =================== Inner chart (grid + center info) ===================

class JamakkolChart extends StatelessWidget {
  const JamakkolChart(
      {super.key, required this.data, required this.useJamakkolLayout});
  final Map<String, dynamic> data;
  final bool useJamakkolLayout;

  static const _signShort = {
    1: 'Ari', 2: 'Tau', 3: 'Gem', 4: 'Can', 5: 'Leo', 6: 'Vir',
    7: 'Lib', 8: 'Sco', 9: 'Sag', 10: 'Cap', 11: 'Aqu', 12: 'Pis',
  };
  static const _planetCode = {
    'Sun': 'SU', 'Moon': 'MO', 'Mercury': 'ME', 'Venus': 'VE', 'Mars': 'MA',
    'Jupiter': 'JU', 'Saturn': 'SA', 'Rahu': 'RA', 'Ketu': 'KE', 'Maandi': 'MD',
    'Ascendant': 'ASC', 'Udhayam': 'UD', 'Arudam': 'AR', 'Kavippu': 'KV',
  };

  @override
  Widget build(BuildContext context) {
    final asc = _find(data['planets'] as List<dynamic>, 'Ascendant');
    final ascSign = asc?['zodiacSign'] as int? ?? 1;

    final Map<int, List<String>> buckets = {
      for (var i = 1; i <= 12; i++) i: <String>[]
    };
    void add(int sign, String code) => buckets[sign]!.add(code);

    for (final raw in (data['planets'] as List<dynamic>)) {
      if (raw is! Map) continue;
      final m = raw.cast<String, dynamic>();
      if (m['name'] == 'Ascendant') continue;
      add((m['zodiacSign'] as num).toInt(),
          _planetCode[m['name']] ?? m['name']);
    }
    if (data['jamakkolInnerPlanets'] is List) {
      for (final raw in (data['jamakkolInnerPlanets'] as List<dynamic>)) {
        if (raw is! Map) continue;
        final m = raw.cast<String, dynamic>();
        add((m['zodiacSign'] as num).toInt(),
            _planetCode[m['name']] ?? m['name']);
      }
    }

    // Order of the 12 tiles on a 4×3 grid
    final List<int> order = useJamakkolLayout
        ? <int>[12, 1, 2, 3, 11, 0, 0, 4, 10, 9, 8, 5] // Pis top-left
        : <int>[1, 2, 3, 4, 12, 0, 0, 5, 11, 10, 9, 6]; // Ari top-left

    return LayoutBuilder(builder: (context, c) {
      final tileW = c.maxWidth / 4.0;
      final tileH = c.maxHeight / 3.0;
      return Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _InnerBorderPainter())),
        for (int i = 0; i < 12; i++)
          if (order[i] != 0)
            Positioned(
              left: (i % 4) * tileW,
              top: (i ~/ 4) * tileH,
              width: tileW,
              height: tileH,
              child: _SignTile(
                sign: order[i],
                label: _signShort[order[i]]!,
                entries: buckets[order[i]]!,
                houseNum: 1 + ((order[i] - ascSign + 12) % 12),
                showAsc: order[i] == ascSign,
              ),
            ),
        // Center info block
        Positioned(
          left: tileW,
          top: tileH,
          width: tileW * 2.0,
          height: tileH,
          child: ClipRect(child: _CenterInfo(data: data)),
        ),
      ]);
    });
  }

  static Map<String, dynamic>? _find(List<dynamic> items, String name) {
    for (final x in items) {
      if (x is Map && x['name'] == name) {
        return (x as Map).cast<String, dynamic>();
      }
    }
    return null;
  }
}

class _SignTile extends StatelessWidget {
  const _SignTile({
    required this.sign,
    required this.label,
    required this.entries,
    required this.houseNum,
    required this.showAsc,
  });

  final int sign;
  final String label;
  final List<String> entries;
  final int houseNum;
  final bool showAsc;

  Color _codeColor(String code) {
    if (code == 'ASC') return const Color(0xFF1976D2);
    const green = {'JU', 'VE', 'MO'};
    return green.contains(code) ? const Color(0xFF1BAA59) : const Color(0xFFE53935);
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...entries];
    const prio = ['UD', 'AR', 'KV'];
    sorted.sort((a, b) {
      int pa = prio.indexOf(a); if (pa == -1) pa = 99;
      int pb = prio.indexOf(b); if (pb == -1) pb = 99;
      return pa.compareTo(pb);
    });

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1E3A8A), width: 1.2),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(6),
      child: Stack(children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Text('$houseNum', style: const TextStyle(fontSize: 12, color: Color(0xFFF4511E))),
        ),
        if (showAsc)
          const Align(
            alignment: Alignment.topCenter,
            child: Text('ASC', style: TextStyle(fontSize: 12, color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
          ),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [for (final c in sorted) Text(c, style: TextStyle(color: _codeColor(c), fontWeight: FontWeight.w700, fontSize: 18))],
          ),
        ),
      ]),
    );
  }
}

class _CenterInfo extends StatelessWidget {
  const _CenterInfo({required this.data});
  final Map<String, dynamic> data;

  String _dms(Map p) => (p['degreeDMS'] as String?)?.trim() ?? '';
  String _short(String n) {
    const m = {
      'Sun': 'SU','Moon': 'MO','Mercury': 'ME','Venus': 'VE','Mars': 'MA',
      'Jupiter': 'JU','Saturn': 'SA','Rahu': 'RA','Ketu': 'KE','Maandi': 'MD',
      'Udhayam': 'UD','Arudam': 'AR','Kavippu': 'KV',
    };
    return m[n] ?? n;
  }

  @override
  Widget build(BuildContext context) {
    final planets = (data['planets'] as List<dynamic>).cast<Map>();
    final inner = (data['jamakkolInnerPlanets'] as List<dynamic>).cast<Map>();
    final list = <Map>[...planets.where((p) => p['name'] != 'Ascendant'), ...inner];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1E3A8A), width: 1.5),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        children: [
          const Text('JAMAKKOL HORARY', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 14,
                runSpacing: 2,
                children: [for (final p in list) Text('${_short(p['name'])}  ${_dms(p)}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12))],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InnerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, p);

    final w = size.width, h = size.height;
    for (int i = 1; i < 4; i++) {
      final x = w * i / 4.0;
      canvas.drawLine(Offset(x, 0), Offset(x, h), p);
    }
    for (int j = 1; j < 3; j++) {
      final y = h * j / 3.0;
      canvas.drawLine(Offset(0, y), Offset(w, y), p);
    }
    final tileW = w / 4.0, tileH = h / 3.0;
    final centerRect = Rect.fromLTWH(tileW, tileH, tileW * 2.0, tileH);
    canvas.drawRect(centerRect, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =================== Outer band + labels ===================

class _OuterBoxPainter extends CustomPainter {
  _OuterBoxPainter(this.outerPlanets);
  final List<Map<String, dynamic>> outerPlanets;

  static const Map<String, String> short = {
    'Jama Sun': 'J.SU',
    'Jama Moon': 'J.MO',
    'Jama Mars': 'J.MA',
    'Jama Mercury': 'J.ME',
    'Jama Jupiter': 'J.JU',
    'Jama Venus': 'J.VE',
    'Jama Saturn': 'J.SA',
    'Jama Snake': 'J.SN',
  };

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(6, 6, size.width - 12, size.height - 12);

    // Fill band
    final fill = Paint()..color = const Color(0xFFFFF6CC)..style = PaintingStyle.fill;
    canvas.drawRect(rect, fill);

    // Border
    final border = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(rect, border);

    // anchor points around the rectangle (top, right upper/lower, bottom, left lower/upper)
    final anchors = <_Anchor>[
      _Anchor(Offset(rect.center.dx, rect.top), 0.0),
      _Anchor(Offset(rect.right, rect.top + rect.height * 0.28), 90.0),
      _Anchor(Offset(rect.right, rect.bottom - rect.height * 0.28), 90.0),
      _Anchor(Offset(rect.center.dx, rect.bottom), 180.0),
      _Anchor(Offset(rect.left, rect.bottom - rect.height * 0.28), -90.0),
      _Anchor(Offset(rect.left, rect.top + rect.height * 0.28), -90.0),
    ];

    final labels = <_Label>[];
    for (final p in outerPlanets) {
      final name = p['name']?.toString() ?? '';
      final code = short[name] ?? name;
      final dms = (p['degreeDMS'] as String?)?.trim() ?? '';
      final deg = (p['degree'] as num?)?.toDouble() ?? 0.0;
      final sector = ((deg % 360.0) / 45.0).floor();
      final anchor = anchors[sector % anchors.length];
      labels.add(_Label(anchor, '$code  $dms'));
    }

    for (final l in labels) {
      final tp = TextPainter(textDirection: TextDirection.ltr);
      final style = const TextStyle(color: Color(0xFF1E3A8A), fontSize: 11, fontWeight: FontWeight.w600);
      final str = (l.anchor.rotation == 0.0 || l.anchor.rotation == 180.0) ? '← ${l.text} →' : l.text;
      tp.text = TextSpan(text: str, style: style);
      tp.layout();

      canvas.save();
      canvas.translate(l.anchor.offset.dx, l.anchor.offset.dy);
      final radians = l.anchor.rotation * 3.1415926535 / 180.0;
      canvas.rotate(radians);

      final bool isTop = l.anchor.rotation == 0.0;
      final bool isBottom = l.anchor.rotation == 180.0;
      final bool isRight = l.anchor.rotation == 90.0;

      final double dx = (isTop || isBottom) ? -tp.width / 2.0 : -tp.height / 2.0;
      final double dy = isTop ? -tp.height - 6.0 : isBottom ? 6.0 : isRight ? -tp.width - 6.0 : 6.0;
      tp.paint(canvas, Offset(dx, dy));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _OuterBoxPainter oldDelegate) =>
      oldDelegate.outerPlanets != outerPlanets;
}

class _Anchor {
  const _Anchor(this.offset, this.rotation);
  final Offset offset;
  final double rotation; // degrees
}

class _Label {
  const _Label(this.anchor, this.text);
  final _Anchor anchor;
  final String text;
}
