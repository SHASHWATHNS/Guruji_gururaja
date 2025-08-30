// lib/features/numerology/presentation/widgets/name_palan_section.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Name Palan — 2 inputs (Initial, Name), 2 results:
/// 1) Name-only palan
/// 2) Total palan (Initial + Name)
class NamePalanSection extends StatefulWidget {
  const NamePalanSection({super.key});

  @override
  State<NamePalanSection> createState() => _NamePalanSectionState();
}

class _NamePalanSectionState extends State<NamePalanSection> {
  final _initialCtrl = TextEditingController(); // e.g., R
  final _nameCtrl = TextEditingController();    // e.g., DHANASEKAR

  PalanStore? _store;
  String? _error;
  final _rows = <_RowItem>[];

  // Chaldean mapping (1–8) for A–Z
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
    _initialCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  int _sumForText(String text) {
    // Letters use Chaldean; digits count as digits; others ignored.
    int sum = 0;
    final upper = text.toUpperCase();
    for (final code in upper.runes) {
      final ch = String.fromCharCode(code);
      if (RegExp(r'[A-Z]').hasMatch(ch)) {
        sum += _mapChaldean[ch] ?? 0;
      } else if (RegExp(r'\d').hasMatch(ch)) {
        sum += int.parse(ch);
      } // ignore other symbols/spaces/dots
    }
    return sum;
  }

  void _calculate() {
    setState(() {
      _error = null;
      _rows.clear();

      if (_store == null) {
        _error = 'பாலன் கோப்பு ஏற்றப்படுகிறது...';
        return;
      }

      final initial = _initialCtrl.text.trim();
      final name = _nameCtrl.text.trim();

      if (name.isEmpty) {
        _error = 'Name பாகம் காலியாக உள்ளது';
        return;
      }

      // 1) NAME ONLY
      final nameSum = _sumForText(name);
      final palanName =
          _store!.totalPalan(nameSum) ?? _store!.pairPalan(nameSum.toString()) ?? 'பாலன் காணப்படவில்லை';

      _rows.add(_RowItem(
        label: nameSum.toString(),
        heading: 'NAME — $name',
        palan: palanName,
      ));

      // 2) TOTAL (INITIAL + NAME)
      final initialSum = _sumForText(initial);
      final total = nameSum + initialSum;
      final palanTotal =
          _store!.totalPalan(total) ?? _store!.pairPalan(total.toString()) ?? 'பாலன் காணப்படவில்லை';

      _rows.add(_RowItem(
        label: total.toString(),
        heading: 'TOTAL — ${initial.isEmpty ? name : "$initial + $name"}',
        palan: palanTotal,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final ready = _store != null;

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
              const Icon(Icons.badge, size: 20),
              const SizedBox(width: 8),
              Text(
                'பெயர் பலன்',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (!ready)
                const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ]),

            const SizedBox(height: 8),
            Text(
              'உதாரணம்:  Initial “R”  |  Name “DHANASEKAR”',
              style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10),

            Row(children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _initialCtrl,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Initial (எ.கா., R)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => ready ? _calculate() : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 7,
                child: TextField(
                  controller: _nameCtrl,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Name (எ.கா., DHANASEKAR)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => ready ? _calculate() : null,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: ready ? _calculate : null,
                icon: const Icon(Icons.calculate),
                label: Text(ready ? 'கணக்கிடு' : 'ஏற்றுகிறது'),
              ),
            ]),

            const SizedBox(height: 12),

            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],

            if (_rows.isEmpty)
              Text('Initial மற்றும் Name ஐ உள்ளிட்டு கணக்கிடு என்பதை தட்டவும்',
                  style: TextStyle(color: Colors.grey.shade600))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _NamePalanCard(row: _rows[i]),
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
  final String label;   // big number in header
  final String heading; // e.g., "NAME — DHANASEKAR", "TOTAL — R + DHANASEKAR"
  final String palan;

  _RowItem({
    required this.label,
    required this.heading,
    required this.palan,
  });
}

/* ---------------------------------- UI ----------------------------------- */

class _NamePalanCard extends StatelessWidget {
  final _RowItem row;
  const _NamePalanCard({super.key, required this.row});

  // --- Color sets (with '00' in yellow) ---
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

  // Extract first <b>...</b> or *...* as bold centered heading
  List<Widget> _renderPalanBody(String palan) {
    final reBold = RegExp(r'<b>(.*?)</b>');
    final reStar = RegExp(r'\*(.*?)\*');

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
