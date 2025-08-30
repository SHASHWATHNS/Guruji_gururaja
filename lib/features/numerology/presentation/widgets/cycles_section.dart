import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/numerology_providers.dart';

class CyclesSection extends ConsumerWidget {
  const CyclesSection({super.key});

  Widget chip(String label, String value) =>
      Chip(label: Text('$label: $value'), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      numerologySectionProvider(NumerologySection.kattangalLuckyNumbers),
    );

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (json) {
        String gs(String k) => '${json[k] ?? ''}';
        // Nested maps for Pinnacles/Challenges
        final pinn = (json['Pinnacles'] as Map?) ?? const {};
        final chall = (json['Challenges'] as Map?) ?? const {};

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        chip('Personal Year', gs('Personal Year')),
                        chip('Personal Month', gs('Personal Month')),
                        chip('Personal Day', gs('Personal Day')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pinnacles',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(label: Text('P1: ${pinn['P1'] ?? ''}')),
                            Chip(label: Text('P2: ${pinn['P2'] ?? ''}')),
                            Chip(label: Text('P3: ${pinn['P3'] ?? ''}')),
                            Chip(label: Text('P4: ${pinn['P4'] ?? ''}')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Challenges',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(label: Text('C1: ${chall['C1'] ?? ''}')),
                            Chip(label: Text('C2: ${chall['C2'] ?? ''}')),
                            Chip(label: Text('C3: ${chall['C3'] ?? ''}')),
                            Chip(label: Text('C4: ${chall['C4'] ?? ''}')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
