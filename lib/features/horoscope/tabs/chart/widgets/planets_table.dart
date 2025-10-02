// lib/features/horoscope/tabs/chart/widgets/planets_table.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../chart_providers.dart';
import '../chart_service.dart';

// l10n
import '../../../../../core/i18n/app_localizations.dart';

class PlanetsTable extends ConsumerWidget {
  const PlanetsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(planetsProvider);
    final t = context.l10n.t;

    final small = Theme.of(context).textTheme.bodySmall!;
    final themed = Theme.of(context).copyWith(
      dataTableTheme: DataTableThemeData(
        headingRowHeight: 36,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 44,
        headingTextStyle: small.copyWith(fontWeight: FontWeight.w600),
        dataTextStyle: small.copyWith(height: 1.1),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Theme(
        data: themed,
        child: async.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '${t('planets.error')}: $e',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          data: (List<PlanetRow> rows) {
            // Defensive: filter outer planets here too in case service missed it.
            rows = rows.where((r) {
              final n = r.name.toLowerCase();
              return !(n.contains('Uranus') || n.contains('Neptune') || n.contains('Pluto'));
            }).toList();

            if (rows.isEmpty) return Text(t('data.noPlanetData'));

            // Desired column order (after Body/fixed):
            // House | Nakshatra | Pada | Degree | Rasi | Lord
            List<_RowView> view = rows.map((r) {
              final degStr = _composeDegree(r.deg, r.min, r.sec);
              return _RowView(
                body: r.name,
                house: r.house,
                nakshatra: r.nakshatra,
                pada: r.pada,
                degree: degStr,
                rasi: r.sign,
                lord: r.lord,
                // kept for future:
                // rawDeg: r.deg, rawMin: r.min, rawSec: r.sec,
              );
            }).toList();

            // Fixed column widths (tuned for readability)
            const bodyW = 160.0;
            const colW = <double>[
              80,   // House
              160,  // Nakshatra
              60,   // Pada
              120,  // Degree
              120,  // Rasi
              120,  // Lord
            ];

            // Build two aligned DataTables: left (fixed Body) & right (scrollable others)
            final leftTable = DataTable(
              columnSpacing: 8,
              horizontalMargin: 8,
              columns: [DataColumn(label: Text(t('planets.col.body')))],
              rows: [
                for (final r in view)
                  DataRow(cells: [
                    DataCell(SizedBox(
                      width: bodyW,
                      child: Text(r.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                    )),
                  ])
              ],
            );

            final rightTable = DataTable(
              columnSpacing: 8,
              horizontalMargin: 8,
              columns: [
                DataColumn(label: Text(t('planets.col.house'))),
                DataColumn(label: Text(t('planets.col.nakshatra'))),
                DataColumn(label: Text(t('planets.col.pada'))),
                DataColumn(label: Text(t('planets.col.deg'))),
                DataColumn(label: Text(t('planets.col.sign'))),
                DataColumn(label: Text(t('planets.col.lord'))),

                // ——————————————— keep old columns commented for future use ———————————————
                // DataColumn(label: Text(t('planets.col.min'))),
                // DataColumn(label: Text(t('planets.col.sec'))),
              ],
              rows: [
                for (final r in view)
                  DataRow(
                    cells: [
                      _cell(colW[0], r.house),
                      _cell(colW[1], r.nakshatra),
                      _cell(colW[2], r.pada),
                      _cell(colW[3], r.degree),
                      _cell(colW[4], r.rasi),
                      _cell(colW[5], r.lord),
                    ],
                  ),
              ],
            );

            return Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fixed first column
                    DataTableTheme(
                      data: themed.dataTableTheme!,
                      child: leftTable,
                    ),
                    // Scrollable other columns
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 4),
                        child: DataTableTheme(
                          data: themed.dataTableTheme!,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: colW.reduce((a, b) => a + b) + (8 * (colW.length - 1)) + 24,
                            ),
                            child: rightTable,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static DataCell _cell(double width, String text) {
    return DataCell(SizedBox(
      width: width,
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
    ));
  }

  static String _composeDegree(String deg, String min, String sec) {
    String d = deg.trim();
    String m = min.trim();
    String s = sec.trim();
    // Clean up trailing symbols if the API already includes them
    d = d.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    m = m.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    s = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    final parts = <String>[];
    if (d.isNotEmpty) parts.add('$d°');
    if (m.isNotEmpty) parts.add("${m}'");
    if (s.isNotEmpty) parts.add('$s"');
    return parts.isEmpty ? '—' : parts.join(' ');
  }
}

class _RowView {
  final String body;
  final String house;
  final String nakshatra;
  final String pada;
  final String degree;
  final String rasi;
  final String lord;
  // String rawDeg; String rawMin; String rawSec; // (kept for future)
  _RowView({
    required this.body,
    required this.house,
    required this.nakshatra,
    required this.pada,
    required this.degree,
    required this.rasi,
    required this.lord,
  });
}
