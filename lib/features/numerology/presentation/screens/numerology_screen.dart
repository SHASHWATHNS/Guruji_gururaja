import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guraj_astro/features/numerology/presentation/providers/numerology_providers.dart';

class NumerologyScreen extends StatelessWidget {
  const NumerologyScreen({super.key});

  static const _tabs = <(String label, NumerologySection section)>[
    ('Jadagarin Vivaram', NumerologySection.jadagarinVivaram),
    ('Kattangal & Lucky Nos', NumerologySection.kattangalLuckyNumbers),
    ('Cell Number', NumerologySection.cellNumber),
    ('Name', NumerologySection.name),
    ('Vehicle Number', NumerologySection.vehicleNumber),
    ('Lucky Color', NumerologySection.luckyColor),
    ('Stones', NumerologySection.stones),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Numerology'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _tabs.map((t) => Tab(text: t.$1)).toList(),
          ),
        ),
        body: TabBarView(
          children: _tabs.map((t) => _NumerologySectionPage(section: t.$2)).toList(),
        ),
      ),
    );
  }
}

class _NumerologySectionPage extends ConsumerWidget {
  const _NumerologySectionPage({required this.section});
  final NumerologySection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(numerologySectionProvider(section));

    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => _ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(numerologySectionProvider(section)),
      ),
      data: (json) => _JsonViewer(json: json),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

/// Simple key-value viewer for arbitrary JSON (Map/List)
class _JsonViewer extends StatelessWidget {
  const _JsonViewer({required this.json});
  final Object? json;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [_buildNode(context, 'result', json)],
    );
  }

  Widget _buildNode(BuildContext context, String key, Object? value) {
    if (value is Map) {
      return _KVGroup(
        title: key,
        children: value.entries
            .map((e) => _buildNode(context, e.key.toString(), e.value))
            .toList(),
      );
    } else if (value is List) {
      return _KVGroup(
        title: key,
        children: [
          for (var i = 0; i < value.length; i++)
            _buildNode(context, '[$i]', value[i]),
        ],
      );
    } else {
      return _KVRow(title: key, value: value?.toString() ?? '');
    }
  }
}

class _KVGroup extends StatelessWidget {
  const _KVGroup({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  const _KVRow({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 4,
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Expanded(flex: 6, child: Text(value)),
        ],
      ),
    );
  }
}
