import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/birth_input.dart';
import '../../providers/dasa_provider.dart';
import '../../../data/models/dasa_models.dart';

class DasaButhiTab extends ConsumerWidget {
  final BirthInput input;
  const DasaButhiTab({super.key, required this.input});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dasaTreeProvider(input));

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'பிழை: $e',
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
      data: (tree) => _DasaBody(tree: tree),
    );
  }
}

class _DasaBody extends StatelessWidget {
  final DasaTree tree;
  const _DasaBody({required this.tree});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = const Color(0xFF795548);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current Dasa / Bhukti banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [accent.withOpacity(.12), accent.withOpacity(.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: accent.withOpacity(.25)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: accent.withOpacity(.15),
                child: Icon(Icons.query_stats, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('தற்போதைய தசை / புத்தி',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _chip('மஹா தசை: ${tree.snapshot.currentMaha}', accent),
                        _chip('புத்தி: ${tree.snapshot.currentAntar}', accent),
                        _chip(
                          'காலம்: ${_fmt(tree.snapshot.from)} – ${_fmt(tree.snapshot.to)}',
                          accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Vimshottari table (Mahadasa -> Antardasas)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _MahaTable(list: tree.table),
          ),
        ),
      ],
    );
  }

  Widget _chip(String text, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withOpacity(.08),
        border: Border.all(color: accent.withOpacity(.25)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12.5)),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
}

class _MahaTable extends StatefulWidget {
  final List<MahaDasa> list;
  const _MahaTable({required this.list});

  @override
  State<_MahaTable> createState() => _MahaTableState();
}

class _MahaTableState extends State<_MahaTable> {
  int? _open; // which mahadasa is expanded

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // header row
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            children: [
              _hdr('மகா தசை', flex: 2, theme: theme),
              _hdr('ஆரம்பம்', theme: theme),
              _hdr('முடிவு', theme: theme),
              const SizedBox(width: 36), // space for expand icon
            ],
          ),
        ),
        const Divider(height: 1),

        // rows
        ...List.generate(widget.list.length, (i) {
          final m = widget.list[i];
          final open = _open == i;
          return Column(
            children: [
              InkWell(
                onTap: () => setState(() => _open = open ? null : i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(m.graha, style: theme.textTheme.bodyLarge)),
                      Expanded(child: Text(_fmt(m.start), textAlign: TextAlign.center)),
                      Expanded(child: Text(_fmt(m.end),   textAlign: TextAlign.center)),
                      Icon(open ? Icons.expand_less : Icons.expand_more),
                    ],
                  ),
                ),
              ),
              // antars
              if (open) _AntarList(antars: m.antars),
              const Divider(height: 1),
            ],
          );
        }),
      ],
    );
  }

  Widget _hdr(String t, {required ThemeData theme, int flex = 1}) =>
      Expanded(
        flex: flex,
        child: Text(
          t,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withOpacity(.7),
            letterSpacing: .1,
          ),
          textAlign: flex == 2 ? TextAlign.start : TextAlign.center,
        ),
      );

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
}

class _AntarList extends StatelessWidget {
  final List<AntarDasa> antars;
  const _AntarList({required this.antars});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceVariant.withOpacity(.12),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        children: [
          // small header
          Row(
            children: [
              Expanded(flex: 2, child: Text('புத்தி', style: theme.textTheme.labelSmall)),
              Expanded(child: Text('ஆரம்பம்', style: theme.textTheme.labelSmall, textAlign: TextAlign.center)),
              Expanded(child: Text('முடிவு',  style: theme.textTheme.labelSmall, textAlign: TextAlign.center)),
              const SizedBox(width: 36),
            ],
          ),
          const SizedBox(height: 6),
          // items
          ...antars.map((a) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(a.name)),
                Expanded(child: Text(_fmt(a.start), textAlign: TextAlign.center)),
                Expanded(child: Text(_fmt(a.end),   textAlign: TextAlign.center)),
                const SizedBox(width: 36),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
}
