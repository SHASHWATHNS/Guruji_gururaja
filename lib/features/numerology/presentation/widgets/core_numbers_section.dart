import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/numerology_providers.dart';

class CoreNumbersSection extends ConsumerWidget {
  const CoreNumbersSection({super.key});

  TableRow _row(String l, String v) => TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: Text(l, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Text(v),
      ),
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      numerologySectionProvider(NumerologySection.jadagarinVivaram),
    );

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (json) {
        // json is the Map returned by _buildJadagarinVivaramJson
        String getS(String k) => '${json[k] ?? ''}';

        return SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1.0),
              },
              border: TableBorder.all(color: Theme.of(context).dividerColor),
              children: [
                _row('பெயர் (Name)', getS('Name')),
                _row('பிறந்த தேதி (DOB)', getS('DOB')),
                _row('Life Path', getS('Life Path')),
                _row('Destiny / Expression', getS('Destiny / Expression')),
                _row('Soul Urge', getS('Soul Urge')),
                _row('Personality', getS('Personality')),
                _row('Maturity', getS('Maturity')),
                _row('Birth-Day Number', getS('Birth-Day Number')),
              ],
            ),
          ),
        );
      },
    );
  }
}
