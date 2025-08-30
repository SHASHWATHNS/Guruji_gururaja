import 'package:flutter/material.dart';
import '../../domain/entities/numerology_input.dart';

class NumerologyJadagarinVivaramTab extends StatelessWidget {
  final NumerologyInput input;
  const NumerologyJadagarinVivaramTab({super.key, required this.input});

  // simple numerology helpers (local, no API)
  int _reduce(int n) {
    if (n == 11 || n == 22 || n == 33) return n;
    n = n.abs();
    while (n > 9) {
      n = n.toString().split('').fold(0, (a, c) => a + int.parse(c));
      if (n == 11 || n == 22 || n == 33) return n;
    }
    return n;
  }

  int _lifePath(DateTime dob) {
    final s =
        '${dob.day.toString().padLeft(2, '0')}${dob.month.toString().padLeft(2, '0')}${dob.year}';
    return _reduce(s.split('').fold(0, (a, c) => a + int.parse(c)));
  }

  int _birthday(DateTime dob) => _reduce(dob.day);

  @override
  Widget build(BuildContext context) {
    final dob = input.dob;
    final age = DateTime.now().difference(dob).inDays ~/ 365;

    final rows = <(String, String)>[
      ('பெயர்', input.name),
      ('பிறந்த தேதி', '${dob.day.toString().padLeft(2, '0')}-'
          '${dob.month.toString().padLeft(2, '0')}-${dob.year}'),
      ('வயது', '$age'),
      ('Life Path', '${_lifePath(dob)}'),
      ('Birth-Day Number', '${_birthday(dob)}'),
    ];

    TableRow row(String l, String v) => TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: Text(l, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      Padding(padding: const EdgeInsets.all(12), child: Text(v)),
    ]);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Table(
            columnWidths: const {0: FlexColumnWidth(1.2), 1: FlexColumnWidth(1.0)},
            border: TableBorder.all(color: Theme.of(context).dividerColor),
            children: [for (final r in rows) row(r.$1, r.$2)],
          ),
        ),
      ],
    );
  }
}
