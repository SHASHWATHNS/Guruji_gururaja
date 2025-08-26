import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class PhoneNumberPalanSection extends StatefulWidget {
  const PhoneNumberPalanSection({super.key});

  @override
  State<PhoneNumberPalanSection> createState() => _PhoneNumberPalanSectionState();
}

class _PhoneNumberPalanSectionState extends State<PhoneNumberPalanSection> {
  final _ctrl = TextEditingController();
  PalanStore? _store; // Tamil only
  String? _error;
  final _rows = <_RowItem>[];

  static const List<String> _pairHeadings = [
    'ஜாதகர் - குடும்பம் - வருமானம்',
    'முயற்சி - வீடு - வாகனம் - சொத்து',
    'குழந்தை - காதல் - கடன் - எதிரி',
    'கணவன்/மனைவி - பார்ட்னர்ஷிப் - சமுதாயம்',
    'தொழில் - புகழ் - பதவிஉயர்வு',
  ];
  static const String _totalHeading = 'லாபமா?  நஷ்டமா?';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTamilStore();
  }

  Future<void> _loadTamilStore() async {
    setState(() {
      _error = null;
      _store = null;
    });

    const path = 'assets/palan/palan_ta.txt';
    try {
      final store = await PalanStore.load(path);
      if (!mounted) return;
      setState(() => _store = store);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'பாலன் கோப்பு ஏற்ற முடியவில்லை');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _error = null;
      _rows.clear();

      final input = _ctrl.text.replaceAll(RegExp(r'\D'), '');
      if (input.length != 10) {
        _error = 'தயவு செய்து சரியாக 10 இலக்கங்களை உள்ளிடுங்கள்';
        return;
      }

      // 5 pairs
      final pairs = <String>[];
      for (int i = 0; i < 10; i += 2) {
        pairs.add(input.substring(i, i + 2));
      }
      for (int i = 0; i < pairs.length; i++) {
        final key = pairs[i];
        final palan = _store?.pairPalan(key) ?? 'பாலன் காணப்படவில்லை';
        _rows.add(_RowItem(
          kind: RowKind.pair,
          label: key,
          heading: _pairHeadings[i],
          palan: palan,
        ));
      }

      // TOTAL row
      final digits = input.split('').map(int.parse).toList();
      final sumDigits = digits.fold<int>(0, (a, b) => a + b);
      final expr = digits.join('+');
      final totalPalan = _store?.totalPalan(sumDigits) ?? 'மொத்த பலன் காணப்படவில்லை';

      _rows.add(_RowItem(
        kind: RowKind.totalPrimary,
        label: 'Total',
        heading: _totalHeading,
        palan: totalPalan,
        note: '$expr = $sumDigits',
        valueForLookup: sumDigits,
        highlight: true,
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
              const Icon(Icons.call, size: 20),
              const SizedBox(width: 8),
              Text(
                'கைபேசி எண் பலன்',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (!ready)
                const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: '10 இலக்க கைபேசி எண்',
                    counterText: '',
                    border: OutlineInputBorder(),
                  ),
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

            if (_rows.isEmpty)
              Text('எண்ணை உள்ளிட்டு கணக்கிடு என்பதை தட்டவும்',
                  style: TextStyle(color: Colors.grey.shade600))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _PalanRow(row: _rows[i]),
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

    final map = <String, String>{};
    final lines = raw.split('\n');

    // tolerant Tamil header
    final header = RegExp(
      r'^\s*(\d{1,3})\s*எண்\s*[:：\-–—]*',
      caseSensitive: false,
    );

    int? currentNum;
    final buf = StringBuffer();

    void commit() {
      if (currentNum == null) return;
      final text = _cleanup(buf.toString());
      if (text.isEmpty) return;

      final k1 = currentNum!.toString();
      final k2 = k1.padLeft(2, '0');
      map[k1] = text;
      map[k2] = text;
      buf.clear();
    }

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      final m = header.firstMatch(line);
      if (m != null) {
        commit();
        currentNum = int.tryParse(m.group(1)!);
        continue;
      }
      buf.writeln(line);
    }
    commit();

    return PalanStore._(map);
  }

  static String _cleanup(String s) {
    var t = s.trim();
    t = t.replaceAll(RegExp(r'\*+'), '');
    t = t.replaceAll('\r', ' ');
    t = t.replaceAll(RegExp(r'\n\s*\n+'), '\n');
    t = t.replaceAll('\n', ' ');
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
    return t;
  }

  String? pairPalan(String twoDigitKey) {
    final exact = _map[twoDigitKey];
    if (exact != null) return exact;
    final nonPadded = int.tryParse(twoDigitKey)?.toString();
    if (nonPadded != null) return _map[nonPadded];
    return null;
  }

  String? totalPalan(int value) {
    final k1 = value.toString();
    final k2 = value.toString().padLeft(2, '0');
    return _map[k1] ?? _map[k2];
  }
}

/* --------------------------------- Models -------------------------------- */

enum RowKind { pair, totalPrimary }

class _RowItem {
  final RowKind kind;
  final String label;
  final String? heading;
  final String palan;
  final String? note;
  final int? valueForLookup;
  final bool highlight;

  _RowItem({
    required this.kind,
    required this.label,
    required this.palan,
    this.heading,
    this.note,
    this.valueForLookup,
    this.highlight = false,
  });
}

/* ---------------------------------- UI ----------------------------------- */

class _PalanRow extends StatelessWidget {
  final _RowItem row;
  const _PalanRow({super.key, required this.row});

  // sets for colors
  static final Set<String> greenSet = {
    '02','04','06','08','10','12','14','16','20','22','26','30','32','33','35','36','37','39',
    '41','42','45','51','52','56','60','64','66','70','72','73','74','77','79','80','84','85',
    '87','88','89','90','92','95','97','99','100','101','102','104','106','108','109','110',
    '111','112','113','114','115','116','117','119','120'
  };
  static final Set<String> yellowSet = {
    '11','17','21','23','27','29','46','54','68','93'
  };
  static final Set<String> redSet = {
    '01','03','05','07','09','13','15','18','19','24','25','28','31','34','38','40','43','44',
    '47','48','49','50','53','55','57','58','59','61','62','63','65','67','69','71','75','76',
    '78','81','82','83','86','91','94','96','98','103','105','107','118'
  };

  Color? _colorForLabel(String label) {
    // Only color pair rows, not TOTAL
    if (greenSet.contains(label)) return Colors.green.shade100;
    if (yellowSet.contains(label)) return Colors.yellow.shade200;
    if (redSet.contains(label)) return Colors.red.shade200;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isPrimary = row.kind == RowKind.totalPrimary;

    Color bg;
    Color border;
    if (isPrimary) {
      bg = Colors.amber.shade300;
      border = Colors.amber.shade700;
    } else {
      bg = _colorForLabel(row.label) ?? Colors.grey.shade50;
      border = Colors.grey.shade300;
    }

    final titleChipColor = isPrimary ? Colors.black : Colors.black87;
    final titleText = isPrimary ? 'TOTAL' : row.label;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: titleChipColor, borderRadius: BorderRadius.circular(999)),
              child: Text(titleText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            if (row.note != null)
              Flexible(
                child: Text(
                  row.note!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontStyle: FontStyle.italic),
                ),
              ),
          ]),

          if (row.heading != null) ...[
            const SizedBox(height: 8),
            Text(
              row.heading!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ],

          const SizedBox(height: 8),
          Text(
            row.palan,
            style: TextStyle(
              fontSize: isPrimary ? 16.5 : 16,
              height: 1.35,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
