import 'package:flutter/material.dart';

class SimpleKVTable extends StatelessWidget {
  final List<(String, String)> rows; // (labelTamil, value)
  const SimpleKVTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final border = TableBorder.all(color: Colors.brown.shade200);
    final head = Theme.of(context).textTheme.labelLarge;
    final val  = Theme.of(context).textTheme.bodyMedium;

    return Table(
      border: border,
      columnWidths: const {0: FlexColumnWidth(0.45), 1: FlexColumnWidth(0.55)},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows.map((r) {
        return TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(r.$1, style: head),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(r.$2, style: val),
          ),
        ]);
      }).toList(),
    );
  }
}
