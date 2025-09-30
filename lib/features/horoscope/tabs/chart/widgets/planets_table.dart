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

    final t = context.l10n.t;

    return Theme(
      data: themed,
      child: async.when(
        loading: () => const Center(
          child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(12),
          child: Text('${t('planets.error')}: $e',
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
        data: (List<PlanetRow> rows) {
          if (rows.isEmpty) return Text(t('data.noPlanetData'));

          const widths = <double>[140, 80, 90, 40, 40, 40, 58, 120, 48];
          return Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: widths.reduce((a, b) => a + b) + 48,
                  ),
                  child: DataTable(
                    columnSpacing: 8,
                    horizontalMargin: 8,
                    columns: [
                      DataColumn(label: Text(t('planets.col.body'))),
                      DataColumn(label: Text(t('planets.col.sign'))),
                      DataColumn(label: Text(t('planets.col.lord'))),
                      DataColumn(label: Text(t('planets.col.house'))),
                      DataColumn(label: Text(t('planets.col.deg'))),
                      DataColumn(label: Text(t('planets.col.min'))),
                      DataColumn(label: Text(t('planets.col.sec'))),
                      DataColumn(label: Text(t('planets.col.nakshatra'))),
                      DataColumn(label: Text(t('planets.col.pada'))),
                    ],
                    rows: rows.map((r) {
                      final cells = [r.name, r.sign, r.lord, r.house, r.deg, r.min, r.sec, r.nakshatra, r.pada];
                      return DataRow(
                        cells: [
                          for (int i = 0; i < cells.length; i++)
                            DataCell(SizedBox(
                              width: widths[i],
                              child: Text(
                                cells[i],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
