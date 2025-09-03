import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/panchanga.dart';
import '../viewmodels/panchanga_view_model.dart';

class PanchangaScreen extends ConsumerWidget {
  const PanchangaScreen({super.key});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  String _fmtIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(panchangaProvider);
    final notifier = ref.read(panchangaProvider.notifier);

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.headerBar,
          centerTitle: true,
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          title: const Text(
            'GURUJI GURURAJA',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
          ),
          actions: [
            IconButton(
              tooltip: 'Share',
              onPressed: () => _share(context, _fmtIso(st.date)),
              icon: const Icon(Icons.share, color: Colors.black),
            ),
          ],
        ),
        body: Column(
          children: [
            // Date navigation row
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: notifier.previousDay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('PREVIOUS DAY'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final res = await showDatePicker(
                          context: context,
                          initialDate: st.date,
                          firstDate: DateTime(now.year - 50),
                          lastDate: DateTime(now.year + 50),
                        );
                        if (res != null) notifier.setDate(res);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(_fmt(st.date),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: notifier.nextDay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('NEXT DAY'),
                    ),
                  ),
                ],
              ),
            ),

            // Orange tab strip
            Container(
              height: 44,
              color: Colors.orange,
              child: const TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: 'Panchanga'),
                  Tab(text: 'Kundali'),
                  Tab(text: 'Hora'),
                  Tab(text: 'Pancha Pakshi'),
                  Tab(text: 'Pancha Tatva'),
                  Tab(text: 'Tatva Character'),
                ],
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                children: [
                  _PanchangaTab(st: st),              // provider-backed
                  _KundaliTab(date: st.date),         // mock
                  _HoraTab(date: st.date),            // mock
                  _PakshiTab(date: st.date),          // mock
                  _TatvaTab(date: st.date),           // mock
                  _TatvaCharTab(date: st.date),       // mock
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _share(BuildContext context, String isoDate) {
    final link = 'https://gurujigururaja.in/panchanga?date=$isoDate';
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy link'),
              subtitle: Text(link, maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: link));
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Link copied')));
              },
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------ TAB 1 ------------------------------ */

class _PanchangaTab extends ConsumerWidget {
  final PanchangaState st;
  const _PanchangaTab({required this.st});

  String _weekdayName(DateTime d) {
    const names = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return names[d.weekday - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (st.loading) return const Center(child: CircularProgressIndicator());
    if (st.error != null) {
      return Center(child: Text('Error: ${st.error}', style: const TextStyle(color: Colors.red)));
    }
    if (st.data == null) {
      return const Center(child: Text('No data'));
    }

    final data = st.data!;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
      itemCount: data.sections.length,
      itemBuilder: (_, i) {
        final sec = data.sections[i];
        final items = sec.items.map((item) {
          if (item.label.trim().toLowerCase() == 'vedic day') {
            return PanchangaItem(
              label: item.label,
              value: _weekdayName(st.date),
              timeText: item.timeText,
            );
          }
          return item;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sec.thickDividerBefore) ...[
              const SizedBox(height: 10),
              const Divider(thickness: 2),
              const SizedBox(height: 4),
            ],
            for (final item in items) _PanchangaRow(item: item),
          ],
        );
      },
    );
  }
}

class _PanchangaRow extends StatelessWidget {
  final PanchangaItem item;
  const _PanchangaRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final hasLabel = item.label.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasLabel)
            Text(
              item.label,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            item.value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              height: 1.1,
            ),
          ),
          if (item.timeText != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                item.timeText!,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

/* ------------------------ SHARED TABLE WIDGET ------------------------ */

class _DualScrollDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double minWidth;
  const _DualScrollDataTable({
    required this.columns,
    required this.rows,
    this.minWidth = 680,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final tableWidth = w < minWidth ? minWidth : w;

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: tableWidth),
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: DataTable(
                headingRowColor:
                MaterialStateProperty.all(Colors.orange.shade300),
                dataRowColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.surface),
                border: TableBorder.all(color: Colors.black87, width: 1),
                columns: columns,
                rows: rows,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ TAB 2: KUNDALI (MOCK) ------------------------------ */

class _KundaliTab extends StatelessWidget {
  final DateTime date;
  const _KundaliTab({required this.date});

  @override
  Widget build(BuildContext context) {
    final planets = ['Lagna','Sun','Moon','Mars','Mercury','Jupiter','Venus','Saturn'];
    final stars   = ['Pūrvā Phalguṇī','Pūrvā Phalguṇī','Mūla','Hasta','Maghā','Punarvasu','Pushya','Anuradha'];

    List<DataRow> rows = [];
    for (int i = 0; i < planets.length; i++) {
      final deg = 4 + i;
      final min = ((date.day * (i + 3)) % 59);
      final sec = ((date.month * (i + 7)) % 59);
      final lon = '${deg.toString().padLeft(2, '0')}s ${min.toString().padLeft(2, '0')}\' ${sec.toString().padLeft(2, '0')}\"';
      rows.add(DataRow(cells: [
        DataCell(Text(planets[i])),
        DataCell(Text(lon)),
        DataCell(Text(stars[i])),
      ]));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black87, width: 2)),
            child: Stack(
              children: [
                Row(
                  children: List.generate(
                    3,
                        (_) => Expanded(
                      child: Column(
                        children: List.generate(
                          3,
                              (_) => Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black45, width: 1),
                                color: Colors.brown.withOpacity(0.08),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Text('V1 Rashi Chart',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _DualScrollDataTable(
          columns: const [
            DataColumn(label: Text('Planets')),
            DataColumn(label: Text('Longitude')),
            DataColumn(label: Text('Star')),
          ],
          rows: rows,
        ),
      ],
    );
  }
}

/* ------------------------------ TAB 3: HORA (MOCK) ------------------------------ */

class _HoraTab extends StatelessWidget {
  final DateTime date;
  const _HoraTab({required this.date});

  String _hhmmss(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final start = DateTime(date.year, date.month, date.day, 6, 8, 27);
    final names = ['Mars','Sun','Venus','Mercury','Moon','Saturn','Jupiter'];

    var cur = start;
    final rows = <DataRow>[];
    for (int i = 0; i < 16; i++) {
      final name = names[(i + date.day) % names.length];
      final next = cur.add(const Duration(hours: 1));
      rows.add(DataRow(cells: [
        DataCell(Text('${i + 1}')),
        DataCell(Text(name)),
        DataCell(Text(_hhmmss(cur))),
        DataCell(Text(_hhmmss(next))),
      ]));
      cur = next;
    }

    return _DualScrollDataTable(
      columns: const [
        DataColumn(label: Text('Serial No.')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Start Time')),
        DataColumn(label: Text('End Time')),
      ],
      rows: rows,
    );
  }
}

/* --------------------------- TAB 4: PANCHA PAKSHI (MOCK) --------------------------- */

class _PakshiTab extends StatelessWidget {
  final DateTime date;
  const _PakshiTab({required this.date});

  String _hhmmss(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final birds = ['Vulture','Owl','Crow','Cock','Peacock'];
    final acts = ['Eat','Move','Rule','Sleep','Death'];
    final endBase = DateTime(date.year, date.month, date.day, 8, 36, 46);

    final rows = <DataRow>[];
    for (int i = 0; i < 10; i++) {
      final end = endBase.add(Duration(hours: (i * 2) % 24, minutes: (i * 33) % 60));
      rows.add(DataRow(cells: [
        DataCell(Text('${i + 1}')),
        DataCell(Text(_hhmmss(end))),
        for (int b = 0; b < birds.length; b++)
          DataCell(Text(acts[(i + b + date.day) % acts.length])),
      ]));
    }

    return _DualScrollDataTable(
      columns: const [
        DataColumn(label: Text('Serial No.')),
        DataColumn(label: Text('End Time')),
        DataColumn(label: Text('Vulture')),
        DataColumn(label: Text('Owl')),
        DataColumn(label: Text('Crow')),
        DataColumn(label: Text('Cock')),
        DataColumn(label: Text('Peacock')),
      ],
      rows: rows,
      minWidth: 820,
    );
  }
}

/* --------------------------- TAB 5: PANCHA TATVA (MOCK) --------------------------- */

class _TatvaTab extends StatelessWidget {
  final DateTime date;
  const _TatvaTab({required this.date});

  String _hhmmss(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final seq = ['Fire[M]', 'Wind[F]', 'Ether[M]', 'Earth[M]', 'Water[F]'];
    final start = DateTime(date.year, date.month, date.day, 6, 8, 27);

    final rows = <DataRow>[];
    var cur = start;
    for (int i = 0; i < 18; i++) {
      final tatva = seq[(i + date.day) % seq.length];
      final next = cur.add(const Duration(minutes: 18));
      rows.add(DataRow(cells: [
        DataCell(Text('${i + 1}')),
        DataCell(Text(tatva)),
        DataCell(Text(_hhmmss(cur))),
        DataCell(Text(_hhmmss(next))),
      ]));
      cur = next;
    }

    return _DualScrollDataTable(
      columns: const [
        DataColumn(label: Text('Serial No.')),
        DataColumn(label: Text('Pancha Tatva')),
        DataColumn(label: Text('Start Time')),
        DataColumn(label: Text('End Time')),
      ],
      rows: rows,
    );
  }
}

/* ------------------------- TAB 6: TATVA CHARACTER (MOCK) ------------------------- */

class _TatvaCharTab extends StatelessWidget {
  final DateTime date;
  const _TatvaCharTab({required this.date});

  String _hhmmss(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final chars = ['Tamasika', 'Sathvika', 'Rajasika'];
    final start = DateTime(date.year, date.month, date.day, 6, 8, 27);

    final rows = <DataRow>[];
    var cur = start;
    for (int i = 0; i < 16; i++) {
      final ch = chars[(i + date.month) % chars.length];
      final next = cur.add(const Duration(minutes: 90));
      rows.add(DataRow(cells: [
        DataCell(Text('${i + 1}')),
        DataCell(Text(ch)),
        DataCell(Text(_hhmmss(cur))),
        DataCell(Text(_hhmmss(next))),
      ]));
      cur = next;
    }

    return _DualScrollDataTable(
      columns: const [
        DataColumn(label: Text('Serial No.')),
        DataColumn(label: Text('Tatva Character')),
        DataColumn(label: Text('Start Time')),
        DataColumn(label: Text('End Time')),
      ],
      rows: rows,
    );
  }
}
