import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transit_models.dart';
import '../viewmodels/tranist_view_model.dart';

class TransitScreen extends ConsumerWidget {
  const TransitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTransit = ref.watch(transitDayProvider);
    final selectedDate = ref.watch(transitSelectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transit (Gochar)'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(transitDayProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          _TopBar(
            date: selectedDate,
            onPick: (d) => ref.read(transitSelectedDateProvider.notifier).state = d,
            onToday: () {
              final now = DateTime.now();
              ref.read(transitSelectedDateProvider.notifier).state =
                  DateTime(now.year, now.month, now.day);
            },
          ),
          Expanded(
            child: asyncTransit.when(
              data: (td) => _TransitList(td),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => _ErrorView(
                message: e.toString(),
                onRetry: () => ref.refresh(transitDayProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onPick;
  final VoidCallback onToday;

  const _TopBar({
    required this.date,
    required this.onPick,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = "${date.year.toString().padLeft(4,'0')}-"
        "${date.month.toString().padLeft(2,'0')}-"
        "${date.day.toString().padLeft(2,'0')}";

    return Material(
      color: const Color(0xFFFFF3CD),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                ActionChip(
                  label: Text(dateStr),
                  avatar: const Icon(Icons.calendar_today_outlined, size: 18),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) onPick(picked);
                  },
                ),
                ActionChip(
                  label: const Text('Today'),
                  avatar: const Icon(Icons.today, size: 18),
                  onPressed: onToday,
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransitList extends StatelessWidget {
  final TransitDay day;
  const _TransitList(this.day);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        _SummaryChips(day: day),
        const SizedBox(height: 12),
        ...day.planets.map((p) => _PlanetTile(p)).toList(),
      ],
    );
  }
}

class _SummaryChips extends StatelessWidget {
  final TransitDay day;
  const _SummaryChips({required this.day});

  @override
  Widget build(BuildContext context) {
    final tz = day.timezone;
    final loc = "${day.latitude.toStringAsFixed(4)}, ${day.longitude.toStringAsFixed(4)}";
    final d = "${day.date.year}-${day.date.month.toString().padLeft(2,'0')}-${day.date.day.toString().padLeft(2,'0')}";

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(avatar: const Icon(Icons.event), label: Text(d)),
        Chip(avatar: const Icon(Icons.schedule), label: Text(tz)),
        Chip(avatar: const Icon(Icons.place), label: Text(loc)),
        Chip(avatar: const Icon(Icons.auto_awesome), label: Text('Planets: ${day.planets.length}')),
      ],
    );
  }
}

class _PlanetTile extends StatelessWidget {
  final PlanetTransit t;
  const _PlanetTile(this.t);

  @override
  Widget build(BuildContext context) {
    final retro = t.retrograde ? 'R' : 'D';
    final deg = t.degree.toStringAsFixed(2);
    final spd = t.speed.toStringAsFixed(3);
    final subtitle = "Sign: ${t.sign}  |  ${deg}°  |  ${t.nakshatra} (Pada ${t.pada})  |  $retro  |  Speed: $spd°/d";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(t.planet.characters.first),
        ),
        title: Text(t.planet, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Placeholder for future "details" page (aspects, house positions, etc.)
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 40),
        const SizedBox(height: 8),
        Text('Failed to load', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Try again')),
      ]),
    );
  }
}
