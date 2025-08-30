import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Vehicle Number Palan — 2 inputs, 5 palans:
/// 1) Box1 palan
/// 2) Pair1 palan (first two of Box2)
/// 3) Pair2 palan (last two of Box2)
/// 4) Pairs total palan ( (a+b) + (c+d) where pair1=ab, pair2=cd )
/// 5) Grand total palan (Box1 sum + pairs total)
class VehicleNumberPalanSection extends StatefulWidget {
  const VehicleNumberPalanSection({super.key});

  @override
  State<VehicleNumberPalanSection> createState() => _VehicleNumberPalanSectionState();
}

class _VehicleNumberPalanSectionState extends State<VehicleNumberPalanSection> {
  final _box1Ctrl = TextEditingController(); // e.g., TN 54 A
  final _box2Ctrl = TextEditingController(); // e.g., 1234

  PalanStore? _store;
  String? _error;
  final _rows = <_RowItem>[];

  static const String _headingSample = 'உதாரணம்:  TN XX (A–Z) XXXX';
  static const String _headingTotal = 'மொத்த பலன்';

  // Chaldean mapping (1–8)
  static const Map<String, int> _mapChaldean = {
    'A': 1, 'I': 1, 'J': 1, 'Q': 1, 'Y': 1,
    'B': 2, 'K': 2, 'R': 2,
    'C': 3, 'G': 3, 'L': 3, 'S': 3,
    'D': 4, 'M': 4, 'T': 4,
    'E': 5, 'H': 5, 'N': 5, 'X': 5,
    'U': 6, 'V': 6, 'W': 6,
    'O': 7, 'Z': 7,
    'F': 8, 'P': 8,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStore();
  }

  Future<void> _loadStore() async {
    setState(() {
      _error = null;
      _store = null;
    });

    const path = 'assets/palan/palan_ta.json';
    try {
      final s = await PalanStore.load(path);
      if (!mounted) return;
      setState(() => _store = s);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'பாலன் கோப்பு ஏற்ற முடியவில்லை');
    }
  }

  @override
  void dispose() {
    _box1Ctrl.dispose();
    _box2Ctrl.dispose();
    super.dispose();
  }

  int _sumForBox1(String input) {
    // Sum of letters (Chaldean) + digits. Ignore spaces/hyphens/others.
    int sum = 0;
    for (final chCode in input.toUpperCase().runes) {
      final ch = String.fromCharCode(chCode);
      if (RegExp(r'[A-Z]').hasMatch(ch)) {
        sum += _mapChaldean[ch] ?? 0;
      } else if (RegExp(r'\d').hasMatch(ch)) {
        sum += int.parse(ch);
      }
    }
    return sum;
  }

  int _digitSum(String twoDigits) {
    // twoDigits is always 2 chars like "07" or "92"
    final a = int.parse(twoDigits[0]);
    final b = int.parse(twoDigits[1]);
    return a + b;
  }

  void _calculate() {
    setState(() {
      _error = null;
      _rows.clear();

      if (_store == null) {
        _error = 'பாலன் கோப்பு ஏற்றப்படுகிறது...';
        return;
      }

      final box1 = _box1Ctrl.text.trim();
      final box2 = _box2Ctrl.text.trim().replaceAll(' ', '');

      if (box1.isEmpty) {
        _error = 'Box 1: TN 54 A போன்றவற்றை உள்ளிடுங்கள்';
        return;
      }
      if (!RegExp(r'^\d{4}$').hasMatch(box2)) {
        _error = 'Box 2: 4 இலக்க எண் (எ.கா., 8490) உள்ளிடுங்கள்';
        return;
      }

      // 1) BOX 1
      final sum1 = _sumForBox1(box1);
      final palan1 = _store!.totalPalan(sum1) ?? 'பாலன் காணப்படவில்லை';

      _rows.add(_RowItem(
        labelNumber: sum1,
        heading: 'BOX 1 — $box1',
        palan: palan1,
      ));

      // 2) PAIR 1 (first two of Box2)
      final pair1 = box2.substring(0, 2); // keep leading zero if any
      final palanPair1 = _store!.pairPalan(pair1) ?? 'பாலன் காணப்படவில்லை';

      _rows.add(_RowItem(
        labelString: pair1,
        heading: 'BOX 2 — Pair 1 ($pair1)',
        palan: palanPair1,
      ));

      // 3) PAIR 2 (last two of Box2)
      final pair2 = box2.substring(2, 4);
      final palanPair2 = _store!.pairPalan(pair2) ?? 'பாலன் காணப்படவில்லை';

      _rows.add(_RowItem(
        labelString: pair2,
        heading: 'BOX 2 — Pair 2 ($pair2)',
        palan: palanPair2,
      ));

      // 4) PAIRS TOTAL using digit-sum logic:
      //    pairsTotal = sumDigits(pair1) + sumDigits(pair2)
      final pairsTotal = _digitSum(pair1) + _digitSum(pair2);
      final pairsTotalStr = pairsTotal.toString();
      final palanPairsTotal =
          _store!.pairPalan(pairsTotalStr) ?? _store!.totalPalan(pairsTotal) ?? 'பாலன் காணப்படவில்லை';

      _rows.add(_RowItem(
        labelNumber: pairsTotal,
        heading: 'Paris Total — $pair1 + $pair2',
        palan: palanPairsTotal,
      ));

      // 5) GRAND TOTAL (Box1 sum + pairsTotal from above)
      final grandTotal = sum1 + pairsTotal;
      final grandTotalStr = grandTotal.toString();
      final palanGrand =
          _store!.pairPalan(grandTotalStr) ?? _store!.totalPalan(grandTotal) ?? 'பாலன் காணப்படவில்லை';

      _rows.add(_RowItem(
        labelNumber: grandTotal,
        heading: _headingTotal,
        palan: palanGrand,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final ready = _store != null;

    // Common decoration for "elongated" inputs with sample inside
    InputDecoration _decor(String hint) => InputDecoration(
      hintText: hint, // sample inside the box
      border: const OutlineInputBorder(),
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18), // taller/elongated
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.directions_car, size: 20),
              const SizedBox(width: 8),
              Text(
                'வாகன எண் பலன்',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (!ready)
                const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ]),

            const SizedBox(height: 8),
            Text(_headingSample, style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),

            // Inputs row — elongated fields; button moved to next line
            Row(children: [
              Expanded(
                flex: 6,
                child: TextField(
                  controller: _box1Ctrl,
                  keyboardType: TextInputType.text,
                  decoration: _decor('TN XX (A–Z)'), // sample inside Box 1
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => ready ? _calculate() : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: TextField(
                  controller: _box2Ctrl,
                  keyboardType: TextInputType.number,
                  decoration: _decor('XXXX'), // sample inside Box 2
                  maxLength: 4,
                  buildCounter: (_, {required int currentLength, required bool isFocused, required int? maxLength}) =>
                  const SizedBox.shrink(),
                  onSubmitted: (_) => ready ? _calculate() : null,
                ),
              ),
            ]),

            const SizedBox(height: 12),

            // Button moved to the next line
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: ready ? _calculate : null,
                icon: const Icon(Icons.calculate),
                label: Text(ready ? 'கணக்கிடு' : 'ஏற்றுகிறது'),
              ),
            ),

            const SizedBox(height: 12),

            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],

            if (_rows.isEmpty)
              Text('இரண்டு பெட்டிகளையும் நிரப்பி கணக்கிடு என்பதை தட்டவும்',
                  style: TextStyle(color: Colors.grey.shade600))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _VehiclePalanCard(row: _rows[i]),
              ),
          ],
        ),
      ),
    );
  }
}

/* ----------------------------- Data + Parsing ----------------------------- */

class PalanStore {
  final Map<String, String> _map;
  PalanStore._(this._map);

  static Future<PalanStore> load(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final jsonData = json.decode(raw);

    final map = <String, String>{};

    String _clean(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();
    String _normalizeBold(String s) {
      final withHtmlBold = s.replaceAllMapped(RegExp(r'\*(.*?)\*'), (m) => '<b>${m.group(1) ?? ''}</b>');
      return _clean(withHtmlBold);
    }

    void _add(String key, String value) {
      final text = _normalizeBold(value);
      if (text.isEmpty) return;
      map[key] = text;

      final n = int.tryParse(key);
      if (n != null) {
        map.putIfAbsent(n.toString(), () => text);
        map.putIfAbsent(n.toString().padLeft(2, '0'), () => text); // "07"
        map.putIfAbsent(n.toString().padLeft(3, '0'), () => text); // "107"
      }
    }

    if (jsonData is Map && (jsonData['pairs'] is Map || jsonData['totals'] is Map)) {
      if (jsonData['pairs'] is Map) {
        (jsonData['pairs'] as Map).forEach((k, v) {
          if (v is String) _add(k.toString(), v);
        });
      }
      if (jsonData['totals'] is Map) {
        (jsonData['totals'] as Map).forEach((k, v) {
          if (v is String) _add(k.toString(), v);
        });
      }
    } else if (jsonData is Map) {
      jsonData.forEach((k, v) {
        if (v is String) _add(k.toString(), v);
      });
    } else {
      throw const FormatException('Unsupported JSON format for palan');
    }

    return PalanStore._(map);
  }

  String? pairPalan(String key) {
    final exact = _map[key];
    if (exact != null) return exact;
    final n = int.tryParse(key);
    if (n != null) {
      final k1 = n.toString();
      final k2 = n.toString().padLeft(2, '0');
      final k3 = n.toString().padLeft(3, '0');
      return _map[k1] ?? _map[k2] ?? _map[k3];
    }
    return null;
  }

  String? totalPalan(int value) {
    final k1 = value.toString();
    final k2 = value.toString().padLeft(2, '0');
    final k3 = value.toString().padLeft(3, '0');
    return _map[k1] ?? _map[k2] ?? _map[k3];
  }
}

/* --------------------------------- Models -------------------------------- */

class _RowItem {
  final String label;  // number as string shown big in header
  final String heading;
  final String palan;

  _RowItem({
    String? labelString,
    int? labelNumber,
    required this.heading,
    required this.palan,
  }) : label = (labelString ?? (labelNumber != null ? labelNumber.toString() : ''))!;
}

/* ---------------------------------- UI ----------------------------------- */

class _VehiclePalanCard extends StatelessWidget {
  final _RowItem row;
  const _VehiclePalanCard({super.key, required this.row});

  // --- Color sets from your spec (including '00' in yellow) ---
  static final Set<String> greenSet = {
    '02','04','06','08','10','12','14','16','20','22','26','30','32','33','35','36','37','39',
    '41','42','45','51','52','56','60','64','66','70','72','73','74','77','79','80','84','85',
    '87','88','89','90','92','95','97','99','100','101','102','104','106','108','109','110',
    '111','112','113','114','115','116','117','119','120'
  };
  static final Set<String> yellowSet = {
    '00','11','17','21','23','27','29','46','54','68','93'
  };
  static final Set<String> redSet = {
    '01','03','05','07','09','13','15','18','19','24','25','28','31','34','38','40','43','44',
    '47','48','49','50','53','55','57','58','59','61','62','63','65','67','69','71','75','76',
    '78','81','82','83','86','91','94','96','98','103','105','107','118'
  };

  bool _inSet(Set<String> set, String label) {
    // Accept "8" or "08", "100", etc.
    final n = int.tryParse(label);
    if (set.contains(label)) return true;
    if (n != null) {
      if (set.contains(n.toString())) return true;
      if (set.contains(n.toString().padLeft(2, '0'))) return true;
      if (set.contains(n.toString().padLeft(3, '0'))) return true;
    }
    return false;
  }

  Color _headerColorByNumber(String label) {
    if (_inSet(greenSet, label)) return Colors.green.shade100;
    if (_inSet(yellowSet, label)) return Colors.yellow.shade200;
    if (_inSet(redSet, label)) return Colors.red.shade500;
    return Colors.grey.shade100;
  }

  // Bold-centered first heading + normal body
  List<Widget> _renderPalanBody(String palan) {
    const boldTag = r'<b>(.*?)</b>';
    const starTag = r'\*(.*?)\*';
    final reBold = RegExp(boldTag);
    final reStar = RegExp(starTag);

    String? heading;
    String remainder = palan;

    final m1 = reBold.firstMatch(palan);
    final m2 = reStar.firstMatch(palan);
    RegExpMatch? chosen;
    if (m1 != null && m2 != null) {
      chosen = (m1.start < m2.start) ? m1 : m2;
    } else {
      chosen = m1 ?? m2;
    }
    if (chosen != null) {
      heading = chosen.group(1)?.trim();
      remainder = palan.substring(0, chosen.start) + palan.substring(chosen.end);
    }

    String _stripTags(String s) => s
        .replaceAllMapped(reBold, (m) => m.group(1) ?? '')
        .replaceAllMapped(reStar, (m) => m.group(1) ?? '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final body = _stripTags(remainder);

    final widgets = <Widget>[];
    if (heading != null && heading!.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Center(
            child: Text(
              heading!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, height: 1.35),
            ),
          ),
        ),
      );
    }
    if (body.isNotEmpty) {
      widgets.add(const SizedBox(height: 2));
      widgets.add(Text(body, style: const TextStyle(fontSize: 16, height: 1.35)));
    }
    if (widgets.isEmpty) {
      widgets.add(Text(palan, style: const TextStyle(fontSize: 16, height: 1.35)));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.grey.shade300;
    final headerBg = _headerColorByNumber(row.label);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header (colored by number)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: headerBg,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            border: Border(
              top: BorderSide(color: borderColor),
              left: BorderSide(color: borderColor),
              right: BorderSide(color: borderColor),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                row.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22, // big number
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              const Text('—', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  row.heading,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ],
          ),
        ),

        // Body (white)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
            border: Border(
              bottom: BorderSide(color: borderColor),
              left: BorderSide(color: borderColor),
              right: BorderSide(color: borderColor),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _renderPalanBody(row.palan),
          ),
        ),
      ],
    );
  }
}
